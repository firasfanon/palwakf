-- Platform Database Ownership Closure — 17
-- DB Public Dependency Classifier Aggregate Hotfix Marker — READ ONLY.
-- Documents the 15A correction for ERROR 42809 caused by pg_get_functiondef()
-- being invoked on aggregate routines such as array_agg.
-- No DDL, no DML, no grants, no destructive action.

select 'db_public_dependency_classifier_aggregate_hotfix' as section,
       'SQL_15A_APPLIED_FILTERS_PG_PROC_TO_FUNCTIONS_AND_PROCEDURES_ONLY' as decision,
       'Retry 15_db_public_dependency_classifier_read_only.sql, then run 16_dependency_resolution_next_gate_read_only.sql' as next_required_action,
       false as dependency_zero_certified,
       false as production_approved,
       false as destructive_sql_authorized,
       false as exact_public_table_replacement_authorized,
       true as read_only,
       true as no_auth_users_migration,
       true as no_flutter_elevated_secret,
       true as no_waqf_assets_mutation;
