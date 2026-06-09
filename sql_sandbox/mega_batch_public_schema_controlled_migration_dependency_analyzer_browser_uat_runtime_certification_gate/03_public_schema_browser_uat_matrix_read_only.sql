-- Mega Batch: Public Schema Controlled Migration Browser/Role UAT Matrix
-- Date: 2026-05-22
-- Safety: READ ONLY. Manual checklist emitted as SQL rows for Supabase evidence capture.

select * from (
  values
    ('public_home', '/home', 'anonymous', 'open page, verify hero/header/footer/dynamic sections', 'no red console errors; no missing public table errors', 'blocks certification'),
    ('public_gallery', '/home/gallery', 'anonymous', 'open gallery; verify empty/non-empty state does not crash', 'no route not found; no legacy table failure', 'blocks certification'),
    ('public_news_list', '/home/news', 'anonymous', 'open list, filters, first card', 'no red console errors', 'blocks certification'),
    ('public_news_detail', '/home/news/:id', 'anonymous', 'open a real published detail route', 'no persistent loading or resolver error', 'blocks certification'),
    ('public_announcements_list', '/home/announcements', 'anonymous', 'open list and filter/priority chips', 'no red console errors', 'blocks certification'),
    ('public_announcements_detail', '/home/announcements/:id', 'anonymous', 'open stable announcement detail route', 'no family key resolver errors', 'blocks certification'),
    ('public_zakat', '/home/zakat', 'anonymous', 'open page and calculator; keep payment disabled', 'no config wrapper missing noise after fallback', 'blocks content certification only'),
    ('legacy_alias_zakat', '/zakat', 'anonymous', 'verify redirect/canonicalization to /home/zakat', 'no duplicate route/page-not-found', 'blocks navigation certification'),
    ('legacy_alias_press', '/press-releases', 'anonymous', 'verify redirect/canonicalization to canonical home route', 'no page-not-found', 'blocks navigation certification'),
    ('admin_migration_page', '/admin/database-migration', 'platform_admin', 'open migration dashboard and verify gate card visible', 'no Flutter layout/contrast/overflow errors', 'blocks certification'),
    ('unauthorized_admin_gate', '/admin/database-migration', 'unauthorized_user', 'verify fail-closed/forbidden behavior', 'no data leakage', 'blocks certification')
) as uat(route_key, route_path, actor, action_required, pass_condition, decision_if_failed);

select * from (
  values
    ('analyzer', 'flutter analyze', 'must return No issues found or a reviewed non-blocking debt register', 'required_before_certification'),
    ('chrome_startup', 'flutter run -d chrome', 'must start without compile/runtime red screen', 'required_before_certification'),
    ('console', 'browser console on public routes', 'must have no red Supabase/PostgREST route errors tied to migrated public tables', 'required_before_certification'),
    ('dependency_zero', 'SQL 01 + SQL 02', 'dependency_blocker_count must be zero before exact replacement/archive/delete', 'required_before_any_destructive_step'),
    ('sovereign_boundary', 'waqf_assets/waqf/awqaf_system', 'must remain untouched', 'non_negotiable')
) as gates(gate_key, evidence_source, pass_condition, requirement_level);
