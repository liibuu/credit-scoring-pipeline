with app as (
    select * from {{ ref('silver_application') }}
),

bureau as (
    select * from {{ ref('gold_bureau_features') }}
),

prev as (
    select * from {{ ref('gold_previous_application_features') }}
),

ins as (
    select * from {{ ref('gold_installments_features') }}
),

joined as (
    select
        app.sk_id_curr,
        app.target,
        app.is_train,
        app.code_gender,
        app.organization_type,
        app.occupation_type,
        app.name_education_type,
        app.days_birth,
        app.days_employed,
        app.days_id_publish,
        app.days_registration,
        app.days_last_phone_change,
        app.amt_credit,
        app.amt_annuity,
        app.amt_goods_price,
        app.amt_income_total,
        app.ext_source_1,
        app.ext_source_2,
        app.ext_source_3,
        app.ext_sources_mean,
        app.ext_sources_min,
        app.ext_sources_max,
        app.ext_sources_prod,
        app.ext_sources_weighted,
        app.credit_to_annuity_ratio,
        app.credit_to_goods_ratio,
        app.annuity_to_income_ratio,
        app.income_to_employed_ratio,
        app.employed_to_birth_ratio,
        app.phone_to_birth_ratio,

        bureau.bureau_debt_credit_diff_mean,
        bureau.bureau_debt_over_credit,
        bureau.bureau_active_debt_credit_diff_mean,
        bureau.bureau_active_debt_percentage_mean,
        bureau.bureau_active_days_credit_max,
        bureau.bureau_active_debt_over_credit,
        bureau.bureau_closed_days_credit_update_max,
        bureau.bureau_consumer_days_credit_enddate_max,
        bureau.bureau_last12m_debt_percentage_mean,
        bureau.bureau_last12m_debt_credit_diff_mean,

        prev.prev_name_contract_status_refused_mean,
        prev.prev_cash_simple_interests_mean,
        prev.prev_cash_simple_interests_max,
        prev.prev_last24m_simple_interests_max,
        prev.prev_last24m_days_last_due_1st_version_mean,
        prev.prev_last24m_days_last_due_1st_version_max,
        prev.approved_amt_annuity_mean,
        prev.approved_amt_annuity_max,
        prev.prev_days_termination_max,

        ins.ins_significant_late_payment_sum,
        ins.ins_36m_dpd_7_mean,
        ins.last_loan_late_payment_mean,
        ins.last_loan_dpd_mean,
        ins.last_loan_dpd_std,

        -- cross-table ratios (need current application's own amt_annuity)
        prev.approved_amt_annuity_max / nullif(app.amt_annuity, 0)  as current_to_approved_annuity_max_ratio,
        prev.approved_amt_annuity_mean / nullif(app.amt_annuity, 0) as current_to_approved_annuity_mean_ratio

    from app
    left join bureau on app.sk_id_curr = bureau.sk_id_curr
    left join prev   on app.sk_id_curr = prev.sk_id_curr
    left join ins    on app.sk_id_curr = ins.sk_id_curr
)

select * from joined