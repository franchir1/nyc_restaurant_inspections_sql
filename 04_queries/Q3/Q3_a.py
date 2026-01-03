import pandas as pd

##############################################
# DATASET (EMBEDDED)
##############################################

data = [
    ("Bronx", 2016, 2), ("Bronx", 2017, 2), ("Bronx", 2018, 1),
    ("Bronx", 2019, 4), ("Bronx", 2020, 1), ("Bronx", 2021, 14),
    ("Bronx", 2022, 367), ("Bronx", 2023, 630), ("Bronx", 2024, 876),
    ("Bronx", 2025, 829),

    ("Brooklyn", 2016, 5), ("Brooklyn", 2017, 7), ("Brooklyn", 2018, 9),
    ("Brooklyn", 2019, 29), ("Brooklyn", 2020, 4), ("Brooklyn", 2021, 88),
    ("Brooklyn", 2022, 1344), ("Brooklyn", 2023, 1904),
    ("Brooklyn", 2024, 2589), ("Brooklyn", 2025, 2220),

    ("Manhattan", 2016, 14), ("Manhattan", 2017, 27),
    ("Manhattan", 2018, 26), ("Manhattan", 2019, 42),
    ("Manhattan", 2020, 15), ("Manhattan", 2021, 122),
    ("Manhattan", 2022, 1958), ("Manhattan", 2023, 2812),
    ("Manhattan", 2024, 3368), ("Manhattan", 2025, 3217),

    ("Queens", 2015, 1), ("Queens", 2016, 9), ("Queens", 2017, 18),
    ("Queens", 2018, 19), ("Queens", 2019, 26), ("Queens", 2020, 7),
    ("Queens", 2021, 58), ("Queens", 2022, 1082),
    ("Queens", 2023, 1543), ("Queens", 2024, 2125),
    ("Queens", 2025, 2260),

    ("Staten Island", 2016, 3), ("Staten Island", 2017, 3),
    ("Staten Island", 2018, 7), ("Staten Island", 2021, 15),
    ("Staten Island", 2022, 207), ("Staten Island", 2023, 298),
    ("Staten Island", 2024, 353), ("Staten Island", 2025, 300),
]

df = pd.DataFrame(
    data,
    columns=["area_name", "inspection_year", "inspection_count"]
)

##############################################
# NORMALIZATION
##############################################

establishments = {
    "Staten Island": 720,
    "Bronx": 1681,
    "Queens": 4305,
    "Brooklyn": 4977,
    "Manhattan": 7223
}

df["per_est"] = (
    df["inspection_count"] /
    df["area_name"].map(establishments)
)

df = df.sort_values(["area_name", "inspection_year"])

##############################################
# 3-YEAR MOVING AVERAGE
##############################################

df["per_est_ma_3y"] = (
    df.groupby("area_name")["per_est"]
      .rolling(3, min_periods=1)
      .mean()
      .reset_index(level=0, drop=True)
)

##############################################
# MATRIX
##############################################

matrix = (
    df.pivot(
        index="area_name",
        columns="inspection_year",
        values="per_est_ma_3y"
    )
    .round(4)
)

##############################################
# SOFT MONOCHROME COLOR SCALE
##############################################

vmin = matrix.min().min()
vmax = matrix.max().max()

def cell_html(val):
    if pd.isna(val):
        return "<td></td>"

    norm = (val - vmin) / (vmax - vmin)

    base = 45        # grigio di partenza
    max_red = 150    # rosso massimo (tenue)

    red = int(base + (max_red - base) * norm)
    green = base
    blue = base

    return (
        f'<td style="background-color: rgb({red},{green},{blue});'
        f' color:white; text-align:right; padding:6px;">{val}</td>'
    )

##############################################
# HTML GENERATION
##############################################

html = """
<html>
<head>
<meta charset="utf-8">
<title>Inspection Intensity Matrix</title>
<style>
  body { background-color: #111; color: white; font-family: Arial, sans-serif; }
  table { border-collapse: collapse; margin-top: 20px; }
  th { background-color: #222; padding: 6px; }
</style>
</head>
<body>
<h3>Inspections per Establishment (3Y Moving Average)</h3>
<table border="1">
"""

# Header
html += "<tr><th>Area</th>"
for year in matrix.columns:
    html += f"<th>{year}</th>"
html += "</tr>"

# Rows
for area, row in matrix.iterrows():
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

with open("inspection_matrix_monochrome.html", "w", encoding="utf-8") as f:
    f.write(html)

print("OK — file generato: inspection_matrix_monochrome.html")
