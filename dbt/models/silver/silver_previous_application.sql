with prev as (
    select
        "SK_ID_CURR"                  as sk_id_curr,
        "SK_ID_PREV"                  as sk_id_prev,
        "NAME_CONTRACT_STATUS"        as name_contract_status,
        "NAME_CONTRACT_TYPE"          as name_contract_type,
        "DAYS_DECISION"               as days_decision,
        case when "DAYS_TERMINATION" = 365243 then null else "DAYS_TERMINATION" end as days_termination,
        case when "DAYS_LAST_DUE_1ST_VERSION" = 365243 then null else "DAYS_LAST_DUE_1ST_VERSION" end as days_last_due_1st_version,
        "AMT_APPLICATION"             as amt_application,
        "AMT_CREDIT"                  as amt_credit,
        "AMT_ANNUITY"                 as amt_annuity,
        "CNT_PAYMENT"                 as cnt_payment
    from {{ source('bronze', 'previous_application') }}
),

final as (
    select
        *,
        amt_application - amt_credit                                  as application_credit_diff,
        amt_application / nullif(amt_credit, 0)                       as application_credit_ratio,
        amt_credit / nullif(amt_annuity, 0)                           as credit_to_annuity_ratio,
        (amt_annuity * cnt_payment / nullif(amt_credit, 0) - 1)
            / nullif(cnt_payment, 0)                                  as simple_interests,
        (name_contract_status = 'Approved')                           as is_approved,
        (name_contract_status = 'Refused')                            as is_refused,
        (name_contract_type = 'Cash loans')                           as is_cash_loan,
        (name_contract_type = 'Consumer loans')                       as is_consumer_loan
    from prev
)

select * from final