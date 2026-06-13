
-- MEDIA_CENTER_MOBILE_APPLICATION_OWNER_SCHEMA_PUBLIC_API_EDGE_MVP
-- READ ONLY diagnostics only.
--
-- No SQL apply.
-- No public base table creation.
-- No RLS mutation.

select
  'media_center_mobile_api_edge_preflight' as section,
  to_regclass('public.v_media_news_compat_v1') is not null as news_api_edge_present,
  to_regclass('public.v_media_announcements_compat_v1') is not null as announcements_api_edge_present,
  to_regclass('public.v_media_activities_compat_v1') is not null as activities_api_edge_present,
  false as public_base_table_creation_authorized,
  false as production_approved;

select
  'media_center_mobile_api_edge_counts' as section,
  'news' as family,
  count(*)::bigint as row_count
from public.v_media_news_compat_v1
union all
select
  'media_center_mobile_api_edge_counts',
  'announcements',
  count(*)::bigint
from public.v_media_announcements_compat_v1
union all
select
  'media_center_mobile_api_edge_counts',
  'activities',
  count(*)::bigint
from public.v_media_activities_compat_v1;

select
  'media_center_mobile_public_schema_policy' as section,
  true as public_schema_is_api_edge_only,
  true as owner_schema_is_media_center,
  false as public_base_tables_as_source_of_truth,
  false as service_role_allowed,
  false as production_approved;
