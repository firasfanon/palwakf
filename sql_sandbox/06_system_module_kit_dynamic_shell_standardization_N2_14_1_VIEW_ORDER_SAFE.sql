-- Mega Batch N2.14.1
-- System Module Kit SQL View Column Order Hotfix
-- Purpose: make N2.14 SQL safe against existing public views whose column order was defined in N2.10.
-- Reason: PostgreSQL CREATE OR REPLACE VIEW cannot change existing view column names/order.
-- No waqf / waqf_assets / awqaf_system DML.

create schema if not exists platform;

alter table if exists platform.system_registry
  add column if not exists system_type text not null default 'generic',
  add column if not exists sensitivity_level text not null default 'standard',
  add column if not exists route_base text,
  add column if not exists public_home_enabled boolean not null default false,
  add column if not exists health_check_key text,
  add column if not exists operational_status text not null default 'active',
  add column if not exists maintenance_mode boolean not null default false,
  add column if not exists maintenance_message_ar text not null default '',
  add column if not exists error_boundary_key text not null default 'default',
  add column if not exists assistant_scope_key text not null default 'system',
  add column if not exists usage_guide_scope_key text not null default 'system';

alter table if exists platform.system_sections
  add column if not exists section_scope text not null default 'system',
  add column if not exists public_visibility boolean not null default false,
  add column if not exists health_check_key text,
  add column if not exists operational_status text not null default 'active',
  add column if not exists maintenance_mode boolean not null default false,
  add column if not exists maintenance_message_ar text not null default '',
  add column if not exists error_boundary_key text not null default 'default',
  add column if not exists assistant_scope_key text not null default 'section',
  add column if not exists usage_guide_scope_key text not null default 'section';

-- IMPORTANT:
-- Keep all N2.10 view columns in the exact same order and append N2.14 columns at the end.
-- This avoids ERROR 42P16: cannot change name of view column "admin_route_path" to "system_type".
create or replace view public.v_platform_system_registry as
select
  system_key,
  name_ar,
  name_en,
  description_ar,
  category_key,
  module_type,
  coalesce(nullif(admin_route_path, ''), '/admin/systems/' || system_key) as admin_route_path,
  public_route_path,
  external_url,
  icon_key,
  display_order,
  is_active,
  show_in_dashboard,
  show_in_sidebar,
  requires_permission,
  is_sovereign,
  metadata,
  system_type,
  sensitivity_level,
  coalesce(route_base, '/admin/systems/' || system_key) as route_base,
  public_home_enabled,
  health_check_key,
  operational_status,
  maintenance_mode,
  maintenance_message_ar,
  error_boundary_key,
  assistant_scope_key,
  usage_guide_scope_key
from platform.system_registry
where is_active = true;

create or replace view public.v_platform_system_sections as
select
  system_key,
  section_key,
  title_ar,
  description_ar,
  coalesce(nullif(route_path, ''), '/admin/systems/' || system_key || '/sections/' || section_key) as route_path,
  section_type,
  icon_key,
  display_order,
  is_active,
  show_in_dashboard,
  show_in_sidebar,
  required_permission_key,
  metadata,
  section_scope,
  public_visibility,
  health_check_key,
  operational_status,
  maintenance_mode,
  maintenance_message_ar,
  error_boundary_key,
  assistant_scope_key,
  usage_guide_scope_key
from platform.system_sections
where is_active = true;

create or replace function public.pwf_platform_system_module_kit_contract_v1()
returns jsonb
language sql
stable
security definer
set search_path = public, platform
as $$
  select jsonb_build_object(
    'contract_key', 'system_module_kit_n2_14_1_view_order_safe',
    'platform_schema_exists', exists(select 1 from information_schema.schemata where schema_name = 'platform'),
    'system_registry_exists', to_regclass('platform.system_registry') is not null,
    'system_sections_exists', to_regclass('platform.system_sections') is not null,
    'registry_view_exists', to_regclass('public.v_platform_system_registry') is not null,
    'sections_view_exists', to_regclass('public.v_platform_system_sections') is not null,
    'system_registry_columns', (
      select coalesce(jsonb_agg(column_name order by column_name), '[]'::jsonb)
      from information_schema.columns
      where table_schema = 'platform'
        and table_name = 'system_registry'
        and column_name in ('system_type','sensitivity_level','route_base','public_home_enabled','health_check_key','operational_status','maintenance_mode','error_boundary_key','assistant_scope_key','usage_guide_scope_key')
    ),
    'system_sections_columns', (
      select coalesce(jsonb_agg(column_name order by column_name), '[]'::jsonb)
      from information_schema.columns
      where table_schema = 'platform'
        and table_name = 'system_sections'
        and column_name in ('section_scope','public_visibility','health_check_key','operational_status','maintenance_mode','error_boundary_key','assistant_scope_key','usage_guide_scope_key')
    ),
    'registry_view_n2_10_order_preserved', exists (
      select 1
      from information_schema.columns
      where table_schema = 'public'
        and table_name = 'v_platform_system_registry'
        and column_name = 'admin_route_path'
        and ordinal_position = 7
    ),
    'registry_view_n2_14_columns_appended', exists (
      select 1
      from information_schema.columns
      where table_schema = 'public'
        and table_name = 'v_platform_system_registry'
        and column_name = 'system_type'
        and ordinal_position > 17
    ),
    'sections_view_n2_14_columns_appended', exists (
      select 1
      from information_schema.columns
      where table_schema = 'public'
        and table_name = 'v_platform_system_sections'
        and column_name = 'section_scope'
        and ordinal_position > 13
    ),
    'no_waq_assets_mutation', true
  );
$$;

grant select on public.v_platform_system_registry, public.v_platform_system_sections to anon, authenticated;
grant execute on function public.pwf_platform_system_module_kit_contract_v1() to authenticated;
