-- Mega Batch: Public Schema Runtime Certification Gate
-- Date: 2026-05-22
-- Safety: READ ONLY. This script decides whether certification may proceed.
-- It deliberately does NOT approve production, archive/delete, or exact table-name replacement.

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
    nv.nspname as dependent_schema,
    v.relname as dependent_name,
    nv.nspname || '.' || v.relname as dependent_object
  from legacy_oids l
  join pg_depend d on d.refobjid = l.legacy_oid
  join pg_rewrite r on r.oid = d.objid
  join pg_class v on v.oid = r.ev_class
  join pg_namespace nv on nv.oid = v.relnamespace
  where v.relkind in ('v','m')
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
), dependency_blockers as (
  select 'view_dependency' as blocker_type, family, legacy_object, dependent_object
  from view_dependencies
  where dependent_object not in (
    'public.v_public_schema_controlled_migration_status_v1'
  )
  union all
  select 'function_reference' as blocker_type, family, legacy_object, dependent_object
  from function_hits
  where dependent_object not like 'public.rpc_public_schema_controlled_migration_status_v1%'
), expected_surfaces(surface_name, expected_kind) as (
  values
    ('public.v_public_schema_controlled_migration_status_v1', 'view'),
    ('public.rpc_public_schema_controlled_migration_status_v1()', 'function'),
    ('public.v_platform_homepage_sections_compat_v1', 'view'),
    ('public.v_platform_header_settings_compat_v1', 'view'),
    ('public.v_platform_footer_settings_compat_v1', 'view'),
    ('public.v_platform_site_pages_compat_v1', 'view'),
    ('public.v_platform_user_system_roles_compat_v1', 'view'),
    ('public.v_platform_user_system_permissions_compat_v1', 'view'),
    ('public.v_core_admin_users_compat_v1', 'view'),
    ('public.v_assistant_chatbot_messages_compat_v1', 'view')
), missing_surfaces as (
  select * from expected_surfaces
  where (expected_kind = 'view' and to_regclass(surface_name) is null)
     or (expected_kind = 'function' and to_regprocedure(surface_name) is null)
), gate as (
  select
    (select count(*) from object_presence) as object_rows,
    (select count(*) from missing_targets) as missing_target_count,
    (select count(*) from dependency_blockers) as dependency_blocker_count,
    (select count(*) from missing_surfaces) as missing_surface_count,
    false::boolean as flutter_analyzer_evidence_attached,
    false::boolean as browser_console_uat_evidence_attached,
    false::boolean as explicit_destructive_sql_authorized,
    true::boolean as no_waq_assets_mutation_in_this_script
)
select
  '01_runtime_certification_gate' as section,
  object_rows,
  missing_target_count,
  dependency_blocker_count,
  missing_surface_count,
  flutter_analyzer_evidence_attached,
  browser_console_uat_evidence_attached,
  explicit_destructive_sql_authorized,
  no_waq_assets_mutation_in_this_script,
  case
    when explicit_destructive_sql_authorized then 'INVALID_GATE_DESTRUCTIVE_SQL_NOT_ALLOWED_HERE'
    when missing_target_count > 0 then 'BLOCKED_MISSING_OWNER_SHADOW_TARGETS'
    when missing_surface_count > 0 then 'BLOCKED_MISSING_PUBLIC_COMPATIBILITY_SURFACES'
    when dependency_blocker_count > 0 then 'BLOCKED_DEPENDENCY_ZERO_NOT_CERTIFIED'
    when not flutter_analyzer_evidence_attached then 'BLOCKED_ANALYZER_EVIDENCE_REQUIRED'
    when not browser_console_uat_evidence_attached then 'BLOCKED_BROWSER_CONSOLE_UAT_REQUIRED'
    else 'RUNTIME_CERTIFICATION_CANDIDATE_REQUIRES_EXPLICIT_APPROVAL'
  end as certification_decision
from gate;

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
)
select
  '02_dependency_blocker_details' as section,
  blocker_type,
  family,
  legacy_object,
  dependent_object,
  'must_be_zero_before_exact_replacement_or_archive_delete' as rule
from (
  select 'view_dependency' as blocker_type, family, legacy_object, dependent_object
  from view_dependencies
  where dependent_object not in ('public.v_public_schema_controlled_migration_status_v1')
  union all
  select 'function_reference' as blocker_type, family, legacy_object, dependent_object
  from function_hits
  where dependent_object not like 'public.rpc_public_schema_controlled_migration_status_v1%'
) blockers
order by blocker_type, family, legacy_object, dependent_object;

select
  '03_final_safety_boundary' as section,
  'no_drop_delete_archive_rename_exact_replacement' as check_key,
  true as passed,
  'This gate never performs destructive SQL and never grants production approval.' as note
union all
select
  '03_final_safety_boundary',
  'no_waq_assets_mutation_in_this_script',
  true,
  'SELECT-only gate; no waqf/waqf_assets/awqaf_system DML.';
