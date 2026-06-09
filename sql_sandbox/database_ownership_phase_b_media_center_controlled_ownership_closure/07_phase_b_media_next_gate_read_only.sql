-- Database Ownership Phase B — Next gate. READ ONLY.

with t(section, gate_key, passed, note) as (
  values
    ('phase_b_media_next_gate'::text, 'wave_a_closed'::text, true, 'Wave A safe stop completed; do not resume access-helper replacement.'::text),
    ('phase_b_media_next_gate', 'media_inventory_required', false, 'Attach SQL 01 result.'),
    ('phase_b_media_next_gate', 'compat_surface_required', false, 'Attach SQL 03 result.'),
    ('phase_b_media_next_gate', 'exact_column_mapping_required_before_sync', false, 'Required before any media copy/sync body.'),
    ('phase_b_media_next_gate', 'browser_console_clean_required', false, 'Required before closure certification.'),
    ('phase_b_media_next_gate', 'legacy_public_preserved', true, 'No drop/delete/archive/exact replacement authorized.'),
    ('phase_b_media_next_gate', 'production_gate', false, 'NOT_APPROVED in this entry pack.')
)
select
  section,
  gate_key,
  passed,
  note,
  false as execution_authorized,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  false as archive_delete_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation,
  true as read_only
from t;
