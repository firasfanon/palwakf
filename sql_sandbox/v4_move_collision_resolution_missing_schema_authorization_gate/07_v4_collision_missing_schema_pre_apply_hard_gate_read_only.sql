with gate_inputs as (
  select
    97::int as mapped_public_table_count,
    23::int as target_schema_count,
    8::int as missing_target_schema_count,
    9::int as target_table_collision_count,
    53::int as structural_view_dependency_rows,
    319::int as function_text_dependency_rows,
    83::int as rls_enabled_table_count,
    119::int as rls_policy_count,
    false::boolean as owner_approvals_confirmed,
    false::boolean as flutter_dependency_zero_certified,
    false::boolean as backup_and_reversal_confirmed,
    false::boolean as role_rls_uat_confirmed
)
select
  'v4_collision_missing_schema_pre_apply_hard_gate' as section,
  mapped_public_table_count,
  target_schema_count,
  missing_target_schema_count,
  target_table_collision_count,
  structural_view_dependency_rows,
  function_text_dependency_rows,
  rls_enabled_table_count,
  rls_policy_count,
  owner_approvals_confirmed,
  flutter_dependency_zero_certified,
  backup_and_reversal_confirmed,
  role_rls_uat_confirmed,
  false as create_schema_authorized_by_this_script,
  false as apply_pack_authorized_by_this_script,
  false as destructive_sql_authorized,
  false as archive_authorized,
  false as production_approved,
  'APPLY_BLOCKED_PENDING_MISSING_SCHEMA_AUTHORIZATION_COLLISION_RESOLUTION_OWNER_APPROVAL_FLUTTER_SCAN_BACKUP_RLS_UAT' as decision,
  true as read_only
from gate_inputs;
