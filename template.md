# Q{N} – <Titolo sintetico dell’analisi>

## Domanda di analisi

<Descrizione della/e domanda/e analitica/che>

Obiettivo dell’analisi:

* <Obiettivo 1>
* <Obiettivo 2>

---

## Contesto analitico

* **Fact table:** `<fact_table>` (<granularità>)
* **Dimensioni:** `<dimension_1>`, `<dimension_2>`, ...
* **Metrica/e principale/i:** `<metric_1>`, `<metric_2>`

> <Nota interpretativa sulla metrica, se necessaria>

---

## Schema colori – Aree geografiche (standard globale)

Questo schema **deve essere utilizzato senza eccezioni** in:
- tabelle Markdown
- file CSV
- grafici (Matplotlib / Power BI)
- documentazione descrittiva

| Area | Colore | Icona |
| ---- | ------ | ----- |
| **Manhattan**     | 🔴 Rosso   | 🔴 |
| **Brooklyn**      | 🟢 Verde   | 🟢 |
| **Queens**        | 🔵 Blu     | 🔵 |
| **Bronx**         | 🟠 Arancione | 🟠 |
| **Staten Island** | 🟣 Viola   | 🟣 |

**Regole vincolanti:**
- stesso colore = stessa area **in tutte le Q**
- ordine di visualizzazione consigliato:
  1. Manhattan
  2. Brooklyn
  3. Queens
  4. Bronx
  5. Staten Island
- usare **icone + testo** nelle tabelle Markdown
- usare **solo colore** nei grafici

---

## Q{N}a – <Titolo sotto-analisi A>

### Obiettivo

<Obiettivo specifico della sotto-analisi>

### Logica

* <Step logico 1>
* <Step logico 2>

### Risultati

| Area | <Metrica 1> | <Metrica 2> |
| ---- | ----------: | ----------: |
| 🔴 **Manhattan**     |            |            |
| 🟢 **Brooklyn**      |            |            |
| 🔵 **Queens**        |            |            |
| 🟠 **Bronx**         |            |            |
| 🟣 **Staten Island** |            |            |

### Insight

* <Insight 1>
* <Insight 2>

---

## Q{N}b – <Titolo sotto-analisi B>

### Obiettivo

<Obiettivo specifico>

### Logica

* <Step logico 1>
* <Step logico 2>

### Risultati

| Area | <Metrica> |
| ---- | --------: |
| 🔴 **Manhattan**     |           |
| 🟢 **Brooklyn**      |           |
| 🔵 **Queens**        |           |
| 🟠 **Bronx**         |           |
| 🟣 **Staten Island** |           |

### Insight

* <Insight 1>

---

## Conclusione Q{N}

* <Conclusione chiave 1>
* <Conclusione chiave 2>

---

## File di riferimento

* `Q{N}.sql`
* `<output>.csv`
* `<output>.png`

---

🔗 **Documentazione**
* Query SQL: `/04_queries/Q{N}/Q{N}.sql`
* Spiegazione completa: `/04_queries/Q{N}/Q{N}.it.md`

↩️ *Torna alla [lista di queries](/04_queries/queries.it.md)*
