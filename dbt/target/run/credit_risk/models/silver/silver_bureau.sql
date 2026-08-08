
  
    

  create  table "credit_risk"."silver"."silver_bureau__dbt_tmp"
  
  
    as
  
  (
    with bureau as (
    select
        "SK_ID_CURR"            as sk_id_curr,
        "SK_ID_BUREAU"          as sk_id_bureau,
        "CREDIT_ACTIVE"         as credit_active,
        "CREDIT_TYPE"           as credit_type,
        "DAYS_CREDIT"           as days_credit,
        "DAYS_CREDIT_ENDDATE"   as days_credit_enddate,
        "DAYS_ENDDATE_FACT"     as days_enddate_fact,
        "DAYS_CREDIT_UPDATE"    as days_credit_update,
        "AMT_CREDIT_SUM"        as amt_credit_sum,
        "AMT_CREDIT_SUM_DEBT"   as amt_credit_sum_debt,
        "AMT_CREDIT_SUM_OVERDUE" as amt_credit_sum_overdue,
        "AMT_CREDIT_MAX_OVERDUE" as amt_credit_max_overdue,
        "AMT_ANNUITY"           as amt_annuity
    from "credit_risk"."bronze"."bureau"
),

bb as (
    select * from "credit_risk"."silver"."silver_bureau_balance"
),

joined as (
    select
        b.*,
        bb.months_balance_min,
        bb.months_balance_max,
        bb.months_balance_mean,
        bb.months_balance_size,
        bb.status_0_mean,
        bb.status_1_mean,
        bb.status_12345_mean,
        bb.status_c_mean,
        bb.status_x_mean,

        -- derived
        b.amt_credit_sum - b.amt_credit_sum_debt                      as debt_credit_diff,
        b.amt_credit_sum / nullif(b.amt_credit_sum_debt, 0)           as debt_percentage,
        b.amt_credit_sum / nullif(b.amt_annuity, 0)                   as credit_to_annuity_ratio,
        (b.credit_active = 'Active')                                  as is_active,
        (b.credit_active = 'Closed')                                  as is_closed,
        (b.credit_type = 'Consumer credit')                           as is_consumer_credit

    from bureau b
    left join bb on b.sk_id_bureau = bb.sk_id_bureau
)

select * from joined
  );
  