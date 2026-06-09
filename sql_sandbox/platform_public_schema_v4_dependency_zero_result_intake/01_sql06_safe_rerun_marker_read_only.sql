/*
Safe constant-marker replacement for SQL06 if the prior run produced:
ERROR: 42P01: relation "public" does not exist
*/
select
  'no_new_public_base_tables_gate_safe_rerun_read_only' as section,
  false as create_table_public_authorized,
  false as operational_or_sovereign_table_in_public_authorized,
  true as public_views_rpc_compatibility_surfaces_only,
  false as ddl_dml_authorized,
  false as grant_revoke_authorized,
  false as archive_drop_rename_authorized,
  false as production_approved,
  true as read_only,
  'No CREATE TABLE public.* is authorized. public remains views/RPC compatibility surface only.' as instruction;
