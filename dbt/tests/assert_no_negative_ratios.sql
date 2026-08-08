-- Fails if any row has a negative value in a ratio column that should only be >= 0
select 'gold_applicant_features.credit_to_annuity_ratio' as source, sk_id_curr
from {{ ref('gold_applicant_features') }}
where credit_to_annuity_ratio < 0

union all

select 'gold_applicant_features.credit_to_goods_ratio', sk_id_curr
from {{ ref('gold_applicant_features') }}
where credit_to_goods_ratio < 0

union all

select 'gold_applicant_features.annuity_to_income_ratio', sk_id_curr
from {{ ref('gold_applicant_features') }}
where annuity_to_income_ratio < 0

union all

select 'gold_applicant_features.cc_limit_use_mean', sk_id_curr
from {{ ref('gold_applicant_features') }}
where cc_limit_use_mean < 0