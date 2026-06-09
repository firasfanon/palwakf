with expected(signature) as (
  values
    ('public.rpc_waqf_assets_runtime_auth_gate_v1()'),
    ('public.rpc_waqf_asset_lifecycle_operational_v1(uuid)'),
    ('public.rpc_waqf_asset_source_records_v1(uuid)'),
    ('public.rpc_waqf_asset_review_queue_v1(integer)')
)
select
  'runtime_rpc_presence_read_only' as section,
  signature,
  to_regprocedure(signature) is not null as present,
  false as ddl_dml_authorized,
  false as production_approved,
  true as read_only
from expected;
