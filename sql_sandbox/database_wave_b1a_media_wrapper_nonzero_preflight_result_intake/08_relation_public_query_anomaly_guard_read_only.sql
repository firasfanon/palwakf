-- Database Wave B-1A — Media Wrapper Nonzero Preflight Result Intake
-- 08: relation "public" query anomaly guard (READ ONLY)
-- Purpose: proves that public is a schema and that the required public media objects exist,
-- without ever querying "public" as a table/relation.

select
  'relation_public_query_anomaly_guard' as section,
  'public_schema_exists' as check_key,
  exists (
    select 1
    from information_schema.schemata
    where schema_name = 'public'
  ) as passed,
  'public is a schema; do not execute SELECT ... FROM public as if it were a table.' as note;

select *
from (
  select
    'relation_public_query_anomaly_guard' as section,
    'public.v_media_content_compat_v1' as object_name,
    to_regclass('public.v_media_content_compat_v1') is not null as passed,
    'view_presence' as decision
  union all
  select 'relation_public_query_anomaly_guard', 'public.v_media_news_compat_v1',
         to_regclass('public.v_media_news_compat_v1') is not null, 'view_presence'
  union all
  select 'relation_public_query_anomaly_guard', 'public.v_media_announcements_compat_v1',
         to_regclass('public.v_media_announcements_compat_v1') is not null, 'view_presence'
  union all
  select 'relation_public_query_anomaly_guard', 'public.v_media_activities_compat_v1',
         to_regclass('public.v_media_activities_compat_v1') is not null, 'view_presence'
  union all
  select 'relation_public_query_anomaly_guard', 'public.v_media_gallery_compat_v1',
         to_regclass('public.v_media_gallery_compat_v1') is not null, 'view_presence'
  union all
  select 'relation_public_query_anomaly_guard', 'media_center.v_content_items_public_v1',
         to_regclass('media_center.v_content_items_public_v1') is not null, 'view_presence'
) s
order by object_name;

select
  'relation_public_query_anomaly_guard' as section,
  'rpc_signature_presence' as check_key,
  exists (
    select 1
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname = 'rpc_media_content_compat_v1'
      and pg_get_function_identity_arguments(p.oid) = 'p_content_type text, p_unit_slug text, p_search text, p_limit integer, p_offset integer'
  ) as passed,
  'rpc_presence_check_without_querying_public_as_relation' as note;
