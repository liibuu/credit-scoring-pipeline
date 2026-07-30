with prev as (
    select * from {{ ref('silver_previous_application') }}
),

refused as (
    select
        sk_id_curr,
        avg(case when is_refused then 1.0 else 0.0 end)        as prev_name_contract_status_refused_mean
    from prev
    group by sk_id_curr
),

cash as (
    select
        sk_id_curr,
        avg(simple_interests)                                  as prev_cash_simple_interests_mean,
        max(simple_interests)                                  as prev_cash_simple_interests_max
    from prev
    where is_cash_loan
    group by sk_id_curr
),

last_24m as (
    select
        sk_id_curr,
        max(simple_interests)                                  as prev_last24m_simple_interests_max,
        avg(days_last_due_1st_version)                         as prev_last24m_days_last_due_1st_version_mean,
        max(days_last_due_1st_version)                         as prev_last24m_days_last_due_1st_version_max
    from prev
    where days_decision >= -720
    group by sk_id_curr
),

approved as (
    select
        sk_id_curr,
        avg(amt_annuity)                                       as approved_amt_annuity_mean,
        max(amt_annuity)                                       as approved_amt_annuity_max,
        max(days_termination)                                  as prev_days_termination_max
    from prev
    where is_approved
    group by sk_id_curr
)

select
    p.sk_id_curr,
    r.prev_name_contract_status_refused_mean,
    c.prev_cash_simple_interests_mean,
    c.prev_cash_simple_interests_max,
    l.prev_last24m_simple_interests_max,
    l.prev_last24m_days_last_due_1st_version_mean,
    l.prev_last24m_days_last_due_1st_version_max,
    a.approved_amt_annuity_mean,
    a.approved_amt_annuity_max,
    a.prev_days_termination_max
from (select distinct sk_id_curr from prev) p
left join refused  r on p.sk_id_curr = r.sk_id_curr
left join cash     c on p.sk_id_curr = c.sk_id_curr
left join last_24m l on p.sk_id_curr = l.sk_id_curr
left join approved a on p.sk_id_curr = a.sk_id_curr