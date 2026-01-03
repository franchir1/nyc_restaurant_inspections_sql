import pandas as pd
import matplotlib.pyplot as plt

##############################################
#   COMMON CONFIGURATIONS
##############################################

colors = {
    "Manhattan": "#1f77b4",
    "Brooklyn": "#ff7f0e",
    "Queens": "#2ca02c",
    "Bronx": "#d62728",
    "Staten Island": "#9467bd"
}

establishments = {
    "Staten Island": 720,
    "Bronx": 1681,
    "Queens": 4305,
    "Brooklyn": 4977,
    "Manhattan": 7223
}

plt.style.use("dark_background")

##############################################
#   CHART 3B — NORMALIZED + 3Y MOVING AVERAGE
##############################################

df = pd.read_csv(r"2_QUERIES\Q3\inspection_count_history.csv")

df["inspection_year"] = df["inspection_year"].astype(int)
df["inspection_count"] = df["inspection_count"].astype(int)

# Normalize
df["per_establishment"] = (
    df["inspection_count"] /
    df["area_name"].map(establishments)
)

# Sort correctly
df = df.sort_values(["area_name", "inspection_year"])

# 3-year moving average (per area)
df["per_est_ma_3y"] = (
    df.groupby("area_name")["per_establishment"]
      .rolling(window=3, min_periods=1)
      .mean()
      .reset_index(level=0, drop=True)
)

plt.figure(figsize=(12, 6))

for area in df["area_name"].unique():
    subset = df[df["area_name"] == area]

    plt.plot(
        subset["inspection_year"],
        subset["per_est_ma_3y"],
        color=colors[area],
        linewidth=2,
        marker="o",
        markersize=4,
        label=area
    )

plt.xticks(
    sorted(df["inspection_year"].unique()),
    fontsize=12
)
plt.yticks(fontsize=12)

plt.grid(axis="y", linestyle="--", alpha=0.5, color="gray")
plt.legend(title="Area", fontsize=12, title_fontsize=14)
plt.xlabel("")
plt.ylabel("Inspections per establishment (3Y MA)")
plt.tight_layout()
plt.show()

##############################################
#   CHART 3C — UP TO 2021 (3Y MA)
##############################################

df_2021 = df[df["inspection_year"] <= 2021]

plt.figure(figsize=(12, 6))

for area in df_2021["area_name"].unique():
    subset = df_2021[df_2021["area_name"] == area]

    plt.plot(
        subset["inspection_year"],
        subset["per_est_ma_3y"],
        color=colors[area],
        linewidth=2,
        marker="o",
        markersize=4,
        label=area
    )

plt.xticks(
    sorted(df_2021["inspection_year"].unique()),
    fontsize=12
)
plt.yticks(fontsize=12)

plt.grid(axis="y", linestyle="--", alpha=0.5, color="gray")
plt.legend(title="Area", fontsize=12, title_fontsize=14)
plt.xlabel("")
plt.ylabel("Inspections per establishment (3Y MA)")
plt.tight_layout()
plt.show()
