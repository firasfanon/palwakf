-- Script 02: Media gallery/assets final closure read-only
-- Purpose: decide whether gallery/assets is data-complete, empty-certified, or blocked.

with counts as (
  select
    case when to_regclass('media_center.content_assets') is not null
      then (xpath('/row/count/text()', query_to_xml('select count(*) as count from media_center.content_assets', false, true, '')))[1]::text::bigint else 0 end as content_assets_rows,
    case when to_regclass('public.media_gallery_items') is not null
      then (xpath('/row/count/text()', query_to_xml('select count(*) as count from public.media_gallery_items', false, true, '')))[1]::text::bigint else 0 end as public_gallery_rows,
    case when to_regclass('public.v_media_gallery_compat_v1') is not null
      then (xpath('/row/count/text()', query_to_xml('select count(*) as count from public.v_media_gallery_compat_v1', false, true, '')))[1]::text::bigint else 0 end as gallery_wrapper_rows
)
select
  'media_gallery_assets_final_closure' as section,
  content_assets_rows,
  public_gallery_rows,
  gallery_wrapper_rows,
  case
    when content_assets_rows > 0 and gallery_wrapper_rows > 0 then 'GALLERY_ASSETS_RUNTIME_READY'
    when content_assets_rows = 0 and public_gallery_rows = 0 and gallery_wrapper_rows = 0 then 'GALLERY_ASSETS_EMPTY_CERTIFIED_MAPPING_READY_NO_DELETE'
    else 'GALLERY_ASSETS_MAPPING_REQUIRED_BEFORE_FULL_CERTIFICATION'
  end as decision,
  'media_center remains owner; public.v_media_gallery_compat_v1 remains wrapper; no deletion of legacy source is authorized' as note
from counts;
