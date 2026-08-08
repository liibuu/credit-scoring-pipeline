with train as (
    select *, 1 as is_train
    from "credit_risk"."bronze"."application_train"
),

test as (
    select *, null::int as "TARGET", 0 as is_train
    from "credit_risk"."bronze"."application_test"
),

unioned as (
    select * from train
    union all
    select * from test
),

cleaned as (
    select
        *,
        case when "DAYS_EMPLOYED" = 365243 then null else "DAYS_EMPLOYED" end as days_employed_clean
    from unioned
    where "CODE_GENDER" != 'XNA'
      and "AMT_INCOME_TOTAL" < 20000000
),

final as (
    select
        "SK_ID_CURR"                as sk_id_curr,
        "TARGET"                    as target,
        is_train,

        -- raw fields kept
        "CODE_GENDER"                as code_gender,
        "ORGANIZATION_TYPE"          as organization_type,
        "OCCUPATION_TYPE"            as occupation_type,
        "NAME_EDUCATION_TYPE"        as name_education_type,
        "DAYS_BIRTH"                 as days_birth,
        days_employed_clean          as days_employed,
        "DAYS_ID_PUBLISH"            as days_id_publish,
        "DAYS_REGISTRATION"          as days_registration,
        "DAYS_LAST_PHONE_CHANGE"     as days_last_phone_change,
        "AMT_CREDIT"                 as amt_credit,
        "AMT_ANNUITY"                as amt_annuity,
        "AMT_GOODS_PRICE"            as amt_goods_price,
        "AMT_INCOME_TOTAL"           as amt_income_total,
        "EXT_SOURCE_1"               as ext_source_1,
        "EXT_SOURCE_2"               as ext_source_2,
        "EXT_SOURCE_3"               as ext_source_3,

        -- derived: ext source aggregates
        (coalesce("EXT_SOURCE_1", 0) + coalesce("EXT_SOURCE_2", 0) + coalesce("EXT_SOURCE_3", 0))
            / nullif(
                (case when "EXT_SOURCE_1" is not null then 1 else 0 end
               + case when "EXT_SOURCE_2" is not null then 1 else 0 end
               + case when "EXT_SOURCE_3" is not null then 1 else 0 end), 0
              )                                                        as ext_sources_mean,
        least("EXT_SOURCE_1", "EXT_SOURCE_2", "EXT_SOURCE_3")          as ext_sources_min,
        greatest("EXT_SOURCE_1", "EXT_SOURCE_2", "EXT_SOURCE_3")       as ext_sources_max,
        "EXT_SOURCE_1" * "EXT_SOURCE_2" * "EXT_SOURCE_3"               as ext_sources_prod,
        ("EXT_SOURCE_1" * 2 + "EXT_SOURCE_2" * 1 + "EXT_SOURCE_3" * 3) as ext_sources_weighted,

        -- derived: credit ratios
        "AMT_CREDIT" / nullif("AMT_ANNUITY", 0)                        as credit_to_annuity_ratio,
        "AMT_CREDIT" / nullif("AMT_GOODS_PRICE", 0)                    as credit_to_goods_ratio,
        "AMT_ANNUITY" / nullif("AMT_INCOME_TOTAL", 0)                  as annuity_to_income_ratio,
        "AMT_INCOME_TOTAL" / nullif(days_employed_clean, 0)            as income_to_employed_ratio,
        days_employed_clean / nullif("DAYS_BIRTH", 0)                  as employed_to_birth_ratio,
        "DAYS_LAST_PHONE_CHANGE" / nullif("DAYS_BIRTH", 0)             as phone_to_birth_ratio

    from cleaned
)

select * from final