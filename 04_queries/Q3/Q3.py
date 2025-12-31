import pandas as pd
import matplotlib.pyplot as plt

##############################################
#   COMMON CONFIGURATIONS
##############################################

# Colors by area
colors = {
    "Manhattan": "#1f77b4",      # 🔵
    "Brooklyn": "#ff7f0e",       # 🟠
    "Queens": "#2ca02c",         # 🟢
    "Bronx": "#d62728",          # 🔴
    "Staten Island": "#9467bd"   # 🟣
}

# Total number of establishments per area
establishments = {
    "Manhattan": 7260,
    "Brooklyn": 5003,
    "Queens": 4313,
    "Bronx": 1684,
    "Staten Island": 721
}

plt.style.use('dark_background')


#######################################################
#   CHART 3A — SCORE TREND BY YEAR AND AREA
#######################################################

df_a = pd.read_csv(r"2_QUERIES\Q3\score_history.csv")

# Remove rows without area_name
df_a = df_a.dropna(subset=['area_name'])

plt.figure(figsize=(12, 6))
for area in df_a["area_name"].unique():
    subset = df_a[df_a["area_name"] == area]
    plt.plot(
        subset["inspection_year"],
        subset["avg_score"],
        color=colors[area],
        linewidth=2,
        marker='o',
        markersize=4,
        label=area
    )

plt.xticks(sorted(df_a["inspection_year"].unique()), fontsize=12)
plt.yticks(fontsize=12)
plt.grid(axis='y', linestyle='--', alpha=0.5, color='gray')
plt.legend(title="Area", fontsize=12, title_fontsize=14)
plt.xlabel("")
plt.ylabel("")
plt.tight_layout()
plt.show()


#######################################################
#   CHART 3B — INSPECTIONS NORMALIZED PER ESTABLISHMENT
#######################################################

df_b = pd.read_csv(r"2_QUERIES\Q3\inspection_count_history.csv")

# Normalization per establishment
df_b["per_establishment"] = df_b.apply(
    lambda row: row["inspection_count"] / establishments[row["area_name"]],
    axis=1
)

plt.figure(figsize=(12, 6))
for area in df_b["area_name"].unique():
    subset = df_b[df_b["area_name"] == area]
    plt.plot(
        subset["inspection_year"],
        subset["per_establishment"],
        color=colors[area],
        linewidth=2,
        marker='o',
        markersize=4,
        label=area
    )

plt.xticks(sorted(df_b["inspection_year"].unique()), fontsize=12)
plt.yticks(fontsize=12)
plt.grid(axis='y', linestyle='--', alpha=0.5, color='gray')
plt.legend(title="Area", fontsize=12, title_fontsize=14)
plt.xlabel("")
plt.ylabel("")
plt.tight_layout()
plt.show()


#######################################################
#   CHART 3C — INSPECTIONS NORMALIZED PER ESTABLISHMENT UP TO 2021
#######################################################

df_c = pd.read_csv(r"2_QUERIES\Q3\inspection_count_history.csv")

# Filter data up to 2021
df_c = df_c[df_c["inspection_year"] <= 2021]

# Normalization per establishment
df_c["per_establishment"] = df_c.apply(
    lambda row: row["inspection_count"] / establishments[row["area_name"]],
    axis=1
)

plt.figure(figsize=(12, 6))
for area in df_c["area_name"].unique():
    subset = df_c[df_c["area_name"] == area]
    plt.plot(
        subset["inspection_year"],
        subset["per_establishment"],
        color=colors[area],
        linewidth=2,
        marker='o',
        markersize=4,
        label=area
    )

plt.xticks(sorted(df_c["inspection_year"].unique()), fontsize=12)
plt.yticks(fontsize=12)
plt.grid(axis='y', linestyle='--', alpha=0.5, color='gray')
plt.legend(title="Area", fontsize=12, title_fontsize=14)
plt.xlabel("")
plt.ylabel("")
plt.tight_layout()
plt.show()
