-- Mega Batch N2.2 — Platform Role Browser UAT Readiness Read-Only Check
-- Purpose: support Browser UAT evidence without mutating sovereign or production data.
-- Scope: platform identity/RBAC/service/media readiness only.
-- Does NOT touch waqf_assets, schema waqf, or awqaf_system internals.

create temp table if not exists pg_temp.pwf_n2_2_role_uat_results (
  section text,
  check_key text,
  passed boolean,
  note text
) on commit drop;

do $$
declare
  v_count bigint;
  v_exists boolean;
begin
  select to_regclass('public.admin_users') is not null into v_exists;
  insert into pg_temp.pwf_n2_2_role_uat_results values
    ('role_uat_readiness', 'admin_users_table_exists', v_exists, case when v_exists then 'public.admin_users exists.' else 'public.admin_users missing.' end);

  if v_exists then
    execute 'select count(*) from public.admin_users' into v_count;
    insert into pg_temp.pwf_n2_2_role_uat_results values
      ('role_uat_readiness', 'admin_users_present', v_count > 0, 'admin_users=' || v_count::text);
  end if;

  select to_regclass('public.platform_systems') is not null into v_exists;
  insert into pg_temp.pwf_n2_2_role_uat_results values
    ('role_uat_readiness', 'platform_systems_table_exists', v_exists, case when v_exists then 'public.platform_systems exists.' else 'public.platform_systems missing.' end);

  if v_exists then
    execute 'select count(*) from public.platform_systems' into v_count;
    insert into pg_temp.pwf_n2_2_role_uat_results values
      ('role_uat_readiness', 'platform_systems_present', v_count > 0, 'platform_systems=' || v_count::text);
  end if;

  select to_regclass('public.platform_permissions') is not null into v_exists;
  insert into pg_temp.pwf_n2_2_role_uat_results values
    ('role_uat_readiness', 'platform_permissions_table_exists', v_exists, case when v_exists then 'public.platform_permissions exists.' else 'public.platform_permissions missing.' end);

  select to_regclass('public.user_system_roles') is not null into v_exists;
  insert into pg_temp.pwf_n2_2_role_uat_results values
    ('role_uat_readiness', 'user_system_roles_table_exists', v_exists, case when v_exists then 'public.user_system_roles exists.' else 'public.user_system_roles missing.' end);

  select to_regclass('public.user_system_permissions') is not null into v_exists;
  insert into pg_temp.pwf_n2_2_role_uat_results values
    ('role_uat_readiness', 'user_system_permissions_table_exists', v_exists, case when v_exists then 'public.user_system_permissions exists.' else 'public.user_system_permissions missing.' end);

  select to_regclass('platform_services.service_requests') is not null into v_exists;
  insert into pg_temp.pwf_n2_2_role_uat_results values
    ('role_uat_readiness', 'service_requests_table_exists', v_exists, case when v_exists then 'platform_services.service_requests exists.' else 'platform_services.service_requests missing.' end);

  select to_regclass('platform_content.center_content_items') is not null into v_exists;
  insert into pg_temp.pwf_n2_2_role_uat_results values
    ('role_uat_readiness', 'platform_content_items_table_exists', v_exists, case when v_exists then 'platform_content.center_content_items exists.' else 'platform_content.center_content_items missing.' end);

  insert into pg_temp.pwf_n2_2_role_uat_results values
    ('sovereign_boundary', 'no_waq_assets_mutation_in_this_script', true, 'Read-only readiness check; no waqf/waqf_assets DML.');
end $$;

select *
from pg_temp.pwf_n2_2_role_uat_results
order by section, check_key;
