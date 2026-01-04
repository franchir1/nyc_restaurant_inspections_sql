Perfetto. Qui sotto trovi **il contenuto completo del file `notes.md`**, pronto da incollare nel repo.
È strutturato, lineare, difendibile a colloquio.
Copre **Power Query (M)** + **decisioni di modellazione a stella**.

---

# ETL & Data Modeling – Note Metodologiche

## 1. Dataset di partenza

Il progetto utilizza il dataset **DOHMH New York City Restaurant Inspection Results**, contenente **~293.000 righe grezze**.

Caratteristiche del dataset originale:

* una singola ispezione può generare **più righe** (una per violazione)
* presenza di **date placeholder** (`01/01/1900`)
* valori mancanti rappresentati come stringhe vuote o valori fittizi (`"0"`)
* grain non esplicitato

Obiettivo del progetto:

> costruire un data warehouse con **grain chiaro**, **pulizia documentata** e **modellazione corretta delle cardinalità**.

---

## 2. Scelte ETL – Power Query (linguaggio M)

### 2.1 Separazione delle responsabilità

* **Power Query**: data cleaning e normalizzazione
* **PostgreSQL**: modellazione a stella e analisi

Questa separazione evita correzioni ex-post nel DW e rende il processo riproducibile.

---

### 2.2 Colonne mantenute

Dal CSV originale sono state mantenute **solo le colonne necessarie all’analisi**:

* `camis_code`
* `restaurant_name`
* `area_name`
* `cuisine_type`
* `inspection_date`
* `action_taken`
* `violation_code`
* `violation_description`
* `critical_flag`
* `score_assigned`

Tutte le altre colonne (coordinate, codici catastali, distretti, ecc.) sono state rimosse perché non rilevanti per gli obiettivi analitici.

---

### 2.3 Trasformazioni applicate (senza rimozione di righe)

Le seguenti trasformazioni **non riducono il numero di righe**:

* conversione dei tipi:

  * date → `date`
  * score → `integer`
  * codici e descrizioni → `text`
* sostituzione stringhe vuote (`""`) con `NULL`
* normalizzazione testuale:

  * `Trim`
  * `Proper` / `Upper` dove opportuno
* gestione valori fittizi:

  * `area_name = '0' → NULL`
  * `inspection_date = '01/01/1900' → NULL`

Queste operazioni rendono esplicita l’assenza di informazione senza alterare la cardinalità.

---

### 2.4 Nessun filtro, nessuna deduplicazione in Power Query

Scelte **intenzionali**:

* ❌ nessun filtro su `NULL`
* ❌ nessuna deduplicazione
* ❌ nessuna aggregazione

Motivazione:

* il dataset contiene **violazioni multiple per la stessa ispezione**
* deduplicare in questa fase avrebbe causato **perdita informativa**
* la decisione sul grain va presa **a livello di modellazione**, non di ETL

Risultato:

> il numero di righe in uscita da Power Query è uguale a quello del CSV (al netto del parsing).

---

## 3. Grain del dataset pulito

Dopo Power Query, il dataset ha il seguente significato:

> **1 riga = 1 violazione rilevata durante un’ispezione**

Questo è il **grain più fine** disponibile e viene preservato integralmente.

---

## 4. Modellazione a stella – decisioni progettuali

### 4.1 Problema da risolvere

* 1 ispezione può avere **0, 1 o N violazioni**
* alcune informazioni sono **a livello ispezione** (`score_assigned`, `action_taken`)
* altre sono **a livello violazione** (`violation_code`, `critical_flag`)

Un’unica fact table porterebbe a:

* duplicazione delle misure
* aggregazioni errate
* ambiguità semantica

---

### 4.2 Soluzione adottata: 2 fact table + bridge

#### Fact 1 – `fact_inspection`

**Grain**

> 1 riga = 1 ispezione

Contiene solo attributi che valgono **una volta per ispezione**.

Campi principali:

* `inspection_key`
* `date_key`
* `establishment_key`
* `area_key`
* `score_assigned`
* `action_taken`

---

#### Fact 2 – `fact_inspection_violation` (bridge)

**Grain**

> 1 riga = 1 violazione associata a un’ispezione

Campi:

* `inspection_key` (FK)
* `violation_key` (FK)

Questa tabella modella la relazione **1 → N** tra ispezioni e violazioni senza duplicare misure.

---

### 4.3 Dimensioni

* `date_dim`
* `establishment_dim`
* `area_dim`
* `violation_dim`

In particolare:

* `violation_dim` contiene codice, descrizione e flag critico
* le dimensioni vengono popolate tramite `SELECT DISTINCT` dalla tabella pulita

---

## 5. Vantaggi della soluzione

* nessuna perdita di violazioni
* nessuna duplicazione dello score
* aggregazioni corrette
* modello facilmente interrogabile
* struttura **classica da data warehouse**, non accademica

Domande supportate correttamente:

* quante ispezioni hanno almeno una violazione critica?
* score medio per area
* violazioni più frequenti
* relazione tra numero di violazioni e score

---

## 6. Nota metodologica finale

La riduzione di righe osservata in precedenti versioni del progetto non era dovuta a errori, ma a:

* rimozione di date placeholder
* filtri su eventi non validi
* deduplicazione sul grain dell’ispezione

In questa versione, tali decisioni sono state **posticipate** e **rese esplicite** nella modellazione, non nell’ETL.

---

**Questo file documenta tutte le scelte tecniche rilevanti ed è pensato per essere letto da un reviewer o in fase di colloquio.**
