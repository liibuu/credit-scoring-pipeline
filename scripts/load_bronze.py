"""
Load raw Kaggle CSVs into the `bronze` schema of local Postgres.
Uses Postgres COPY (alternative for pandas to_sql) for bulk load speed.

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
SCHEMA_SAMPLE_ROWS = 5000

TABLES = [
    "application_train",
    "application_test",
    "bureau",
    "bureau_balance",
    "previous_application",
    "installments_payments",
    "POS_CASH_balance",
    "credit_card_balance",
]


def create_table_from_sample(engine, table_name: str, csv_path: Path) -> None:
    """Infer column types from a small sample and create the (empty) table."""
    sample = pd.read_csv(csv_path, nrows=SCHEMA_SAMPLE_ROWS)
    sample.to_sql(table_name, engine, schema="bronze", if_exists="replace", index=False)
    with engine.begin() as conn:
        conn.execute(text(f'TRUNCATE TABLE bronze."{table_name}"'))


def copy_csv_into_table(engine, table_name: str, csv_path: Path) -> None:
    """Bulk load the full CSV via COPY -- much faster than row-by-row INSERT."""
    raw_conn = engine.raw_connection()
    try:
        cur = raw_conn.cursor()
        with open(csv_path, "r", encoding="utf-8") as f:
            cur.copy_expert(
                f'COPY bronze."{table_name}" FROM STDIN WITH (FORMAT csv, HEADER true, NULL \'\')',
                f,
            )
        raw_conn.commit()
    finally:
        raw_conn.close()


def load_table(engine, table_name: str) -> None:
    csv_path = DATA_DIR / f"{table_name}.csv"
    if not csv_path.exists():
        print(f"  SKIP {table_name}: {csv_path} not found")
        return

    create_table_from_sample(engine, table_name, csv_path)
    copy_csv_into_table(engine, table_name, csv_path)

    with engine.begin() as conn:
        count = conn.execute(text(f'SELECT COUNT(*) FROM bronze."{table_name}"')).scalar()
    print(f"  OK   {table_name}: {count:,} rows loaded")


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