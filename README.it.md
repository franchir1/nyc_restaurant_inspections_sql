Italiano | [English](README.md)

# Ispezioni ristoranti NYC – Analisi dei dati con SQL

Questo progetto analizza il dataset del **Department of Health and Mental Hygiene (DOHMH)** relativo ai risultati delle **ispezioni sanitarie di ristoranti e mense universitarie** di New York City.

## Dataset

Il dataset include informazioni su:
- ispezioni sanitarie
- punteggi assegnati
- violazioni rilevate, incluse violazioni critiche
- area geografica (borough)
- tipologia di cucina
- data di ispezione

La granularità originale è **ispezione–violazione**, con potenziali duplicazioni del punteggio per singola ispezione. Questo aspetto richiede una modellazione analitica esplicita.

Il dataset grezzo richiede un processo di pulizia e trasformazione prima di poter essere utilizzato in un modello analitico.

## Obiettivo del progetto

L’obiettivo è rispondere in modo strutturato e riproducibile a domande chiave sul sistema di ispezioni sanitarie di NYC:

- Qual è il **livello medio di qualità igienico-sanitaria** nelle diverse aree della città?
- Le ispezioni sono **distribuite in modo proporzionale** tra borough e tipologie di esercizi?
- Come evolvono **punteggi e controlli nel tempo** e sono presenti discontinuità strutturali?
- Quanto è **diffuso il rischio sanitario critico** e come varia nel tempo?
- Le azioni correttive producono **miglioramenti misurabili nel lungo periodo** o i problemi tendono a ripresentarsi?

L’approccio adottato è **KPI-driven** e orientato al **supporto decisionale**.

## Pulizia e trasformazione dei dati

La fase di preparazione dati include:

- pulizia preliminare tramite **Power Query**
- caricamento in **PostgreSQL**
- creazione della tabella `clean_data_table`
- rimozione dei record non utilizzabili per l’analisi

Questa fase garantisce **coerenza e affidabilità** del dato utilizzato nelle analisi SQL successive.

## Modello dati

Il modello utilizza una **struttura a stella**, composta da:

- una **fact table** contenente il punteggio assegnato alle ispezioni
- tabelle dimensionali per:
  - contesto geografico
  - contesto temporale
  - tipologia di cucina
  - ristorante
  - violazione


<p align="center">
  <img src="03_data_model/star_scheme_sql.png" alt="Schema a stella del modello dati" width="600"><br>
  <em>Schema a stella del modello dati</em>
</p>

Le relazioni sono:
- one-to-many
- a direzione singola

## Analisi SQL

Le analisi SQL sono organizzate per **domande di business** e includono:

- aggregazioni dei punteggi medi per area e tipologia di cucina
- analisi temporali tramite **window functions**
- confronto tra prime e ultime ispezioni degli stabilimenti
- identificazione di pattern di miglioramento o peggioramento
- analisi della frequenza e persistenza delle violazioni critiche

## Scelte metodologiche e assunzioni di modellazione

- La fact table (`inspection_events_table`) è modellata a **livello di violazione**:
  ogni riga rappresenta una singola violazione rilevata durante un’ispezione.

- L’ispezione **non è un’entità esplicita** nel dataset sorgente.
  A fini analitici, un’ispezione viene approssimata come:
  **(stabilimento, data di ispezione)**.

- Tutti i KPI vengono calcolati **dopo un’aggregazione a livello ispezione**
  per evitare distorsioni dovute a violazioni multiple nella stessa ispezione.

- La presenza di più ispezioni per lo stesso stabilimento nello stesso giorno
  è stata verificata empiricamente e risulta pari a circa **0,003% dei casi**,
  pertanto considerata statisticamente trascurabile.

## Principali evidenze

- Il sistema di ispezioni risulta **strutturalmente bilanciato** tra le aree di NYC
- Il periodo **2019–2020** rappresenta una discontinuità significativa nei dati
- Solo circa **22%** degli stabilimenti mostra un miglioramento netto nel tempo
- Il **77–78%** mantiene o peggiora il proprio livello
- Le violazioni più ricorrenti sono:
  - strutturali
  - igienico-operative
  - difficili da correggere in modo definitivo

## Strumenti utilizzati

* **Pulizia preliminare dei dati:** Excel Power Query
* **Amministrazione del database:** pgAdmin 4
* **Linguaggio di interrogazione:** PostgreSQL (CTE, funzioni finestra, aggregazioni avanzate)
* **Visualizzazione dei dati:** Python (`pandas`, `matplotlib`)
* **IDE:** Visual Studio Code
* **Controllo di versione e documentazione:** Git / GitHub

## Competenze dimostrate

- data modeling con schema a stella
- utilizzo di chiavi surrogate
- JOIN multipli
- CTE complesse
- window functions (`FIRST_VALUE`)
- analisi temporali
- interpretazione business-oriented dei risultati
- documentazione tecnica strutturata

## Documentazione tecnica

- [Caricamento e trasformazione dati](/02_etl/etl.it.md)
- [Panoramica del modello](/03_data_model/data_model.it.md)
- [Analisi SQL](/04_queries/queries.it.md)

- [Dataset originale](https://data.cityofnewyork.us/Health/DOHMH-New-York-City-Restaurant-Inspection-Results/43nn-pn8j/about_data)
