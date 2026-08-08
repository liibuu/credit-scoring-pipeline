"""
Sync gold-layer tables from local Postgres to Neon (cloud).
Only gold tables are synced -- bronze/silver stay local (Neon free tier is too small for raw data).
Uses COPY via an in-memory buffer for speed (matters more here due to network latency to Neon).

Usage:
    python scripts/sync_gold_to_neon.py
"""
import io
import os

import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

load_dotenv()

GOLD_TABLES = [
    "gold_bureau_features",
    "gold_previous_application_features",
    "gold_installments_features",
    "gold_pos_cash_features",
    "gold_credit_card_features",
    "gold_applicant_features",
]


def create_table_schema(df: pd.DataFrame, neon_engine, table_name: str) -> None:
    """Create the (empty) table on Neon with matching column types."""
    df.head(0).to_sql(table_name, neon_engine, schema="gold", if_exists="replace", index=False)


def copy_df_into_neon(df: pd.DataFrame, neon_engine, table_name: str) -> None:
    """Bulk load via COPY FROM STDIN using an in-memory CSV buffer -- no per-row INSERT overhead."""
    buffer = io.StringIO()
    df.to_csv(buffer, index=False, header=False, na_rep="")
    buffer.seek(0)

    raw_conn = neon_engine.raw_connection()
    try:
        cur = raw_conn.cursor()
        cur.copy_expert(
            f'COPY gold."{table_name}" FROM STDIN WITH (FORMAT csv, NULL \'\')',
            buffer,
        )
        raw_conn.commit()
    finally:
        raw_conn.close()


def sync_table(local_engine, neon_engine, table_name: str) -> None:
    df = pd.read_sql(f'SELECT * FROM gold."{table_name}"', local_engine)
    create_table_schema(df, neon_engine, table_name)
    copy_df_into_neon(df, neon_engine, table_name)
    print(f"  OK   {table_name}: {len(df):,} rows synced")


def main():
    local_url = os.environ.get("LOCAL_DATABASE_URL")
    neon_url = os.environ.get("NEON_DATABASE_URL")
    if not local_url or not neon_url:
        raise RuntimeError("LOCAL_DATABASE_URL and NEON_DATABASE_URL must both be set in .env")

    local_engine = create_engine(local_url)
    neon_engine = create_engine(neon_url)

    with neon_engine.begin() as conn:
        conn.execute(text("CREATE SCHEMA IF NOT EXISTS gold"))

    print(f"Syncing {len(GOLD_TABLES)} gold tables to Neon...")
    for table in GOLD_TABLES:
        sync_table(local_engine, neon_engine, table)

    print("Done.")


if __name__ == "__main__":
    main()