-- PalWakf Platform
-- Database Ownership Phase C — Service Center Controlled Ownership Closure
-- 05_SERVICE_CENTER_FINAL_CLOSURE_GATE_READ_ONLY.sql
-- Purpose: final gate marker. SELECT-only. This script does not itself accept browser evidence.

with gate(section, gate_key, passed, note) as (
  values
    ('phase_c_service_center_final_closure_gate','phase_b_media_center_closed', true, 'Media Center Phase B remains closed and is not modified by Phase C.'),
    ('phase_c_service_center_final_closure_gate','wave_a_safe_stop_preserved', true, 'Wave A access-helper execution remains cancelled.'),
    ('phase_c_service_center_final_closure_gate','service_center_owner_contract_prepared', true, 'platform_services owner schema and public compatibility strategy are defined in this mega pack.'),
    ('phase_c_service_center_final_closure_gate','master_census_required', false, 'Attach 01 result before apply/closure decision.'),
    ('phase_c_service_center_final_closure_gate','one_shot_apply_requires_operator_token', false, '02 is guarded and must not run without backup, explicit token, and proven gaps.'),
    ('phase_c_service_center_final_closure_gate','post_apply_or_current_state_validation_required', false, 'Attach 03 result after current-state validation or after controlled apply if needed.'),
    ('phase_c_service_center_final_closure_gate','browser_runtime_uat_required', false, 'Attach 04 browser/network evidence.'),
    ('phase_c_service_center_final_closure_gate','public_tracking_sensitive_field_gate_required', false, 'Public tracking must not expose requester/payload/internal fields.'),
    ('phase_c_service_center_final_closure_gate','legacy_public_tables_preserved', true, 'No drop/delete/archive/exact public replacement authorized.'),
    ('phase_c_service_center_final_closure_gate','production_gate', false, 'Production is not approved by this package alone.')
)
select
  section,
  gate_key,
  passed,
  note,
  false as execution_authorized_by_this_script,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  false as archive_delete_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation,
  true as read_only
from gate
order by gate_key;
