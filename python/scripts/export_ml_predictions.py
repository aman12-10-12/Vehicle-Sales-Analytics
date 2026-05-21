"""Export ML predictions for Power BI ML Insights page."""

from pathlib import Path

import joblib
import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
DATA = ROOT / "dataset" / "cleaned" / "cleaned_vehicle_sales.csv"
OUT = ROOT / "powerbi" / "ml_predictions.csv"
MODEL = Path(__file__).resolve().parents[1] / "models" / "random_forest_model.pkl"


def main(sample_n: int = 20_000) -> None:
    df = pd.read_csv(DATA, low_memory=False)
    if len(df) > sample_n:
        df = df.sample(n=sample_n, random_state=42)

    from preprocessing import FEATURE_COLUMNS

    model = joblib.load(MODEL)
    preds = model.predict(df[FEATURE_COLUMNS])
    export = df[["vin", "make", "model", "sellingprice", "mmr", "deal_label"]].copy()
    export["predicted_price"] = preds.round(2)
    export["prediction_error"] = (export["sellingprice"] - export["predicted_price"]).round(2)
    export.to_csv(OUT, index=False)
    print(f"Saved {len(export):,} rows to {OUT}")


if __name__ == "__main__":
    main()
