# credit-scoring-pipeline

## Setup
```bash
python -m venv venv
source /d/credit-scoring-pipeline/venv/Scripts/activate
pip freeze > requirements.txt
```

## Download Kaggle data
```bash
python scripts/download_data.py
```

## Start local Postgres 
```bash
docker compose up -d
```

# Load bronze
```bash
python scripts/load_bronze.py

docker exec -it credit-risk-postgres psql -U postgres -d credit_risk -c "\dt bronze.*"
docker exec -it credit-risk-postgres psql -U postgres -d credit_risk -c "SELECT count(*) FROM bronze.application_train;"
docker exec -it credit-risk-postgres psql -U postgres -d credit_risk -c "SELECT count(*) FROM bronze.application_test;"
docker exec -it credit-risk-postgres psql -U postgres -d credit_risk -c "SELECT count(*) FROM bronze.bureau;"
docker exec -it credit-risk-postgres psql -U postgres -d credit_risk -c "SELECT count(*) FROM bronze.bureau_balance;"
docker exec -it credit-risk-postgres psql -U postgres -d credit_risk -c "SELECT count(*) FROM bronze.previous_application;"
docker exec -it credit-risk-postgres psql -U postgres -d credit_risk -c "SELECT count(*) FROM bronze.installments_payments;"
docker exec -it credit-risk-postgres psql -U postgres -d credit_risk -c 'SELECT count(*) FROM bronze."POS_CASH_balance";'
docker exec -it credit-risk-postgres psql -U postgres -d credit_risk -c "SELECT count(*) FROM bronze.credit_card_balance;"
```

## Set up profiles.yml
```bash
mkdir -p ~/.dbt
cp dbt/profiles.yml.example ~/.dbt/profiles.yml
```

## Sanity check the connection
```bash
cd dbt
dbt debug
```

# Run dbt
```bash
dbt run
```

# Check results
```bash
dbt test    # if you add tests later
psql postgresql://postgres:postgres@localhost:5432/credit_risk -c "select count(*) from gold.gold_applicant_features;"
```

## Bronze (local Postgres, Docker)
**Input**: Raw Kaggle CSVs in ./data/ (minus bureau_balance, per scope trim)
**Output**: bronze.* tables in local Postgres — 1:1 mirror of CSVs, no transformation
**Flow**: 
1. Load .env → connect to local Postgres
2. Create bronze schema 
3. For each CSV: 
    - Read with pandas (downcast dtypes)
    - to_sql() into bronze.<table_name>

## Silver (local Postgres, via dbt)
**Input**: bronze.* tables
**Output**: silver.* tables — cleaned, typed, deduplicated, one model per source table (e.g. silver.application, silver.bureau, silver.previous_application)
**Flow**: 
1. dbt models run SQL against bronze
2. Cast types properly, handle nulls/outliers, rename columns to consistent convention
3. Materialize as tables/views in silver schema

## Gold (local Postgres → then pushed/synced to Neon)

**Input**: silver.* tables
**Output**: gold.applicant_features — one row per SK_ID_CURR, all silver tables joined and aggregated to applicant grain (this is the training + serving feature table)
**Flow**: 
1. dbt model joins silver.application with aggregated features from silver.bureau, silver.previous_application (e.g. counts, sums, ratios per applicant) → one wide table
2. This table (only, not bronze/silver) gets loaded into Neon for anything cloud-facing (training script, later the API)

## Reasoning about keeping a subset of tables
As I don't have money to buy storage in Neon for a learning project -> I decided to push Gold layer only to serve with API.
Also, I keep only top several source tables with most gain [7th place solution feature importance](https://www.kaggle.com/code/jsaguiar/lightgbm-7th-place-solution/output)






## Material
Cloud sync step (new, not a dbt layer):

Input: gold.applicant_features from local Postgres
Output: same table in Neon
Flow: small script or pg_dump/pg_restore on just that table, or pandas read-local → write-to-Neon, run manually whenever gold is rebuilt

5. Log row counts per table so you can sanity-check nothing silently failed.