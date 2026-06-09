-- Mega Batch F — Operational Maturity Read-only UAT
-- Purpose: verify platform maturity anchors without mutating data.

select
  'homepage_public_services_section' as section,
  count(*) as row_count
from public.homepage_sections
where section_name = 'pwf_public_services_catalog';

select
  'active_public_services' as section,
  count(*) as row_count
from public.services
where coalesce(is_active, false) = true;

select
  'homepage_scope_duplicates' as section,
  section_name,
  unit_id,
  count(*) as duplicate_count
from public.homepage_sections
group by section_name, unit_id
having count(*) > 1;

select
  'awqaf_assets_tables_presence_read_only' as section,
  table_schema,
  table_name
from information_schema.tables
where table_schema = 'waqf'
  and table_name in (
    'waqf_assets',
    'waqf_asset_source_records',
    'waqf_asset_review_events',
    'waqf_asset_duplicate_candidates',
    'waqf_asset_source_parcel_match_candidates',
    'waqf_asset_parcel_links'
  )
order by table_name;
