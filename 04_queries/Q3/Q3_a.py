import pandas as pd

establishments = {
    "Staten Island": 720,
    "Bronx": 1681,
    "Queens": 4305,
    "Brooklyn": 4977,
    "Manhattan": 7223
}

df = pd.read_csv("inspection_count_history.csv")

df["inspection_year"] = df["inspection_year"].astype(int)
df["inspection_count"] = df["inspection_count"].astype(int)

# Normalizzazione
df["per_est"] = (
    df["inspection_count"] /
    df["area_name"].map(establishments)
)

# Ordinamento corretto
df = df.sort_values(["area_name", "inspection_year"])

# Media mobile 3 anni
df["per_est_ma_3y"] = (
    df.groupby("area_name")["per_est"]
      .rolling(3, min_periods=1)
      .mean()
      .reset_index(level=0, drop=True)
)

# Matrice
matrix = (
    df.pivot(
        index="area_name",
        columns="inspection_year",
        values="per_est_ma_3y"
    )
    .round(4)
)

# -------- SCALA MONOCROMATICA --------
def mono_scale(val, vmin, vmax):
    if pd.isna(val):
        return ""
    norm = (val - vmin) / (vmax - vmin)
    red = int(255 * norm)
    return f"background-color: rgb({red}, 30, 30); color: white;"

vmin = matrix.min().min()
vmax = matrix.max().max()

styled = matrix.style.applymap(
    lambda v: mono_scale(v, vmin, vmax)
)

styled.to_html("inspection_matrix_monochrome.html")