# Power BI Dashboard Setup

## Data Sources

1. **Primary:** `dataset/cleaned/cleaned_vehicle_sales.csv`
2. **Aggregated:** `powerbi/vehicle_sales_for_powerbi.csv` (from Excel build script)
3. **ML metrics (optional):** `python/models/model_metrics.json`

## Build `vehicle_sales_dashboard.pbix`

### Step 1 — Import

1. Open **Power BI Desktop**
2. **Get Data → Text/CSV** → select `cleaned_vehicle_sales.csv`
3. Import `vehicle_sales_for_powerbi.csv` as **Market Summary**

### Step 2 — Model

| Table | Key columns |
|-------|-------------|
| vehicle_sales | vin, make, body, state, sellingprice, mmr, deal_label |
| Market Summary | make, body, state, units, avg_price, revenue |

Relationships: optional star schema if you load SQL dimension tables.

### Step 3 — DAX Measures

Copy measures from `dax_measures.txt` into the model.

### Step 4 — Report Pages

| Page | Visuals |
|------|---------|
| **Executive Dashboard** | KPI: Total Revenue, Avg Price, Good Deal %, Volume |
| **Market Analysis** | Map by state, bar chart top makes, quarterly line |
| **Pricing Analysis** | Scatter odometer vs price, MMR vs selling price, deal mix donut |
| **ML Insights** | Import predictions table when available; Actual vs Predicted scatter |

### Step 5 — Export

- **File → Export → PDF** → save to `exported_reports/dashboard.pdf`
- Export page images to `exported_reports/dashboard_images/`

## Refresh

After re-running `python python/scripts/cleaning.py`, refresh datasets in Power BI.
