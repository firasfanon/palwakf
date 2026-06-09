select
  'ownership_routing_contract_schema_matrix' as section,
  'production_approval' as gate_key,
  false as production_approved,
  false as migration_authorized_by_this_script,
  false as delete_authorized_by_this_script,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation,
  true as read_only,
  'Contract/matrix only; implementation requires a separate explicitly authorized owner migration pack.' as note;
