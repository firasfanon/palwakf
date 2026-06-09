-- Platform Database Ownership Closure — 16
-- Dependency Resolution Next Gate — READ ONLY.
-- Defines the next authorized action after SQL 14/15. No DDL/DML.

with gate as (
  select * from (values
    ('flutter_literal_remediation', true, 'accepted for scanned Flutter files; remaining scanned direct .from literals = 0'),
    ('db_dependency_classifier', false, 'run SQL 15 and attach classified output before owner-schema or compatibility execution'),
    ('owner_schema_shadow_targets', false, 'blocked until classifier confirms missing targets and explicit token/backup are supplied'),
    ('public_compatibility_view_rpc', false, 'blocked until classifier confirms safe wrappers and explicit approval'),
    ('rls_negative_uat', false, 'actual actor-case evidence still required'),
    ('browser_console_clean', false, 'route evidence still required after reroute'),
    ('archive_delete_drop_exact_replacement', false, 'blocked until dependency-zero, backup, and governance approval')
  ) as v(gate_key, passed, note)
)
select 'dependency_resolution_next_gate' as section,
       gate_key,
       passed,
       note,
       false as production_approved,
       false as destructive_sql_authorized,
       false as exact_public_table_replacement_authorized,
       true as no_auth_users_migration,
       true as no_flutter_elevated_secret,
       true as no_waqf_assets_mutation
from gate;
