# Methodology

## 1. Data Cleaning (Python + SQL)

- Standardize text fields (`make`, `body`, `transmission`, etc.)
- Parse `saledate` with flexible datetime handling
- Remove duplicate VINs (keep lower price record)
- Impute `condition` using median by `make` + `body`
- Remove statistical + business outliers on `sellingprice` ($500–$250K)
- Engineer: `vehicle_age`, `price_vs_mmr`, `deal_label`, `odometer_bin`, sale period fields

## 2. Exploratory Analysis

- Univariate: price distribution, condition mix, geographic spreads
- Bivariate: odometer vs price, MMR vs selling price
- Multivariate: correlation heatmap, box plots by make, depreciation curves

## 3. Business Analytics (SQL)

- Revenue and volume by make, body, state, quarter
- Seller scorecards and market efficiency scores
- Window functions: ranking, MoM trends, cumulative revenue, hot markets

## 4. Excel

- Make × body price matrix (pivot)
- State summary, quarterly trends, deal mix
- Sample transactions sheet for ad-hoc exploration

## 5. Machine Learning

| Model | Use |
|-------|-----|
| Linear Regression | Interpretable baseline |
| Random Forest Regressor | Primary price predictor |
| Random Forest Classifier | Optional deal-quality labels |

**Process:** 80/20 train-test split (stratified on body type), encoding via `ColumnTransformer`, metrics: **MAE, RMSE, R²**.

## 6. Power BI

- Import cleaned CSV + aggregated export
- Star-style relationships (optional) via dimension tables in SQL
- KPI cards, maps, trend lines, actual vs predicted scatter
