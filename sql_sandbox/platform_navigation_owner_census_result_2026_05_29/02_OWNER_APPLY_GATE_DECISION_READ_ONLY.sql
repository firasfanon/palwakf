-- Platform Navigation Owner Apply Gate Decision — READ ONLY
-- This does not authorize execution. It only states the next explicit gate.

select
  'platform_navigation_owner_apply_gate'::text as section,
  'OWNER_SCHEMA_APPLY_REVIEW_REQUIRED'::text as gate_key,
  false as apply_authorized_by_this_script,
  'Review guarded drafts 02-04 from platform_navigation_owner_bootstrap before any explicit staging apply.'::text as required_next_action,
  false as destructive_sql_authorized,
  false as archive_delete_authorized,
  false as exact_public_table_replacement_authorized,
  false as production_approved,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation,
  true as read_only;
