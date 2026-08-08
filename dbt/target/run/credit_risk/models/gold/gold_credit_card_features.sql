
  
    

  create  table "credit_risk"."gold"."gold_credit_card_features__dbt_tmp"
  
  
    as
  
  (
    with loans as (
    select * from "credit_risk"."silver"."silver_credit_card_balance"
),

agg as (
    select
        sk_id_curr,
        count(*)                                                as cc_loan_count,
        avg(amt_balance_mean)                                   as cc_amt_balance_mean,
        max(amt_balance_max)                                    as cc_amt_balance_max,
        avg(limit_use_mean)                                     as cc_limit_use_mean,
        max(limit_use_max)                                      as cc_limit_use_max,
        sum(late_payment_sum)                                   as cc_late_payment_sum,
        avg(payment_div_min_mean)                               as cc_payment_div_min_mean,
        avg(drawing_limit_ratio_mean)                           as cc_drawing_limit_ratio_mean
    from loans
    group by sk_id_curr
)

select * from agg
  );
  