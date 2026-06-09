-- Full Site Audit Closure Decision Pack
-- 02_FULL_SITE_AUDIT_PRODUCTION_GATE_READ_ONLY.sql
-- READ ONLY / STATIC DECISION MARKER ONLY

select *
from (
  values
    (
      'full_site_audit_closure_production_gate'::text,
      'scoped_audit_closure'::text,
      true::boolean,
      'Scoped Full Site Audit stream is accepted for the audited Media Center, Service Center, admin console, and database migration surfaces.'::text,
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
      'full_site_audit_closure_production_gate'::text,
      'global_production_approval'::text,
      false::boolean,
      'Global production approval is not granted by this scoped closure pack; remaining systems and full role/RLS matrices require their own gates.'::text,
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
