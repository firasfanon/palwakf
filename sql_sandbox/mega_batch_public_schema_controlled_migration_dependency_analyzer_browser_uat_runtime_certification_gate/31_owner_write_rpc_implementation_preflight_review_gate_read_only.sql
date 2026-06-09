-- Development 9D — Owner-Write RPC Implementation Preflight Review Gate
-- READ ONLY. This is a review gate, not implementation authorization.
-- It intentionally does not create functions or alter runtime repositories.

with gate(section, check_key, passed, note) as (
  values
    ('preflight_review', 'rpc_body_review_completed', false,
      'RPC bodies for core/admin/platform owner writes must be reviewed before CREATE FUNCTION is authorized.'),
    ('preflight_review', 'rls_and_auth_uid_guards_reviewed', false,
      'Every RPC must enforce auth.uid/admin/scope checks inside SQL, not only in Flutter.'),
    ('preflight_review', 'audit_contract_reviewed', false,
      'Every write RPC must emit an audit/admin event with actor, target, action, payload, and correlation metadata.'),
    ('preflight_review', 'security_definer_search_path_locked', false,
      'SECURITY DEFINER is not accepted unless search_path is explicitly locked and owner reviewed.'),
    ('preflight_review', 'rollback_flag_defined', false,
      'Repository write reroute must remain controlled by one explicit rollback/feature flag.'),
    ('preflight_review', 'self_lockout_guard_defined', false,
      'Role/user write RPCs must prevent self-lockout and privilege escalation.'),
    ('preflight_review', 'legacy_direct_write_fallback_disabled_plan_reviewed', false,
      'Legacy direct write fallbacks must not remain silently enabled after RPC reroute.'),
    ('preflight_review', 'role_rls_browser_console_evidence_supplied', false,
      'Fresh Role/RLS/Browser Console evidence is still not supplied.'),
    ('preflight_review', 'implementation_authorized', false,
      'Development 9D records preflight only; implementation is not authorized.'),
    ('production_gate', 'production_approved', false,
      'Production remains not approved.'),
    ('sovereign_boundary', 'no_auth_users_migration', true,
      'auth.users remains Supabase Auth identity source and is not migrated.'),
    ('sovereign_boundary', 'no_waqf_assets_mutation', true,
      'No waqf_assets/waqf/awqaf_system DDL or DML is included.')
)
select * from gate;
