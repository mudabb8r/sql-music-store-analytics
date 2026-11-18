# Rebuilding this dashboard in Power BI Desktop

The CSV files in `outputs/` are ready to load into Power BI. This takes about 30–45 minutes the first time.

## 1. Load the data
1. Install **Power BI Desktop** (free, Windows, from the Microsoft Store).
2. **Home → Get data → Text/CSV** and load these files from `outputs/`:
   `02_monthly_revenue.csv`, `03_revenue_by_country.csv`, `05_genre_revenue.csv`, `07_customer_segments.csv`.
3. In **Power Query** (Transform data), check that `month` is a Date type (change type → Date) and numbers are Decimal Number.

## 2. Create DAX measures
In the Data pane, right-click `02_monthly_revenue` → **New measure**, one at a time:

```DAX
Total Revenue = SUM('02_monthly_revenue'[revenue])

Total Invoices = SUM('02_monthly_revenue'[invoices])

Avg Invoice Value = DIVIDE([Total Revenue], [Total Invoices])

Revenue YoY % =
VAR CurrentYear = [Total Revenue]
VAR PriorYear  = CALCULATE([Total Revenue], SAMEPERIODLASTYEAR('02_monthly_revenue'[month]))
RETURN DIVIDE(CurrentYear - PriorYear, PriorYear)
```

(`SAMEPERIODLASTYEAR` needs a proper date column; if it errors, add a date table with **Modeling → New table → `Dates = CALENDARAUTO()`** and relate it to `month`.)

## 3. Build the visuals
| Visual | Fields |
|---|---|
| 3 **Card** visuals | Total Revenue, Total Invoices, Avg Invoice Value |
| **Line and clustered column chart** | X: month · Columns: revenue · Line: rolling_3m_avg |
| **Bar chart** | Y: country · X: revenue (top 10 filter) |
| **Bar chart** | Y: genre · X: revenue |
| **Donut chart** | Legend: segment · Values: count of customer |
| **Slicer** | segment (from customer segments) |

## 4. Save and share
- Save as `music_store_dashboard.pbix` in this repo.
- Take a screenshot and save it as `images/powerbi_dashboard.png`, then add it to the README.
- Only list Power BI on your resume for this project once you have built it yourself.
