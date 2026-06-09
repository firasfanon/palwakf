-- Script 20: Phase 2 RBAC Role/RLS/Browser UAT matrix (READ ONLY)

select *
from (values
  ('superuser', '/admin', 'sidebar/dashboard/rbac access remains allowed', false, 'browser role evidence required'),
  ('platform_admin', '/admin/database-migration', 'can view migration gate without write escalation', false, 'browser role evidence required'),
  ('unit_admin', '/admin', 'sees only scoped systems/sections allowed by RBAC', false, 'role-scope evidence required'),
  ('scoped_user', '/admin/dashboard', 'does not see platform-wide RBAC controls unless granted', false, 'negative role evidence required'),
  ('unauthorized_user', '/admin/database-migration', 'blocked or restricted without leaking RBAC data', false, 'negative role evidence required'),
  ('anonymous', '/admin', 'redirected/blocked before RBAC data read', false, 'anonymous evidence required')
) as matrix(role_key, route_path, expected_result, evidence_accepted, note);

select
  '20_phase2_rbac_role_rls_browser_gate' as section,
  false as role_uat_evidence_accepted,
  false as rls_evidence_accepted,
  false as browser_console_evidence_accepted,
  false as production_approved,
  'ROLE_RLS_BROWSER_EVIDENCE_REQUIRED_AFTER_PHASE2_IMPLEMENTATION' as decision;
