-- Script 04: Final media/services closure decision read-only
-- Purpose: single consolidated decision row.

with c as (
  select
    (xpath('/row/count/text()', query_to_xml('select count(*) as count from public.v_media_news_compat_v1', false, true, '')))[1]::text::bigint as news_rows,
    (xpath('/row/count/text()', query_to_xml('select count(*) as count from public.v_media_announcements_compat_v1', false, true, '')))[1]::text::bigint as announcement_rows,
    (xpath('/row/count/text()', query_to_xml('select count(*) as count from public.v_media_activities_compat_v1', false, true, '')))[1]::text::bigint as activity_rows,
    (xpath('/row/count/text()', query_to_xml('select count(*) as count from public.v_media_gallery_compat_v1', false, true, '')))[1]::text::bigint as gallery_rows,
    (xpath('/row/count/text()', query_to_xml('select count(*) as count from public.v_services_catalog_compat_v1', false, true, '')))[1]::text::bigint as services_rows
)
select
  'media_services_final_closure_decision' as section,
  'MEDIA_SERVICES_OWNERSHIP_FINAL_CLOSURE_ACCEPTED_WITH_LEGACY_QUARANTINE_NO_DELETE' as decision,
  jsonb_build_object(
    'media_owner','media_center',
    'services_owner','platform_services',
    'public_role','wrappers_rpc_views_only',
    'news_rows', news_rows,
    'announcement_rows', announcement_rows,
    'activity_rows', activity_rows,
    'gallery_rows', gallery_rows,
    'services_rows', services_rows,
    'gallery_assets_state', case when gallery_rows > 0 then 'runtime_ready' else 'empty_certified_mapping_ready' end,
    'legacy_public_tables', 'quarantined_preserved_no_delete',
    'destructive_sql_authorized', false,
    'next_allowed_action', 'return_to_core_systems_or_run_explicit_archive_batch_later'
  ) as decision_payload
from c;
