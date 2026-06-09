-- Mega Batch N2.6 — Role Browser UAT Runtime Evidence Read-Only
-- Purpose: support role/browser UAT evidence collection without mutating data.
-- Scope: users/RBAC, platform centers, services, public content exposure checks.
-- Does NOT touch waq_assets, schema waqf, or awqaf_system internals.

create temp table if not exists pg_temp.pwf_n2_6_role_browser_uat_results (
  section text,
  check_key text,
  passed boolean,
  note text
) on commit drop;

do $$
declare
  v_exists boolean;
  v_count bigint;
begin
  select to_regclass('public.admin_users') is not null into v_exists;
  insert into pg_temp.pwf_n2_6_role_browser_uat_results values
    ('identity', 'admin_users_table_exists', v_exists, case when v_exists then 'public.admin_users exists' else 'public.admin_users missing' end);

  if v_exists then
    execute 'select count(*) from public.admin_users' into v_count;
    insert into pg_temp.pwf_n2_6_role_browser_uat_results values
      ('identity', 'admin_users_present', v_count > 0, 'admin_users=' || v_count::text);
  end if;

  select to_regclass('public.user_system_roles') is not null into v_exists;
  insert into pg_temp.pwf_n2_6_role_browser_uat_results values
    ('rbac', 'user_system_roles_table_exists', v_exists, case when v_exists then 'public.user_system_roles exists' else 'public.user_system_roles missing' end);

  select to_regclass('public.user_system_permissions') is not null into v_exists;
  insert into pg_temp.pwf_n2_6_role_browser_uat_results values
    ('rbac', 'user_system_permissions_table_exists', v_exists, case when v_exists then 'public.user_system_permissions exists' else 'public.user_system_permissions missing' end);

  select to_regclass('platform_services.service_requests') is not null into v_exists;
  insert into pg_temp.pwf_n2_6_role_browser_uat_results values
    ('service_center', 'service_requests_table_exists', v_exists, case when v_exists then 'platform_services.service_requests exists' else 'platform_services.service_requests missing' end);

  select to_regclass('platform_services.service_forms_registry') is not null into v_exists;
  insert into pg_temp.pwf_n2_6_role_browser_uat_results values
    ('service_center', 'forms_registry_table_exists', v_exists, case when v_exists then 'platform_services.service_forms_registry exists' else 'platform_services.service_forms_registry missing' end);

  select to_regclass('platform_content.center_content_items') is not null into v_exists;
  insert into pg_temp.pwf_n2_6_role_browser_uat_results values
    ('platform_content', 'center_content_items_table_exists', v_exists, case when v_exists then 'platform_content.center_content_items exists' else 'platform_content.center_content_items missing' end);

  select to_regclass('public.v_platform_center_content') is not null into v_exists;
  insert into pg_temp.pwf_n2_6_role_browser_uat_results values
    ('platform_content', 'public_view_exists', v_exists, case when v_exists then 'public.v_platform_center_content exists' else 'public.v_platform_center_content missing' end);

  select to_regclass('public.homepage_sections') is not null into v_exists;
  insert into pg_temp.pwf_n2_6_role_browser_uat_results values
    ('public_homepage', 'homepage_sections_table_exists', v_exists, case when v_exists then 'public.homepage_sections exists' else 'public.homepage_sections missing' end);

  insert into pg_temp.pwf_n2_6_role_browser_uat_results values
    ('sovereign_boundary', 'no_waq_assets_mutation_in_this_script', true, 'Read-only temp-table evidence only; no waqf/waq_assets DML.');
end $$;

select *
from pg_temp.pwf_n2_6_role_browser_uat_results
order by section, check_key;
