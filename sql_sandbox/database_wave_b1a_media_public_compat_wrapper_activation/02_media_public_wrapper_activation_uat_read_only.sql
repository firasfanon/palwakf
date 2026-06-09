-- Database Wave B-1A — Media Public Compatibility Wrapper Activation UAT
-- Read-only verification after 01_media_public_compat_wrapper_activation.sql.

select
  'media_public_wrapper_activation_uat' as section,
  contract_name,
  object_type,
  object_exists,
  row_count,
  activation_decision
from (
  select
    'public.v_media_content_compat_v1'::text as contract_name,
    'view'::text as object_type,
    to_regclass('public.v_media_content_compat_v1') is not null as object_exists,
    (select count(*) from public.v_media_content_compat_v1)::bigint as row_count,
    'activated-read-only-public-wrapper'::text as activation_decision
  union all
  select 'public.v_media_news_compat_v1','view',to_regclass('public.v_media_news_compat_v1') is not null,(select count(*) from public.v_media_news_compat_v1)::bigint,'activated-read-only-public-wrapper'
  union all
  select 'public.v_media_announcements_compat_v1','view',to_regclass('public.v_media_announcements_compat_v1') is not null,(select count(*) from public.v_media_announcements_compat_v1)::bigint,'activated-read-only-public-wrapper'
  union all
  select 'public.v_media_activities_compat_v1','view',to_regclass('public.v_media_activities_compat_v1') is not null,(select count(*) from public.v_media_activities_compat_v1)::bigint,'activated-read-only-public-wrapper'
  union all
  select 'public.v_media_gallery_compat_v1','view',to_regclass('public.v_media_gallery_compat_v1') is not null,(select count(*) from public.v_media_gallery_compat_v1)::bigint,'activated-read-only-public-wrapper'
  union all
  select 'public.rpc_media_content_compat_v1(text,text,text,integer,integer)','rpc',to_regprocedure('public.rpc_media_content_compat_v1(text,text,text,integer,integer)') is not null,null::bigint,'activated-read-only-public-rpc'
) s
order by contract_name;
