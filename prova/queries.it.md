# Analisi SQL – Panoramica delle Query

Le analisi sono organizzate in cartelle (`Q1`–`Q6`) e ordinate in modo progressivo: dalla **verifica della qualità e coerenza dei dati** fino all’**identificazione delle criticità strutturali** del sistema di ispezioni.

Ogni cartella di analisi contiene:

- descrizione della domanda analitica
- spiegazione della logica seguita
- query SQL completa
- output (tabelle CSV e/o grafici)
- interpretazione finale dei risultati

## Nota metodologica

Le query analitiche operano su dati aggregati a livello di ispezione
(stabilimento + data di ispezione).

Questa scelta è necessaria per evitare distorsioni nei KPI
dovute alla granularità a livello di violazione della fact table.

Le query di verifica utilizzate per validare tali assunzioni
sono incluse nel repository a scopo documentativo.


## [Q1](/04_queries/Q1/Q1.it.md) – Qualità dei dati e proporzionalità delle ispezioni  
**Domanda:**  
Il numero di ispezioni è **proporzionale al numero di stabilimenti**
per ciascuna area di New York City?

Questa analisi verifica che:
- il sistema di ispezioni sia distribuito in modo equo
- le analisi successive non siano influenzate da bias strutturali nei dati

## [Q2](/04_queries/Q2/Q2.it.md) – Criticità delle aree  
**Domanda:**  
Quali aree presentano una **maggiore incidenza di eventi critici**,
normalizzata sul numero totale di ispezioni?

L’obiettivo è confrontare le aree in modo corretto,
tenendo conto della diversa intensità dei controlli.


## [Q3](/04_queries/Q3/Q3.it.md) – Analisi dei trend temporali  
**Domande:**  
- I punteggi medi degli stabilimenti migliorano o peggiorano nel tempo?
- Come varia il numero di ispezioni per area nel corso degli anni?

Questa analisi fornisce il contesto temporale
necessario per interpretare correttamente tutte le altre metriche.

## [Q4](/04_queries/Q4/Q4.it.md) – Criticità nei giorni festivi  
**Domanda:**  
Le violazioni delle norme igienico-sanitarie
sono più frequenti durante i **fine settimana**
rispetto ai giorni feriali?

L’analisi distingue tra:
- distribuzione grezza delle violazioni
- distribuzione normalizzata rispetto al numero di giorni


## [Q5](/04_queries/Q5/Q5.it.md) – Miglioramento degli stabilimenti nel tempo  
**Domanda:**  
Le azioni correttive adottate a seguito delle ispezioni
risultano **efficaci nel lungo periodo**?

L’analisi confronta il punteggio della prima e dell’ultima ispezione
per valutare il miglioramento complessivo degli stabilimenti.

## [Q6](/04_queries/Q6/Q6.it.md) – Identificazione delle criticità maggiori  
**Domanda:**  
Quali caratteristiche accomunano gli stabilimenti
che **non mostrano miglioramenti** tra la prima e l’ultima ispezione?

In particolare:
- distribuzione geografica
- violazioni più ricorrenti
- pattern strutturali di criticità

---

# Q1 – Qualità dei dati e proporzionalità delle ispezioni per area

## Domanda di analisi

Le ispezioni sanitarie a New York City sono:

1. associate a livelli di **qualità media differenti tra le aree**?
2. distribuite in modo **proporzionale al numero di stabilimenti** presenti in ciascuna area?

L’obiettivo è valutare:

* la **qualità igienico-sanitaria media** per area
* l’**equità del sistema di controllo**

---

## Contesto analitico

* **Fact table:** `fact_inspection` (inspection-day)
* **Dimensioni:** `area_dim`, `establishment_dim`
* **Metrica:** `score_assigned`

> Un punteggio più alto indica condizioni peggiori.

---

## Q1a – Qualità media delle ispezioni per area

### Obiettivo

Confrontare le aree in base al **punteggio medio delle ispezioni**.

### Logica

* aggregazione delle inspection-days per area
* calcolo della media di `score_assigned`

### Risultati

