-- Database Wave B-1A Media Runtime Strategy Decision
-- 01_media_wrapper_state_and_empty_contract_recheck.sql
-- Read-only. Corrects prior planning bug by avoiding FROM media_center as a relation.

with wrapper_objects as (
  select * from (values
    ('public.v_media_content_compat_v1'::text, 'content_all'),
    ('public.v_media_news_compat_v1'::text, 'news'),
    ('public.v_media_announcements_compat_v1'::text, 'announcements'),
    ('public.v_media_activities_compat_v1'::text, 'activities'),
    ('public.v_media_gallery_compat_v1'::text, 'gallery')
  ) as v(contract_name, content_kind)
), object_state as (
  select
    contract_name,
    content_kind,
    to_regclass(contract_name) is not null as object_exists
  from wrapper_objects
), schema_state as (
  select exists (
    select 1 from information_schema.schemata where schema_name = 'media_center'
  ) as media_center_schema_exists,
  to_regclass('media_center.content_items') is not null as content_items_exists,
  to_regclass('media_center.v_content_items_public_v1') is not null as public_view_exists
)
select
  'media_runtime_strategy_wrapper_state' as section,
  o.contract_name,
  o.content_kind,
  o.object_exists,
  s.media_center_schema_exists,
  s.content_items_exists,
  s.public_view_exists,
  case
    when not o.object_exists then 'wrapper_missing'
    when not s.media_center_schema_exists then 'media_center_schema_missing'
    when not s.content_items_exists or not s.public_view_exists then 'media_center_contract_incomplete'
    else 'wrapper_exists_runtime_reroute_still_requires_nonzero_data_uat'
  end as decision
from object_state o cross join schema_state s
order by o.contract_name;
