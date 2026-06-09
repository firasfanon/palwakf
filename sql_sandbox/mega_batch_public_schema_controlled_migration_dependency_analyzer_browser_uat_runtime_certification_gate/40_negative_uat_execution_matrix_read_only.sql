-- Platform Development 10 — Negative UAT Execution Matrix
-- READ ONLY. No CREATE FUNCTION. No GRANT. No DDL. No DML.
-- Purpose: define execution evidence required before any write reroute.

with actor_cases(actor_case, positive_expectation, negative_expectation, required_evidence, evidence_supplied, passed) as (
  values
    ('anonymous', 'can access public surfaces only', 'cannot access admin/core/platform write surfaces or sensitive wrappers', 'browser screenshot; console clean; SQL/RLS proof', false, false),
    ('unauthorized_authenticated_user', 'can authenticate if valid user', 'blocked from platform-wide admin/user/system controls and RPC writes', 'browser screenshot; console clean; denied RPC/write attempt evidence', false, false),
    ('scoped_user', 'sees permitted modules only', 'cannot grant roles or permissions', 'sidebar/dashboard evidence; RBAC wrapper evidence', false, false),
    ('unit_admin', 'can access unit-scoped controls where authorized', 'cannot access platform-wide unsafe controls or cross-unit writes', 'browser evidence; denied write-path evidence', false, false),
    ('platform_admin', 'can access governed management surfaces', 'cannot bypass SQL-level guards or escalate privilege', 'positive view evidence; negative privilege escalation evidence', false, false),
    ('superuser', 'can access migration/RBAC/core planning surfaces', 'cannot self-lockout or bypass SQL guard constraints', 'positive access evidence; self-lockout denial evidence', false, false)
), gate(section, check_key, passed, note) as (
  values
    ('negative_uat_execution_gate', 'all_actor_cases_supplied', false,
      'No full actor-case evidence bundle was supplied.'),
    ('negative_uat_execution_gate', 'browser_console_clean', false,
      'Browser console clean evidence is not supplied.'),
    ('negative_uat_execution_gate', 'sql_rls_proofs_supplied', false,
      'SQL/RLS evidence is not supplied.'),
    ('negative_uat_execution_gate', 'write_attempt_denials_supplied', false,
      'Denied write/RPC attempt evidence is not supplied.'),
    ('negative_uat_execution_gate', 'implementation_authorized', false,
      'Implementation remains unauthorized until negative UAT passes.'),
    ('negative_uat_execution_gate', 'production_approved', false,
      'Production remains not approved.')
)
select
  'negative_uat_actor_case' as section,
  actor_case as check_key,
  passed,
  'positive=' || positive_expectation || ' | negative=' || negative_expectation || ' | evidence=' || required_evidence as note
from actor_cases
union all
select section, check_key, passed, note from gate;
