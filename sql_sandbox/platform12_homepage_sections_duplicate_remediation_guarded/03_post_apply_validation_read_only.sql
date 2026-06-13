-- Platform 12 — Post-Apply Validation for Homepage Section Duplicate Remediation
-- READ ONLY. No DDL/DML.

with alias_map(raw_key, canonical_key) as (
  values
    ('minister', 'pwf_minister_word'),
    ('statistics', 'pwf_stats_grid'),
    ('breaking_news', 'pwf_breaking_news_marquee'),
    ('announcements', 'pwf_announcements'),
    ('services', 'pwf_quick_services'),
    ('service_catalog', 'pwf_public_services_catalog'),
    ('services_catalog', 'pwf_public_services_catalog'),
    ('public_services_catalog', 'pwf_public_services_catalog'),
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
    coalesce(is_active, false) as is_active,
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
  'post_apply_duplicate_active_check' as diagnostic,
  unit_scope,
  canonical_key,
  count(*) as row_count,
  count(*) filter (where is_active) as active_count,
  array_agg(section_name order by display_order nulls last, section_name) as source_section_names
from canonical_rows
group by unit_scope, canonical_key
having count(*) filter (where is_active) > 1
order by active_count desc, row_count desc, unit_scope, canonical_key;
