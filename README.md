# Vehicle Sales Analytics

End-to-end data analytics portfolio project using **car auction data** (~558K records) to perform data cleaning, exploratory analysis, business intelligence, price prediction, and dashboard visualization using SQL, Python, Excel, Machine Learning, and Power BI. Pipeline: **SQL → Python → Excel → Machine Learning → Power BI**.

## Project Structure

```
Vehicle-Sales-Analytics/
├── dataset/raw/car_prices.csv
├── dataset/cleaned/cleaned_vehicle_sales.csv
├── sql/01–07_*.sql
├── python/notebooks/, python/scripts/, python/models/
├── excel/vehicle_sales_analysis.xlsx
├── powerbi/
├── visuals/
├── docs/
└── reports/
```

## Quick Start

```bash
cd Vehicle-Sales-Analytics
python3 -m pip install -r requirements.txt

# Full pipeline
bash run_pipeline.sh
```

### Manual Steps

| Step | Command |
|------|---------|
| 1. Clean data | `python3 python/scripts/cleaning.py` |
| 2. SQLite (local SQL) | `python3 python/scripts/setup_sqlite.py` |
| 3. MySQL | Run `sql/01_database_creation.sql` through `07_final_insights.sql` |
| 4. Excel | `python3 python/scripts/build_excel_analysis.py` |
| 5. ML | `python3 python/scripts/train_model.py` |
| 6. Charts | `python3 python/scripts/generate_eda_charts.py` |
| 7. Power BI | See `powerbi/POWERBI_SETUP.md` |

## Machine Learning

| Model | Purpose | Metrics (sample 80K) |
|-------|---------|------------------------|
| **Linear Regression** | Baseline price prediction | R² ≈ 0.96 |
| **Random Forest Regressor** | Primary model | R² ≈ 0.97, lower MAE |
| **Random Forest Classifier** | Good / Fair / Overpriced deals | See `model_metrics.json` |

```python
from python.scripts.predict import predict_price

predict_price({
    "year": 2018, "odometer": 45000, "condition": 4,
    "vehicle_age": 2, "mmr": 22000, "body": "suv",
    "transmission": "automatic", "state": "ca", "make": "ford"
})
```

## Documentation & Analysis Mapping

Analytical tasks, SQL workflows, EDA processes, and ML components are mapped in: [`docs/index.md`].

## Project Outputs

- **528,845** cleaned records → `dataset/cleaned/cleaned_vehicle_sales.csv`
- **4 EDA charts** → `visuals/eda_charts/`
- **Excel workbook** → `excel/vehicle_sales_analysis.xlsx`
- **Models** → `python/models/random_forest_model.pkl`
- **SQLite** → `vehicle_sales.db` (optional local SQL)
- **Reports** → `reports/project_report.pdf`, `business_insights.pdf`, `presentation.pptx`
- **Power BI** → `powerbi/vehicle_sales_dashboard.pbix`, `exported_reports/dashboard.pdf`

### Power BI dashboard

1. Open `powerbi/vehicle_sales_dashboard.pbix` (4 pages: Executive, Market, Pricing, ML)
2. **Get Data → Text/CSV** → `dataset/cleaned/cleaned_vehicle_sales.csv`
3. Import `powerbi/ml_predictions.csv` for ML Insights page
4. Apply DAX from `powerbi/dax_measures.txt`

## Documentation

- [Problem Statement](docs/problem_statement.md)
- [Architecture](docs/project_architecture.md)
- [Methodology](docs/methodology.md)
- [Conclusions](docs/conclusions.md)
- [Future Scope](docs/future_scope.md)

## License

MIT — see [LICENSE](LICENSE).
