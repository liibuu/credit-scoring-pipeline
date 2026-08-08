
  
    

  create  table "credit_risk"."silver"."silver_credit_card_balance__dbt_tmp"
  
  
    as
  
  (
    with cc as (
    select
        "SK_ID_CURR"                    as sk_id_curr,
        "SK_ID_PREV"                    as sk_id_prev,
        "MONTHS_BALANCE"                as months_balance,
        "AMT_BALANCE"                   as amt_balance,
        "AMT_CREDIT_LIMIT_ACTUAL"       as amt_credit_limit_actual,
        "AMT_DRAWINGS_ATM_CURRENT"      as amt_drawings_atm_current,
        "AMT_INST_MIN_REGULARITY"       as amt_inst_min_regularity,
        "AMT_PAYMENT_CURRENT"           as amt_payment_current,
        "SK_DPD"                        as sk_dpd
    from "credit_risk"."bronze"."credit_card_balance"
),

cleaned as (
    select
        *,
        amt_balance / nullif(amt_credit_limit_actual, 0)              as limit_use,
        amt_payment_current / nullif(amt_inst_min_regularity, 0)      as payment_div_min,
        amt_drawings_atm_current / nullif(amt_credit_limit_actual, 0) as drawing_limit_ratio,
        case when sk_dpd > 0 then 1 else 0 end                        as late_payment
    from cc
),

-- rolled up to loan (SK_ID_PREV) grain
agg as (
    select
        sk_id_prev,
        max(sk_id_curr)                                         as sk_id_curr,  -- constant per loan
        avg(amt_balance)                                        as amt_balance_mean,
        max(amt_balance)                                        as amt_balance_max,
        avg(limit_use)                                          as limit_use_mean,
        max(limit_use)                                          as limit_use_max,
        sum(late_payment)                                       as late_payment_sum,
        avg(payment_div_min)                                    as payment_div_min_mean,
        avg(drawing_limit_ratio)                                as drawing_limit_ratio_mean
    from cleaned
    group by sk_id_prev
)

select * from agg
  );
  