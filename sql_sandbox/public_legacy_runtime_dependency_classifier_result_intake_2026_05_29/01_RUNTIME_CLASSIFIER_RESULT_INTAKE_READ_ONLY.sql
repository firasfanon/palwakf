select
  'public_legacy_runtime_dependency_classifier_result_intake'::text as section,
  'PUBLIC_LEGACY_RUNTIME_DEPENDENCY_CLASSIFIER_RESULT_ACCEPTED_REWRITE_BLOCKED'::text as decision,
  'Classifier accepted. No exact runtime table dependency was proven sufficient to authorize rewrite. Deletion remains blocked.'::text as note,
  false as rewrite_authorized_by_this_script,
  false as deletion_authorized_by_this_script,
  false as destructive_sql_authorized,
  false as production_approved,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation,
  true as read_only;
