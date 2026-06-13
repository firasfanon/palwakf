
-- READ ONLY
-- 06_dependency_probe_admin_users_references.sql
-- Finds views/routines that reference admin_users identity surfaces.

select
  'view_dependencies_text' as section,
  schemaname as view_schema,
  viewname as view_name
from pg_views
where definition ilike '%admin_users%'
order by schemaname, viewname;

select
  'routine_dependencies_text' as section,
  n.nspname as routine_schema,
  p.proname as routine_name,
  pg_get_function_identity_arguments(p.oid) as identity_arguments
from pg_proc p
join pg_namespace n
  on n.oid = p.pronamespace
where pg_get_functiondef(p.oid) ilike '%admin_users%'
order by n.nspname, p.proname;
