import pandas as pd
import matplotlib.pyplot as plt

# Load the CSV file
df = pd.read_csv(r"C:\Users\Lenovo\Documents\GitHub\SQL_Data_Analysis_project_01\2_QUERIES\Q2\total_critical_events_per_area.csv")

# Color map consistent with the other charts
color_map = {
    "Queens": "#1f77b4",
    "Bronx": "#ff7f0e",
    "Brooklyn": "#2ca02c",
    "Manhattan": "#d62728",
    "Staten Island": "#9467bd"
}

# Apply the color to the corresponding bar
colors = [color_map.get(area, "gray") for area in df["area"]]

# Dark style
plt.style.use("dark_background")

# Bar chart (compact)
plt.figure(figsize=(7, 4))
plt.bar(df["area"], df["total_critical_events"], color=colors, edgecolor="white")

# Titles and axes
#plt.title("Total critical violations by area", fontsize=16, pad=12)
#plt.xlabel("Area", fontsize=14)
#plt.ylabel("Critical violations", fontsize=14)

# Axis label size
plt.xticks(fontsize=13)
plt.yticks(fontsize=13)

plt.tight_layout()
plt.show()
