"""
Vehicle Sales Data Cleaning Pipeline
Covers Basic/Intermediate question bank: nulls, duplicates, dates, outliers, features.
"""

from __future__ import annotations

import re
from pathlib import Path

import numpy as np
import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parents[2]
RAW_PATH = PROJECT_ROOT / "dataset" / "raw" / "car_prices.csv"
CLEAN_PATH = PROJECT_ROOT / "dataset" / "cleaned" / "cleaned_vehicle_sales.csv"


def standardize_text(series: pd.Series) -> pd.Series:
    return series.astype(str).str.strip().str.lower().replace({"nan": np.nan, "none": np.nan})


def parse_saledate(series: pd.Series) -> pd.Series:
    """Robust parser for mixed date formats (Basic Q4, Intermediate Q15)."""
    cleaned = series.astype(str).str.strip()
    cleaned = cleaned.str.replace(
        r"^[A-Za-z]{3} \w{3} \d{2} \d{4}.*$",
        lambda m: re.sub(r"^[A-Za-z]{3} ", "", m.group(0)),
        regex=True,
    )
    parsed = pd.to_datetime(cleaned, errors="coerce", utc=True)
    fallback = pd.to_datetime(
        cleaned.str.extract(r"(\w{3} \d{1,2},? \d{4})")[0], errors="coerce", utc=True
    )
    return parsed.fillna(fallback).dt.tz_localize(None)


def remove_price_outliers(df: pd.DataFrame, column: str = "sellingprice") -> pd.DataFrame:
    q1, q3 = df[column].quantile(0.25), df[column].quantile(0.75)
    iqr = q3 - q1
    lower, upper = q1 - 1.5 * iqr, q3 + 1.5 * iqr
    business_lower, business_upper = 500, 250_000
    mask = (
        df[column].between(lower, upper)
        & df[column].between(business_lower, business_upper)
    )
    return df.loc[mask].copy()


def impute_condition(df: pd.DataFrame) -> pd.DataFrame:
    """Grouped median imputation by make + body (Intermediate Q2)."""
    df = df.copy()
    df["condition"] = pd.to_numeric(df["condition"], errors="coerce")
    grouped = df.groupby(["make", "body"], dropna=False)["condition"].transform("median")
    df["condition"] = df["condition"].fillna(grouped).fillna(df["condition"].median())
    return df


def add_engineered_features(df: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df["sale_year"] = df["saledate"].dt.year
    df["sale_month"] = df["saledate"].dt.month
    df["sale_quarter"] = df["saledate"].dt.quarter
    df["vehicle_age"] = (df["sale_year"] - df["year"]).clip(lower=0)
    invalid_age = df["vehicle_age"] < 0
    if invalid_age.any():
        df.loc[invalid_age, "vehicle_age"] = np.nan
        df["vehicle_age"] = df["vehicle_age"].fillna(0)

    df["price_vs_mmr"] = np.where(df["mmr"] > 0, df["sellingprice"] / df["mmr"], np.nan)
    df["mmr_premium_pct"] = (df["price_vs_mmr"] - 1) * 100
    df["deal_label"] = pd.cut(
        df["price_vs_mmr"],
        bins=[-np.inf, 0.95, 1.05, np.inf],
        labels=["Good Deal", "Fair Deal", "Overpriced"],
    )
    df["odometer_bin"] = pd.cut(
        df["odometer"],
        bins=[-1, 30000, 60000, 90000, np.inf],
        labels=["Low", "Mid", "High", "Very High"],
    )
    return df


def clean_vehicle_sales(
    raw_path: Path = RAW_PATH,
    output_path: Path = CLEAN_PATH,
) -> pd.DataFrame:
    df = pd.read_csv(raw_path, low_memory=False)

    df.columns = [c.strip().lower() for c in df.columns]
    text_cols = ["make", "model", "trim", "body", "transmission", "state", "color", "interior", "seller"]
    for col in text_cols:
        if col in df.columns:
            df[col] = standardize_text(df[col])

    df["saledate"] = parse_saledate(df["saledate"])
    for col in ["year", "condition", "odometer", "mmr", "sellingprice"]:
        df[col] = pd.to_numeric(df[col], errors="coerce")

    df = df.dropna(subset=["vin", "sellingprice", "mmr", "odometer", "year", "saledate"])
    df = df.drop_duplicates(subset=["vin"], keep="first")
    df = impute_condition(df)
    df = remove_price_outliers(df)
    df = add_engineered_features(df)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(output_path, index=False)
    return df


if __name__ == "__main__":
    cleaned = clean_vehicle_sales()
    print(f"Cleaned rows: {len(cleaned):,}")
    print(f"Saved to: {CLEAN_PATH}")