| Area                 | Average score |
| -------------------- | ------------: |
| 🔵 **Queens**        |     **19.29** |
| 🟢 **Brooklyn**      |     **18.10** |
| 🟠 **Bronx**         |     **17.87** |
| 🔴 **Manhattan**     |     **17.31** |
| 🟣 **Staten Island** |     **16.84** |

### Insight

* le differenze non sono estreme
* emerge un **gradiente geografico coerente**
* aree più dense tendono ad avere punteggi medi leggermente più elevati

Da sola, questa analisi **non basta** a valutare l’equità del sistema: è necessario verificare la **proporzionalità delle ispezioni**.

---

## Q1b – Proporzionalità delle ispezioni rispetto agli stabilimenti

### Obiettivo

Verificare se il numero di ispezioni è **proporzionale al numero di stabilimenti** in ciascuna area.

### Logica

Per ogni area si calcola:

[
\text{Ispezioni per stabilimento} =
\frac{\text{Ispezioni totali}}
{\text{Numero di stabilimenti}}
]

### Risultati

| Area                 |  Ispezioni | Stabilimenti | Ispezioni / Stabilimento |
| -------------------- | ---------: | -----------: | -----------------------: |
| 🔴 **Manhattan**     | **11 502** |    **7 223** |                 **1.59** |
| 🟢 **Brooklyn**      |  **8 132** |    **4 977** |                 **1.63** |
| 🔵 **Queens**        |  **7 115** |    **4 305** |                 **1.65** |
| 🟠 **Bronx**         |  **2 719** |    **1 681** |                 **1.62** |
| 🟣 **Staten Island** |  **1 179** |      **720** |                 **1.64** |

### Insight

* il rapporto **ispezioni / stabilimento** è molto simile in tutte le aree
* non emergono anomalie o squilibri sistematici

---

## Conclusione Q1

* le aree mostrano **livelli medi di qualità differenti**, ma senza outlier estremi
* il sistema di ispezioni risulta **proporzionale** alla distribuzione degli stabilimenti
* le differenze osservate riflettono principalmente **fattori strutturali**, non bias di controllo

---

*Torna alla [lista di queries](/04_queries/queries.it.md)*

# Q2 – Criticità delle aree: eventi critici e incidenza relativa

## Domanda di analisi

Le diverse aree di New York City presentano **livelli differenti di criticità sanitaria**?

In particolare:

1. quali aree registrano il **maggior numero assoluto di eventi critici**?
2. tali differenze persistono **dopo la normalizzazione per dimensione**?

L’obiettivo è distinguere tra:

* effetto **dimensionale** (più stabilimenti → più eventi)
* reale **maggiore incidenza di criticità**

---

## Contesto analitico

* **Fact table:** `fact_inspection` (inspection-day)
* **Fact di supporto:** `fact_inspection_violation`
* **Dimensioni:** `area_dim`, `establishment_dim`
* **Definizione di evento critico:**

  * `critical_flag = 'Critical'`
  * **oppure** `action_taken` indica una chiusura

---

## Q2a – Numero assoluto di eventi critici per area

### Obiettivo

Individuare le aree con il **maggior volume di eventi critici**,
come prima misura grezza della pressione sanitaria.

### Logica

* filtraggio degli inspection-days critici
* conteggio degli eventi per area

### Risultati

| Area                 | Eventi critici | Stabilimenti | Eventi critici / Stabilimento |
| -------------------- | -------------: | -----------: | ----------------------------: |
| 🔴 **Manhattan**     |     **38 272** |    **7 223** |                      **5.30** |
| 🟢 **Brooklyn**      |     **27 478** |    **4 977** |                      **5.52** |
| 🔵 **Queens**        |     **25 756** |    **4 305** |                      **5.98** |
| 🟠 **Bronx**         |      **9 341** |    **1 681** |                      **5.56** |
| 🟣 **Staten Island** |      **3 764** |      **720** |                      **5.23** |

---

## Q2b – Incidenza relativa degli eventi critici

### Obiettivo

Verificare se le differenze osservate in Q2a
sono dovute alla **dimensione delle aree**
oppure a una **maggiore incidenza reale di criticità**.

### Logica

* normalizzazione del numero di eventi critici
* rapporto eventi critici / stabilimenti

*(già incluso nella tabella precedente)*

