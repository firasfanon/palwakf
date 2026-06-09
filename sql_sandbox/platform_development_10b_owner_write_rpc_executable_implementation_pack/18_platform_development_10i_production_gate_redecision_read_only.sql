-- Platform Development 10I
-- Production gate redecision template after actual Negative UAT runner (read-only).
-- This script intentionally keeps production blocked unless the operator also
-- supplies SQL 17 proof and admin/write-surface browser console evidence.

with evidence as (
  select
    true as actual_negative_uat_runner_passed,
    true as all_required_actor_cases_denied,
    0::int as unsafe_success_count,
    false as sql_rls_no_unsafe_mutation_proof_attached,
    false as admin_write_surface_console_clean_attached,
    false as explicit_production_owner_write_reroute_approval
)
select
  'platform_development_10i_production_gate_redecision' as section,
  case
    when actual_negative_uat_runner_passed
     and all_required_actor_cases_denied
     and unsafe_success_count = 0
     and sql_rls_no_unsafe_mutation_proof_attached
     and admin_write_surface_console_clean_attached
     and explicit_production_owner_write_reroute_approval
    then 'PRODUCTION_APPROVAL_ELIGIBLE'
    else 'PRODUCTION_BLOCKED_PENDING_SQL_RLS_PROOF_ADMIN_WRITE_CONSOLE_AND_EXPLICIT_APPROVAL'
  end as decision,
  jsonb_build_object(
    'actual_negative_uat_runner_passed', actual_negative_uat_runner_passed,
    'all_required_actor_cases_denied', all_required_actor_cases_denied,
    'unsafe_success_count', unsafe_success_count,
    'sql_rls_no_unsafe_mutation_proof_attached', sql_rls_no_unsafe_mutation_proof_attached,
    'admin_write_surface_console_clean_attached', admin_write_surface_console_clean_attached,
    'explicit_production_owner_write_reroute_approval', explicit_production_owner_write_reroute_approval,
    'production_approved', false,
    'no_auth_users_migration', true,
    'no_flutter_elevated_secret', true,
    'no_waq_assets_mutation', true
  ) as decision_payload
from evidence;
