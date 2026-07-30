"""
Load raw Home Credit CSVs into the `bronze` schema of local Postgres.
Only loads the tables in scope: application_train/test, bureau, bureau_balance,
previous_application, installments_payments.

Usage:
    python scripts/load_bronze.py
"""
import os
from pathlib import Path

import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

DATA_DIR = Path("./data")
CHUNK_SIZE = 10_000

TABLES = [
    "application_train",
    "application_test",
    "bureau",
    "bureau_balance",
    "previous_application",
    "installments_payments",
]


def downcast_dtypes(df: pd.DataFrame) -> pd.DataFrame:
    """Shrink int64/float64 columns to smaller types where safe. Reduces load size/time."""
    for col in df.select_dtypes(include=["int64"]).columns:
        df[col] = pd.to_numeric(df[col], downcast="integer")
    for col in df.select_dtypes(include=["float64"]).columns:
        df[col] = pd.to_numeric(df[col], downcast="float")
    return df


def load_table(engine, table_name: str) -> None:
    csv_path = DATA_DIR / f"{table_name}.csv"
    if not csv_path.exists():
        print(f"  SKIP {table_name}: {csv_path} not found")
        return

    df = pd.read_csv(csv_path)
    df = downcast_dtypes(df)

    df.to_sql(
        table_name,
        engine,
        schema="bronze",
        if_exists="replace",
        index=False,
        chunksize=CHUNK_SIZE,
        method="multi",
    )
    print(f"  OK   {table_name}: {len(df):,} rows, {len(df.columns)} cols")


def main():
    db_url = os.environ.get("LOCAL_DATABASE_URL")
    if not db_url:
        raise RuntimeError("LOCAL_DATABASE_URL not set in .env")

    engine = create_engine(db_url)

    with engine.begin() as conn:
        conn.execute(text("CREATE SCHEMA IF NOT EXISTS bronze"))

    print(f"Loading {len(TABLES)} tables into bronze schema...")
    for table in TABLES:
        load_table(engine, table)

    print("Done.")


if __name__ == "__main__":
    main()