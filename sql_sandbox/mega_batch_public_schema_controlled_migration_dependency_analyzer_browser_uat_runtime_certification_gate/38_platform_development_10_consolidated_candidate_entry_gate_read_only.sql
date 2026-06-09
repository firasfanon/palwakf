-- Platform Development 10 — Consolidated Implementation Candidate Entry Gate
-- READ ONLY. No CREATE FUNCTION. No GRANT. No DDL. No DML.
-- Purpose: accept SQL 37 and decide whether a consolidated implementation candidate is allowed.

with sql37_result(section, check_key, passed, note) as (
  values
    ('negative_uat_plan', 'anonymous', false,
      'must not access admin/core/platform write surfaces or sensitive wrappers | evidence=browser screenshot + console clean + SQL/RLS proof'),
    ('negative_uat_plan', 'unauthorized_authenticated_user', false,
      'must be blocked from platform-wide admin/user/system controls | evidence=browser screenshot + console clean + denied RPC/write attempt evidence'),
    ('negative_uat_plan', 'scoped_user', false,
      'must see only permitted modules and must not grant roles/permissions | evidence=browser screenshot + RBAC wrapper evidence'),
    ('negative_uat_plan', 'unit_admin', false,
      'must not access platform-wide unsafe controls or cross-unit write paths | evidence=browser screenshot + denied write-path evidence'),
    ('negative_uat_plan', 'platform_admin', false,
      'may access governed management surfaces but must not bypass SQL-level guards | evidence=positive view evidence + negative privilege escalation evidence'),
    ('negative_uat_plan', 'superuser', false,
      'may access migration/RBAC/core planning surfaces but must still pass SQL-level guard constraints | evidence=positive view evidence + self-lockout denial evidence'),
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
), candidate_decision(section, check_key, passed, note) as (
  values
    ('platform_development_10_entry_gate', 'sql37_result_accepted', true,
      'SQL 37 negative UAT planning and single-pack rule are accepted.'),
    ('platform_development_10_entry_gate', 'consolidated_candidate_allowed_now', false,
      'Implementation candidate is blocked because exact SQL bodies, negative UAT evidence, and explicit authorization are not supplied.'),
    ('platform_development_10_entry_gate', 'consolidated_readiness_pack_allowed', true,
      'A consolidated readiness/blocker pack is allowed and should replace small review-only patches.'),
    ('platform_development_10_entry_gate', 'implementation_authorized', false,
      'Implementation remains unauthorized.'),
    ('platform_development_10_entry_gate', 'production_approved', false,
      'Production remains not approved.'),
    ('platform_development_10_entry_gate', 'owner_write_rpcs_created', false,
      'No owner-write RPCs are created by this read-only gate.'),
    ('platform_development_10_entry_gate', 'flutter_write_reroute_authorized', false,
      'Flutter write reroute remains unauthorized.'),
    ('platform_development_10_entry_gate', 'next_real_implementation_requires_explicit_go', true,
      'Next implementation-capable pack requires exact bodies, SQL-level guards, audit, locked search_path, rollback, self-lockout, role/browser evidence, and explicit approval.')
)
select section, check_key, passed, note from sql37_result
union all
select section, check_key, passed, note from candidate_decision;
