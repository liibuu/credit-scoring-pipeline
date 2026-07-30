with pay as (
    select
        "SK_ID_CURR"           as sk_id_curr,
        "SK_ID_PREV"           as sk_id_prev,
        "DAYS_INSTALMENT"      as days_instalment,
        "DAYS_ENTRY_PAYMENT"   as days_entry_payment,
        "AMT_INSTALMENT"       as amt_instalment,
        "AMT_PAYMENT"          as amt_payment
    from {{ source('bronze', 'installments_payments') }}
),

final as (
    select
        *,
        greatest(days_entry_payment - days_instalment, 0)             as dpd,
        greatest(days_instalment - days_entry_payment, 0)             as dbd,
        (days_instalment - days_entry_payment) < 0                    as is_late_payment,
        amt_payment / nullif(amt_instalment, 0)                       as payment_ratio,
        case
            when (days_instalment - days_entry_payment) < 0
            then amt_payment / nullif(amt_instalment, 0)
            else 0
        end                                                            as late_payment_ratio,
        case when (days_instalment - days_entry_payment) < 0
             and (amt_payment / nullif(amt_instalment, 0)) > 0.05
             then 1 else 0 end                                         as significant_late_payment,
        case when greatest(days_entry_payment - days_instalment, 0) >= 7 then 1 else 0 end as dpd_7,
        row_number() over (
            partition by sk_id_curr, sk_id_prev
            order by days_instalment desc
        ) as installment_recency_rank
    from pay
)

select * from final