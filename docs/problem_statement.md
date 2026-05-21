# Problem Statement

Used vehicle auction data contains hundreds of thousands of transactions with inconsistent formatting, missing values, and mixed signals across price, mileage, condition, and geographic markets. Dealers and analysts need a repeatable pipeline to clean data, explore market patterns, quantify deal quality, and estimate fair selling prices.

## Objectives

1. Build an end-to-end analytics stack: **SQL → Python → Excel → ML → Power BI**
2. Perform data cleaning, exploratory data analysis, business intelligence, and market trend analysis on large-scale vehicle auction data.
3. Develop predictive machine learning models to estimate vehicle selling prices using historical transaction records.
4. Create interactive dashboards and portfolio-ready analytical artifacts including SQL scripts, notebooks, reports, visualizations, and business insights.

## Dataset

- **Source:** `dataset/raw/car_prices.csv` (~558K auction records)
- **Target variable (regression):** `sellingprice`
- **Secondary target (classification):** `deal_label` — Good Deal / Fair Deal / Overpriced from `price_vs_mmr`

  ---

# Project Scope

## SQL
- Data cleaning
- Exploratory queries
- Business KPI analysis
- Window functions and CTEs

## Python
- Data preprocessing
- Exploratory Data Analysis (EDA)
- Feature engineering
- Regression modeling

## Machine Learning
- Linear Regression
- Random Forest Regressor
- Model evaluation using MAE, RMSE, and R² Score

## Power BI
- Executive dashboard
- Market trend analysis
- Pricing intelligence dashboard
- Business insights visualization

---

## Success Criteria

- Reproducible cleaning with documented rules
- SQL layer for validation, EDA, business KPIs, and window analytics
- ML models: Linear Regression baseline + Random Forest Regressor (MAE, RMSE, R²)
- Optional deal-quality classifier for inventory decisions
- Executive dashboard in Power BI connected to cleaned data and ML exports
