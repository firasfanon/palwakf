-- Database Wave B-1A — Media Public Compatibility Wrapper Controlled Activation
-- APPLY SCRIPT: activate public.* compatibility wrappers only.
-- Scope: public.v_media_*_compat_v1 + public.rpc_media_content_compat_v1 over media_center.v_content_items_public_v1.
-- No public media extraction, no data import, no mutation to public.activities/public.announcements/public.news_articles, no waqf mutation.

begin;

-- Guard: previous media_center bootstrap must be present.
do $$
begin
  if to_regnamespace('media_center') is null then
    raise exception 'media_center schema is required before public media compatibility wrapper activation';
  end if;

  if to_regclass('media_center.v_content_items_public_v1') is null then
    raise exception 'media_center.v_content_items_public_v1 is required before public media compatibility wrapper activation';
  end if;
end $$;

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
where content_type in ('gallery','media_gallery','photo_gallery','video_gallery');

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

comment on view public.v_media_content_compat_v1 is 'Public compatibility wrapper over media_center.v_content_items_public_v1. Controlled activation only; no legacy public media extraction.';
comment on view public.v_media_news_compat_v1 is 'Public media news compatibility wrapper over media_center content. Runtime reroute is not applied in this pack.';
comment on view public.v_media_announcements_compat_v1 is 'Public media announcements compatibility wrapper over media_center content. Runtime reroute is not applied in this pack.';
comment on view public.v_media_activities_compat_v1 is 'Public media activities/events compatibility wrapper over media_center content. Runtime reroute is not applied in this pack.';
comment on view public.v_media_gallery_compat_v1 is 'Public media gallery compatibility wrapper over media_center content. Runtime reroute is not applied in this pack.';
comment on function public.rpc_media_content_compat_v1(text,text,text,integer,integer) is 'Read-only media compatibility RPC over media_center public facade. No public legacy extraction and no waqf mutation.';

commit;
