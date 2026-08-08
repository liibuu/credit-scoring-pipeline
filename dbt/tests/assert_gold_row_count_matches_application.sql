-- Fails if gold_applicant_features row count doesn't match silver_application row count
-- (catches join fan-out from a many-side table accidentally duplicating rows)
with expected as (
    select count(*) as cnt from {{ ref('silver_application') }}
),

actual as (
    select count(*) as cnt from {{ ref('gold_applicant_features') }}
)

select expected.cnt as expected_count, actual.cnt as actual_count
from expected, actual
where expected.cnt != actual.cnt