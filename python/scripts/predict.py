"""Load trained model and predict selling price / deal quality."""

from __future__ import annotations

from pathlib import Path

import joblib
import pandas as pd

from preprocessing import FEATURE_COLUMNS

MODEL_DIR = Path(__file__).resolve().parents[1] / "models"


def load_model(name: str = "random_forest"):
    path = MODEL_DIR / (
        "random_forest_model.pkl"
        if name == "random_forest"
        else "linear_regression_model.pkl"
    )
    return joblib.load(path)


def predict_price(record: dict, model_name: str = "random_forest") -> float:
    model = load_model(model_name)
    frame = pd.DataFrame([{k: record.get(k) for k in FEATURE_COLUMNS}])
    return float(model.predict(frame)[0])


def predict_deal(record: dict) -> str:
    model = joblib.load(MODEL_DIR / "deal_classifier_model.pkl")
    frame = pd.DataFrame([{k: record.get(k) for k in FEATURE_COLUMNS}])
    return str(model.predict(frame)[0])
