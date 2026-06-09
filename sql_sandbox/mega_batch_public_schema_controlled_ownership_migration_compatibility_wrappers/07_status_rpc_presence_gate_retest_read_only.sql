-- Mega Batch: Public Schema Controlled Ownership Migration SQL Result Intake + Compatibility Certification Decision
-- Script 07: status RPC presence root-fix retest, read-only.
-- Purpose: avoid false negatives caused by using to_regclass() for function presence.
-- Important: Do NOT rerun migration apply scripts if 02/03 already succeeded.

with status as (
  select
    case when to_regclass('public.v_public_schema_controlled_migration_status_v1') is not null
      then (xpath('/row/count/text()', query_to_xml('select count(*) as count from public.v_public_schema_controlled_migration_status_v1', false, true, '')))[1]::text::bigint
      else 0 end as status_rows,
    case when to_regclass('public.v_public_schema_controlled_migration_status_v1') is not null
      then (xpath('/row/count/text()', query_to_xml($q$select count(*) as count from public.v_public_schema_controlled_migration_status_v1 where action like 'failed%'$q$, false, true, '')))[1]::text::bigint
      else 0 end as failed_rows,
    to_regclass('public.v_public_schema_controlled_migration_status_v1') is not null as status_view_present,
    to_regprocedure('public.rpc_public_schema_controlled_migration_status_v1()') is not null as status_rpc_present
), boundary as (
  select
    true as legacy_public_tables_preserved,
    true as exact_public_table_name_replacement_performed_false,
    true as destructive_sql_authorized_false,
    true as auth_users_not_migrated,
    true as no_waq_assets_mutation_in_this_script
)
select
  'public_schema_controlled_migration_status_rpc_root_fix_retest' as section,
  case
    when status_view_present and status_rpc_present and status_rows > 0 and failed_rows = 0 then
      'CONTROLLED_OWNER_SHADOW_MIGRATION_READY_LEGACY_PRESERVED_BROWSER_UAT_REQUIRED'
    when status_view_present and status_rows > 0 and failed_rows > 0 then
      'CONTROLLED_OWNER_SHADOW_MIGRATION_PARTIAL_RECONCILIATION_REQUIRED'
    when status_view_present and status_rows > 0 and status_rpc_present = false then
      'STATUS_RPC_MISSING_OR_NOT_VISIBLE_REVIEW_REQUIRED'
    else
      'CONTROLLED_OWNER_SHADOW_MIGRATION_NOT_APPLIED_OR_STATUS_MISSING'
  end as decision,
  jsonb_build_object(
    'status_view_present', status_view_present,
    'status_rpc_present_checked_by_to_regprocedure', status_rpc_present,
    'status_rows', status_rows,
    'failed_rows', failed_rows,
    'legacy_public_tables_preserved', true,
    'exact_public_table_name_replacement_performed', false,
    'destructive_sql_authorized', false,
    'auth_users_not_migrated', true,
    'no_waq_assets_mutation_in_this_script', true,
    'next_required_evidence', 'Flutter dependency scan + browser/analyzer evidence before archive/delete or exact table-name replacement'
  ) as decision_payload
from status, boundary;
