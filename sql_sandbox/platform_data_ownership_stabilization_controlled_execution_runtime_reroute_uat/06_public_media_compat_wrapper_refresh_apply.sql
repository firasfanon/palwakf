-- 06_public_media_compat_wrapper_refresh_apply.sql
-- APPLY. Refreshes public media compatibility wrappers after controlled normalization/mapping.
-- No legacy public table deletion. No waqf mutation.

begin;

create or replace view public.v_media_content_compat_v1 as
select
  id,
  content_key,
  content_type,
  title_ar,
  title_en,
  summary_ar,
  summary_en,
  category_key,
  unit_slug,
  published_at,
  metadata,
  created_at,
  updated_at,
  'media_center'::text as source_schema_name,
  'public.v_media_content_compat_v1'::text as compatibility_contract
from media_center.v_content_items_public_v1;

create or replace view public.v_media_news_compat_v1 as
select *
from public.v_media_content_compat_v1
where content_type in ('news','news_article','breaking_news','press_release','official_statement');

create or replace view public.v_media_announcements_compat_v1 as
select *
from public.v_media_content_compat_v1
where content_type in ('announcement','public_announcement');

create or replace view public.v_media_activities_compat_v1 as
select *
from public.v_media_content_compat_v1
where content_type in ('activity','event','media_activity');

create or replace view public.v_media_gallery_compat_v1 as
select *
from public.v_media_content_compat_v1
where content_type in ('gallery','media_gallery','photo_gallery','video_gallery')
union all
select
  ca.id,
  coalesce(ca.content_key, 'asset_' || ca.id::text) as content_key,
  case when lower(coalesce(ca.asset_type,'')) like '%video%' then 'video_gallery' else 'photo_gallery' end as content_type,
  coalesce(ca.title_ar, ci.title_ar, 'عنصر معرض') as title_ar,
  ca.title_en,
  coalesce(ca.alt_text_ar, ci.summary_ar) as summary_ar,
  ca.alt_text_en as summary_en,
  coalesce(ci.category_key, ca.asset_type, 'gallery') as category_key,
  coalesce(ca.unit_slug, ci.unit_slug) as unit_slug,
  coalesce(ca.published_at, ci.published_at) as published_at,
  coalesce(ca.metadata, '{}'::jsonb) || jsonb_build_object(
    'asset_public_url', ca.url,
    'asset_storage_path', ca.storage_path,
    'asset_type', ca.asset_type,
    'content_item_id', ca.content_item_id
  ) as metadata,
  ca.created_at,
  ca.updated_at,
  'media_center'::text as source_schema_name,
  'public.v_media_gallery_compat_v1'::text as compatibility_contract
from media_center.content_assets ca
join media_center.content_items ci on ci.id = ca.content_item_id
where ci.status='published'
  and ci.visibility_scope='public'
  and (ci.published_at is null or ci.published_at <= now());

create or replace function public.rpc_media_content_compat_v1(
  p_content_type text default null,
  p_category_key text default null,
  p_unit_slug text default null,
  p_limit integer default 20,
  p_offset integer default 0
)
returns table (
  id uuid,
  content_key text,
  content_type text,
  title_ar text,
  title_en text,
  summary_ar text,
  summary_en text,
  category_key text,
  unit_slug text,
  published_at timestamptz,
  metadata jsonb,
  created_at timestamptz,
  updated_at timestamptz,
  source_schema_name text,
  compatibility_contract text
)
language sql
stable
security invoker
as $$
  select
    v.id,
    v.content_key,
    v.content_type,
    v.title_ar,
    v.title_en,
    v.summary_ar,
    v.summary_en,
    v.category_key,
    v.unit_slug,
    v.published_at,
    v.metadata,
    v.created_at,
    v.updated_at,
    v.source_schema_name,
    v.compatibility_contract
  from public.v_media_content_compat_v1 v
  where (p_content_type is null or v.content_type = p_content_type)
    and (p_category_key is null or v.category_key = p_category_key)
    and (p_unit_slug is null or v.unit_slug = p_unit_slug)
  order by v.published_at desc nulls last, v.created_at desc
  limit least(greatest(coalesce(p_limit, 20), 1), 100)
  offset greatest(coalesce(p_offset, 0), 0)
$$;

grant select on public.v_media_content_compat_v1 to anon, authenticated;
grant select on public.v_media_news_compat_v1 to anon, authenticated;
grant select on public.v_media_announcements_compat_v1 to anon, authenticated;
grant select on public.v_media_activities_compat_v1 to anon, authenticated;
grant select on public.v_media_gallery_compat_v1 to anon, authenticated;
grant execute on function public.rpc_media_content_compat_v1(text,text,text,integer,integer) to anon, authenticated;

commit;

select 'media_wrapper_refresh_result' as section, contract_name, row_count from (
  select 'public.v_media_content_compat_v1' contract_name, (select count(*) from public.v_media_content_compat_v1)::bigint row_count
  union all select 'public.v_media_news_compat_v1', (select count(*) from public.v_media_news_compat_v1)::bigint
  union all select 'public.v_media_announcements_compat_v1', (select count(*) from public.v_media_announcements_compat_v1)::bigint
  union all select 'public.v_media_activities_compat_v1', (select count(*) from public.v_media_activities_compat_v1)::bigint
  union all select 'public.v_media_gallery_compat_v1', (select count(*) from public.v_media_gallery_compat_v1)::bigint
) s order by contract_name;
