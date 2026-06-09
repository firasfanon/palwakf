-- Platform Development 10I
-- Actual Negative UAT runner result intake (read-only).
-- This script records the uploaded runner facts as SELECT output only.
-- No DDL, no DML, no auth.users mutation, no waqf mutation.

with uploaded_evidence as (
  select
    'platform_development_10i_actual_negative_uat_result_intake'::text as section,
    '2026-05-24T131133_266186Z'::text as run_id,
    '2026-05-24T13:11:40.302182Z'::timestamptz as generated_at_utc,
    true as all_required_actor_cases_denied,
    0::int as unsafe_success_count,
    0::int as missing_config_count,
    false as production_approved_by_runner,
    'cd1e4746b32757240702cf3bfbeb56259db9c845a9aab73dcca0e69282c03b75'::text as json_sha256,
    '2671d0a667e6805dbff85ea95690184ae894d9775693605507ba8619a782e6f8'::text as md_sha256
),
actor_matrix(actor, required, total_attempts, denied_attempts, unsafe_success, status) as (
  values
    ('anonymous', true, 8, 8, 0, 'passed_negative_denial'),
    ('unauthorized_authenticated_user', true, 2, 2, 0, 'passed_negative_denial'),
    ('scoped_user', true, 2, 2, 0, 'passed_negative_denial'),
    ('unit_admin', true, 2, 2, 0, 'passed_negative_denial'),
    ('platform_admin', true, 2, 2, 0, 'passed_negative_denial'),
    ('superuser', true, 2, 2, 0, 'passed_negative_denial')
)
select * from uploaded_evidence
union all
select
  'actor_matrix:' || actor as section,
  null::text as run_id,
  null::timestamptz as generated_at_utc,
  (denied_attempts = total_attempts and unsafe_success = 0) as all_required_actor_cases_denied,
  unsafe_success as unsafe_success_count,
  0::int as missing_config_count,
  false as production_approved_by_runner,
  null::text as json_sha256,
  null::text as md_sha256
from actor_matrix;

select
  'sovereign_boundary' as section,
  'no_mutation_in_this_script' as check_key,
  true as passed,
  'Read-only result intake; no DDL/DML; does not touch auth.users, waqf, waqf_assets, or awqaf_system.' as note;
