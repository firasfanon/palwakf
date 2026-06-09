-- Mega Batch: Public Schema Controlled Ownership Migration + Compatibility Wrappers
-- Script 04: post-migration UAT, read-only.
-- This script uses catalog guards and public wrapper/status views only.

with candidates(target_schema, table_name, migration_group) as (
  values
    ('platform','app_settings','platform_shell'),
    ('platform','footer_settings','platform_shell'),
    ('platform','header_settings','platform_shell'),
    ('platform','homepage_sections','platform_shell'),
    ('platform','site_pages','platform_shell'),
    ('platform','site_settings','platform_shell'),
    ('platform','home_config','platform_shell'),
    ('platform','hero_slides','platform_shell'),
    ('platform','home_stats','platform_shell'),
    ('platform','home_services','platform_shell'),
    ('platform','home_hero_slides','platform_shell'),
    ('platform','breaking_news','platform_shell'),
    ('platform','platform_permissions','platform_access'),
    ('platform','platform_systems','platform_access'),
    ('platform','user_permissions','platform_access'),
    ('platform','user_system_permissions','platform_access'),
    ('platform','user_system_roles','platform_access'),
    ('core','admin_users','core_identity_linkage'),
    ('core','user_accounts','core_identity_linkage'),
    ('core','org_units_cache','core_org_linkage'),
    ('core','pwf_org_units_cache','core_org_linkage'),
    ('assistant','assistant_conversations','assistant'),
    ('assistant','assistant_messages','assistant'),
    ('assistant','chatbot_conversations','assistant'),
    ('assistant','chatbot_messages','assistant'),
    ('assistant','chatbot_intents','assistant'),
    ('assistant','chatbot_retention_policies','assistant')
), counts as (
  select
    c.*,
    to_regclass('public.' || c.table_name) is not null as public_source_present,
    to_regclass(format('%I.%I', c.target_schema, c.table_name)) is not null as target_present,
    case when to_regclass('public.' || c.table_name) is not null
      then (xpath('/row/count/text()', query_to_xml(format('select count(*) as count from public.%I', c.table_name), false, true, '')))[1]::text::bigint
      else null end as public_source_rows,
    case when to_regclass(format('%I.%I', c.target_schema, c.table_name)) is not null
      then (xpath('/row/count/text()', query_to_xml(format('select count(*) as count from %I.%I', c.target_schema, c.table_name), false, true, '')))[1]::text::bigint
      else null end as target_rows
  from candidates c
)
select
  'post_migration_row_count_uat' as section,
  target_schema || '.' || table_name as target_relation,
  migration_group,
  public_source_present,
  target_present,
  public_source_rows,
  target_rows,
  case
    when public_source_present = false then 'SOURCE_NOT_PRESENT_SKIPPED'
    when target_present = false then 'TARGET_MISSING_BLOCKER'
    when coalesce(public_source_rows,0) = coalesce(target_rows,0) then 'ROW_COUNT_MATCHED'
    when target_rows > 0 then 'TARGET_HAS_ROWS_RECONCILIATION_REQUIRED'
    else 'TARGET_EMPTY_AFTER_MIGRATION_BLOCKER'
  end as decision
from counts
order by migration_group, target_relation;

select
  'public_migration_status_wrapper' as section,
  to_regclass('public.v_public_schema_controlled_migration_status_v1') is not null as status_view_present,
  to_regprocedure('public.rpc_public_schema_controlled_migration_status_v1()') is not null as status_rpc_present,
  case when to_regclass('public.v_public_schema_controlled_migration_status_v1') is not null then
    (xpath('/row/count/text()', query_to_xml('select count(*) as count from public.v_public_schema_controlled_migration_status_v1', false, true, '')))[1]::text::bigint
  else 0 end as status_rows;
