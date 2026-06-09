
-- Future Auth/RBAC Controlled Migration Gate
-- SQL 43: read-only future-track conditions.

select *
from (
  values
    ('future_track', 'auth_rbac_controlled_migration_required', false, 'Access-helper rewrites must be moved out of Database Ownership cleanup.'),
    ('required_evidence', 'exact_body_approval', false, 'No approved replacement bodies attached.'),
    ('required_evidence', 'backup_restore_point', false, 'No real backup/restore point supplied.'),
    ('required_evidence', 'governance_token', false, 'No explicit governance token supplied.'),
    ('required_evidence', 'rls_negative_uat', false, 'Actor-case evidence still required.'),
    ('required_evidence', 'browser_network_clean', false, 'Browser/network evidence still required.'),
    ('production_gate', 'not_approved', false, 'Production remains blocked.')
) as t(section, gate_key, passed, note);
