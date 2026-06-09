-- Mega Batch: Public Schema Controlled Migration Dependency Surface Inventory
-- Date: 2026-05-22
-- Safety: READ ONLY. No DDL. No DML. No destructive SQL.
-- Purpose: determine whether legacy public tables still have database-level
-- dependencies before any exact table-name replacement or archive/delete step.

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
    family,
    legacy_schema,
    legacy_table,
    target_schema,
    target_table,
    owner_rule,
    to_regclass(format('%I.%I', legacy_schema, legacy_table)) is not null as legacy_object_present,
    to_regclass(format('%I.%I', target_schema, target_table)) is not null as target_object_present
  from migration_objects
)
select
  '01_object_presence' as section,
  family,
  legacy_schema || '.' || legacy_table as legacy_object,
  target_schema || '.' || target_table as target_object,
  legacy_object_present,
  target_object_present,
  owner_rule,
  case
    when legacy_object_present and target_object_present then 'shadow_target_present_legacy_preserved'
    when legacy_object_present and not target_object_present then 'target_shadow_missing_blocker'
    when not legacy_object_present and target_object_present then 'legacy_missing_manual_review'
    else 'both_missing_manual_review'
  end as decision_hint
from object_presence
order by family, legacy_object;

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
    nv.nspname as dependent_schema,
    v.relname as dependent_view,
    case
      when nv.nspname = 'public' and v.relname like 'v_%_compat_v1' then 'public_compat_view_review_required'
      when nv.nspname = 'public' then 'public_view_dependency_blocker'
      else 'cross_schema_view_dependency_blocker'
    end as dependency_class
  from legacy_oids l
  join pg_depend d on d.refobjid = l.legacy_oid
  join pg_rewrite r on r.oid = d.objid
  join pg_class v on v.oid = r.ev_class
  join pg_namespace nv on nv.oid = v.relnamespace
  where v.relkind in ('v','m')
)
select
  '02_view_dependencies_on_legacy_public_tables' as section,
  family,
  legacy_object,
  dependent_schema || '.' || dependent_view as dependent_object,
  dependency_class,
  case
    when dependency_class = 'public_compat_view_review_required'
      then 'verify view reads owner schema, not legacy public table'
    else 'blocks exact table-name replacement/archive/delete'
  end as required_action
from view_dependencies
order by family, legacy_object, dependent_object;

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
), function_hits as (
  select distinct
    m.family,
    m.legacy_schema || '.' || m.legacy_table as legacy_object,
    n.nspname as function_schema,
    p.proname as function_name,
    p.oid::regprocedure::text as function_signature,
    case
      when n.nspname = 'public' then 'public_function_reference_review_required'
      else 'cross_schema_function_reference_blocker'
    end as dependency_class
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
  '03_function_text_references_to_legacy_public_tables' as section,
  family,
  legacy_object,
  function_schema || '.' || function_signature as dependent_object,
  dependency_class,
  'review before archive/delete/exact replacement' as required_action
from function_hits
order by family, legacy_object, dependent_object;

with expected_surfaces(surface_name, expected_kind, note) as (
  values
    ('public.v_public_schema_controlled_migration_status_v1', 'view', 'status view required'),
    ('public.rpc_public_schema_controlled_migration_status_v1()', 'function', 'status RPC required'),
    ('public.v_platform_homepage_sections_compat_v1', 'view', 'platform homepage compatibility'),
    ('public.v_platform_header_settings_compat_v1', 'view', 'platform header compatibility'),
    ('public.v_platform_footer_settings_compat_v1', 'view', 'platform footer compatibility'),
    ('public.v_platform_site_pages_compat_v1', 'view', 'platform site pages compatibility'),
    ('public.v_platform_user_system_roles_compat_v1', 'view', 'platform user-system roles compatibility'),
    ('public.v_platform_user_system_permissions_compat_v1', 'view', 'platform user-system permissions compatibility'),
    ('public.v_core_admin_users_compat_v1', 'view', 'core admin users compatibility'),
    ('public.v_assistant_chatbot_messages_compat_v1', 'view', 'assistant chatbot compatibility')
)
select
  '04_expected_public_compatibility_surfaces' as section,
  surface_name,
  expected_kind,
  case
    when expected_kind = 'view' then to_regclass(surface_name) is not null
    when expected_kind = 'function' then to_regprocedure(surface_name) is not null
    else false
  end as present,
  note,
  case
    when expected_kind = 'view' and to_regclass(surface_name) is null then 'missing_surface_blocker'
    when expected_kind = 'function' and to_regprocedure(surface_name) is null then 'missing_surface_blocker'
    else 'present_or_not_required'
  end as decision_hint
from expected_surfaces
order by surface_name;

select
  '05_sovereign_boundary' as section,
  'no_waq_assets_mutation_in_this_script' as check_key,
  true as passed,
  'This script is SELECT-only and does not touch waqf_assets, waqf, or awqaf_system.' as note
union all
select
  '05_sovereign_boundary',
  'no_destructive_sql_in_this_script',
  true,
  'No DROP/DELETE/ARCHIVE/RENAME/ALTER statements are included.';
