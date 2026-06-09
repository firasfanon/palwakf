-- Platform Development 10 — Consolidated Production Gate Re-decision
-- READ ONLY. No CREATE FUNCTION. No GRANT. No DDL. No DML.
-- Purpose: final decision for Development 10 entry based on currently supplied evidence.

with gate_inputs(section, check_key, passed, note) as (
  values
    ('gate_input', 'single_consolidated_pack_required', true,
      'The user accepted the move to Platform Development 10 as a consolidated pack.'),
    ('gate_input', 'sql37_negative_uat_plan_accepted', true,
      'SQL 37 plan is accepted as a planning gate.'),
    ('gate_input', 'exact_sql_bodies_supplied', false,
      'Exact executable SQL bodies are not supplied.'),
    ('gate_input', 'exact_sql_bodies_approved', false,
      'Exact executable SQL bodies are not approved.'),
    ('gate_input', 'rls_auth_guards_approved', false,
      'RLS/auth.uid guards are not approved.'),
    ('gate_input', 'audit_contract_implementation_approved', false,
      'Audit implementation is not approved.'),
    ('gate_input', 'locked_search_path_approved', false,
      'Locked search_path evidence is not approved.'),
    ('gate_input', 'rollback_feature_flag_approved', false,
      'Rollback feature flag is not approved.'),
    ('gate_input', 'self_lockout_guard_approved', false,
      'Self-lockout/privilege escalation guard is not approved.'),
    ('gate_input', 'negative_uat_supplied', false,
      'Negative UAT evidence is not supplied.'),
    ('gate_input', 'role_browser_console_evidence_supplied', false,
      'Role/browser console evidence is not supplied.'),
    ('gate_input', 'owner_write_rpcs_created', false,
      'Owner-write RPCs are not created.'),
    ('gate_input', 'grants_created', false,
      'No grants are created.'),
    ('gate_input', 'flutter_write_reroute_authorized', false,
      'Flutter write reroute is not authorized.'),
    ('gate_input', 'no_auth_users_migration', true,
      'auth.users remains Supabase Auth identity source.'),
    ('gate_input', 'no_destructive_sql', true,
      'No destructive SQL is authorized.'),
    ('gate_input', 'no_flutter_service_role', true,
      'No service_role use inside Flutter is authorized.'),
    ('gate_input', 'no_waqf_assets_mutation', true,
      'No waqf_assets/waqf/awqaf_system DDL or DML is included.')
), decision(section, check_key, passed, note) as (
  values
    ('platform_development_10_decision', 'CONSOLIDATED_IMPLEMENTATION_CANDIDATE_BLOCKED', false,
      'Development 10 can only be a readiness/blocker pack now; implementation is blocked until exact bodies and evidence are supplied.'),
    ('platform_development_10_decision', 'PRODUCTION_NOT_APPROVED', false,
      'Production is not approved.'),
    ('platform_development_10_decision', 'NEXT_IMPLEMENTATION_PACK_REQUIRES_EXPLICIT_AUTHORIZATION', true,
      'The next implementation-capable package must include exact SQL bodies and explicit execution authorization.')
)
select section, check_key, passed, note from gate_inputs
union all
select section, check_key, passed, note from decision;
