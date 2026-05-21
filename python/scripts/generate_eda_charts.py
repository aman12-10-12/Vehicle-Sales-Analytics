"""Generate EDA chart PNGs for visuals/eda_charts."""

from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DATA_PATH = PROJECT_ROOT / "dataset" / "cleaned" / "cleaned_vehicle_sales.csv"
OUT_DIR = PROJECT_ROOT / "visuals" / "eda_charts"


def main(sample_n: int = 50_000) -> None:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    df = pd.read_csv(DATA_PATH, low_memory=False)
    if len(df) > sample_n:
        df = df.sample(n=sample_n, random_state=42)

    sns.set_theme(style="whitegrid")

    plt.figure(figsize=(10, 6))
    sns.histplot(df["sellingprice"], bins=60, kde=True)
    plt.title("Selling Price Distribution")
    plt.xlabel("Selling Price ($)")
    plt.tight_layout()
    plt.savefig(OUT_DIR / "price_distribution.png", dpi=150)
    plt.close()

    plt.figure(figsize=(10, 6))
    sns.scatterplot(data=df, x="odometer", y="sellingprice", alpha=0.25, s=10)
    plt.title("Mileage vs Selling Price")
    plt.tight_layout()
    plt.savefig(OUT_DIR / "mileage_vs_price.png", dpi=150)
    plt.close()

    numeric = df[["year", "odometer", "condition", "vehicle_age", "mmr", "sellingprice"]].corr()
    plt.figure(figsize=(8, 6))
    sns.heatmap(numeric, annot=True, fmt=".2f", cmap="coolwarm")
    plt.title("Correlation Heatmap")
    plt.tight_layout()
    plt.savefig(OUT_DIR / "correlation_heatmap.png", dpi=150)
    plt.close()

    top_makes = df["make"].value_counts().head(5).index
    dep = (
        df[df["make"].isin(top_makes)]
        .groupby(["make", "vehicle_age"])["sellingprice"]
        .median()
        .reset_index()
    )
    plt.figure(figsize=(10, 6))
    for make in top_makes:
        sub = dep[dep["make"] == make]
        plt.plot(sub["vehicle_age"], sub["sellingprice"], marker="o", label=make)
    plt.title("Depreciation Curve (Median Price vs Vehicle Age)")
    plt.xlabel("Vehicle Age (years)")
    plt.ylabel("Median Selling Price ($)")
    plt.legend()
    plt.tight_layout()
    plt.savefig(OUT_DIR / "depreciation_curve.png", dpi=150)
    plt.close()


if __name__ == "__main__":
    main()
