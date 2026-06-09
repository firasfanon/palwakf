-- Development 9F — Owner-Write RPC Implementation Authorization Review
-- READ ONLY. No CREATE FUNCTION. No GRANT. No DDL. No DML.
-- Purpose: intake SQL 32/33 results and decide whether implementation can start.

with accepted_input(section, check_key, passed, note) as (
  values
    ('sql32_result', 'proposed_rpc_bodies_review_required', true,
      'SQL 32 result accepted: all proposed owner-write RPCs remain review_required and implementation_authorized=false.'),
    ('sql32_result', 'rpc_body_review_completed', false,
      'Exact SQL function bodies are not reviewed or approved.'),
    ('sql32_result', 'rls_auth_uid_guards_approved', false,
      'SQL-level actor/admin/scope guards are not approved.'),
    ('sql32_result', 'audit_contract_approved', false,
      'Audit/admin event implementation contract is not approved.'),
    ('sql32_result', 'search_path_locked_approved', false,
      'SECURITY DEFINER remains blocked unless search_path is explicitly locked and reviewed.'),
    ('sql32_result', 'rollback_feature_flag_approved', false,
      'Repository write reroute rollback/feature flag is not approved.'),
    ('sql32_result', 'self_lockout_guard_approved', false,
      'Self-lockout and privilege-escalation guard evidence is not approved.'),
    ('sql33_result', 'implementation_gate_decision', false,
      'OWNER_WRITE_RPC_IMPLEMENTATION_NOT_AUTHORIZED remains the correct decision.'),
    ('sql33_result', 'role_rls_browser_console_evidence_supplied', false,
      'Fresh role/RLS/browser-console evidence is still absent.'),
    ('sovereign_boundary', 'no_auth_users_migration', true,
      'auth.users remains Supabase Auth identity source and is not migrated.'),
    ('sovereign_boundary', 'no_destructive_sql', true,
      'No DROP/DELETE/TRUNCATE/ALTER/rename/archive/exact public table replacement.'),
    ('sovereign_boundary', 'no_flutter_service_role', true,
      'No service_role use inside Flutter is authorized.'),
    ('sovereign_boundary', 'no_waqf_assets_mutation', true,
      'No waqf_assets/waqf/awqaf_system DDL or DML is included.')
), authorization_gate(check_key, passed, note) as (
  values
    ('implementation_authorized', false,
      'Implementation is not authorized in 9F because body review, RLS/auth guards, audit, locked search_path, rollback, self-lockout, and role/browser evidence remain open.'),
    ('exact_body_draft_gate_opened', true,
      '9F opens a review-only exact body draft gate. It does not install functions.'),
    ('owner_write_rpcs_created', false,
      'No owner-write RPCs are created by this read-only gate.'),
    ('flutter_write_reroute_authorized', false,
      'Flutter write reroute remains unauthorized.'),
    ('production_approved', false,
      'Production remains not approved.')
)
select section, check_key, passed, note from accepted_input
union all
select 'authorization_gate' as section, check_key, passed, note from authorization_gate;
