-- Database Wave B-0A
-- Read-only UAT gate. No DDL. No DML. No waqf_assets mutation.

select
  'wave_b0a_readiness' as section,
  'public_schema_exists' as check_key,
  to_regnamespace('public') is not null as passed,
  'public schema must exist as compatibility facade surface.' as note
union all
select
  'wave_b0a_readiness',
  'platform_schema_exists',
  to_regnamespace('platform') is not null,
  'platform schema should own registry/governance contracts.'
union all
select
  'wave_b0a_readiness',
  'platform_services_schema_exists',
  to_regnamespace('platform_services') is not null,
  'platform_services is the intended service center owner.'
union all
select
  'wave_b0a_readiness',
  'platform_content_schema_exists',
  to_regnamespace('platform_content') is not null,
  'platform_content remains generic shared content owner, not media sovereign owner.'
union all
select
  'wave_b0a_readiness',
  'gis_schema_exists',
  to_regnamespace('gis') is not null,
  'gis should own spatial authority and must be reviewed for locations.'
union all
select
  'wave_b0a_readiness',
  'waqf_schema_exists_read_only_check',
  to_regnamespace('waqf') is not null,
  'waqf is checked read-only; no mutation allowed.'
union all
select
  'wave_b0a_hotspots',
  'public_services_presence_detected',
  to_regclass('public.services') is not null,
  'If present, public.services is a compatibility/extraction hotspot, not production mutation target in B-0A.'
union all
select
  'wave_b0a_hotspots',
  'public_locations_presence_detected',
  to_regclass('public.locations') is not null,
  'If present, public.locations requires manual authority decision vs gis.locations.'
union all
select
  'wave_b0a_hotspots',
  'media_public_legacy_presence_scan',
  exists (
    select 1 from information_schema.tables
    where table_schema='public'
      and table_name in ('news','news_articles','announcements','activities','media_gallery_items','breaking_news')
  ),
  'If true, public media tables are Wave B ownership hotspots.'
union all
select
  'sovereign_boundary',
  'no_waq_assets_mutation_in_this_script',
  true,
  'Read-only UAT only; this script does not mutate waqf/waqf_assets/awqaf_system.';
