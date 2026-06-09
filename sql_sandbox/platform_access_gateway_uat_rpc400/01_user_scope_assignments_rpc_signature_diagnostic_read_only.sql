-- READ ONLY: inspect rpc_user_scope_assignments_list_v1 signatures.
select
  n.nspname as schema_name,
  p.proname as function_name,
  pg_get_function_arguments(p.oid) as arguments,
  pg_get_function_result(p.oid) as result_type,
  p.prosecdef as security_definer
from pg_catalog.pg_proc p
join pg_catalog.pg_namespace n on n.oid = p.pronamespace
where p.proname = 'rpc_user_scope_assignments_list_v1'
order by n.nspname, p.oid;
