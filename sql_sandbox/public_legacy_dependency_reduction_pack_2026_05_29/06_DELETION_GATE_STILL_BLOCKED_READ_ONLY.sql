-- Public Legacy Dependency Reduction Pack
-- 06_DELETION_GATE_STILL_BLOCKED_READ_ONLY.sql
-- Read-only destructive-action guard.

select *
from (
  values
    ('public_legacy_deletion_gate', 'media_center_present_legacy_tables', 'preserve', 'Data moved, but routine/policy/grant dependencies remain.'),
    ('public_legacy_deletion_gate', 'service_center_present_legacy_tables', 'preserve', 'Service catalog/taxonomy remains runtime/dependency surface.'),
    ('public_legacy_deletion_gate', 'drop_authorized', 'false', 'DROP is not authorized.'),
    ('public_legacy_deletion_gate', 'delete_authorized', 'false', 'DELETE is not authorized.'),
    ('public_legacy_deletion_gate', 'archive_authorized', 'false', 'Archive/delete is not authorized.'),
    ('public_legacy_deletion_gate', 'exact_public_replacement_authorized', 'false', 'Exact public table replacement is not authorized.'),
    ('public_legacy_deletion_gate', 'next_pack', 'exact_body_rewrite_pack_after_export_review', 'Dependency reduction may continue only after exact body export and mapping review.')
) as t(section, gate_key, gate_value, note);
