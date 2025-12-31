
A = 29903 # violazioni nel fine settimana
B = 74708 # violazioni nei giorni feriali

percentage_weekends = round((A/2)/((A/2)+(B/5))*100, 2) # % normalizzata 2 su 7
percentage_weekdays = round((B/5)/((A/2)+(B/5))*100, 2) # % normalizzata 5 su 7

print(percentage_weekends)
# = 50.02 %
print(percentage_weekdays)
# = 49.98 %