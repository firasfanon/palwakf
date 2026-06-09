-- Platform Database Ownership Closure — 14
-- Dependency Reduction Retest Result Intake — READ ONLY.
-- Records the operator evidence after owner-wrapper remediation.
-- No DDL, no DML, no grants, no destructive action.

select 'dependency_reduction_retest_result_intake' as section,
       502::integer as latest_db_public_dependency_count,
       319::integer as intake_flutter_direct_from_literal_count,
       39::integer as centralized_surface_count,
       45::integer as changed_flutter_file_count,
       0::integer as remaining_scanned_direct_from_literal_count,
       true as flutter_literal_remediation_accepted,
       false as dependency_zero_certified,
       false as rls_negative_uat_accepted,
       false as browser_console_clean_accepted,
       false as archive_delete_authorized,
       false as exact_public_table_replacement_authorized,
       false as destructive_sql_authorized,
       false as production_approved,
       true as no_auth_users_migration,
       true as no_flutter_elevated_secret,
       true as no_waqf_assets_mutation,
       'DB_PUBLIC_DEPENDENCIES_REMAIN_CLASSIFICATION_REQUIRED' as decision;
