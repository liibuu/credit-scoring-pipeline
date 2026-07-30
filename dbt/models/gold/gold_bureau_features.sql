with bureau as (
    select * from {{ ref('silver_bureau') }}
),

overall as (
    select
        sk_id_curr,
        avg(debt_credit_diff)                                  as bureau_debt_credit_diff_mean,
        sum(amt_credit_sum_debt) / nullif(sum(amt_credit_sum), 0) as bureau_debt_over_credit
    from bureau
    group by sk_id_curr
),

active as (
    select
        sk_id_curr,
        avg(debt_credit_diff)                                  as bureau_active_debt_credit_diff_mean,
        avg(debt_percentage)                                   as bureau_active_debt_percentage_mean,
        max(days_credit)                                       as bureau_active_days_credit_max,
        sum(amt_credit_sum_debt) / nullif(sum(amt_credit_sum), 0) as bureau_active_debt_over_credit
    from bureau
    where is_active
    group by sk_id_curr
),

closed as (
    select
        sk_id_curr,
        max(days_credit_update)                                as bureau_closed_days_credit_update_max
    from bureau
    where is_closed
    group by sk_id_curr
),

consumer as (
    select
        sk_id_curr,
        max(days_credit_enddate)                               as bureau_consumer_days_credit_enddate_max
    from bureau
    where is_consumer_credit
    group by sk_id_curr
),

last_12m as (
    select
        sk_id_curr,
        avg(debt_percentage)                                   as bureau_last12m_debt_percentage_mean,
        avg(debt_credit_diff)                                  as bureau_last12m_debt_credit_diff_mean
    from bureau
    where days_credit >= -360
    group by sk_id_curr
)

select
    o.sk_id_curr,
    o.bureau_debt_credit_diff_mean,
    o.bureau_debt_over_credit,
    a.bureau_active_debt_credit_diff_mean,
    a.bureau_active_debt_percentage_mean,
    a.bureau_active_days_credit_max,
    a.bureau_active_debt_over_credit,
    c.bureau_closed_days_credit_update_max,
    cons.bureau_consumer_days_credit_enddate_max,
    l.bureau_last12m_debt_percentage_mean,
    l.bureau_last12m_debt_credit_diff_mean
from overall o
left join active   a    on o.sk_id_curr = a.sk_id_curr
left join closed    c    on o.sk_id_curr = c.sk_id_curr
left join consumer  cons on o.sk_id_curr = cons.sk_id_curr
left join last_12m  l    on o.sk_id_curr = l.sk_id_curr