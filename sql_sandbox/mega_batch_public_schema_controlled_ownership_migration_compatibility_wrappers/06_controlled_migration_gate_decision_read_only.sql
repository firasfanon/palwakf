-- Mega Batch: Public Schema Controlled Ownership Migration + Compatibility Wrappers
-- Script 06: controlled migration gate decision, read-only.

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
)
select
  'public_schema_controlled_migration_gate' as section,
  case
    when status_view_present and status_rpc_present and status_rows > 0 and failed_rows = 0 then
      'CONTROLLED_OWNER_SHADOW_MIGRATION_READY_LEGACY_PRESERVED_BROWSER_UAT_REQUIRED'
    when status_view_present and status_rows > 0 and failed_rows > 0 then
      'CONTROLLED_OWNER_SHADOW_MIGRATION_PARTIAL_RECONCILIATION_REQUIRED'
    else
      'CONTROLLED_OWNER_SHADOW_MIGRATION_NOT_APPLIED_OR_STATUS_MISSING'
  end as decision,
  jsonb_build_object(
    'status_view_present', status_view_present,
    'status_rpc_present', status_rpc_present,
    'status_rows', status_rows,
    'failed_rows', failed_rows,
    'legacy_public_tables_preserved', true,
    'exact_public_table_name_replacement_performed', false,
    'destructive_sql_authorized', false,
    'next_required_evidence', 'SQL UAT + Flutter dependency scan + browser/analyzer evidence before archive/delete'
  ) as decision_payload
from status;
