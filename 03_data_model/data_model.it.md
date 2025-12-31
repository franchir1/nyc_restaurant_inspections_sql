# Modello Dati – Schema a Stella

## Obiettivo

Questo capitolo descrive il **modello dati analitico** utilizzato per l’analisi
dei risultati delle ispezioni sanitarie di New York City.

Il modello è costruito a partire dalla tabella `clean_data_table`
(prodotto finale della fase ETL) ed è stato progettato per:

- supportare analisi temporali e geografiche
- migliorare le performance delle aggregazioni
- ridurre la ridondanza del dataset originale
- separare chiaramente fatti e dimensioni

---

## Approccio di modellazione

È stato adottato uno **schema a stella**, con:

- una **tabella dei fatti** centrale
- più **tabelle dimensionali** collegate tramite chiavi surrogate

Questo approccio è tipico dei sistemi di **data warehouse**
e consente di costruire query:

- più leggibili
- più performanti
- più facili da estendere nel tempo

Il dataset originale è una tabella “flat” in cui informazioni
anagrafiche, geografiche e temporali sono ripetute molte volte
(una riga per evento / violazione).
La normalizzazione in schema a stella elimina queste duplicazioni.

---

## Panoramica del modello

<p align="center">
  <img src="star_scheme_sql.png" alt="descrizione" width="600"><br>
  <em>Schema a stella del modello dati</em>
</p>

### Tabelle dimensionali
- `date_dim` — dimensione temporale delle ispezioni
- `area_dim` — dimensione geografica (indirizzi / aree)
- `establishment_dim` — dimensione degli stabilimenti
- `inspection_dim` — dimensione ispezione / violazione

### Tabella dei fatti
- `inspection_events_table` — eventi di ispezione con la misura `score_assigned`

---

# 1) Tabelle dimensionali

## 1.1 `date_dim` – Dimensione temporale

### Scopo

Rappresentare la dimensione temporale delle ispezioni, permettendo:

- aggregazioni per anno, mese, giorno
- analisi di trend temporali
- distinzione tra giorni feriali e weekend

### Struttura

- **Chiave surrogata**: `date_key` (INT, formato `YYYYMMDD`)
- **Chiave naturale**: `inspection_date` (DATE, UNIQUE)

```sql
CREATE TABLE date_dim (
    date_key INT PRIMARY KEY,
    inspection_date DATE UNIQUE,
    inspection_year INT NOT NULL,
    inspection_month INT NOT NULL,
    inspection_day INT NOT NULL,
    is_weekend BOOLEAN NOT NULL
);
```

### Popolamento

La tabella viene popolata tramite una `SELECT DISTINCT`
dalla `clean_data_table` per evitare duplicazioni.

```sql
INSERT INTO date_dim (
    date_key,
    inspection_date,
    inspection_year,
    inspection_month,
    inspection_day,
    is_weekend
)
SELECT DISTINCT
    TO_CHAR(cdt.inspection_date, 'YYYYMMDD')::INT,
    cdt.inspection_date,
    EXTRACT(YEAR FROM cdt.inspection_date),
    EXTRACT(MONTH FROM cdt.inspection_date),
    EXTRACT(DAY FROM cdt.inspection_date),
    CASE
        WHEN EXTRACT(DOW FROM cdt.inspection_date) IN (0,6)
        THEN TRUE ELSE FALSE
    END
FROM clean_data_table AS cdt
WHERE cdt.inspection_date IS NOT NULL;
```

---

## 1.2 `establishment_dim` – Dimensione stabilimenti

### Scopo

Raccogliere le informazioni anagrafiche degli stabilimenti
per analisi su:

* performance del singolo ristorante
* confronto tra tipologie di cucina
* evoluzione nel tempo di uno stesso esercizio

### Struttura

* **Chiave surrogata**: `establishment_key`
* **Chiave naturale**: `camis_code` (univoca)

```sql
CREATE TABLE establishment_dim (
    establishment_key SERIAL PRIMARY KEY,
    camis_code VARCHAR(10) NOT NULL UNIQUE,
    establishment_name VARCHAR(255),
    cuisine_description VARCHAR(100)
);
```

### Popolamento

```sql
INSERT INTO establishment_dim (
    camis_code,
    establishment_name,
    cuisine_description
)
SELECT DISTINCT
    cdt.camis_code,
    cdt.establishment_name,
    cdt.cuisine_description
FROM clean_data_table AS cdt
WHERE cdt.camis_code IS NOT NULL;
```

---

## 1.3 `area_dim` – Dimensione geografica

### Scopo

Normalizzare le informazioni di localizzazione per:

