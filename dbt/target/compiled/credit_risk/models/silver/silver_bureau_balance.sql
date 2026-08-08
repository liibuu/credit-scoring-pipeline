with bb as (
    select
        "SK_ID_BUREAU"   as sk_id_bureau,
        "MONTHS_BALANCE" as months_balance,
        "STATUS"         as status
    from "credit_risk"."bronze"."bureau_balance"
),

agg as (
    select
        sk_id_bureau,
        min(months_balance)                                         as months_balance_min,
        max(months_balance)                                         as months_balance_max,
        avg(months_balance)                                         as months_balance_mean,
        count(*)                                                    as months_balance_size,
        avg(case when status = '0' then 1.0 else 0.0 end)           as status_0_mean,
        avg(case when status = '1' then 1.0 else 0.0 end)           as status_1_mean,
        avg(case when status in ('1','2','3','4','5') then 1.0 else 0.0 end) as status_12345_mean,
        avg(case when status = 'C' then 1.0 else 0.0 end)           as status_c_mean,
        avg(case when status = 'X' then 1.0 else 0.0 end)           as status_x_mean
    from bb
    group by sk_id_bureau
)

select * from agg