#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

echo "==> Installing dependencies"
python3 -m pip install -r requirements.txt -q

echo "==> Cleaning data"
python3 python/scripts/cleaning.py

echo "==> SQLite database"
python3 python/scripts/setup_sqlite.py

echo "==> Excel analysis"
python3 python/scripts/build_excel_analysis.py

echo "==> Training ML models"
python3 python/scripts/train_model.py

echo "==> EDA charts"
python3 python/scripts/generate_eda_charts.py

echo "==> ML predictions for Power BI"
python3 python/scripts/export_ml_predictions.py

echo "==> Jupyter notebooks"
python3 python/scripts/create_notebooks.py

echo "==> Reports, PPTX, dashboard PDF, Power BI pbix"
python3 python/scripts/generate_deliverables.py

echo "Pipeline complete. Open powerbi/vehicle_sales_dashboard.pbix in Power BI Desktop."
