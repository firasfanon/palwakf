-- Media Center Runtime Source Root Cutover — read-only diagnostics only.
-- No DDL/DML/GRANT/DROP. No waqf/awqaf_system/GIS mutation.

select
  'media_center_runtime_source_root_cutover_read_only' as section,
  to_regclass('media_center.content_items') is not null as owner_content_items_present,
  to_regclass('public.v_media_news_compat_v1') is not null as news_owner_facade_present,
  to_regclass('public.v_media_announcements_compat_v1') is not null as announcements_owner_facade_present,
  to_regclass('public.v_media_activities_compat_v1') is not null as activities_owner_facade_present,
  to_regclass('public.news_articles') is not null as legacy_news_preserved,
  to_regclass('public.announcements') is not null as legacy_announcements_preserved,
  to_regclass('public.activities') is not null as legacy_activities_preserved,
  false as destructive_sql_authorized,
  false as production_approved,
  true as read_only;
