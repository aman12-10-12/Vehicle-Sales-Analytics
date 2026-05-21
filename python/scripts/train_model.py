"""
Train Linear Regression + Random Forest Regressor + optional deal classifier.
"""

from __future__ import annotations

import json
from pathlib import Path

import joblib
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.linear_model import LinearRegression
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    mean_absolute_error,
    mean_squared_error,
    r2_score,
)
from sklearn.pipeline import Pipeline

from preprocessing import (
    FEATURE_COLUMNS,
    prepare_classification_data,
    prepare_regression_data,
)

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DATA_PATH = PROJECT_ROOT / "dataset" / "cleaned" / "cleaned_vehicle_sales.csv"
MODEL_DIR = Path(__file__).resolve().parents[1] / "models"
METRICS_PATH = MODEL_DIR / "model_metrics.json"


def evaluate_regression(name: str, y_true, y_pred) -> dict:
    return {
        "model": name,
        "mae": float(mean_absolute_error(y_true, y_pred)),
        "rmse": float(np.sqrt(mean_squared_error(y_true, y_pred))),
        "r2": float(r2_score(y_true, y_pred)),
    }


def train_models(sample_n: int | None = 80_000) -> dict:
    df = pd.read_csv(DATA_PATH, low_memory=False)
    if sample_n and len(df) > sample_n:
        df = df.sample(n=sample_n, random_state=42)

    X_train, X_test, y_train, y_test, preprocessor = prepare_regression_data(df)

    models = {
        "linear_regression": LinearRegression(),
        "random_forest_regressor": RandomForestRegressor(
            n_estimators=120,
            max_depth=18,
            min_samples_leaf=5,
            random_state=42,
            n_jobs=-1,
        ),
    }

    metrics = []
    fitted = {}
    for name, estimator in models.items():
        pipe = Pipeline([("prep", preprocessor), ("model", estimator)])
        pipe.fit(X_train, y_train)
        preds = pipe.predict(X_test)
        metrics.append(evaluate_regression(name, y_test, preds))
        fitted[name] = pipe

    MODEL_DIR.mkdir(parents=True, exist_ok=True)
    joblib.dump(fitted["random_forest_regressor"], MODEL_DIR / "random_forest_model.pkl")
    joblib.dump(fitted["linear_regression"], MODEL_DIR / "linear_regression_model.pkl")

    rf_model = fitted["random_forest_regressor"].named_steps["model"]
    prep = fitted["random_forest_regressor"].named_steps["prep"]
    feature_names = prep.get_feature_names_out()
    importances = pd.Series(rf_model.feature_importances_, index=feature_names)
    top_features = importances.sort_values(ascending=False).head(15)
    top_features.to_csv(MODEL_DIR / "feature_importance.csv")

    clf_metrics = {}
    try:
        Xc_train, Xc_test, yc_train, yc_test = prepare_classification_data(df)
        clf_pipe = Pipeline(
            [
                ("prep", preprocessor),
                (
                    "model",
                    RandomForestClassifier(
                        n_estimators=50,
                        max_depth=12,
                        max_samples=0.5,
                        class_weight="balanced",
                        random_state=42,
                        n_jobs=-1,
                    ),
                ),
            ]
        )
        clf_pipe.fit(Xc_train, yc_train)
        yc_pred = clf_pipe.predict(Xc_test)
        clf_metrics = {
            "accuracy": float(accuracy_score(yc_test, yc_pred)),
            "classification_report": classification_report(yc_test, yc_pred, output_dict=True),
        }
        joblib.dump(clf_pipe, MODEL_DIR / "deal_classifier_model.pkl")
        fitted["deal_classifier"] = clf_pipe
    except ValueError as exc:
        clf_metrics = {"error": str(exc)}

    result = {"regression": metrics, "classification": clf_metrics}
    METRICS_PATH.write_text(json.dumps(result, indent=2))
    return result


if __name__ == "__main__":
    out = train_models()
    print(json.dumps(out, indent=2))
