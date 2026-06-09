-- PalWakf Mega Batch N2.7
-- Production Access Certification: Dashboard/RBAC Read-only Evidence
-- READ ONLY. No DML on waqf, waqf_assets, awqaf_system, platform tables.

with checks as (
  select 'identity'::text as section, 'admin_users_table_exists'::text as check_key,
         to_regclass('public.admin_users') is not null as passed,
         case when to_regclass('public.admin_users') is not null then 'public.admin_users exists' else 'public.admin_users missing' end as note
  union all
  select 'identity','active_admin_users_present',
         coalesce((select count(*) > 0 from public.admin_users), false),
         'active/admin users count=' || coalesce((select count(*)::text from public.admin_users),'0')
  union all
  select 'rbac','user_system_roles_table_exists',
         to_regclass('public.user_system_roles') is not null,
         case when to_regclass('public.user_system_roles') is not null then 'public.user_system_roles exists' else 'public.user_system_roles missing' end
  union all
  select 'rbac','user_system_permissions_table_exists',
         to_regclass('public.user_system_permissions') is not null,
         case when to_regclass('public.user_system_permissions') is not null then 'public.user_system_permissions exists' else 'public.user_system_permissions missing' end
  union all
  select 'rbac','role_assignments_present',
         case when to_regclass('public.user_system_roles') is null then false else coalesce((select count(*) > 0 from public.user_system_roles), false) end,
         'user_system_roles rows=' || case when to_regclass('public.user_system_roles') is null then 'missing' else coalesce((select count(*)::text from public.user_system_roles),'0') end
  union all
  select 'rbac','permission_assignments_present',
         case when to_regclass('public.user_system_permissions') is null then false else coalesce((select count(*) > 0 from public.user_system_permissions), false) end,
         'user_system_permissions rows=' || case when to_regclass('public.user_system_permissions') is null then 'missing' else coalesce((select count(*)::text from public.user_system_permissions),'0') end
  union all
  select 'service_center','forms_registry_table_exists',
         to_regclass('platform_services.service_forms_registry') is not null,
         case when to_regclass('platform_services.service_forms_registry') is not null then 'platform_services.service_forms_registry exists' else 'forms registry missing' end
  union all
  select 'service_center','service_requests_table_exists',
         to_regclass('platform_services.service_requests') is not null,
         case when to_regclass('platform_services.service_requests') is not null then 'platform_services.service_requests exists' else 'service requests missing' end
  union all
  select 'platform_content','center_content_items_table_exists',
         to_regclass('platform_content.center_content_items') is not null,
         case when to_regclass('platform_content.center_content_items') is not null then 'platform_content.center_content_items exists' else 'center content items missing' end
  union all
  select 'platform_content','public_view_exists',
         to_regclass('public.v_platform_center_content') is not null,
         case when to_regclass('public.v_platform_center_content') is not null then 'public.v_platform_center_content exists' else 'public view missing' end
  union all
  select 'public_homepage','homepage_sections_table_exists',
         to_regclass('public.homepage_sections') is not null,
         case when to_regclass('public.homepage_sections') is not null then 'public.homepage_sections exists' else 'homepage_sections missing' end
  union all
  select 'sovereign_boundary','no_waq_assets_mutation_in_this_script',
         true,
         'Read-only evidence only; no INSERT/UPDATE/DELETE/MERGE/TRUNCATE on waqf/waq_assets/awqaf_system.'
)
select * from checks order by section, check_key;

-- Optional manual follow-up in SQL Editor:
-- 1) Review role rows grouped by system/user without exposing PII publicly.
-- 2) Pair this SQL with browser screenshots for every role before production approval.
