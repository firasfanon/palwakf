-- Database Wave B-1A Final Consolidation Read-only UAT
-- Purpose: summarize news/announcements runtime candidate state without DML.

select
  'b1a_final_consolidation_candidate'::text as section,
  'media_center_public_news_announcements_counts'::text as check_key,
  (select count(*) from public.v_media_news_compat_v1) as news_rows,
  (select count(*) from public.v_media_announcements_compat_v1) as announcement_rows,
  (select count(*) from public.v_media_content_compat_v1 where content_type in ('news','announcement')) as combined_rows,
  'read_only_no_runtime_change'::text as note;

select
  'b1a_final_consolidation_decision'::text as section,
  'news-announcements-staging-candidate-accepted-production-candidate-deferred-pending-console-clean-evidence'::text as decision,
  'Production is not approved by SQL; this is an evidence/state summary only.'::text as note;
