-- Development 9G — Negative UAT Planning Gate + Batch Consolidation Decision
-- READ ONLY. No CREATE FUNCTION. No GRANT. No DDL. No DML.
-- Purpose: define the next single large gate and end repetitive micro-patches.

with negative_uat_plan(actor_case, expected_result, required_evidence, passed) as (
  values
    ('anonymous',
      'must not access admin/core/platform write surfaces or sensitive wrappers',
      'browser screenshot + console clean + SQL/RLS proof',
      false),
    ('unauthorized_authenticated_user',
      'must be blocked from platform-wide admin/user/system controls',
      'browser screenshot + console clean + denied RPC/write attempt evidence',
      false),
    ('scoped_user',
      'must see only permitted modules and must not grant roles/permissions',
      'browser screenshot + RBAC wrapper evidence',
      false),
    ('unit_admin',
      'must not access platform-wide unsafe controls or cross-unit write paths',
      'browser screenshot + denied write-path evidence',
      false),
    ('platform_admin',
      'may access governed management surfaces but must not bypass SQL-level guards',
      'positive view evidence + negative privilege escalation evidence',
      false),
    ('superuser',
      'may access migration/RBAC/core planning surfaces but must still pass SQL-level guard constraints',
      'positive view evidence + self-lockout denial evidence',
      false)
), next_gate(section, check_key, passed, note) as (
  values
    ('next_gate', 'single_consolidated_pack_required', true,
      'Next work must be one consolidated pack, not another chain of small gates.'),
    ('next_gate', 'exact_sql_bodies_required', true,
      'All eight RPC bodies must be supplied as reviewable SQL before CREATE FUNCTION can be considered.'),
    ('next_gate', 'negative_uat_required', true,
      'Anonymous/unauthorized/scoped/unit/platform/superuser negative UAT is mandatory.'),
    ('next_gate', 'implementation_authorized_now', false,
      'Implementation is not authorized by this plan.'),
    ('next_gate', 'production_approved', false,
      'Production remains not approved.'),
    ('sovereign_boundary', 'no_auth_users_migration', true,
      'auth.users remains Supabase Auth identity source and is not migrated.'),
    ('sovereign_boundary', 'no_destructive_sql', true,
      'No DROP/DELETE/TRUNCATE/ALTER/rename/archive/exact public table replacement.'),
    ('sovereign_boundary', 'no_flutter_service_role', true,
      'No service_role use inside Flutter is authorized.'),
    ('sovereign_boundary', 'no_waqf_assets_mutation', true,
      'No waqf_assets/waqf/awqaf_system DDL or DML is included.')
)
select
  'negative_uat_plan' as section,
  actor_case as check_key,
  passed,
  expected_result || ' | evidence=' || required_evidence as note
from negative_uat_plan
union all
select section, check_key, passed, note from next_gate;
