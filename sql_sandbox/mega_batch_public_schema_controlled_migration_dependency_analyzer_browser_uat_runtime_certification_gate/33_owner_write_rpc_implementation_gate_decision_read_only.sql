-- Development 9E — Owner-Write RPC Implementation Gate Decision
-- READ ONLY. No DDL. No DML. No runtime reroute.

with gate_input(check_key, passed, note) as (
  values
    ('sql30_runtime_read_adapter_uat_passed', true, 'SQL 30 result accepted: read adapter remediation is present.'),
    ('sql31_preflight_review_gate_passed_as_blocking_evidence', true, 'SQL 31 result accepted: preflight remains closed for implementation.'),
    ('rpc_body_review_completed', false, 'Exact RPC SQL bodies have not been approved.'),
    ('rls_and_auth_uid_guards_reviewed', false, 'SQL-level guards still require review.'),
    ('audit_contract_reviewed', false, 'Audit event contract still requires implementation review.'),
    ('security_definer_search_path_locked', false, 'search_path lock review is not closed.'),
    ('rollback_flag_defined', false, 'Repository write reroute rollback flag is not approved.'),
    ('self_lockout_guard_defined', false, 'Self-lockout/privilege escalation guard is not approved.'),
    ('role_rls_browser_console_evidence_supplied', false, 'Fresh role/RLS/browser-console evidence is not supplied.'),
    ('owner_write_rpcs_created', false, 'Owner-write RPCs are not installed by 9E.'),
    ('flutter_write_reroute_authorized', false, 'No Flutter write reroute is authorized.'),
    ('production_approved', false, 'Production remains not approved.'),
    ('no_auth_users_migration', true, 'auth.users remains Supabase Auth identity source.'),
    ('no_destructive_sql', true, 'No destructive SQL or exact public table-name replacement.'),
    ('no_flutter_service_role', true, 'No service_role use inside Flutter is authorized.'),
    ('no_waqf_assets_mutation', true, 'No waqf_assets/waqf/awqaf_system DDL or DML is included.')
), final_decision as (
  select
    bool_and(case when check_key in (
      'rpc_body_review_completed',
      'rls_and_auth_uid_guards_reviewed',
      'audit_contract_reviewed',
      'security_definer_search_path_locked',
      'rollback_flag_defined',
      'self_lockout_guard_defined',
      'role_rls_browser_console_evidence_supplied'
    ) then passed else true end) as implementation_gate_ready
  from gate_input
)
select 'gate_input' as section, check_key, passed, note from gate_input
union all
select
  'implementation_gate_decision' as section,
  'OWNER_WRITE_RPC_IMPLEMENTATION_NOT_AUTHORIZED' as check_key,
  implementation_gate_ready as passed,
  'Implementation remains blocked until RPC body review, RLS/auth guards, audit, locked search_path, rollback flag, self-lockout guard, and role/browser evidence are all accepted.' as note
from final_decision;
