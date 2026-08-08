-- Fails if any training-set row has a null target
select sk_id_curr
from {{ ref('silver_application') }}
where is_train = 1
  and target is null