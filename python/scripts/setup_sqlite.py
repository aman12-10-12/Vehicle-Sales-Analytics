"""Load cleaned CSV into SQLite for local SQL execution without MySQL."""

import sqlite3
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).resolve().parents[2]
DB = ROOT / "vehicle_sales.db"
CSV = ROOT / "dataset" / "cleaned" / "cleaned_vehicle_sales.csv"


def main() -> None:
    df = pd.read_csv(CSV, low_memory=False)
    conn = sqlite3.connect(DB)
    df.to_sql("vehicle_sales", conn, if_exists="replace", index=False)
    df.to_sql("raw_vehicle_sales", conn, if_exists="replace", index=False)
    conn.close()
    print(f"SQLite DB created: {DB}")


if __name__ == "__main__":
    main()
