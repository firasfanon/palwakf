select
  'public_legacy_exact_body_mapping_gap_result_intake' as section,
  'decision' as key,
  'PUBLIC_LEGACY_EXACT_BODY_AND_MAPPING_GAP_RESULT_INTaken_REWRITE_BLOCKED' as value,
  false as rewrite_authorized_by_this_script,
  false as deletion_authorized_by_this_script,
  false as destructive_sql_authorized,
  false as production_approved,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation,
  true as read_only
union all
select
  'public_legacy_exact_body_mapping_gap_result_intake',
  'status',
  'staging-stable / exact-body-export-result-intaken / service-catalog-mapping-gap-confirmed / deletion-still-blocked / rewrite-body-not-authorized / exact-runtime-dependency-classifier-required / production-not-approved / no-destructive-sql / no-auth-users-migration / no-flutter-elevated-secret / no-waqf-assets-mutation',
  false, false, false, false, true, true, true, true, true;
