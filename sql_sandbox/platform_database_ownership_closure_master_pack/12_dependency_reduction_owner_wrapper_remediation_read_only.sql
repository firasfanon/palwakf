-- Platform Database Ownership Closure — Dependency Reduction + Owner Wrapper Remediation
-- 2026-05-26
-- READ ONLY marker. This script does not create, update, delete, drop, archive, or replace tables.

select
  'dependency_reduction_owner_wrapper_remediation' as section,
  502::int as intake_db_public_dependency_count,
  319::int as intake_flutter_direct_from_literal_count,
  39::int as centralized_surface_count,
  45::int as changed_flutter_file_count,
  0::int as remaining_scanned_direct_from_literal_count,
  false::boolean as dependency_zero_certified,
  false::boolean as exact_public_table_replacement_authorized,
  false::boolean as destructive_sql_authorized,
  false::boolean as production_approved,
  true::boolean as no_auth_users_migration,
  true::boolean as no_flutter_elevated_secret,
  true::boolean as no_waqf_assets_mutation;
