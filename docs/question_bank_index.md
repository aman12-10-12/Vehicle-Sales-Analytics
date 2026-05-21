# Question Bank Index

Maps all **60 questions** from `vehicle_sales_question_bank.docx` to project artifacts.

## Basic (15)

| # | Topic | Answer Location |
|---|-------|-----------------|
| 1 | Rows/columns/nulls | `01_data_cleaning.ipynb`, `02_data_cleaning.sql` |
| 2 | Missing % by column | `01_data_cleaning.ipynb`, `02_data_cleaning.sql` |
| 3 | Duplicate VINs | `cleaning.py`, `02_data_cleaning.sql` |
| 4 | saledate parsing | `cleaning.py`, `01_data_cleaning.ipynb` |
| 5 | Standardize make | `cleaning.py` |
| 6 | Avg price by body | `03_eda_queries.sql`, `02_eda.ipynb` |
| 7 | Top 10 makes | `03_eda_queries.sql` |
| 8 | Condition distribution | `03_eda_queries.sql` |
| 9 | State avg prices | `03_eda_queries.sql` |
| 10 | Above/below MMR % | `03_eda_queries.sql` |
| 11 | Revenue by make | `04_business_analysis.sql`, `05_business_insights.ipynb` |
| 12 | Transmission price diff | `04_business_analysis.sql` |
| 13 | Color vs price | `04_business_analysis.sql` |
| 14 | Price histogram | `02_eda.ipynb`, `visuals/eda_charts/` |
| 15 | Odometer scatter | `02_eda.ipynb`, `mileage_vs_price.png` |

## Intermediate (15)

| # | Topic | Answer Location |
|---|-------|-----------------|
| 1 | IQR outliers | `cleaning.py`, `02_data_cleaning.sql` |
| 2 | Condition imputation | `cleaning.py` |
| 3 | vehicle_age | `cleaning.py`, `03_feature_engineering.ipynb` |
| 4 | Window rank by body | `05_window_functions.sql` |
| 5 | MoM price change | `05_window_functions.sql` |
| 6 | Seller scorecard | `04_business_analysis.sql`, `06_views_and_ctes.sql` |
| 7 | MMR retention by body | `04_business_analysis.sql` |
| 8 | Top make-model premium | `04_business_analysis.sql` |
| 9 | Q1 vs Q3 seasonality | `04_business_analysis.sql`, `05_business_insights.ipynb` |
| 10 | Correlation heatmap | `02_eda.ipynb`, `correlation_heatmap.png` |
| 11 | Box plot by make | `02_eda.ipynb` |
| 12 | Depreciation curves | `generate_eda_charts.py`, `depreciation_curve.png` |
| 13 | Odometer bins | `cleaning.py`, `03_eda_queries.sql` |
| 14 | Faceted scatter | `02_eda.ipynb` (extend with seaborn facetgrid) |
| 15 | Robust date parser | `cleaning.py` |

## Advanced (15)

| # | Topic | Answer Location |
|---|-------|-----------------|
| 1 | Pipeline class | `cleaning.py` (function-based; extend to class) |
| 2 | Fraud detection | `02_data_cleaning.sql` |
| 3 | Star schema | `01_database_creation.sql`, `06_views_and_ctes.sql` |
| 4 | Recursive cumulative revenue | `05_window_functions.sql` |
| 5 | Market efficiency by state | `04_business_analysis.sql` |
| 6 | ROI stocking framework | `04_business_analysis.sql` |
| 7 | Underpriced profit simulation | `04_business_analysis.sql`, `05_business_insights.ipynb` |
| 8 | Plotly choropleth | `02_eda.ipynb` (optional Plotly cell) |
| 9 | KMeans clustering | `03_feature_engineering.ipynb` (optional extension) |
| 10 | Data quality funnel | `03_eda_queries.sql` |
| 11 | Pivot make×body | `build_excel_analysis.py`, Excel workbook |
| 12 | November drill-down | `06_views_and_ctes.sql` |
| 13 | Quality dashboard | `future_scope.md` |
| 14 | Pairplot | `02_eda.ipynb` |
| 15 | Hot markets SQL | `05_window_functions.sql` |

## Master (15)

| # | Topic | Answer Location |
|---|-------|-----------------|
| 1 | ELT architecture | `project_architecture.md`, `future_scope.md` |
| 2 | CEO 5-slide story | `reports/EXECUTIVE_STORY.md` |
| 3 | CDC strategy | `future_scope.md` |
| 4 | Cohort analysis | `07_final_insights.sql` |
| 5 | Pricing rules | `07_final_insights.sql` |
| 6 | Auto EDA report | `02_eda.ipynb` + `generate_eda_charts.py` |
| 7 | Volume vs value | `04_business_analysis.sql`, `07_final_insights.sql` |
| 8 | Data contract | `future_scope.md` |
| 9 | Market share SQL | `07_final_insights.sql` |
| 10 | VIN case study | `05_business_insights.ipynb` |
| 11 | Dealer health score | `07_final_insights.sql` |
| 12 | Kafka streaming | `future_scope.md` |
| 13 | PE benchmark KPIs | `07_final_insights.sql` |
| 14 | Residual analysis | `04_price_prediction.ipynb` |
| 15 | Price elasticity | `05_window_functions.sql` |

## Machine Learning

| Concept | Location |
|---------|----------|
| Linear Regression | `train_model.py`, `04_price_prediction.ipynb` |
| Random Forest Regressor | `train_model.py`, `random_forest_model.pkl` |
| Train-test split | `preprocessing.py` |
| Encoding | `preprocessing.py` (OneHot + StandardScaler) |
| MAE / RMSE / R² | `model_metrics.json` |
| Feature importance | `feature_importance.csv` |
| Deal classifier (optional) | `deal_classifier_model.pkl` |
