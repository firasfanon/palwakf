-- Mega Batch N2.36
-- 57_domain_migration_wave_b_post_uat_READ_ONLY_N2_36.sql
-- Purpose: post execution UAT for SQL54/SQL55. Read-only single result set.
-- Safety: no DDL/DML; no waqf/waqf_assets/awqaf_system mutation.

with cache_checks as (
  select
    'cache_quarantine'::text as section,
    'org_units_cache_public_is_view'::text as check_key,
    exists (
      select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'org_units_cache' and c.relkind = 'v'
    ) as passed,
    'public.org_units_cache should be a compatibility view after quarantine.'::text as note
  union all
  select
    'cache_quarantine',
    'pwf_org_units_cache_public_is_view',
    exists (
      select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'pwf_org_units_cache' and c.relkind = 'v'
    ),
    'public.pwf_org_units_cache should be a compatibility view after quarantine.'
  union all
  select
    'cache_quarantine',
    'org_units_cache_archived_table_exists',
    exists (
      select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'legacy_archive' and c.relname = 'org_units_cache' and c.relkind in ('r','p')
    ),
    'legacy_archive.org_units_cache should retain the old table for rollback/audit.'
  union all
  select
    'cache_quarantine',
    'pwf_org_units_cache_archived_table_exists',
    exists (
      select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'legacy_archive' and c.relname = 'pwf_org_units_cache' and c.relkind in ('r','p')
    ),
    'legacy_archive.pwf_org_units_cache should retain the old table for rollback/audit.'
), site_content_checks as (
  select
    'site_content_migration'::text as section,
    'header_settings_site_content_table_exists'::text as check_key,
    exists (
      select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'site_content' and c.relname = 'header_settings' and c.relkind in ('r','p')
    ) as passed,
    'site_content.header_settings should become source-of-truth after SQL55.'::text as note
  union all
  select
    'site_content_migration',
    'footer_settings_site_content_table_exists',
    exists (
      select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'site_content' and c.relname = 'footer_settings' and c.relkind in ('r','p')
    ),
    'site_content.footer_settings should become source-of-truth after SQL55.'
  union all
  select
    'site_content_migration',
    'header_settings_public_is_view',
    exists (
      select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'header_settings' and c.relkind = 'v'
    ),
    'public.header_settings should remain as a compatibility view.'
  union all
  select
    'site_content_migration',
    'footer_settings_public_is_view',
    exists (
      select 1 from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = 'footer_settings' and c.relkind = 'v'
    ),
    'public.footer_settings should remain as a compatibility view.'
), column_compatibility as (
  select
    'site_content_migration'::text as section,
    'header_settings_column_order_compatible'::text as check_key,
    coalesce((
      select string_agg(a.attname || ':' || a.atttypid::regtype::text, ',' order by a.attnum)
      from pg_class c join pg_namespace n on n.oid = c.relnamespace
      join pg_attribute a on a.attrelid = c.oid
      where n.nspname = 'public' and c.relname = 'header_settings' and a.attnum > 0 and not a.attisdropped
    ), '') = coalesce((
      select string_agg(a.attname || ':' || a.atttypid::regtype::text, ',' order by a.attnum)
      from pg_class c join pg_namespace n on n.oid = c.relnamespace
      join pg_attribute a on a.attrelid = c.oid
      where n.nspname = 'site_content' and c.relname = 'header_settings' and a.attnum > 0 and not a.attisdropped
    ), '') as passed,
    'public.header_settings view must preserve source column order/types.'::text as note
  union all
  select
    'site_content_migration',
    'footer_settings_column_order_compatible',
    coalesce((
      select string_agg(a.attname || ':' || a.atttypid::regtype::text, ',' order by a.attnum)
      from pg_class c join pg_namespace n on n.oid = c.relnamespace
      join pg_attribute a on a.attrelid = c.oid
      where n.nspname = 'public' and c.relname = 'footer_settings' and a.attnum > 0 and not a.attisdropped
    ), '') = coalesce((
      select string_agg(a.attname || ':' || a.atttypid::regtype::text, ',' order by a.attnum)
      from pg_class c join pg_namespace n on n.oid = c.relnamespace
      join pg_attribute a on a.attrelid = c.oid
      where n.nspname = 'site_content' and c.relname = 'footer_settings' and a.attnum > 0 and not a.attisdropped
    ), ''),
    'public.footer_settings view must preserve source column order/types.'
), sovereign_boundary as (
  select
    'sovereign_boundary'::text as section,
    'no_waq_assets_mutation_in_this_script'::text as check_key,
    true as passed,
    'Read-only UAT only; no DDL/DML; no waqf/waqf_assets/awqaf_system mutation.'::text as note
)
select * from cache_checks
union all select * from site_content_checks
union all select * from column_compatibility
union all select * from sovereign_boundary
order by section, check_key;
