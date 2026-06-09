-- Database Wave B-1A Announcement Detail Deep Fix
-- Read-only contract check. Does not mutate public/media_center/waqf/waqf_assets/awqaf_system.

select
  'announcement_detail_deep_fix_contract' as section,
  'announcement_compat_view_has_rows' as check_key,
  (count(*) > 0) as passed,
  count(*) as row_count,
  'public.v_media_announcements_compat_v1 must keep nonzero rows for public announcement detail fallback.' as note
from public.v_media_announcements_compat_v1;

select
  'announcement_detail_deep_fix_contract' as section,
  'sample_announcement_route_inputs' as check_key,
  id::text as compat_uuid,
  coalesce(legacy_source_id::text, '') as legacy_source_id,
  coalesce(content_key::text, '') as content_key,
  title_ar,
  published_at,
  'Dart resolver computes stable route ids through MediaCompatMapper.stableCompatIdFromRow(row).' as note
from public.v_media_announcements_compat_v1
order by published_at desc nulls last
limit 10;

select
  'sovereign_boundary' as section,
  'no_waq_assets_mutation_in_this_script' as check_key,
  true as passed,
  'Read-only diagnostic only; no waqf/waqf_assets/awqaf_system DML.' as note
union all
select
  'sovereign_boundary',
  'no_public_media_extraction_in_this_script',
  true,
  'No import/move/delete from legacy public media tables.'
union all
select
  'sovereign_boundary',
  'wave_b1b_not_authorized',
  true,
  'This diagnostic does not authorize selective sovereign extraction.';
