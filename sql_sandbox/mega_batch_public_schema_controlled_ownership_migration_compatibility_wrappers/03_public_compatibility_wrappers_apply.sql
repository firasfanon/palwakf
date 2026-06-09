-- Mega Batch: Public Schema Controlled Ownership Migration + Compatibility Wrappers
-- Script 03: public compatibility wrapper creation.
-- Creates non-conflicting v_*_compat_v1 views/RPCs over target owner schemas.
-- Does not replace existing legacy public table names.

create schema if not exists platform;

create table if not exists platform.public_schema_migration_log (
  id bigserial primary key,
  batch_key text not null,
  source_relation text not null,
  target_relation text not null,
  migration_group text not null,
  source_rows bigint,
  target_rows_before bigint,
  target_rows_after bigint,
  action text not null,
  error_message text,
  created_at timestamptz not null default now()
);

do $$
declare
  item text[];
  wrappers text[][] := array[
    array['platform','app_settings','v_platform_app_settings_compat_v1'],
    array['platform','footer_settings','v_platform_footer_settings_compat_v1'],
    array['platform','header_settings','v_platform_header_settings_compat_v1'],
    array['platform','homepage_sections','v_platform_homepage_sections_compat_v1'],
    array['platform','site_pages','v_platform_site_pages_compat_v1'],
    array['platform','site_settings','v_platform_site_settings_compat_v1'],
    array['platform','home_config','v_platform_home_config_compat_v1'],
    array['platform','hero_slides','v_platform_hero_slides_compat_v1'],
    array['platform','home_stats','v_platform_home_stats_compat_v1'],
    array['platform','home_services','v_platform_home_services_compat_v1'],
    array['platform','home_hero_slides','v_platform_home_hero_slides_compat_v1'],
    array['platform','breaking_news','v_platform_breaking_news_compat_v1'],
    array['platform','platform_permissions','v_platform_permissions_compat_v1'],
    array['platform','platform_systems','v_platform_systems_compat_v1'],
    array['platform','user_permissions','v_platform_user_permissions_compat_v1'],
    array['platform','user_system_permissions','v_platform_user_system_permissions_compat_v1'],
    array['platform','user_system_roles','v_platform_user_system_roles_compat_v1'],
    array['core','admin_users','v_core_admin_users_compat_v1'],
    array['core','user_accounts','v_core_user_accounts_compat_v1'],
    array['core','org_units_cache','v_core_org_units_cache_compat_v1'],
    array['core','pwf_org_units_cache','v_core_pwf_org_units_cache_compat_v1'],
    array['assistant','assistant_conversations','v_assistant_conversations_compat_v1'],
    array['assistant','assistant_messages','v_assistant_messages_compat_v1'],
    array['assistant','chatbot_conversations','v_assistant_chatbot_conversations_compat_v1'],
    array['assistant','chatbot_messages','v_assistant_chatbot_messages_compat_v1'],
    array['assistant','chatbot_intents','v_assistant_chatbot_intents_compat_v1'],
    array['assistant','chatbot_retention_policies','v_assistant_chatbot_retention_policies_compat_v1']
  ];
  target_schema text;
  table_name text;
  view_name text;
  action_taken text;
  err text;
begin
  foreach item slice 1 in array wrappers loop
    target_schema := item[1];
    table_name := item[2];
    view_name := item[3];
    action_taken := 'not_started';
    err := null;
    begin
      if to_regclass(format('%I.%I', target_schema, table_name)) is null then
        action_taken := 'target_missing_skipped';
      else
        execute format('create or replace view public.%I as select * from %I.%I', view_name, target_schema, table_name);
        execute format('comment on view public.%I is %L', view_name,
          'Compatibility wrapper over ' || target_schema || '.' || table_name || '. Public remains a wrapper surface only. Legacy public tables are preserved.');
        action_taken := 'compat_view_created_or_replaced';
      end if;
    exception when others then
      action_taken := 'failed_guarded_exception';
      err := sqlerrm;
    end;

    insert into platform.public_schema_migration_log(
      batch_key, source_relation, target_relation, migration_group, action, error_message
    ) values (
      'public_schema_controlled_ownership_migration_wrappers_2026_05_22',
      target_schema || '.' || table_name,
      'public.' || view_name,
      'compatibility_wrapper',
      action_taken,
      err
    );
  end loop;
end $$;

create or replace view public.v_public_schema_controlled_migration_status_v1 as
select
  id,
  batch_key,
  source_relation,
  target_relation,
  migration_group,
  source_rows,
  target_rows_before,
  target_rows_after,
  action,
  error_message,
  created_at
from platform.public_schema_migration_log
where batch_key in (
  'public_schema_controlled_ownership_migration_2026_05_22',
  'public_schema_controlled_ownership_migration_wrappers_2026_05_22'
);

comment on view public.v_public_schema_controlled_migration_status_v1 is
  'Read-only public compatibility view for controlled public schema migration status.';

create or replace function public.rpc_public_schema_controlled_migration_status_v1()
returns setof public.v_public_schema_controlled_migration_status_v1
language sql
stable
security definer
set search_path = public, platform
as $$
  select * from public.v_public_schema_controlled_migration_status_v1 order by id;
$$;

select
  'public_compatibility_wrappers_apply' as section,
  target_relation as compatibility_object,
  action,
  error_message
from platform.public_schema_migration_log
where batch_key = 'public_schema_controlled_ownership_migration_wrappers_2026_05_22'
order by id;
