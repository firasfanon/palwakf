-- Database Ownership Phase B — Media Center Mega Closure Pack
-- 05 — Final closure gate. READ ONLY.

with gates(gate_key, passed, note) as (
  values
    ('wave_a_safe_stop_preserved'::text, true, 'Wave A access-helper execution remains cancelled.'::text),
    ('media_center_owner_contract_prepared', true, 'Owner schema and compatibility strategy are defined in this mega pack.'),
    ('master_census_required', false, 'Attach 01 result before apply.'),
    ('one_shot_apply_requires_operator_token', false, '02 is guarded and must not run without token and backup.'),
    ('post_apply_validation_required', false, 'Attach 03 result after 02.'),
    ('browser_runtime_uat_required', false, 'Attach 04 browser/network evidence.'),
    ('legacy_public_tables_preserved', true, 'No drop/delete/archive/exact public replacement authorized.'),
    ('service_center_deferred', true, 'Service Center starts only after media closure evidence.'),
    ('production_gate', false, 'Production is not approved by this package alone.')
)
select
  'phase_b_media_final_closure_gate'::text as section,
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
from gates;
