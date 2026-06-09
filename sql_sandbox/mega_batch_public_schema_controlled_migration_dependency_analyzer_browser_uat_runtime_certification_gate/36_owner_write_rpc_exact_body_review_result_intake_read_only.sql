-- Development 9G — Owner-Write RPC Exact Body Review Result Intake
-- READ ONLY. No CREATE FUNCTION. No GRANT. No DDL. No DML.
-- Purpose: accept SQL 34/35 evidence and close the repetitive micro-gate loop.

with sql34_result(section, check_key, passed, note) as (
  values
    ('sql34_result', 'implementation_authorized', false,
      'SQL 34 confirms implementation is not authorized.'),
    ('sql34_result', 'exact_body_draft_gate_opened', true,
      'SQL 34 confirms an exact body draft review gate is open, review-only.'),
    ('sql34_result', 'owner_write_rpcs_created', false,
      'No owner-write RPCs were created.'),
    ('sql34_result', 'flutter_write_reroute_authorized', false,
      'Flutter write reroute remains unauthorized.'),
    ('sql34_result', 'production_approved', false,
      'Production remains not approved.'),
    ('sql34_result', 'no_auth_users_migration', true,
      'auth.users remains Supabase Auth identity source and is not migrated.'),
    ('sql34_result', 'no_destructive_sql', true,
      'No destructive SQL or exact public table-name replacement is authorized.'),
    ('sql34_result', 'no_flutter_service_role', true,
      'No service_role use inside Flutter is authorized.'),
    ('sql34_result', 'no_waqf_assets_mutation', true,
      'No waqf_assets/waqf/awqaf_system DDL or DML is included.')
), sql35_result(section, check_key, passed, note) as (
  values
    ('sql35_result', 'create_function_authorized', false,
      'SQL 35 confirms no executable CREATE FUNCTION is authorized.'),
    ('sql35_result', 'grant_authorized', false,
      'SQL 35 confirms no GRANT is authorized.'),
    ('sql35_result', 'locked_search_path_required', true,
      'Future SECURITY DEFINER bodies must lock search_path.'),
    ('sql35_result', 'audit_required', true,
      'Future write bodies must emit controlled audit/admin events.'),
    ('sql35_result', 'negative_uat_required', true,
      'Negative UAT is mandatory before reroute.'),
    ('sql35_result', 'rpc_exact_body_requirements_defined', true,
      'Exact body requirements are defined for all eight proposed owner-write RPCs.'),
    ('sql35_result', 'no_auth_users_migration', true,
      'auth.users remains Supabase Auth identity source and is not migrated.'),
    ('sql35_result', 'no_waqf_assets_mutation', true,
      'No waq_assets/waqf/awqaf_system DDL or DML is included.')
), consolidated_decision(section, check_key, passed, note) as (
  values
    ('development_9g_consolidated_decision', 'phase3_micro_patch_loop_closed', true,
      'Do not continue small review-only micro-patches. Next step must be either one consolidated implementation-candidate pack with exact bodies and evidence, or a handoff/stream switch.'),
    ('development_9g_consolidated_decision', 'implementation_candidate_allowed_without_exact_bodies', false,
      'No implementation candidate is allowed without full SQL bodies, RLS/auth guards, audit, locked search_path, rollback, self-lockout guards, and role/browser evidence.'),
    ('development_9g_consolidated_decision', 'production_approved', false,
      'Production remains not approved.'),
    ('development_9g_consolidated_decision', 'runtime_write_reroute_authorized', false,
      'Runtime write reroute remains unauthorized.')
)
select section, check_key, passed, note from sql34_result
union all
select section, check_key, passed, note from sql35_result
union all
select section, check_key, passed, note from consolidated_decision;
