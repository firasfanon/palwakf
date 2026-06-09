-- Database Wave B-1A — News/Announcements Runtime Candidate Read-Only Check
-- Purpose: post-retest evidence support only. No DDL/DML.
-- Do not run as migration.

select
  'media_runtime_retest_support' as section,
  'news_announcements_wrappers_expected_nonzero' as check_key,
  (select count(*) from public.v_media_news_compat_v1) as news_rows,
  (select count(*) from public.v_media_announcements_compat_v1) as announcement_rows,
  (select count(*) from public.v_media_content_compat_v1 where status <> 'published') as non_published_public_rows,
  (select count(*) from public.v_media_content_compat_v1 where coalesce(visibility_scope, 'public') <> 'public') as non_public_visibility_rows;

select
  'sovereign_boundary' as section,
  'no_waq_assets_mutation_in_this_script' as check_key,
  true as passed,
  'Read-only support query only; no waqf/waqf_assets/awqaf_system DML.' as note
union all
select
  'sovereign_boundary',
  'no_public_media_extraction_in_this_script',
  true,
  'Legacy public media tables remain unchanged; no import/move/delete.'
union all
select
  'sovereign_boundary',
  'locations_authority_gate_preserved',
  true,
  'No locations wrapper activation.'
union all
select
  'sovereign_boundary',
  'wave_b1b_not_authorized',
  true,
  'No extraction wave is authorized by this pack.';
