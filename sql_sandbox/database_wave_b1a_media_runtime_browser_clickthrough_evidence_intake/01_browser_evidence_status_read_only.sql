-- Database Wave B-1A Media Runtime Browser Evidence Closure — read-only template
-- Purpose: capture operator-side evidence status only. This script performs no DML.
-- Do not use this as production approval. Browser console and detail route resolution remain required.

select *
from (values
  ('/home/news', 'news_list', true, 'screenshot accepted'),
  ('/home/news/1963512572', 'news_detail', true, 'screenshot accepted'),
  ('/home/announcements', 'announcements_list', true, 'screenshot accepted'),
  ('/home/announcements/1295789704', 'announcement_detail', false, 'screenshot shows loading state'),
  ('/home', 'home_route', false, 'no screenshot supplied'),
  ('browser_console_review', 'console', false, 'no console evidence supplied')
) as evidence(route, check_key, passed, note);

select
  'media_runtime_browser_gate_decision' as section,
  'production-not-approved' as decision,
  'news/list/detail partly accepted; announcement detail loading and console/home evidence missing' as note;
