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

pos as (
    select * from {{ ref('gold_pos_cash_features') }}
),

cc as (
    select * from {{ ref('gold_credit_card_features') }}
),

joined as (
    select
        app.*,
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

        pos.pos_loan_count,
        pos.pos_sk_dpd_max,
        pos.pos_sk_dpd_mean,
        pos.pos_late_payment_mean,
        pos.pos_loan_completed_mean,
        pos.pos_remaining_instalments_ratio_mean,

        cc.cc_amt_balance_mean,
        cc.cc_amt_balance_max,
        cc.cc_limit_use_mean,
        cc.cc_limit_use_max,
        cc.cc_late_payment_sum,
        cc.cc_payment_div_min_mean,
        cc.cc_drawing_limit_ratio_mean,

        -- cross-table ratios (need current application's own amt_annuity)
        prev.approved_amt_annuity_max / nullif(app.amt_annuity, 0)  as current_to_approved_annuity_max_ratio,
        prev.approved_amt_annuity_mean / nullif(app.amt_annuity, 0) as current_to_approved_annuity_mean_ratio

    from app
    left join bureau on app.sk_id_curr = bureau.sk_id_curr
    left join prev   on app.sk_id_curr = prev.sk_id_curr
    left join ins    on app.sk_id_curr = ins.sk_id_curr
    left join pos    on app.sk_id_curr = pos.sk_id_curr
    left join cc     on app.sk_id_curr = cc.sk_id_curr
)

select * from joined