* confronto tra quartieri / aree
* analisi geografiche
* normalizzazione degli indicatori per area

### Struttura

* **Chiave surrogata**: `area_key`
* **Chiave naturale composta**:
  `(building_code, street_name, zip_code)`

```sql
CREATE TABLE area_dim (
    area_key SERIAL PRIMARY KEY,
    area_name VARCHAR(25),
    building_code VARCHAR(10),
    street_name VARCHAR(100),
    zip_code VARCHAR(10),
    UNIQUE (building_code, street_name, zip_code)
);
```

### Popolamento

```sql
INSERT INTO area_dim (
    area_name,
    building_code,
    street_name,
    zip_code
)
SELECT DISTINCT
    cdt.area_name,
    cdt.building_code,
    cdt.street_name,
    cdt.zip_code
FROM clean_data_table AS cdt
WHERE
    cdt.building_code IS NOT NULL
    AND cdt.street_name IS NOT NULL
    AND cdt.zip_code IS NOT NULL;
```

---

## 1.4 `inspection_dim` – Dimensione ispezioni / violazioni

### Scopo

Descrivere l’evento di ispezione dal punto di vista normativo:

* codice violazione
* descrizione
* azione intrapresa
* livello di criticità

Questa dimensione abilita analisi su:

* violazioni più frequenti
* distribuzione per criticità
* azioni correttive ricorrenti

### Struttura

* **Chiave surrogata**: `inspection_key`
* **Chiave naturale**: `violation_code`

```sql
CREATE TABLE inspection_dim (
    inspection_key SERIAL PRIMARY KEY,
    violation_code VARCHAR(10) NOT NULL UNIQUE,
    violation_description VARCHAR(1000),
    action_taken VARCHAR(255),
    critical_flag VARCHAR(25)
);
```

### Popolamento

```sql
INSERT INTO inspection_dim (
    violation_code,
    violation_description,
    action_taken,
    critical_flag
)
SELECT
    cdt.violation_code,
    cdt.violation_description,
    cdt.action_taken,
    cdt.critical_flag
FROM clean_data_table AS cdt
WHERE cdt.violation_code IS NOT NULL
ON CONFLICT (violation_code) DO NOTHING;
```

---

# 2) Tabella dei fatti

## `inspection_events_table`

### Scopo

La tabella dei fatti rappresenta **l’evento di ispezione**
nel modello analitico.

Contiene:

* le **chiavi surrogate** verso le dimensioni
* la **misura principale**: `score_assigned`

Ogni riga rappresenta **un evento di ispezione / violazione**.

### Struttura

```sql
CREATE TABLE inspection_events_table (
    event_key SERIAL PRIMARY KEY,
    area_key INT NOT NULL REFERENCES area_dim(area_key),
    date_key INT NOT NULL REFERENCES date_dim(date_key),
    establishment_key INT NOT NULL REFERENCES establishment_dim(establishment_key),
    inspection_key INT NOT NULL REFERENCES inspection_dim(inspection_key),
    score_assigned INT NOT NULL
);
```

---

## Popolamento della fact table

### Logica

Il popolamento avviene a partire dalla `clean_data_table` sostituendo le chiavi naturali con le chiavi surrogate tramite join sulle dimensioni.

```sql
INSERT INTO inspection_events_table (
    area_key,
    date_key,
    establishment_key,
    inspection_key,
    score_assigned
)
SELECT
    ad.area_key,
    dd.date_key,
    ed.establishment_key,
    id.inspection_key,
    cdt.score_assigned
FROM clean_data_table AS cdt
JOIN area_dim AS ad
    ON cdt.building_code = ad.building_code
   AND cdt.street_name = ad.street_name
   AND cdt.zip_code = ad.zip_code
JOIN date_dim AS dd
    ON cdt.inspection_date = dd.inspection_date
JOIN establishment_dim AS ed
    ON cdt.camis_code = ed.camis_code
JOIN inspection_dim AS id
    ON cdt.violation_code = id.violation_code;
```

---

## Considerazioni tecniche

### Granularità della fact table

Il dataset originale può contenere:

* più violazioni per la stessa ispezione
* più righe per lo stesso stabilimento e la stessa data

Questo implica che la fact table
possa avere più righe per uno stesso evento “logico”.
In fase di analisi è quindi fondamentale distinguere tra:

* conteggio di eventi
* conteggio di violazioni

---

## Output del modello dati

Al termine della fase di modellazione si ottiene un **modello a stella completo**, composto da:

* 4 tabelle dimensionali
* 1 tabella dei fatti

Questo modello rappresenta la base unica per tutte le analisi SQL e le visualizzazioni del progetto.

Torna al [README](/README.it.md)