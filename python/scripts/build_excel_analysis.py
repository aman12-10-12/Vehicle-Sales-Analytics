"""
Excel analysis workbook — pivot tables & cross-tabs (Advanced Q11).
Exports aggregated tables for Power BI / Excel dashboards.
"""

from pathlib import Path

import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DATA_PATH = PROJECT_ROOT / "dataset" / "cleaned" / "cleaned_vehicle_sales.csv"
EXCEL_DIR = PROJECT_ROOT / "excel"
POWERBI_DIR = PROJECT_ROOT / "powerbi"


def build_workbook(sample_n: int = 100_000) -> Path:
    EXCEL_DIR.mkdir(parents=True, exist_ok=True)
    POWERBI_DIR.mkdir(parents=True, exist_ok=True)

    df = pd.read_csv(DATA_PATH, low_memory=False)
    if len(df) > sample_n:
        df = df.sample(n=sample_n, random_state=42)

    price_matrix = pd.pivot_table(
        df,
        values="sellingprice",
        index="make",
        columns="body",
        aggfunc="mean",
    ).round(2)

    state_summary = (
        df.groupby("state")
        .agg(avg_price=("sellingprice", "mean"), volume=("vin", "count"), revenue=("sellingprice", "sum"))
        .round(2)
        .reset_index()
        .sort_values("revenue", ascending=False)
    )

    quarterly = (
        df.groupby(["sale_year", "sale_quarter"])
        .agg(avg_price=("sellingprice", "mean"), volume=("vin", "count"))
        .round(2)
        .reset_index()
    )

    deal_mix = df["deal_label"].value_counts(normalize=True).mul(100).round(2).reset_index()
    deal_mix.columns = ["deal_label", "pct"]

    out = EXCEL_DIR / "vehicle_sales_analysis.xlsx"
    with pd.ExcelWriter(out, engine="openpyxl") as writer:
        price_matrix.to_excel(writer, sheet_name="Make_Body_Price_Matrix")
        state_summary.to_excel(writer, sheet_name="State_Summary", index=False)
        quarterly.to_excel(writer, sheet_name="Quarterly_Trends", index=False)
        deal_mix.to_excel(writer, sheet_name="Deal_Mix", index=False)
        df.head(5000).to_excel(writer, sheet_name="Sample_Transactions", index=False)

    df.groupby(["make", "body", "state"]).agg(
        units=("vin", "count"),
        avg_price=("sellingprice", "mean"),
        revenue=("sellingprice", "sum"),
    ).reset_index().to_csv(POWERBI_DIR / "vehicle_sales_for_powerbi.csv", index=False)

    return out


if __name__ == "__main__":
    path = build_workbook()
    print(f"Excel workbook: {path}")
