select
  'no_public_new_table_gate' as section,
  'PUBLIC_IS_NOT_OWNER_FOR_NEW_OPERATIONAL_TABLES' as gate_key,
  true as contract_required,
  false as ddl_authorized_by_this_script,
  false as destructive_sql_authorized,
  false as production_approved,
  true as read_only,
  'Any new database-backed feature must declare an owner schema outside public. Public may expose RPC/views only.' as note;
