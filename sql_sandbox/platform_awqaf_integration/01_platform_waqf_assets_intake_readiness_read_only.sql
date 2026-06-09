-- Mega Batch B — Platform read-only intake verification for awqaf_system waqf_assets outputs.
-- This script must remain read-only and contains SELECT statements only.

select
  'platform_awqaf_intake_required_functions' as section,
  count(*) filter (where routine_schema = 'waqf') as waqf_functions_visible,
  count(*) filter (where routine_schema = 'public') as public_wrappers_visible
from information_schema.routines
where routine_name in (
  'rpc_waqf_asset_source_record_create_draft_v1',
  'rpc_waqf_asset_source_record_commit_review_decision_v1',
  'rpc_waqf_asset_source_duplicate_candidate_decision_v1',
  'rpc_waqf_asset_source_parcel_match_decision_v1'
)
and routine_schema in ('waqf', 'public');

select
  'platform_awqaf_intake_required_tables' as section,
  table_schema,
  table_name
from information_schema.tables
where table_schema = 'waqf'
and table_name in (
  'waqf_assets',
  'waqf_asset_source_records',
  'waqf_asset_review_events',
  'waqf_asset_duplicate_candidates',
  'waqf_asset_source_parcel_match_candidates',
  'waqf_asset_parcel_links',
  'waqf_asset_normalization_dictionary',
  'waqf_asset_rbac_permissions',
  'waqf_asset_rbac_assignments'
)
order by table_name;

select
  'platform_awqaf_intake_public_safety_contract' as section,
  'platform must not expose unapproved/internal-only waqf assets in public routes or public maps' as rule,
  'manual/browser UAT required after awqaf_system provides integration-ready outputs' as required_evidence;
