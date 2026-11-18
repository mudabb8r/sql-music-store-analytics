"""Run every .sql file in sql/ against the Chinook database and save each result as a CSV in outputs/.

Usage:  python run_queries.py
"""
import sqlite3
from pathlib import Path

import pandas as pd

ROOT = Path(__file__).parent
DB_PATH = ROOT / "data" / "chinook.sqlite"
SQL_DIR = ROOT / "sql"
OUT_DIR = ROOT / "outputs"


def run_all() -> dict[str, pd.DataFrame]:
    OUT_DIR.mkdir(exist_ok=True)
    results = {}
    with sqlite3.connect(DB_PATH) as conn:
        for sql_file in sorted(SQL_DIR.glob("*.sql")):
            query = sql_file.read_text()
            df = pd.read_sql_query(query, conn)
            df.to_csv(OUT_DIR / f"{sql_file.stem}.csv", index=False)
            results[sql_file.stem] = df
            print(f"{sql_file.name:32s} -> {len(df):3d} rows")
    return results


if __name__ == "__main__":
    results = run_all()
    print("\nKPIs:")
    print(results["01_kpis"].to_string(index=False))
