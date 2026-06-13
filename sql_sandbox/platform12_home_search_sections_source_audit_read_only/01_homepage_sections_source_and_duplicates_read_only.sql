-- Platform 12 — Homepage Sections Source + Duplicate Canonical Key Diagnostics
-- READ ONLY. Do not run as a write operation.
-- No DDL/DML/GRANT/REVOKE/DROP/TRUNCATE/ALTER/UPDATE/INSERT/DELETE.

with object_presence as (
  select
    'object_presence' as section,
    to_regclass('public.v_platform_homepage_sections_compat_v1') is not null as compat_view_present,
    to_regclass('public.homepage_sections') is not null as legacy_table_present
), alias_map(raw_key, canonical_key) as (
  values
    ('minister', 'pwf_minister_word'),
    ('statistics', 'pwf_stats_grid'),
    ('breaking_news', 'pwf_breaking_news_marquee'),
    ('announcements', 'pwf_announcements'),
    ('services', 'pwf_quick_services'),
    ('service_catalog', 'pwf_public_services_catalog'),
    ('services_catalog', 'pwf_public_services_catalog'),
    ('public_services_catalog', 'pwf_public_services_catalog'),
    ('media_center_highlights', 'pwf_media_center_highlights'),
    ('services_center_highlights', 'pwf_services_center_highlights'),
    ('social_posts', 'pwf_social_posts_section'),
    ('press_releases', 'pwf_press_releases_section'),
    ('official_statements', 'pwf_official_statements_section'),
    ('awareness_campaigns', 'pwf_awareness_campaigns_section'),
    ('sanctities_observatory', 'pwf_sanctities_observatory_section'),
    ('legal_references', 'pwf_legal_references_section'),
    ('events', 'pwf_events_section'),
    ('pwf_services_catalog', 'pwf_public_services_catalog'),
    ('news', 'pwf_news_tabs'),
    ('top_bar', 'pwf_top_bar'),
    ('pwf_topbar', 'pwf_top_bar'),
    ('main_nav', 'pwf_main_nav'),
    ('pwf_mainnav', 'pwf_main_nav'),
    ('footer', 'pwf_footer')
), source_rows as (
  select
    id,
    unit_id,
    section_name,
    lower(regexp_replace(regexp_replace(trim(section_name), '[^a-zA-Z0-9]+', '_', 'g'), '_+', '_', 'g')) as normalized_key,
    is_active,
    display_order,
    updated_at
  from public.v_platform_homepage_sections_compat_v1
), canonical_rows as (
  select
    s.*,
    coalesce(a.canonical_key, s.normalized_key) as canonical_key,
    coalesce(s.unit_id::text, 'GLOBAL_NULL') as unit_scope
  from source_rows s
  left join alias_map a on a.raw_key = s.normalized_key
)
select
  'canonical_duplicate_keys' as diagnostic,
  unit_scope,
  canonical_key,
  count(*) as row_count,
  count(*) filter (where coalesce(is_active, false)) as active_count,
  array_agg(section_name order by display_order nulls last, section_name) as source_section_names,
  min(display_order) as min_display_order,
  max(updated_at) as latest_updated_at
from canonical_rows
where canonical_key is not null and canonical_key <> ''
group by unit_scope, canonical_key
having count(*) > 1 or count(*) filter (where coalesce(is_active, false)) > 1
order by active_count desc, row_count desc, unit_scope, canonical_key;

-- Expected interpretation:
-- - Any returned row means more than one source row maps to the same logical section.
-- - Active duplicates should be cleaned or scoped intentionally.
