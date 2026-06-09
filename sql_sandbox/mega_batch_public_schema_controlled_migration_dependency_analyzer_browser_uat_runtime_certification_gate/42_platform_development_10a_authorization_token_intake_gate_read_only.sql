-- Platform Development 10A — Authorization Token Intake Gate
-- READ ONLY. No executable function body. No permission grant. No DDL. No DML.
-- Purpose: record the user-supplied execution token while enforcing the remaining blockers.

with token_input(section, check_key, passed, note) as (
  values
    ('authorization_token', 'AUTHORIZE_OWNER_WRITE_RPC_EXECUTION', true,
      'User supplied the authorization token in chat.'),
    ('authorization_token', 'token_is_sufficient_alone', false,
      'Token is only an intent marker; exact bodies and evidence are mandatory before execution.'),
    ('authorization_token', 'effective_implementation_authorized', false,
      'Effective authorization remains false because exact bodies and negative UAT evidence are not supplied.')
), required_inputs(section, check_key, passed, note) as (
  values
    ('required_input', 'all_eight_exact_sql_bodies_supplied', false,
      'Executable owner-write RPC bodies are still absent.'),
    ('required_input', 'negative_uat_actor_bundle_supplied', false,
      'Anonymous, unauthorized, scoped, unit, platform, and superuser evidence remains absent.'),
    ('required_input', 'role_rls_browser_console_evidence_supplied', false,
      'Fresh role/RLS/browser-console evidence is still absent.'),
    ('required_input', 'rls_audit_search_path_rollback_review_closed', false,
      'SQL-level guard, audit, locked search path, rollback, and self-lockout reviews remain open.')
), decision_rows(section, check_key, passed, note) as (
  values
    ('development_10a_decision', 'authorization_token_intaken', true,
      'The token is recorded in baseline and governance documents.'),
    ('development_10a_decision', 'owner_write_rpcs_created', false,
      'No owner-write RPCs are created by this gate.'),
    ('development_10a_decision', 'flutter_write_reroute_authorized', false,
      'Flutter write reroute remains blocked.'),
    ('development_10a_decision', 'production_approved', false,
      'Production remains not approved.'),
    ('sovereign_boundary', 'no_auth_users_migration', true,
      'Supabase Auth identity source remains unchanged.'),
    ('sovereign_boundary', 'no_destructive_sql', true,
      'This gate is read-only and does not modify schema or data.'),
    ('sovereign_boundary', 'no_flutter_service_role', true,
      'No service role is authorized in Flutter.'),
    ('sovereign_boundary', 'no_waqf_assets_mutation', true,
      'No waqf assets, waqf schema, or awqaf system changes are included.')
)
select section, check_key, passed, note from token_input
union all
select section, check_key, passed, note from required_inputs
union all
select section, check_key, passed, note from decision_rows;
