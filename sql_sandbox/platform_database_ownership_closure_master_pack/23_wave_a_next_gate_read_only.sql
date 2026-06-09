-- Platform Database Ownership Closure — Wave A next gate
-- Read-only decision gate after SQL 21/22.

with gates as (
  select * from (values
    ('classifier_output_intaken', true, 'accepted'),
    ('bucket_normalization_complete', true, 'Wave A candidate buckets separated from accepted compatibility/review-only buckets'),
    ('wave_a_execution_design_required', true, 'Prepare exact owner-wrapper execution bodies only for Wave A candidates'),
    ('rls_negative_uat_required', false, 'Actual actor-case evidence still required'),
    ('browser_console_clean_required', false, 'Browser/Network clean evidence still required'),
    ('token_backup_governance_required', false, 'Required before any guarded candidate execution'),
    ('archive_delete_drop_exact_replacement_authorized', false, 'Blocked')
  ) as t(gate_key, passed, note)
)
select
  'wave_a_next_gate' as section,
  gate_key,
  passed,
  note,
  case when bool_and(passed) over () then 'READY_FOR_EXECUTION_REVIEW' else 'DESIGN_ONLY_EXECUTION_BLOCKED' end as decision,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as read_only
from gates;
