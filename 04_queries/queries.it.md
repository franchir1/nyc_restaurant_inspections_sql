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

*Torna al [README](/README.it.md)*