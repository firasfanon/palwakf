-- Platform Database Ownership Closure Master Pack — 10
-- PRODUCTION GATE RE-DECISION READ-ONLY.
select 'production_gate_redecision' as section,
       'NOT_APPROVED' as decision,
       false as production_approved,
       false as dependency_zero_certified,
       false as destructive_sql_authorized,
       false as exact_public_table_replacement_authorized,
       true as no_auth_users_migration,
       true as no_flutter_elevated_secret,
       true as no_waqf_assets_mutation;
