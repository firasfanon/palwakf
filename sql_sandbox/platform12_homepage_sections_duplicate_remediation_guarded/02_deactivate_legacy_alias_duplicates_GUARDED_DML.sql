-- Platform 12 — Guarded DML: Deactivate legacy alias duplicate homepage sections
-- WRITE SCRIPT. DO NOT RUN unless explicitly authorized.
-- Required token:
--   PLATFORM12_DEACTIVATE_DUPLICATE_HOME_SECTIONS_2026_06_13
-- Operator execution pattern:
--   begin;
--   set local pwf.operator_approval_token = 'PLATFORM12_DEACTIVATE_DUPLICATE_HOME_SECTIONS_2026_06_13';
--   \i sql_sandbox/platform12_homepage_sections_duplicate_remediation_guarded/02_deactivate_legacy_alias_duplicates_GUARDED_DML.sql
--   -- inspect returned rows
--   commit; -- or rollback

-- Safety gate.
do $$
begin
  if current_setting('pwf.operator_approval_token', true) <> 'PLATFORM12_DEACTIVATE_DUPLICATE_HOME_SECTIONS_2026_06_13' then
    raise exception 'Missing operator approval token. This guarded DML must not be executed without explicit authorization.';
  end if;
end $$;

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
    h.id,
    h.unit_id,
    h.section_name,
    lower(regexp_replace(regexp_replace(trim(h.section_name), '[^a-zA-Z0-9]+', '_', 'g'), '_+', '_', 'g')) as normalized_key,
    coalesce(h.is_active, false) as is_active
  from public.homepage_sections h
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
), candidates as (
  select c.id
  from canonical_rows c
  join dupes d on d.unit_scope = c.unit_scope and d.canonical_key = c.canonical_key
  where c.is_legacy_alias = true
)
update public.homepage_sections h
set
  is_active = false,
  updated_at = now()
from candidates c
where h.id = c.id
returning
  'legacy_alias_duplicate_deactivated' as action,
  h.id,
  h.unit_id,
  h.section_name,
  h.is_active,
  h.updated_at;
