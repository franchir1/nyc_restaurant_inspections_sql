# ETL – Estrazione, Pulizia e Caricamento dei Dati

## Fonte del dataset

Il dataset originale include:
- informazioni sugli stabilimenti
- date e tipologie di ispezione
- violazioni riscontrate
- punteggi assegnati
- numerosi dati amministrativi e geografici

Non tutte le colonne sono rilevanti. Una selezione e normalizzazione mirata è quindi necessaria.

## Preparazione dei dati grezzi

Il dataset originale del DOHMH viene inizialmente trattato **al di fuori del database** tramite **Power Query (Excel)**.

Le trasformazioni effettuate includono:
1. rimozione delle colonne amministrative e non rilevanti
2. rinomina delle colonne con nomi semantici
3. normalizzazione dei formati data
4. sostituzione dei valori vuoti o fasulli con `NULL`
5. correzione dei tipi di dato
6. rimozione delle righe prive di `inspection_date` o `score_assigned`

Al termine di questa fase, il dataset viene esportato in formato CSV e utilizzato come input per PostgreSQL.

## Creazione della tabella intermedia

Nel database PostgreSQL viene creata una tabella di **staging** denominata `raw_data_table`.

Questa tabella:
- **non rappresenta il dataset grezzo originale**
- contiene dati **già puliti e normalizzati** tramite Power Query
- serve come livello intermedio prima del filtraggio finale

```sql
CREATE TABLE raw_data_table (
    camis_code VARCHAR(10) NOT NULL,
    establishment_name VARCHAR(120),
    area_name VARCHAR(15),
    building_code VARCHAR(15),
    street_name VARCHAR(150),
    zip_code VARCHAR(5) NOT NULL,
    cuisine_description VARCHAR(60),
    inspection_date DATE,
    action_taken VARCHAR(150),
    violation_code VARCHAR(5) NOT NULL,
    violation_description VARCHAR(2000),
    critical_flag VARCHAR(15),
    score_assigned INT
);
```

## Caricamento dei dati puliti

Il dataset pulito viene esportato in formato CSV e caricato in PostgreSQL tramite il comando `COPY`.

```sql
COPY public.raw_data_table (
    camis_code,
    establishment_name,
    area_name,
    building_code,
    street_name,
    zip_code,
    cuisine_description,
    inspection_date,
    action_taken,
    violation_code,
    violation_description,
    critical_flag,
    score_assigned
)
FROM 'C:\raw_data\raw_data_table.csv'
WITH (FORMAT csv, DELIMITER ';', HEADER, ENCODING 'UTF8', QUOTE '"');
```

## Creazione della tabella finale

La tabella `clean_data_table` rappresenta il **dataset finale** utilizzato in tutto il progetto.

```sql
CREATE TABLE clean_data_table (
    camis_code VARCHAR(10) NOT NULL,
    establishment_name VARCHAR(120),
    area_name VARCHAR(15),
    building_code VARCHAR(15),
    street_name VARCHAR(150),
    zip_code VARCHAR(5) NOT NULL,
    cuisine_description VARCHAR(60),
    inspection_date DATE,
    action_taken VARCHAR(150),
    violation_code VARCHAR(5) NOT NULL,
    violation_description VARCHAR(2000),
    critical_flag VARCHAR(15),
    score_assigned INT
);
```

## Filtraggio delle righe non valide

Per garantire analisi coerenti, vengono inserite nella tabella finale solo le righe che contengono:

* una **data di ispezione valida**
* un **punteggio assegnato valido**

```sql
INSERT INTO clean_data_table
SELECT *
FROM raw_data_table
WHERE inspection_date IS NOT NULL
  AND score_assigned IS NOT NULL;
```

### Motivazione

* senza data → nessuna analisi temporale
* senza punteggio → nessuna valutazione di performance

## Strumenti di reset e manutenzione del database

Durante sviluppo e test, è necessario poter ripulire rapidamente le tabelle.

```sql
TRUNCATE TABLE date_dim RESTART IDENTITY;
TRUNCATE TABLE establishment_dim RESTART IDENTITY;
TRUNCATE TABLE area_dim RESTART IDENTITY;
TRUNCATE TABLE inspection_dim RESTART IDENTITY;
TRUNCATE TABLE inspection_events_table RESTART IDENTITY;
```

Per una pulizia completa con vincoli attivi:

```sql
TRUNCATE TABLE
    date_dim,
    establishment_dim,
    area_dim,
    inspection_dim
RESTART IDENTITY CASCADE;
```

## Gestione dei vincoli e adattamento dello schema

Durante il caricamento e le join, alcuni vincoli `NOT NULL` possono causare errori. Per questo motivo vengono temporaneamente rimossi.

```sql
ALTER TABLE public.clean_data_table ALTER COLUMN camis_code DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN establishment_name DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN cuisine_description DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN area_name DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN building_code DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN street_name DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN zip_code DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN inspection_date DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN action_taken DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN violation_code DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN violation_description DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN critical_flag DROP NOT NULL;
ALTER TABLE public.clean_data_table ALTER COLUMN score_assigned DROP NOT NULL;
```

Per evitare troncamenti nelle descrizioni delle violazioni:

```sql
ALTER TABLE public.raw_data_table
ALTER COLUMN violation_description TYPE VARCHAR(2000);
```

## Output finale della fase ETL

Il risultato del processo ETL è la tabella `clean_data_table`
* contenente solo dati validi
* coerente dal punto di vista semantico
* pronta per la modellazione a stella

*Torna al [README](/README.it.md)*