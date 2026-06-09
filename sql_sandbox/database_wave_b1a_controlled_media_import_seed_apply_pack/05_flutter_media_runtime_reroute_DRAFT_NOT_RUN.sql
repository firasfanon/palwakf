-- Database Wave B-1A — Flutter Media Runtime Reroute DRAFT — NOT RUN
-- This is a placeholder marker only. Flutter reroute must be implemented in Dart after:
-- 1) controlled media seed apply succeeds,
-- 2) public.v_media_*_compat_v1 wrappers show nonzero rows for the relevant surfaces,
-- 3) browser UAT confirms no content loss,
-- 4) a separate runtime reroute pack is explicitly authorized.

select
  'flutter_media_runtime_reroute_draft' as section,
  'not_run_sql_marker_only' as state,
  'Do not reroute Flutter media runtime in this apply pack.' as note;
