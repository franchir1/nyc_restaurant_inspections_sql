import pandas as pd

##############################################
# DATASET (EMBEDDED)
##############################################

data = [
    ("Bronx", 2016, 12.50), ("Bronx", 2017, 10.50), ("Bronx", 2018, 21.00),
    ("Bronx", 2019, 40.50), ("Bronx", 2020, 9.00),  ("Bronx", 2021, 11.29),
    ("Bronx", 2022, 14.74), ("Bronx", 2023, 17.47), ("Bronx", 2024, 18.74),
    ("Bronx", 2025, 18.60),

    ("Brooklyn", 2016, 8.20), ("Brooklyn", 2017, 15.71), ("Brooklyn", 2018, 11.56),
    ("Brooklyn", 2019, 16.24), ("Brooklyn", 2020, 12.00), ("Brooklyn", 2021, 14.94),
    ("Brooklyn", 2022, 15.50), ("Brooklyn", 2023, 17.83),
    ("Brooklyn", 2024, 18.57), ("Brooklyn", 2025, 19.29),

    ("Manhattan", 2016, 10.86), ("Manhattan", 2017, 10.19),
    ("Manhattan", 2018, 9.08),  ("Manhattan", 2019, 12.29),
    ("Manhattan", 2020, 16.20), ("Manhattan", 2021, 14.14),
    ("Manhattan", 2022, 14.95), ("Manhattan", 2023, 16.72),
    ("Manhattan", 2024, 17.61), ("Manhattan", 2025, 19.02),

    ("Queens", 2015, 21.00), ("Queens", 2016, 10.44), ("Queens", 2017, 9.22),
    ("Queens", 2018, 13.53), ("Queens", 2019, 15.31), ("Queens", 2020, 10.57),
    ("Queens", 2021, 16.72), ("Queens", 2022, 15.37),
    ("Queens", 2023, 18.80), ("Queens", 2024, 19.70),
    ("Queens", 2025, 21.24),

    ("Staten Island", 2016, 10.67), ("Staten Island", 2017, 18.00),
    ("Staten Island", 2018, 15.14), ("Staten Island", 2021, 16.40),
    ("Staten Island", 2022, 15.09), ("Staten Island", 2023, 16.18),
    ("Staten Island", 2024, 16.84), ("Staten Island", 2025, 18.59),
]

df = pd.DataFrame(
    data,
    columns=["area_name", "inspection_year", "avg_score"]
)

##############################################
# MATRIX (NUMERIC)
##############################################

matrix = df.pivot(
    index="area_name",
    columns="inspection_year",
    values="avg_score"
)

vmin = matrix.min().min()
vmax = matrix.max().max()

##############################################
# FORMATTING (AFTER CALCULATIONS)
##############################################

matrix_fmt = matrix.applymap(
    lambda x: f"{x:.2f}" if pd.notna(x) else ""
)

##############################################
# SOFT MONOCHROME COLOR SCALE
##############################################

def cell_html(val):
    if val == "":
        return "<td></td>"

    num = float(val)
    norm = (num - vmin) / (vmax - vmin)

    base = 45
    max_red = 150

    red = int(base + (max_red - base) * norm)

    return (
        f'<td style="background-color: rgb({red},{base},{base});'
        f' color:white; text-align:right; padding:6px;">{val}</td>'
    )

##############################################
# HTML GENERATION
##############################################

html = """
<html>
<head>
<meta charset="utf-8">
<title>Average Inspection Score Trend</title>
<style>
  body {
    background-color: #111;
    color: white;
    font-family: "JetBrains Mono", Consolas, monospace;
  }
  table {
    border-collapse: collapse;
    margin-top: 20px;
  }
  th {
    background-color: #222;
    padding: 6px;
  }
</style>
</head>
<body>
<h3>Average Inspection Score by Area and Year</h3>
<p>Higher values indicate worse inspection outcomes.</p>
<table border="1">
"""

# Header
html += "<tr><th>Area</th>"
for year in matrix_fmt.columns:
    html += f"<th>{year}</th>"
html += "</tr>"

# Rows
for area, row in matrix_fmt.iterrows():
    html += f"<tr><th>{area}</th>"
    for val in row:
        html += cell_html(val)
    html += "</tr>"

html += """
</table>
</body>
</html>
"""

##############################################
# EXPORT
##############################################

with open("Q3B.html", "w", encoding="utf-8") as f:
    f.write(html)

print("OK — file generato: avg_score_trend_monochrome.html")
