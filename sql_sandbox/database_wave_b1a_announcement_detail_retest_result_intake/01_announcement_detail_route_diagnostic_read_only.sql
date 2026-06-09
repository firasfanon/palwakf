-- Database Wave B-1A — Announcement Detail Route Diagnostic (READ ONLY)
-- Purpose: support the next deep fix by listing announcement compatibility rows
-- and key fields that Dart uses for stable route id calculation.
-- This script does not mutate data.

select
  'announcement_detail_route_diagnostic' as section,
  id,
  content_key,
  legacy_source,
  legacy_source_id,
  title_ar,
  published_at,
  category_key,
  unit_slug,
  source_schema_name,
  compatibility_contract
from public.v_media_announcements_compat_v1
order by published_at desc nulls last, title_ar asc
limit 120;

select
  'sovereign_boundary' as section,
  'no_waq_assets_mutation_in_this_script' as check_key,
  true as passed,
  'Read-only diagnostic only; no waqf/waqf_assets/awqaf_system DML.' as note;
