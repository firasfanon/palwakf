select
  'rewrite_gate' as section,
  'rewrite_body_authorization' as gate_key,
  false as passed,
  'Exact body export and mapping review do not authorize rewrite. Exact runtime dependency classifier must be reviewed first.' as note,
  false as rewrite_authorized_by_this_script,
  false as deletion_authorized_by_this_script,
  false as destructive_sql_authorized,
  false as production_approved,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation,
  true as read_only;