---

## Insight Q2

* i **valori assoluti** differiscono sensibilmente tra le aree
* dopo la normalizzazione:

  * le differenze si **ridimensionano**
  * **non emergono outlier significativi**
* l’incidenza relativa degli eventi critici è **sorprendentemente uniforme**

---

## Conclusione Q2

* le differenze tra aree sono guidate principalmente da:

  * numero di stabilimenti
  * volume di ispezioni
* **non emerge un’area strutturalmente più critica delle altre**
* il sistema di controllo appare **coerente ed equilibrato** anche sotto il profilo della severità

---

*Torna alla [lista di queries](/04_queries/queries.it.md)*

---

### Prossimo passo

Se vuoi, continuo **senza cambiare ritmo** con:

👉 **Q3 – Trend temporali**, riducendo drasticamente la verbosità
👉 oppure passiamo prima a **Q4**, che richiede l’allineamento più forte al nuovo modello

Dimmi tu.


# Q3 – Analisi dei trend temporali

## Domanda di analisi

Come si evolvono nel tempo le ispezioni sanitarie a New York City?

In particolare:

1. i punteggi medi mostrano un miglioramento o un peggioramento nel tempo?
2. l’intensità dei controlli varia tra le aree e negli anni?

L’obiettivo è fornire il **contesto temporale** necessario per interpretare correttamente tutte le analisi successive.

---

## Contesto analitico

* **Fact table:** `inspection_events_table` (inspection-day)
* **Dimensioni:** `date_dim`, `area_dim`, `establishment_dim`
* **Metriche:**

  * `score_assigned`
  * numero di ispezioni

> Un punteggio più alto indica condizioni peggiori.

---

## Q3a – Andamento del numero di ispezioni per area

### Obiettivo

Osservare l’evoluzione temporale del **volume di ispezioni** per area geografica.

### Logica

* aggregazione delle ispezioni per area e anno
* conteggio degli inspection-days

### Risultati

| Area          | 2016 | 2017 | 2018 | 2019 | 2020 | 2021 | 2022 | 2023 | 2024 | 2025 |
| ------------- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Bronx         |    2 |    2 |    1 |    4 |    1 |   14 |  367 |  630 |  876 |  829 |
| Brooklyn      |    5 |    7 |    9 |   29 |    4 |   88 | 1344 | 1904 | 2589 | 2220 |
| Manhattan     |   14 |   27 |   26 |   42 |   15 |  122 | 1958 | 2812 | 3368 | 3217 |
| Queens        |    9 |   18 |   19 |   26 |    7 |   58 | 1082 | 1543 | 2125 | 2260 |
| Staten Island |    3 |    3 |    7 |    – |    – |   15 |  207 |  298 |  353 |  300 |

### Insight

* tutte le aree mostrano un **picco nel 2019**
* nel **2020** si osserva un crollo generalizzato
* dal **2021** il sistema riparte con un trend stabile di crescita

---

## Q3b – Intensità dei controlli (normalizzata per stabilimento)

### Obiettivo

Confrontare le aree eliminando l’effetto dimensionale, osservando il **numero medio di ispezioni per stabilimento**.

### Logica

* conteggio delle ispezioni per area e anno
* divisione per il numero totale di stabilimenti dell’area

### Risultati

| Area          |  2016 |  2017 |  2018 |  2019 |  2020 |  2021 |  2022 |  2023 |  2024 |  2025 |
| ------------- | ----: | ----: | ----: | ----: | ----: | ----: | ----: | ----: | ----: | ----: |
| Bronx         | 12.50 | 10.50 | 21.00 | 40.50 |  9.00 | 11.29 | 14.74 | 17.47 | 18.74 | 18.60 |
| Brooklyn      |  8.20 | 15.71 | 11.56 | 16.24 | 12.00 | 14.94 | 15.50 | 17.83 | 18.57 | 19.29 |
| Manhattan     | 10.86 | 10.19 |  9.08 | 12.29 | 16.20 | 14.14 | 14.95 | 16.72 | 17.61 | 19.02 |
| Queens        | 10.44 |  9.22 | 13.53 | 15.31 | 10.57 | 16.72 | 15.37 | 18.80 | 19.70 | 21.24 |
| Staten Island | 10.67 | 18.00 | 15.14 |     – |     – | 16.40 | 15.09 | 16.18 | 16.84 | 18.59 |

