-- Database Wave B-1A Announcement Detail Runtime Resolver Fix
-- 01_announcement_detail_runtime_contract_read_only.sql
-- Read-only verification only. No DML, no DDL, no waqf/waqf_assets mutation.

select
  'announcement_detail_runtime_contract' as section,
  'media_announcements_compat_rows' as check_key,
  count(*) as row_count,
  case when count(*) > 0 then 'passed' else 'blocked' end as decision
from public.v_media_announcements_compat_v1;

select
  'announcement_detail_runtime_contract' as section,
  'announcement_detail_candidate_route' as check_key,
  count(*) as candidate_rows,
  'Route id is deterministic in Flutter via MediaCompatMapper.stableCompatIdFromRow(row); SQL only confirms compatible payload presence.' as note
from public.v_media_announcements_compat_v1
where content_type = 'announcement'
  and title_ar is not null
  and coalesce(trim(title_ar), '') <> '';

select
  'sovereign_boundary' as section,
  'no_waqf_assets_mutation_in_this_script' as check_key,
  true as passed,
  'Read-only contract check only; no waqf/waqf_assets/awqaf_system DML or DDL.' as note;

select
  'sovereign_boundary' as section,
  'no_public_media_extraction_in_this_script' as check_key,
  true as passed,
  'No legacy public media table is moved, deleted, copied, or modified.' as note;

select
  'runtime_gate' as section,
  'production_not_approved' as check_key,
  true as passed,
  'This SQL cannot approve production; browser retest evidence is required.' as note;
