-- 17_phase2_rbac_role_uat_matrix_read_only.sql
-- Browser/Role UAT matrix required before any Phase 2 RBAC adapter remediation is accepted.
-- Read-only.

with role_matrix(role_key, route_or_surface, expected_result, required_evidence) as (
  values
    ('super_admin', '/admin/platform/system-registry', 'allowed with visible platform/RBAC diagnostics', 'browser screenshot + console clean'),
    ('super_admin', '/admin/database-migration', 'allowed with Phase 2 planning gate visible', 'browser screenshot + console clean'),
    ('platform_admin', '/admin/database-migration', 'allowed if policy permits diagnostics; otherwise safe forbidden', 'browser screenshot + console clean'),
    ('unit_admin', '/admin/database-migration', 'safe forbidden or scoped read-only diagnostics only', 'browser screenshot + console clean'),
    ('unauthorized_user', '/admin/database-migration', 'forbidden/login redirect; no partial RBAC data leak', 'browser screenshot + console clean'),
    ('anonymous', '/admin/database-migration', 'login redirect; no RBAC data leak', 'browser screenshot + console clean'),
    ('bthusr1_scoped_user', '/admin/assistant or scoped surfaces', 'only scoped systems/sections visible; no platform-wide RBAC leakage', 'browser screenshot + console clean')
)
select
  '17_phase2_rbac_role_uat_matrix' as section,
  role_key,
  route_or_surface,
  expected_result,
  required_evidence,
  false as evidence_accepted,
  'Role evidence not supplied in this planning batch.' as note
from role_matrix;

select
  '17_phase2_rbac_role_gate' as section,
  false as role_uat_evidence_accepted,
  false as rls_evidence_accepted,
  false as browser_console_evidence_accepted,
  false as phase2_runtime_remediation_authorized,
  'PHASE2_RBAC_ROLE_UAT_PENDING_RUNTIME_REMEDIATION_BLOCKED' as decision;
