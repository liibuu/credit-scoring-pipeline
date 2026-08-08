
  
    

  create  table "credit_risk"."gold"."gold_pos_cash_features__dbt_tmp"
  
  
    as
  
  (
    with loans as (
    select * from "credit_risk"."silver"."silver_pos_cash_balance"
),

agg as (
    select
        sk_id_curr,
        count(*)                                                as pos_loan_count,
        max(sk_dpd_max)                                         as pos_sk_dpd_max,
        avg(sk_dpd_mean)                                        as pos_sk_dpd_mean,
        avg(late_payment_rate)                                  as pos_late_payment_mean,
        avg(is_completed)                                       as pos_loan_completed_mean,
        avg(remaining_instalments_ratio)                        as pos_remaining_instalments_ratio_mean
    from loans
    group by sk_id_curr
)

select * from agg
  );
  