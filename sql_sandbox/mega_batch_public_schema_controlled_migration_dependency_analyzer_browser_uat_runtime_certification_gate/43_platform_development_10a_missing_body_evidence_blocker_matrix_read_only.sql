-- Platform Development 10A — Missing Exact Body and Evidence Blocker Matrix
-- READ ONLY. No executable function body. No permission grant. No DDL. No DML.

with blocker_matrix(section, check_key, passed, note) as (
  values
    ('body_blocker', 'rpc_core_admin_user_profile_update_body_supplied', false,
      'Required body is not supplied.'),
    ('body_blocker', 'rpc_core_admin_user_link_body_supplied', false,
      'Required body is not supplied.'),
    ('body_blocker', 'rpc_core_admin_user_deactivate_body_supplied', false,
      'Required body is not supplied.'),
    ('body_blocker', 'rpc_platform_system_register_body_supplied', false,
      'Required body is not supplied.'),
    ('body_blocker', 'rpc_platform_user_role_upsert_body_supplied', false,
      'Required body is not supplied.'),
    ('body_blocker', 'rpc_platform_user_role_delete_body_supplied', false,
      'Required body is not supplied.'),
    ('body_blocker', 'rpc_platform_user_permission_grant_body_supplied', false,
      'Required body is not supplied.'),
    ('body_blocker', 'rpc_platform_user_permission_revoke_body_supplied', false,
      'Required body is not supplied.'),
    ('evidence_blocker', 'negative_uat_supplied', false,
      'Negative UAT bundle is not supplied.'),
    ('evidence_blocker', 'browser_console_clean_supplied', false,
      'Browser console evidence is not supplied.'),
    ('evidence_blocker', 'sql_rls_proofs_supplied', false,
      'SQL/RLS proofs are not supplied.'),
    ('evidence_blocker', 'denied_write_attempts_supplied', false,
      'Denied write/RPC attempt evidence is not supplied.')
)
select section, check_key, passed, note from blocker_matrix;
