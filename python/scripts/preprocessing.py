"""
Feature engineering and encoding for ML (train/test split BEFORE transform).
"""

from __future__ import annotations

from typing import Tuple

import numpy as np
import pandas as pd
from sklearn.compose import ColumnTransformer
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder, StandardScaler


FEATURE_COLUMNS = [
    "year",
    "odometer",
    "condition",
    "vehicle_age",
    "mmr",
    "body",
    "transmission",
    "state",
    "make",
]

NUMERIC_FEATURES = ["year", "odometer", "condition", "vehicle_age", "mmr"]
CATEGORICAL_FEATURES = ["body", "transmission", "state", "make"]


def prepare_regression_data(
    df: pd.DataFrame,
    test_size: float = 0.2,
    random_state: int = 42,
) -> Tuple[pd.DataFrame, pd.DataFrame, pd.Series, pd.Series, ColumnTransformer]:
    data = df.dropna(subset=FEATURE_COLUMNS + ["sellingprice"]).copy()
    X = data[FEATURE_COLUMNS]
    y = data["sellingprice"]

    body_counts = data["body"].value_counts()
    stratify_col = data["body"].where(data["body"].map(body_counts) >= 2, other="other")
    X_train, X_test, y_train, y_test = train_test_split(
        X,
        y,
        test_size=test_size,
        random_state=random_state,
        stratify=stratify_col,
    )

    preprocessor = ColumnTransformer(
        transformers=[
            ("num", StandardScaler(), NUMERIC_FEATURES),
            (
                "cat",
                OneHotEncoder(handle_unknown="ignore", sparse_output=False),
                CATEGORICAL_FEATURES,
            ),
        ]
    )
    return X_train, X_test, y_train, y_test, preprocessor


def prepare_classification_data(
    df: pd.DataFrame,
    test_size: float = 0.2,
    random_state: int = 42,
) -> Tuple[pd.DataFrame, pd.DataFrame, pd.Series, pd.Series]:
    data = df.dropna(subset=FEATURE_COLUMNS + ["deal_label"]).copy()
    X = data[FEATURE_COLUMNS]
    y = data["deal_label"].astype(str)

    return train_test_split(
        X, y, test_size=test_size, random_state=random_state, stratify=y
    )
