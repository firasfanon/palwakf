-- Platform Development 10A Final Result Intake + 10B Entry Decision Gate
-- Date: 2026-05-23
-- Type: READ ONLY / decision evidence only
-- No CREATE FUNCTION, no GRANT, no DDL/DML, no auth.users migration, no waqf_assets mutation.

with final_gate(section, check_key, passed, note) as (
  values
    ('authorization_token', 'AUTHORIZE_OWNER_WRITE_RPC_EXECUTION', true, 'Token was supplied and recorded as intent.'),
    ('authorization_token', 'token_is_sufficient_alone', false, 'Token alone is not sufficient; exact bodies and evidence remain mandatory.'),
    ('implementation_gate', 'effective_implementation_authorized', false, 'Effective authorization remains false because exact bodies and negative UAT evidence are absent.'),
    ('required_input', 'all_eight_exact_sql_bodies_supplied', false, 'No executable owner-write RPC bodies were supplied.'),
    ('required_input', 'negative_uat_actor_bundle_supplied', false, 'Anonymous/unauthorized/scoped/unit/platform/superuser evidence remains absent.'),
    ('required_input', 'role_rls_browser_console_evidence_supplied', false, 'Fresh role/RLS/browser-console evidence remains absent.'),
    ('required_input', 'rls_audit_search_path_rollback_review_closed', false, 'SQL-level guards, audit, locked search_path, rollback, self-lockout reviews remain open.'),
    ('development_10b_entry_contract', 'exact_bodies_required', true, 'All eight SQL bodies must be submitted as one reviewable 10B pack.'),
    ('development_10b_entry_contract', 'negative_uat_required', true, 'Full actor-case evidence is mandatory before execution.'),
    ('development_10b_entry_contract', 'audit_contract_required', true, 'Every write RPC must emit controlled audit/admin event.'),
    ('development_10b_entry_contract', 'locked_search_path_required', true, 'Any elevated execution body must lock search_path to trusted schemas only.'),
    ('development_10b_entry_contract', 'rollback_flag_required', true, 'Repository write reroute must be behind one explicit rollback feature flag.'),
    ('development_10b_entry_contract', 'self_lockout_guard_required', true, 'Self-lockout and privilege escalation guards are mandatory.'),
    ('production_gate', 'owner_write_rpcs_created', false, 'No owner-write RPCs are created by this final gate.'),
    ('production_gate', 'grants_created', false, 'No GRANT is created by this final gate.'),
    ('production_gate', 'flutter_write_reroute_authorized', false, 'Flutter write reroute remains blocked.'),
    ('production_gate', 'production_approved', false, 'Production remains not approved.'),
    ('production_gate', 'next_allowed_action', true, 'Submit single 10B executable candidate pack with exact bodies/evidence, or switch streams.'),
    ('sovereign_boundary', 'no_auth_users_migration', true, 'Supabase Auth identity source remains unchanged.'),
    ('sovereign_boundary', 'no_destructive_sql', true, 'Read-only gate; no DROP/DELETE/TRUNCATE/ALTER/rename/archive/exact public table replacement.'),
    ('sovereign_boundary', 'no_flutter_service_role', true, 'No service role is authorized in Flutter.'),
    ('sovereign_boundary', 'no_waqf_assets_mutation', true, 'No waqf_assets/waqf/awqaf_system DDL or DML is included.')
)
select * from final_gate
order by section, check_key;
