-- Public Schema Phase 3 — Role/RLS/Browser Console Evidence Intake
-- Date: 2026-05-23
-- Mode: READ ONLY manual evidence checklist/intake marker.
-- No evidence files/logs were supplied with this batch; all evidence gates remain pending.

with required_evidence as (
  select * from (values
    ('format_analyze', 'dart format + flutter analyze', 'not_supplied', false, 'Required after applying Development 9 pack.'),
    ('chrome_startup', 'flutter run -d chrome', 'not_supplied', false, 'Required after applying Development 9 pack.'),
    ('route_console', '/admin/database-migration console clean', 'not_supplied', false, 'Must show no red Supabase/PostgREST/schema errors.'),
    ('role_superuser', 'superuser can view migration/RBAC/core planning surfaces', 'not_supplied', false, 'Required browser evidence.'),
    ('role_platform_admin', 'platform admin can view allowed management surfaces', 'not_supplied', false, 'Required browser evidence.'),
    ('role_unit_admin', 'unit admin cannot access platform-wide unsafe controls', 'not_supplied', false, 'Required browser evidence.'),
    ('role_scoped_user', 'scoped user sees only permitted modules', 'not_supplied', false, 'Required browser evidence.'),
    ('role_unauthorized', 'unauthorized admin/user is blocked', 'not_supplied', false, 'Required browser evidence.'),
    ('anonymous', 'anonymous cannot access admin surfaces', 'not_supplied', false, 'Required browser evidence.'),
    ('rls_core_admin', 'core/admin compatibility surfaces do not leak data', 'not_supplied', false, 'Required SQL/browser evidence.'),
    ('rls_rbac', 'RBAC compatibility wrappers do not leak platform-wide assignments', 'not_supplied', false, 'Required SQL/browser evidence.')
  ) as t(section, evidence_item, supplied_status, passed, note)
)
select section, evidence_item, supplied_status, passed, note
from required_evidence
order by section, evidence_item;
