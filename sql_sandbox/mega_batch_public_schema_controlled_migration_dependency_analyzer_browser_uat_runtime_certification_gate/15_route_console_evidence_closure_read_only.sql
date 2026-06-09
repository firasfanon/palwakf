-- 15_route_console_evidence_closure_read_only.sql
-- Route Console Evidence Closure gate for Public Schema Phase 1.
-- Read-only. This does not accept missing evidence and does not authorize reroute.

with route_console_routes(route_path, route_family, expected_signal, accepted) as (
  values
    ('/home', 'public_home', 'No red Supabase/PostgREST errors tied to platform shell/site-content wrappers', false),
    ('/home/news', 'media_public', 'No red route/runtime errors after platform shell wrapper remediation', false),
    ('/home/news/:id', 'media_public_detail', 'No red route/runtime errors after platform shell wrapper remediation', false),
    ('/home/announcements', 'media_public', 'No red route/runtime errors after platform shell wrapper remediation', false),
    ('/home/announcements/:id', 'media_public_detail', 'No red route/runtime errors after platform shell wrapper remediation', false),
    ('/home/gallery', 'public_gallery', 'No red asset/gallery runtime errors tied to migrated public shell objects', false),
    ('/home/services', 'public_services', 'No red service runtime errors tied to platform shell wrappers', false),
    ('/zakat', 'zakat_public_alias', 'No red shell/runtime errors; zakat payment remains disabled', false),
    ('/press-releases', 'legacy_alias', 'No red route/runtime errors tied to public shell wrappers', false),
    ('/admin/database-migration', 'admin_diagnostics', 'Page opens and displays gates without red runtime errors', false)
)
select
  '15_route_console_evidence_routes' as section,
  route_path,
  route_family,
  expected_signal,
  accepted as console_clean_evidence_accepted,
  'Manual Browser Console evidence was not supplied in this result intake; route remains pending.' as note
from route_console_routes;

with closure as (
  select
    false::boolean as route_console_clean_evidence_accepted,
    false::boolean as runtime_reroute_authorized,
    false::boolean as exact_public_table_name_replacement_authorized,
    false::boolean as production_approved
)
select
  '15_route_console_evidence_closure_gate' as section,
  route_console_clean_evidence_accepted,
  runtime_reroute_authorized,
  exact_public_table_name_replacement_authorized,
  production_approved,
  'ROUTE_CONSOLE_EVIDENCE_NOT_SUPPLIED_CLOSURE_RECORDED_AS_PENDING' as decision
from closure;
