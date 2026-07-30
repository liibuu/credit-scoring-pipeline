# dbt

## Visualization
![dbt models](../docs/dbt_models.png)

## Project structure
```text
/dbt/
├── dbt_project.yml
├── profiles.yml
├── macros/
│   └── get_custom_schema.sql
└── models/
    ├── sources.yml
    ├── silver/
    │   ├── silver_application.sql
    │   ├── silver_bureau_balance.sql
    │   ├── silver_bureau.sql
    │   ├── silver_previous_application.sql
    │   └── silver_installments_payments.sql
    └── gold/
        ├── gold_bureau_features.sql
        ├── gold_previous_application_features.sql
        ├── gold_installments_features.sql
        └── gold_applicant_features.sql             ← final training/serving table
```

## List of features
|	Source	|	Feature name	|
|	-----	|	------------	|
|	app	|	sk_id_curr	|
|	app	|	target	|
|	app	|	is_train	|
|	app	|	code_gender	|
|	app	|	organization_type	|
|	app	|	occupation_type	|
|	app	|	name_education_type	|
|	app	|	days_birth	|
|	app	|	days_employed	|
|	app	|	days_id_publish	|
|	app	|	days_registration	|
|	app	|	days_last_phone_change	|
|	app	|	amt_credit	|
|	app	|	amt_annuity	|
|	app	|	amt_goods_price	|
|	app	|	amt_income_total	|
|	app	|	ext_source_1	|
|	app	|	ext_source_2	|
|	app	|	ext_source_3	|
|	app	|	ext_sources_mean	|
|	app	|	ext_sources_min	|
|	app	|	ext_sources_max	|
|	app	|	ext_sources_prod	|
|	app	|	ext_sources_weighted	|
|	app	|	credit_to_annuity_ratio	|
|	app	|	credit_to_goods_ratio	|
|	app	|	annuity_to_income_ratio	|
|	app	|	income_to_employed_ratio	|
|	app	|	employed_to_birth_ratio	|
|	app	|	phone_to_birth_ratio	|
|	prev	|	prev_name_contract_status_refused_mean	|
|	prev	|	prev_cash_simple_interests_mean	|
|	prev	|	prev_cash_simple_interests_max	|
|	prev	|	prev_last24m_simple_interests_max	|
|	prev	|	prev_last24m_days_last_due_1st_version_mean	|
|	prev	|	prev_last24m_days_last_due_1st_version_max	|
|	prev	|	approved_amt_annuity_mean	|
|	prev	|	approved_amt_annuity_max	|
|	prev	|	prev_days_termination_max	|
|	prev	|	current_to_approved_annuity_max_ratio	|
|	prev	|	current_to_approved_annuity_mean_ratio	|
|	bureau	|	bureau_debt_credit_diff_mean	|
|	bureau	|	bureau_debt_over_credit	|
|	bureau	|	bureau_active_debt_credit_diff_mean	|
|	bureau	|	bureau_active_debt_percentage_mean	|
|	bureau	|	bureau_active_days_credit_max	|
|	bureau	|	bureau_active_debt_over_credit	|
|	bureau	|	bureau_closed_days_credit_update_max	|
|	bureau	|	bureau_consumer_days_credit_enddate_max	|
|	bureau	|	bureau_last12m_debt_percentage_mean	|
|	bureau	|	bureau_last12m_debt_credit_diff_mean	|
|	ins	|	ins_significant_late_payment_sum	|
|	ins	|	ins_36m_dpd_7_mean	|
|	ins	|	last_loan_late_payment_mean	|
|	ins	|	last_loan_dpd_mean	|
|	ins	|	last_loan_dpd_std	|
