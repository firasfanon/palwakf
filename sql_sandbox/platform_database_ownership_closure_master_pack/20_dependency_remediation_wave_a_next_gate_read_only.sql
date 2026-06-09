-- Platform Database Ownership — SQL 20
-- Wave A next gate.
-- READ ONLY. No DDL. No DML. No grants. No destructive action.

select * from (values
  (
    'wave_a_gate',
    'classifier_output_intaken',
    true,
    'SQL 15 classified output has been supplied and accepted for planning.',
    false,
    false,
    false
  ),
  (
    'wave_a_gate',
    'raw_502_not_flat_blocker',
    true,
    'Raw dependency count includes compatibility wrappers, text mentions, sovereign review-only items, and genuine remediation candidates.',
    false,
    false,
    false
  ),
  (
    'wave_a_gate',
    'wave_a_remediation_design_required',
    false,
    'Prepare owner-wrapper remediation only for normalized Wave A candidates.',
    false,
    false,
    false
  ),
  (
    'wave_a_gate',
    'guarded_sql_02_03_04_authorized',
    false,
    'Still blocked until token, backup/restore point, and explicit governance authorization are supplied.',
    false,
    false,
    false
  ),
  (
    'wave_a_gate',
    'archive_delete_drop_authorized',
    false,
    'Still blocked until dependency-zero certification and explicit governance approval.',
    false,
    false,
    false
  ),
  (
    'wave_a_gate',
    'production_gate',
    false,
    'NOT_APPROVED. Browser console, RLS negative UAT, dependency-zero, and governance approval are still required.',
    false,
    false,
    false
  )
) as t(section, gate_key, passed, note, production_approved, destructive_sql_authorized, exact_public_table_replacement_authorized);
