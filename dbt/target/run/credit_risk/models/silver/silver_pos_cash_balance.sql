
  
    

  create  table "credit_risk"."silver"."silver_pos_cash_balance__dbt_tmp"
  
  
    as
  
  (
    with pos as (
    select
        "SK_ID_CURR"              as sk_id_curr,
        "SK_ID_PREV"              as sk_id_prev,
        "MONTHS_BALANCE"          as months_balance,
        "CNT_INSTALMENT"          as cnt_instalment,
        "CNT_INSTALMENT_FUTURE"   as cnt_instalment_future,
        "NAME_CONTRACT_STATUS"    as name_contract_status,
        "SK_DPD"                  as sk_dpd,
        "SK_DPD_DEF"              as sk_dpd_def
    from "credit_risk"."bronze"."POS_CASH_balance"
),

cleaned as (
    select
        *,
        case when sk_dpd > 0 then 1 else 0 end                 as late_payment,
        (name_contract_status = 'Completed')                   as is_completed,
        cnt_instalment_future / nullif(cnt_instalment, 0)       as remaining_instalments_ratio,
        row_number() over (
            partition by sk_id_prev
            order by months_balance desc
        ) as recency_rank
    from pos
),

-- rolled up to loan (SK_ID_PREV) grain
agg as (
    select
        sk_id_prev,
        max(sk_id_curr)                                         as sk_id_curr,  -- constant per loan
        count(*)                                                as months_count,
        max(sk_dpd)                                             as sk_dpd_max,
        avg(sk_dpd)                                             as sk_dpd_mean,
        avg(late_payment)                                       as late_payment_rate,
        max(case when is_completed then 1 else 0 end)           as is_completed,
        max(case when recency_rank = 1 then remaining_instalments_ratio end) as remaining_instalments_ratio
    from cleaned
    group by sk_id_prev
)

select * from agg
  );
  