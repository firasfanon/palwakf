-- Public Legacy Dependency Reduction Pack
-- 02_PUBLIC_LEGACY_EXACT_BODY_EXPORT_READ_ONLY.sql
-- Purpose: export exact routine bodies before any rewrite.
-- Read-only. Excludes aggregate/window functions to avoid pg_get_functiondef() failures.

with legacy_terms(term, domain_key, target_decision) as (
  values
    ('public.news_articles', 'media_center', 'rewrite_reference_to_media_owner_or_public_compat_surface'),
    ('news_articles', 'media_center', 'rewrite_reference_to_media_owner_or_public_compat_surface'),
    ('public.announcements', 'media_center', 'rewrite_reference_to_media_owner_or_public_compat_surface'),
    ('announcements', 'media_center', 'rewrite_reference_to_media_owner_or_public_compat_surface'),
    ('public.activities', 'media_center', 'rewrite_reference_to_media_owner_or_public_compat_surface'),
    ('activities', 'media_center', 'rewrite_reference_to_media_owner_or_public_compat_surface'),
    ('public.breaking_news', 'media_center', 'rewrite_reference_to_media_owner_or_public_compat_surface'),
    ('breaking_news', 'media_center', 'rewrite_reference_to_media_owner_or_public_compat_surface'),
    ('public.media_gallery_items', 'media_center', 'rewrite_reference_to_media_owner_or_public_compat_surface'),
    ('media_gallery_items', 'media_center', 'rewrite_reference_to_media_owner_or_public_compat_surface'),
    ('public.services', 'service_center', 'rewrite_reference_to_platform_services_after_mapping_gap_closure'),
    ('services', 'service_center', 'rewrite_reference_to_platform_services_after_mapping_gap_closure'),
    ('public.servicepoints', 'service_center', 'preserve_until_owner_target_defined'),
    ('servicepoints', 'service_center', 'preserve_until_owner_target_defined'),
    ('public.serviceproviders', 'service_center', 'preserve_until_owner_target_defined'),
    ('serviceproviders', 'service_center', 'preserve_until_owner_target_defined'),
    ('public.servicetypes', 'service_center', 'preserve_until_owner_target_defined'),
    ('servicetypes', 'service_center', 'preserve_until_owner_target_defined')
),
safe_routines as (
  select
    p.oid,
    pn.nspname,
    p.proname,
    pg_get_function_identity_arguments(p.oid) as args,
    p.prokind,
    pg_get_functiondef(p.oid) as function_body
  from pg_proc p
  join pg_namespace pn on pn.oid = p.pronamespace
  where p.prokind in ('f', 'p')
    and pn.nspname not in ('pg_catalog', 'information_schema')
),
matched as (
  select
    sr.oid,
    sr.nspname,
    sr.proname,
    sr.args,
    sr.function_body,
    string_agg(distinct lt.domain_key, ', ' order by lt.domain_key) as matched_domains,
    string_agg(distinct lt.term, ', ' order by lt.term) as matched_terms,
    string_agg(distinct lt.target_decision, ', ' order by lt.target_decision) as target_decisions
  from safe_routines sr
  join legacy_terms lt
    on sr.function_body ilike '%' || lt.term || '%'
  group by sr.oid, sr.nspname, sr.proname, sr.args, sr.function_body
)
select
  'public_legacy_exact_body_export' as section,
  nspname || '.' || proname || '(' || args || ')' as routine_signature,
  matched_domains,
  matched_terms,
  target_decisions,
  function_body,
  false as rewrite_authorized_by_this_script,
  false as destructive_sql_authorized,
  false as production_approved,
  true as read_only
from matched
order by matched_domains, routine_signature;
