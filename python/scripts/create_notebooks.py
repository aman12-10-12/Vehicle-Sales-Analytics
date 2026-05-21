"""Generate project Jupyter notebooks from templates."""

import json
from pathlib import Path

NOTEBOOK_DIR = Path(__file__).resolve().parents[1] / "notebooks"

NOTEBOOKS = {
    "01_data_cleaning.ipynb": [
        ("markdown", "# 01 — Data Cleaning\nAnswers Basic Q1–Q5, Intermediate Q1–Q3, Q15."),
        (
            "code",
            "import pandas as pd\nfrom pathlib import Path\n\nROOT = Path('../../')\nRAW = ROOT / 'dataset/raw/car_prices.csv'\nCLEAN = ROOT / 'dataset/cleaned/cleaned_vehicle_sales.csv'\nraw = pd.read_csv(RAW, nrows=200000, low_memory=False)\nprint('Shape:', raw.shape)\nprint(raw.isnull().sum().sort_values(ascending=False).head(10))",
        ),
        (
            "code",
            "import sys\nsys.path.append('../scripts')\nfrom cleaning import clean_vehicle_sales\n\ncleaned = clean_vehicle_sales()\ncleaned.head()",
        ),
        (
            "code",
            "# Q3 duplicate VINs\nraw['vin'].duplicated().sum()",
        ),
        (
            "code",
            "# Q4 saledate parsing\npd.to_datetime(raw['saledate'].head(), errors='coerce')",
        ),
    ],
    "02_eda.ipynb": [
        ("markdown", "# 02 — Exploratory Data Analysis\nBasic Q14–Q15, Intermediate Q10–Q14, Advanced Q8–Q10, Q14."),
        (
            "code",
            "import pandas as pd\nimport matplotlib.pyplot as plt\nimport seaborn as sns\nfrom pathlib import Path\n\nROOT = Path('../../')\ndf = pd.read_csv(ROOT / 'dataset/cleaned/cleaned_vehicle_sales.csv', nrows=80000)\nsns.histplot(df['sellingprice'], bins=50, kde=True)\nplt.title('Price Distribution'); plt.show()",
        ),
        (
            "code",
            "sns.scatterplot(data=df.sample(5000), x='odometer', y='sellingprice', alpha=0.3)\nplt.title('Odometer vs Price'); plt.show()",
        ),
        (
            "code",
            "numeric = df[['year','odometer','condition','vehicle_age','mmr','sellingprice']].corr()\nsns.heatmap(numeric, annot=True, fmt='.2f'); plt.show()",
        ),
        (
            "code",
            "top = df['make'].value_counts().head(8).index\nsns.boxplot(data=df[df['make'].isin(top)], x='make', y='sellingprice')\nplt.xticks(rotation=45); plt.show()",
        ),
    ],
    "03_feature_engineering.ipynb": [
        ("markdown", "# 03 — Feature Engineering\nvehicle_age, deal_label, odometer_bin, encoding prep."),
        (
            "code",
            "import pandas as pd\nfrom pathlib import Path\ndf = pd.read_csv('../../dataset/cleaned/cleaned_vehicle_sales.csv', nrows=100000)\ndf[['vehicle_age','price_vs_mmr','deal_label','odometer_bin']].head()",
        ),
        (
            "code",
            "df.groupby(['body','odometer_bin'])['sellingprice'].mean().unstack().round(2)",
        ),
    ],
    "04_price_prediction.ipynb": [
        ("markdown", "# 04 — Price Prediction (ML)\nLinear Regression + Random Forest Regressor + metrics."),
        (
            "code",
            "import json\nfrom pathlib import Path\nimport joblib\nimport pandas as pd\nfrom sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score\nimport numpy as np\n\nmetrics = json.loads(Path('../models/model_metrics.json').read_text())\nmetrics",
        ),
        (
            "code",
            "model = joblib.load('../models/random_forest_model.pkl')\nfi = pd.read_csv('../models/feature_importance.csv', header=None, names=['feature','importance'])\nfi.sort_values('importance', ascending=False).head(10)",
        ),
        (
            "code",
            "# Residual analysis (Master Q14)\nfrom preprocessing import prepare_regression_data\ndf = pd.read_csv('../../dataset/cleaned/cleaned_vehicle_sales.csv', nrows=50000)\nX_train, X_test, y_train, y_test, prep = prepare_regression_data(df)\nimport sys; sys.path.append('../scripts')\npipe = joblib.load('../models/random_forest_model.pkl')\npreds = pipe.predict(X_test)\nimport matplotlib.pyplot as plt\nresiduals = y_test - preds\nplt.scatter(preds, residuals, alpha=0.2)\nplt.axhline(0, color='red')\nplt.xlabel('Predicted'); plt.ylabel('Residual'); plt.show()",
        ),
    ],
    "05_business_insights.ipynb": [
        ("markdown", "# 05 — Business Insights\nRevenue, MMR premium, seasonal & seller scorecards."),
        (
            "code",
            "import pandas as pd\ndf = pd.read_csv('../../dataset/cleaned/cleaned_vehicle_sales.csv', nrows=150000)\n(df.groupby('make')['sellingprice'].sum().sort_values(ascending=False).head(10) / 1e6).round(2)",
        ),
        (
            "code",
            "df.groupby('sale_quarter')['sellingprice'].mean().round(2)",
        ),
        (
            "code",
            "underpriced = df[df['sellingprice'] < 0.9 * df['mmr']]\nprint('Units:', len(underpriced))\nprint('Potential profit @ MMR:', (underpriced['mmr'] - underpriced['sellingprice']).sum())",
        ),
    ],
}


def make_notebook(cells):
    nb = {
        "nbformat": 4,
        "nbformat_minor": 5,
        "metadata": {"kernelspec": {"display_name": "Python 3", "language": "python", "name": "python3"}},
        "cells": [],
    }
    for cell_type, source in cells:
        nb["cells"].append(
            {
                "cell_type": cell_type,
                "metadata": {},
                "source": source.splitlines(keepends=True),
                "outputs": [],
                "execution_count": None,
            }
        )
    return nb


def main():
    NOTEBOOK_DIR.mkdir(parents=True, exist_ok=True)
    for name, cells in NOTEBOOKS.items():
        path = NOTEBOOK_DIR / name
        path.write_text(json.dumps(make_notebook(cells), indent=1))
        print(f"Created {path}")


if __name__ == "__main__":
    main()