### Insight

* nel periodo pre-2020 l’intensità dei controlli è simile tra le aree
* il **2020 rappresenta una discontinuità strutturale**
* dal 2021 il sistema torna progressivamente omogeneo

---

## Conclusione Q3

* i trend temporali spiegano molte variazioni osservate nei punteggi
* l’intensità dei controlli è un fattore chiave nell’interpretazione dei risultati
* le analisi successive vanno lette alla luce di questa dinamica temporale

---

# Q4 – Criticità nei giorni festivi vs feriali

## Domanda di analisi

Le violazioni igienico-sanitarie sono più frequenti nei **weekend** rispetto ai giorni feriali?

---

## Contesto analitico

* **Fact table:** `inspection_events_table`
* **Dimensioni:** `date_dim`, `inspection_dim`
* **Metrica:** numero di violazioni

---

## Q4a – Confronto grezzo

| Tipo di giorno | Violazioni | Percentuale |
| -------------- | ---------: | ----------: |
| Giorni feriali |     74 708 |       71.4% |
| Weekend        |     29 903 |       28.6% |

---

## Q4b – Confronto normalizzato

| Tipo di giorno | Percentuale normalizzata |
| -------------- | -----------------------: |
| Weekend        |                   50.02% |
| Giorni feriali |                   49.98% |

### Insight

* le differenze grezze sono dovute alla diversa numerosità dei giorni
* la probabilità media di violazione per giorno è sostanzialmente identica

---

## Conclusione Q4

* il weekend **non è strutturalmente più critico**
* la qualità dipende da fattori organizzativi, non dal giorno della settimana

---

# Q5 – Miglioramento degli stabilimenti nel tempo

## Domanda di analisi

Le azioni correttive producono un **miglioramento duraturo** negli stabilimenti?

---

## Contesto analitico

* **Fact table:** `inspection_events_table`
* **Dimensioni:** `establishment_dim`, `date_dim`
* **Metrica:** `score_assigned`

---

## Risultati

| Categoria                   | Criterio                 | Percentuale |
| --------------------------- | ------------------------ | ----------: |
| Stabilimenti migliorati     | last_score < first_score |         22% |
| Stabilimenti non migliorati | last_score ≥ first_score |         78% |

### Insight

* solo una minoranza mostra un miglioramento netto
* molti stabilimenti correggono problemi solo temporaneamente

---

## Conclusione Q5

* il sistema produce miglioramenti, ma **non strutturali**
* è necessario analizzare le cause della mancata evoluzione positiva

---

# Q6 – Analisi degli stabilimenti non migliorati

## Domanda di analisi

Quali caratteristiche accomunano gli stabilimenti che **non migliorano nel tempo**?

---

## Contesto analitico

* **Fact table:** `inspection_events_table`
* **Dimensioni:** `establishment_dim`, `area_dim`, `inspection_dim`

---

## Q6a – Distribuzione geografica

| Area          | % stabilimenti non migliorati |
| ------------- | ----------------------------: |
| Manhattan     |                        78.17% |
| Brooklyn      |                        77.96% |
| Queens        |                        77.49% |
| Bronx         |                        77.98% |
| Staten Island |                        77.26% |

### Insight

* distribuzione estremamente uniforme
* il fenomeno **non è geografico**

---

## Q6b – Violazioni più ricorrenti

| Codice | Occorrenze | Descrizione                   |
| ------ | ---------: | ----------------------------- |
| 10F    |     15 529 | Superfici difficili da pulire |
| 08A    |     10 362 | Presenza di roditori/insetti  |
| 06D    |      7 027 | Superfici non sanificate      |
| 02G    |      6 945 | Refrigerazione inadeguata     |

### Insight

* violazioni **strutturali e ricorrenti**
* difficili da eliminare con interventi superficiali

---

## Conclusione Q6

* la mancata evoluzione positiva è sistemica
* servono interventi strutturali, non correttivi temporanei


*Torna al [README](/README.it.md)*