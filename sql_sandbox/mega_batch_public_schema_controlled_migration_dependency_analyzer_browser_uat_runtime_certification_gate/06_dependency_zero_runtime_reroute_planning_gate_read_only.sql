-- 06_dependency_zero_runtime_reroute_planning_gate_read_only.sql
-- Mega Batch: Public Schema Controlled Migration Dependency-Zero Runtime Reroute Planning Gate
-- Date: 2026-05-22
-- Safety: SELECT-only. No DDL, no DML, no destructive SQL.
-- Purpose: combine database dependency probes with the last known static
-- Flutter dependency scan. This script cannot authorize runtime reroute;
-- it only states whether planning may proceed.

with migration_objects(family, legacy_schema, legacy_table, target_schema, target_table, owner_rule) as (
  values
    ('platform_shell', 'public', 'app_settings', 'platform', 'app_settings', 'platform-owned shell/settings'),
    ('platform_shell', 'public', 'footer_settings', 'platform', 'footer_settings', 'platform-owned shell/settings'),
    ('platform_shell', 'public', 'header_settings', 'platform', 'header_settings', 'platform-owned shell/settings'),
    ('platform_shell', 'public', 'homepage_sections', 'platform', 'homepage_sections', 'platform-owned dynamic homepage'),
    ('platform_shell', 'public', 'site_pages', 'platform', 'site_pages', 'platform-owned public pages'),
    ('platform_shell', 'public', 'site_settings', 'platform', 'site_settings', 'platform-owned site settings'),
    ('platform_shell', 'public', 'home_config', 'platform', 'home_config', 'platform-owned homepage config'),
    ('platform_shell', 'public', 'hero_slides', 'platform', 'hero_slides', 'platform-owned home hero'),
    ('platform_shell', 'public', 'home_stats', 'platform', 'home_stats', 'platform-owned home stats'),
    ('platform_shell', 'public', 'home_services', 'platform', 'home_services', 'platform-owned home services'),
    ('platform_shell', 'public', 'home_hero_slides', 'platform', 'home_hero_slides', 'platform-owned home hero legacy family'),
    ('platform_shell', 'public', 'breaking_news', 'platform', 'breaking_news', 'platform-owned breaking news shell'),
    ('platform_access', 'public', 'platform_permissions', 'platform', 'platform_permissions', 'platform RBAC catalog'),
    ('platform_access', 'public', 'platform_systems', 'platform', 'platform_systems', 'platform system registry legacy family'),
    ('platform_access', 'public', 'user_permissions', 'platform', 'user_permissions', 'platform user permissions'),
    ('platform_access', 'public', 'user_system_permissions', 'platform', 'user_system_permissions', 'platform user system permissions'),
    ('platform_access', 'public', 'user_system_roles', 'platform', 'user_system_roles', 'platform user system roles'),
    ('core_linkage', 'public', 'admin_users', 'core', 'admin_users', 'core administrative profile/linkage'),
    ('core_linkage', 'public', 'user_accounts', 'core', 'user_accounts', 'core user account profile'),
    ('core_linkage', 'public', 'org_units_cache', 'core', 'org_units_cache', 'core org-unit compatibility cache'),
    ('core_linkage', 'public', 'pwf_org_units_cache', 'core', 'pwf_org_units_cache', 'core org-unit compatibility cache'),
    ('assistant', 'public', 'assistant_conversations', 'assistant', 'assistant_conversations', 'assistant conversations'),
    ('assistant', 'public', 'assistant_messages', 'assistant', 'assistant_messages', 'assistant messages'),
    ('assistant', 'public', 'chatbot_conversations', 'assistant', 'chatbot_conversations', 'public chatbot conversations'),
    ('assistant', 'public', 'chatbot_messages', 'assistant', 'chatbot_messages', 'public chatbot messages'),
    ('assistant', 'public', 'chatbot_intents', 'assistant', 'chatbot_intents', 'public chatbot intents'),
    ('assistant', 'public', 'chatbot_retention_policies', 'assistant', 'chatbot_retention_policies', 'public chatbot retention')
), object_presence as (
  select
    *,
    to_regclass(format('%I.%I', legacy_schema, legacy_table)) is not null as legacy_present,
    to_regclass(format('%I.%I', target_schema, target_table)) is not null as target_present
  from migration_objects
), missing_targets as (
  select * from object_presence where legacy_present and not target_present
), legacy_oids as (
  select
    *,
    to_regclass(format('%I.%I', legacy_schema, legacy_table))::oid as legacy_oid
  from migration_objects
  where to_regclass(format('%I.%I', legacy_schema, legacy_table)) is not null
), view_dependencies as (
  select distinct
    l.family,
    l.legacy_schema || '.' || l.legacy_table as legacy_object,
    nv.nspname || '.' || v.relname as dependent_object
  from legacy_oids l
  join pg_depend d on d.refobjid = l.legacy_oid
  join pg_rewrite r on r.oid = d.objid
  join pg_class v on v.oid = r.ev_class
  join pg_namespace nv on nv.oid = v.relnamespace
  where v.relkind in ('v','m')
    and nv.nspname not in ('pg_catalog','information_schema')
    and not (nv.nspname = 'public' and v.relname like 'v_%_compat_v1')
    and not (nv.nspname = 'public' and v.relname = 'v_public_schema_controlled_migration_status_v1')
), function_hits as (
  select distinct
    m.family,
    m.legacy_schema || '.' || m.legacy_table as legacy_object,
    n.nspname || '.' || p.oid::regprocedure::text as dependent_object
  from migration_objects m
  join pg_proc p on true
  join pg_namespace n on n.oid = p.pronamespace
  where p.prokind in ('f','p')
    and n.nspname not in ('pg_catalog','information_schema')
    and (
      lower(pg_get_functiondef(p.oid)) like lower('%' || m.legacy_schema || '.' || m.legacy_table || '%')
      or lower(pg_get_functiondef(p.oid)) like lower('%from ' || m.legacy_table || '%')
      or lower(pg_get_functiondef(p.oid)) like lower('%join ' || m.legacy_table || '%')
    )
), static_app_scan as (
  select
    29::integer as direct_postgrest_unique_file_table_pair_count,
    16::integer as unique_direct_file_count,
    'last_static_scan_from_current_baseline_zip'::text as source
), dependency_totals as (
  select
    (select count(*) from missing_targets)::integer as missing_target_count,
    (select count(*) from view_dependencies)::integer as database_view_dependency_count,
    (select count(*) from function_hits)::integer as database_function_dependency_count,
    (select direct_postgrest_unique_file_table_pair_count from static_app_scan)::integer as static_flutter_dependency_count,
    false::boolean as browser_console_clean_evidence_accepted,
    false::boolean as explicit_reroute_approval_granted
)
select
  '06_dependency_zero_runtime_reroute_planning_gate'::text as section,
  missing_target_count,
  database_view_dependency_count,
  database_function_dependency_count,
  static_flutter_dependency_count,
  (database_view_dependency_count + database_function_dependency_count + static_flutter_dependency_count + missing_target_count)::integer as dependency_blocker_count,
  browser_console_clean_evidence_accepted,
  explicit_reroute_approval_granted,
  case
    when (database_view_dependency_count + database_function_dependency_count + static_flutter_dependency_count + missing_target_count) = 0
      and browser_console_clean_evidence_accepted
      and explicit_reroute_approval_granted
    then 'REROUTE_PLANNING_MAY_START_WITH_EXPLICIT_APPROVAL'
    else 'REROUTE_BLOCKED_DEPENDENCY_OR_CONSOLE_OR_APPROVAL_PENDING'
  end as gate_decision,
  false as production_approved,
  false as destructive_sql_authorized,
  true as no_waq_assets_mutation_in_this_script
from dependency_totals;

-- Hotfix 06A note:
-- The previous version attempted to reuse CTE static_app_scan in a second
-- statement. PostgreSQL CTE scope is one statement only, so this second
-- result set must be self-contained. This remains SELECT-only.
select
  '06_static_flutter_dependency_detail'::text as section,
  'last_static_scan_from_current_baseline_zip'::text as source,
  29::integer as direct_postgrest_unique_file_table_pair_count,
  16::integer as unique_direct_file_count,
  case when 29 = 0 then 'static_dependency_zero' else 'static_direct_public_dependencies_remain' end as decision_hint;
