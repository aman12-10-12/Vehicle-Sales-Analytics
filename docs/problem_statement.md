# Problem Statement

Used vehicle auction data contains hundreds of thousands of transactions with inconsistent formatting, missing values, and mixed signals across price, mileage, condition, and geographic markets. Dealers and analysts need a repeatable pipeline to clean data, explore market patterns, quantify deal quality, and estimate fair selling prices.

## Objectives

1. Build an end-to-end analytics stack: **SQL → Python → Excel → ML → Power BI**
2. Answer all **60 questions** in `vehicle_sales_question_bank.docx` (Basic, Intermediate, Advanced, Master)
3. Deliver portfolio-ready artifacts: cleaned dataset, SQL scripts, notebooks, models, dashboards, and documentation

## Dataset

- **Source:** `dataset/raw/car_prices.csv` (~558K auction records)
- **Target variable (regression):** `sellingprice`
- **Secondary target (classification):** `deal_label` — Good Deal / Fair Deal / Overpriced from `price_vs_mmr`

## Success Criteria

- Reproducible cleaning with documented rules
- SQL layer for validation, EDA, business KPIs, and window analytics
- ML models: Linear Regression baseline + Random Forest Regressor (MAE, RMSE, R²)
- Optional deal-quality classifier for inventory decisions
- Executive dashboard in Power BI connected to cleaned data and ML exports
