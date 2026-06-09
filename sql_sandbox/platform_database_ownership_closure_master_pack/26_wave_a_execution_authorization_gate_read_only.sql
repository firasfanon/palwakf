-- Platform Database Dependency Remediation Wave A
-- SQL 26: execution authorization gate (READ ONLY)
-- This script blocks execution until exact body review + RLS + browser + token/backup/governance evidence exist.

select *
from (values
  ('wave_a_execution_authorization_gate', 'exact_body_export_reviewed', false, 'SQL 25 output must be reviewed and approved before any execution body is prepared.'),
  ('wave_a_execution_authorization_gate', 'rls_negative_uat_accepted', false, 'Anonymous, unauthorized, wrong-unit, scoped, platform-admin, and superuser cases must be supplied.'),
  ('wave_a_execution_authorization_gate', 'browser_console_clean_accepted', false, 'Admin/public/system route console/network evidence is still required after reroute.'),
  ('wave_a_execution_authorization_gate', 'token_backup_governance_accepted', false, 'A real backup/restore point and explicit governance token are required.'),
  ('wave_a_execution_authorization_gate', 'guarded_sql_02_03_04_authorized', false, 'Still blocked.'),
  ('wave_a_execution_authorization_gate', 'archive_delete_drop_exact_replacement_authorized', false, 'Still blocked until dependency-zero and explicit approval.'),
  ('wave_a_execution_authorization_gate', 'production_gate', false, 'NOT_APPROVED.')
) as t(section, gate_key, passed, note)
cross join lateral (
  select
    false as execution_authorized,
    false as production_approved,
    false as destructive_sql_authorized,
    false as exact_public_table_replacement_authorized,
    true as no_auth_users_migration,
    true as no_flutter_elevated_secret,
    true as no_waqf_assets_mutation,
    true as read_only
) safety;
