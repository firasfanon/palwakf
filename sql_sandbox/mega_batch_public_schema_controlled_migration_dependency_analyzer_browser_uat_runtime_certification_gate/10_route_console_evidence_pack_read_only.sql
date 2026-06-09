-- Mega Batch — Public Schema Direct Dependency Remediation Plan + Route Console Evidence Pack
-- 10_route_console_evidence_pack_read_only.sql
-- SELECT-only browser evidence matrix. No DDL/DML.

with route_console_matrix(route_path, expected_result) as (
  values
  ('/home', 'public homepage opens without migrated-public-object console errors'),
  ('/home/news', 'news list opens without migrated-public-object console errors'),
  ('/home/news/:id', 'news detail opens without migrated-public-object console errors'),
  ('/home/announcements', 'announcements list opens without migrated-public-object console errors'),
  ('/home/announcements/:id', 'announcement detail opens without migrated-public-object console errors'),
  ('/home/gallery', 'gallery route opens or graceful empty state without migrated-public-object console errors'),
  ('/home/zakat', 'zakat route opens without payment workflow activation'),
  ('/zakat', 'legacy alias resolves safely'),
  ('/press-releases', 'legacy alias resolves safely'),
  ('/admin/database-migration', 'admin gate page opens and does not execute SQL from Flutter')
)
select
  '10_route_console_evidence_pack' as section,
  route_path,
  expected_result,
  'pending_user_browser_console_evidence' as console_status,
  'required_before_runtime_reroute' as requirement_level
from route_console_matrix
order by route_path;

select
  '10_route_console_gate' as section,
  false as route_console_clean_evidence_accepted,
  false as runtime_reroute_authorized,
  false as exact_public_table_name_replacement_authorized,
  'ROUTE_CONSOLE_EVIDENCE_PENDING_RUNTIME_REROUTE_BLOCKED' as decision;
