-- 13_phase1_route_console_uat_matrix_read_only.sql
-- Read-only Browser Console UAT matrix for Phase 1.

with routes(route_path, evidence_required, expected_runtime_surface) as (
  values
    ('/home', true, 'platform shell/site content wrappers'),
    ('/home/news', true, 'platform shell wrappers + media runtime'),
    ('/home/announcements', true, 'platform shell wrappers + media runtime'),
    ('/home/services', true, 'platform shell wrappers + services runtime'),
    ('/press-releases', true, 'platform shell wrappers + press runtime'),
    ('/zakat', true, 'platform shell wrappers + zakat runtime'),
    ('/admin/database-migration', true, 'admin gate diagnostics')
)
select
  '13_phase1_route_console_uat_matrix' as section,
  route_path,
  evidence_required,
  false as console_clean_evidence_accepted,
  expected_runtime_surface,
  'Browser console screenshot/log required after Phase 1 patch' as note
from routes;

select
  '13_phase1_console_gate' as section,
  false as route_console_clean_evidence_accepted,
  false as runtime_reroute_authorized,
  false as exact_public_table_name_replacement_authorized,
  'ROUTE_CONSOLE_EVIDENCE_PENDING_PHASE1_RUNTIME_REROUTE_BLOCKED' as decision;
