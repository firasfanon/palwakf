-- 04_gallery_asset_mapping_apply.sql
-- APPLY. Idempotent gallery asset mapping from public.media_gallery_items to media_center.
-- Current source may be zero rows; the script is still valid and establishes the contract.

begin;

-- Create a lightweight gallery content item for each legacy gallery asset when present.
insert into media_center.content_items (
  legacy_source,
  legacy_source_id,
  content_key,
  content_type,
  title_ar,
  summary_ar,
  body_ar,
  category_key,
  status,
  visibility_scope,
  unit_slug,
  source_public_table,
  published_at,
  metadata
)
select
  'public.media_gallery_items',
  coalesce(j->>'id', j->>'uuid', md5(j::text)),
  'legacy_gallery_' || coalesce(j->>'id', j->>'uuid', md5(j::text)),
  'gallery',
  coalesce(nullif(j->>'title_ar',''), nullif(j->>'title',''), nullif(j->>'name_ar',''), 'عنصر معرض'),
  nullif(coalesce(j->>'description_ar', j->>'description', j->>'summary_ar', j->>'summary'), ''),
  nullif(coalesce(j->>'description_ar', j->>'description', j->>'summary_ar', j->>'summary'), ''),
  coalesce(nullif(j->>'media_type',''), 'gallery'),
  case
    when lower(coalesce(j->>'is_active', j->>'active', 'true')) in ('false','f','0','no','n') then 'draft'
    else 'published'
  end,
  'public',
  nullif(coalesce(j->>'unit_slug', j->>'unit_id'), ''),
  'public.media_gallery_items',
  coalesce(
    case when nullif(coalesce(j->>'publish_at', j->>'published_at', j->>'created_at'), '') ~ '^\d{4}-\d{2}-\d{2}'
      then nullif(coalesce(j->>'publish_at', j->>'published_at', j->>'created_at'), '')::timestamptz
      else null end,
    now()
  ),
  jsonb_build_object(
    'legacy_payload', j,
    'controlled_execution_batch', 'platform_data_ownership_stabilization_controlled_execution',
    'seed_scope', 'media_gallery_items'
  )
from (select to_jsonb(s) as j from public.media_gallery_items s) q
where not exists (
  select 1 from media_center.content_items ci
  where ci.legacy_source='public.media_gallery_items'
    and ci.legacy_source_id=coalesce(j->>'id', j->>'uuid', md5(j::text))
);

-- Create asset rows linked to the gallery content item.
insert into media_center.content_assets (
  content_item_id,
  legacy_source,
  legacy_source_id,
  content_key,
  asset_type,
  title_ar,
  url,
  storage_path,
  unit_slug,
  source_public_table,
  published_at,
  is_primary,
  display_order,
  metadata
)
select
  ci.id,
  'public.media_gallery_items',
  coalesce(j->>'id', j->>'uuid', md5(j::text)),
  'legacy_gallery_asset_' || coalesce(j->>'id', j->>'uuid', md5(j::text)),
  case when lower(coalesce(j->>'media_type', j->>'mime_type', j->>'media_url', j->>'external_url', 'image')) like '%video%' then 'video' else 'image' end,
  coalesce(nullif(j->>'title_ar',''), nullif(j->>'title',''), 'عنصر معرض'),
  nullif(coalesce(j->>'media_url', j->>'public_url', j->>'url', j->>'thumbnail_url', j->>'external_url'), ''),
  nullif(coalesce(j->>'storage_path', j->>'path'), ''),
  nullif(coalesce(j->>'unit_slug', j->>'unit_id'), ''),
  'public.media_gallery_items',
  ci.published_at,
  true,
  case when coalesce(j->>'display_order','') ~ '^\\d+$' then (j->>'display_order')::integer else 0 end,
  jsonb_build_object(
    'legacy_payload', j,
    'controlled_execution_batch', 'platform_data_ownership_stabilization_controlled_execution',
    'asset_mapping', 'public.media_gallery_items -> media_center.content_assets'
  )
from (select to_jsonb(s) as j from public.media_gallery_items s) q
join media_center.content_items ci
  on ci.legacy_source='public.media_gallery_items'
 and ci.legacy_source_id=coalesce(j->>'id', j->>'uuid', md5(j::text))
where not exists (
  select 1 from media_center.content_assets ca
  where ca.legacy_source='public.media_gallery_items'
    and ca.legacy_source_id=coalesce(j->>'id', j->>'uuid', md5(j::text))
);

commit;

select
  'gallery_asset_mapping_result' as section,
  (select count(*) from public.media_gallery_items)::bigint as public_gallery_rows,
  (select count(*) from media_center.content_items where legacy_source='public.media_gallery_items')::bigint as gallery_content_items,
  (select count(*) from media_center.content_assets where legacy_source='public.media_gallery_items')::bigint as gallery_content_assets;
