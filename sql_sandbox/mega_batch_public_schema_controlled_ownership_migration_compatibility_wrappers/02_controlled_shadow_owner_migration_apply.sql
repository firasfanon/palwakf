-- Mega Batch: Public Schema Controlled Ownership Migration + Compatibility Wrappers
-- Script 02: controlled shadow owner migration apply.
-- This script copies selected public operational tables into target owner schemas only when target tables are empty.
-- It preserves legacy public tables. It does not rename/drop/delete legacy objects.

create schema if not exists platform;
create schema if not exists core;
create schema if not exists assistant;

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

comment on table platform.public_schema_migration_log is
  'Controlled public schema ownership migration log. This does not authorize legacy public table deletion.';

do $$
declare
  item text[];
  candidates text[][] := array[
    array['platform','app_settings','platform_shell'],
    array['platform','footer_settings','platform_shell'],
    array['platform','header_settings','platform_shell'],
    array['platform','homepage_sections','platform_shell'],
    array['platform','site_pages','platform_shell'],
    array['platform','site_settings','platform_shell'],
    array['platform','home_config','platform_shell'],
    array['platform','hero_slides','platform_shell'],
    array['platform','home_stats','platform_shell'],
    array['platform','home_services','platform_shell'],
    array['platform','home_hero_slides','platform_shell'],
    array['platform','breaking_news','platform_shell'],
    array['platform','platform_permissions','platform_access'],
    array['platform','platform_systems','platform_access'],
    array['platform','user_permissions','platform_access'],
    array['platform','user_system_permissions','platform_access'],
    array['platform','user_system_roles','platform_access'],
    array['core','admin_users','core_identity_linkage'],
    array['core','user_accounts','core_identity_linkage'],
    array['core','org_units_cache','core_org_linkage'],
    array['core','pwf_org_units_cache','core_org_linkage'],
    array['assistant','assistant_conversations','assistant'],
    array['assistant','assistant_messages','assistant'],
    array['assistant','chatbot_conversations','assistant'],
    array['assistant','chatbot_messages','assistant'],
    array['assistant','chatbot_intents','assistant'],
    array['assistant','chatbot_retention_policies','assistant']
  ];
  target_schema text;
  table_name text;
  migration_group text;
  source_rows bigint := 0;
  target_before bigint := 0;
  target_after bigint := 0;
  action_taken text;
  err text;
begin
  foreach item slice 1 in array candidates loop
    target_schema := item[1];
    table_name := item[2];
    migration_group := item[3];
    source_rows := null;
    target_before := null;
    target_after := null;
    action_taken := 'not_started';
    err := null;

    begin
      if to_regclass(format('public.%I', table_name)) is null then
        action_taken := 'source_missing_skipped';
      else
        execute format('create table if not exists %I.%I (like public.%I including all)', target_schema, table_name, table_name);
        execute format('select count(*) from public.%I', table_name) into source_rows;
        execute format('select count(*) from %I.%I', target_schema, table_name) into target_before;

        if coalesce(target_before, 0) = 0 then
          execute format('insert into %I.%I select * from public.%I', target_schema, table_name, table_name);
          execute format('select count(*) from %I.%I', target_schema, table_name) into target_after;
          action_taken := 'copied_source_to_empty_target';
        else
          target_after := target_before;
          action_taken := 'target_nonempty_preserved_no_copy';
        end if;
      end if;
    exception when others then
      action_taken := 'failed_guarded_exception';
      err := sqlerrm;
    end;

    insert into platform.public_schema_migration_log(
      batch_key,
      source_relation,
      target_relation,
      migration_group,
      source_rows,
      target_rows_before,
      target_rows_after,
      action,
      error_message
    ) values (
      'public_schema_controlled_ownership_migration_2026_05_22',
      'public.' || table_name,
      target_schema || '.' || table_name,
      migration_group,
      source_rows,
      target_before,
      target_after,
      action_taken,
      err
    );
  end loop;
end $$;

select
  'controlled_shadow_migration_apply' as section,
  source_relation,
  target_relation,
  migration_group,
  source_rows,
  target_rows_before,
  target_rows_after,
  action,
  error_message
from platform.public_schema_migration_log
where batch_key = 'public_schema_controlled_ownership_migration_2026_05_22'
order by id;
