
  
    

  create  table "credit_risk"."gold"."gold_installments_features__dbt_tmp"
  
  
    as
  
  (
    with pay as (
    select * from "credit_risk"."silver"."silver_installments_payments"
),

overall as (
    select
        sk_id_curr,
        sum(significant_late_payment)                          as ins_significant_late_payment_sum,
        avg(payment_ratio)                                     as payment_mean_to_annuity_ratio_helper -- joined to annuity later
    from pay
    group by sk_id_curr
),

last_36m as (
    select
        sk_id_curr,
        avg(dpd_7)                                              as ins_36m_dpd_7_mean
    from pay
    where days_instalment >= -1080
    group by sk_id_curr
),

most_recent_prev as (
    -- one row per SK_ID_CURR: which SK_ID_PREV is their most recent loan
    select distinct on (sk_id_curr)
        sk_id_curr,
        sk_id_prev as last_sk_id_prev
    from pay
    order by sk_id_curr, days_instalment desc
),

last_loan as (
    select
        m.sk_id_curr,
        avg(case when p.is_late_payment then 1.0 else 0.0 end) as last_loan_late_payment_mean,
        avg(p.dpd)                                             as last_loan_dpd_mean,
        stddev(p.dpd)                                          as last_loan_dpd_std
    from most_recent_prev m
    join pay p
        on p.sk_id_curr = m.sk_id_curr
       and p.sk_id_prev = m.last_sk_id_prev
    group by m.sk_id_curr
)

select
    o.sk_id_curr,
    o.ins_significant_late_payment_sum,
    l36.ins_36m_dpd_7_mean,
    ll.last_loan_late_payment_mean,
    ll.last_loan_dpd_mean,
    ll.last_loan_dpd_std
from overall o
left join last_36m  l36 on o.sk_id_curr = l36.sk_id_curr
left join last_loan ll  on o.sk_id_curr = ll.sk_id_curr
  );
  