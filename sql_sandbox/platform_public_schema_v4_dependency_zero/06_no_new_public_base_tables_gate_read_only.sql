/* Gate confirming this package does not authorize public base table creation. */

select
  'no_new_public_base_tables_gate_read_only' as section,
  false as create_table_public_authorized,
  false as operational_or_sovereign_table_in_public_authorized,
  true as public_views_rpc_compatibility_surfaces_only,
  false as ddl_dml_authorized,
  false as grant_revoke_authorized,
  false as production_approved,
  true as read_only,
  'Any CREATE TABLE public.* for sovereign/operational data is blocked by governing contract V4.3.' as instruction;
