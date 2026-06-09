-- Full Site Audit Closure Decision Pack
-- 01_FULL_SITE_AUDIT_CLOSURE_STATUS_READ_ONLY.sql
-- READ ONLY / STATIC DECISION MARKER ONLY

select *
from (
  values
    (
      'full_site_audit_closure_decision_pack'::text,
      'media_center_db_ownership_closed'::text,
      true::boolean,
      'Media Center Phase B ownership and browser/admin evidence accepted; SQL02 was not run.'::text,
      false::boolean,
      false::boolean,
      false::boolean,
      false::boolean,
      false::boolean,
      true::boolean,
      true::boolean,
      true::boolean,
      true::boolean,
      true::boolean
    ),
    (
      'full_site_audit_closure_decision_pack'::text,
      'service_center_db_ownership_validated'::text,
      true::boolean,
      'Service Center Phase C ownership, public RPC wrappers, RLS/policy surface, and browser rendering evidence accepted; SQL02 was not run.'::text,
      false::boolean,
      false::boolean,
      false::boolean,
      false::boolean,
      false::boolean,
      true::boolean,
      true::boolean,
      true::boolean,
      true::boolean,
      true::boolean
    ),
    (
      'full_site_audit_closure_decision_pack'::text,
      'auth_token_400_clean_retest_cleared'::text,
      true::boolean,
      'Clean admin console retest evidence did not show the prior auth/token 400 warning.'::text,
      false::boolean,
      false::boolean,
      false::boolean,
      false::boolean,
      false::boolean,
      true::boolean,
      true::boolean,
      true::boolean,
      true::boolean,
      true::boolean
    ),
    (
      'full_site_audit_closure_decision_pack'::text,
      'database_migration_alias_clean_acceptance'::text,
      true::boolean,
      'Alias is accepted if the operator entered /admin/database-migration directly and the app rendered or redirected to /admin/platform/database-migration without Page Not Found.'::text,
      false::boolean,
      false::boolean,
      false::boolean,
      false::boolean,
      false::boolean,
      true::boolean,
      true::boolean,
      true::boolean,
      true::boolean,
      true::boolean
    )
) as t(
  section,
  gate_key,
  passed,
  note,
  execution_authorized_by_this_script,
  production_approved,
  destructive_sql_authorized,
  exact_public_table_replacement_authorized,
  archive_delete_authorized,
  no_auth_users_migration,
  no_flutter_elevated_secret,
  no_waqf_assets_mutation,
  no_gis_mutation,
  read_only
);
