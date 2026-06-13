-- Platform 12 — Homepage Sections Duplicate Remediation Preflight
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
    coalesce(s.unit_id::text, 'GLOBAL_NULL') as unit_scope,
    (a.canonical_key is not null and s.normalized_key <> a.canonical_key) as is_legacy_alias
  from source_rows s
  left join alias_map a on a.raw_key = s.normalized_key
), dupes as (
  select unit_scope, canonical_key
  from canonical_rows
  group by unit_scope, canonical_key
  having count(*) > 1
)
select
  'duplicate_row_preflight' as diagnostic,
  c.unit_scope,
  c.canonical_key,
  c.id,
  c.section_name,
  c.normalized_key,
  c.is_legacy_alias,
  c.is_active,
  c.display_order,
  c.updated_at,
  case
    when c.is_legacy_alias then 'candidate_deactivate_legacy_alias'
    when c.normalized_key = c.canonical_key then 'candidate_keep_canonical'
    else 'review_manually'
  end as suggested_action
from canonical_rows c
join dupes d on d.unit_scope = c.unit_scope and d.canonical_key = c.canonical_key
order by c.unit_scope, c.canonical_key, c.is_legacy_alias, c.display_order nulls last, c.section_name;
