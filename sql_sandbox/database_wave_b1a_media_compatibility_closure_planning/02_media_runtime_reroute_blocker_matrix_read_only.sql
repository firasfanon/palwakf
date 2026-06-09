-- Database Wave B-1A Media Compatibility Closure Planning Pack
-- 02_media_runtime_reroute_blocker_matrix_read_only.sql
-- READ ONLY: decision matrix only.

select * from (values
  ('media_runtime_reroute_blocker_matrix','news_pages','public.news_articles/public.news','public.v_media_news_compat_v1','blocked','wrapper may be empty until media_center is populated or fallback is approved'),
  ('media_runtime_reroute_blocker_matrix','activities_pages','public.activities','public.v_media_activities_compat_v1','blocked','wrapper may be empty until media_center is populated or fallback is approved'),
  ('media_runtime_reroute_blocker_matrix','announcements_pages','public.announcements','public.v_media_announcements_compat_v1','blocked','wrapper may be empty until media_center is populated or fallback is approved'),
  ('media_runtime_reroute_blocker_matrix','gallery_pages','public.media_gallery_items','public.v_media_gallery_compat_v1','blocked','asset mapping is required'),
  ('media_runtime_reroute_blocker_matrix','generic_media_feed','mixed public media','public.v_media_content_compat_v1','blocked','data continuity strategy required')
) as t(section,runtime_area,current_source,proposed_wrapper,reroute_decision,note);
