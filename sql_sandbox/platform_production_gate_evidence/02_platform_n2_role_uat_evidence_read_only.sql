-- Mega Batch N2 — Platform Production Gate / Role UAT Evidence Read-only Check
-- Read-only. Does not mutate waqf, awqaf_system, or any operational table.
with checks as (
  select 'users_rbac_catalog_present'::text as check_key,
         (to_regclass('public.admin_users') is not null
          and to_regclass('public.platform_systems') is not null
          and to_regclass('public.platform_permissions') is not null
          and to_regclass('public.user_system_roles') is not null
          and to_regclass('public.user_system_permissions') is not null) as passed,
         'Checks core Users/RBAC catalog tables.'::text as note
  union all
  select 'admin_users_active_present',
         exists (select 1 from public.admin_users where coalesce((to_jsonb(admin_users)->>'is_active')::boolean, true) = true),
         'At least one active admin user must exist.'
  union all
  select 'platform_services_browser_evidence_present',
         (to_regclass('platform_services.service_requests') is not null and exists (select 1 from platform_services.service_requests limit 1)),
         'Service Center Browser UAT should have at least one browser-created request.'
  union all
  select 'platform_services_workflow_events_present',
         (to_regclass('platform_services.service_request_status_events') is not null and exists (select 1 from platform_services.service_request_status_events limit 1)),
         'Service Center Browser Admin UAT should create workflow events.'
  union all
  select 'platform_content_backend_present',
         (to_regclass('platform_content.center_content_items') is not null and to_regclass('public.v_platform_center_content') is not null),
         'Platform Centers backend table/view exists.'
  union all
  select 'admin_route_contract_sql_not_provable',
         true,
         'Route access contract is Flutter-side; verify by browser role UAT.'
  union all
  select 'role_based_browser_uat_required',
         false,
         'Manual role-based browser UAT evidence is required; SQL cannot prove it.'
  union all
  select 'fresh_flutter_analyzer_required',
         false,
         'Run dart format and flutter analyze locally after N2.'
  union all
  select 'no_waq_assets_mutation_in_this_script',
         true,
         'Read-only UAT. This script does not touch waqf schema or awqaf_system.'
)
select * from checks order by check_key;
