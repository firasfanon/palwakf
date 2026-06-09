-- DRAFT ONLY — DO NOT RUN IN THIS PACK
-- Future candidate after media_center bootstrap UAT + RLS certification + public/admin mapping approval.
-- This would activate public compatibility wrappers, but B-1A controlled bootstrap does NOT authorize it.

/*
create or replace view public.v_media_content_compat_v1 as
select * from media_center.v_content_items_public_v1;

create or replace function public.rpc_media_content_compat_v1(
  p_content_type text default null,
  p_limit integer default 20
)
returns setof media_center.v_content_items_public_v1
language sql
stable
security definer
set search_path = public, media_center
as $$
  select *
  from media_center.v_content_items_public_v1 v
  where p_content_type is null or v.content_type = p_content_type
  order by v.published_at desc nulls last, v.created_at desc
  limit greatest(1, least(coalesce(p_limit,20), 100));
$$;
*/
