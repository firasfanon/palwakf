-- Public Schema Phase 3 — Production Gate Re-Decision
-- Date: 2026-05-23
-- Mode: READ ONLY decision marker. No DDL/DML.

with gate_inputs as (
  select * from (values
    ('phase2_rbac_read_adapters', true, 'Phase 2 read adapter remediation is preserved as staging candidate.'),
    ('phase3_core_admin_auth_runtime_remediation', false, 'Planning gate only; no runtime remediation executed.'),
    ('owner_write_rpcs_created', false, 'Owner-write RPCs are design-only and not installed.'),
    ('role_rls_browser_console_evidence', false, 'No fresh evidence supplied with this batch.'),
    ('dependency_zero_certified', false, 'Core/admin/write blockers remain.'),
    ('auth_users_migrated', false, 'Correct: auth.users must not be migrated.'),
    ('destructive_sql_authorized', false, 'Correct: destructive SQL remains blocked.'),
    ('waqf_assets_mutated', false, 'Correct: this batch does not touch waqf_assets/waqf/awqaf_system.')
  ) as t(check_key, passed, note)
), decision as (
  select
    'production_gate_redecision' as section,
    'PRODUCTION_NOT_APPROVED_PHASE3_AND_OWNER_WRITE_RPC_BLOCKERS_REMAIN' as decision,
    'Continue with owner-write RPC implementation only after explicit SQL review, RLS/audit contract, rollback plan, and role/browser evidence.' as next_required_action
)
select 'gate_input' as section, check_key as key, passed::text as value, note
from gate_inputs
union all
select section, decision, 'false', next_required_action
from decision;
