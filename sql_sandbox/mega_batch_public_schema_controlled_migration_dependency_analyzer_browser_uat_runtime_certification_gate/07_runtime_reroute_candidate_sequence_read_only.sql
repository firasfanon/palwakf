-- 07_runtime_reroute_candidate_sequence_read_only.sql
-- Mega Batch: Public Schema Controlled Migration Runtime Reroute Candidate Sequence
-- Date: 2026-05-22
-- Safety: SELECT-only. No DDL, no DML, no destructive SQL.
-- Purpose: define an ordered, reversible reroute plan. It is a plan only.

select * from (
  values
    ('phase_0_hold', 0, 'keep legacy public tables preserved', 'required now', 'No runtime reroute until route console evidence and dependency-zero evidence are accepted'),
    ('phase_1_adapter_probe', 1, 'add repository-level compatibility-wrapper probes only', 'future candidate', 'Use public wrappers/RPCs first; do not read owner schemas directly from public runtime'),
    ('phase_2_low_risk_read_only', 2, 'header/footer/site_pages/homepage read-only reroute candidates', 'future candidate', 'Single-family reroute with rollback flag and Browser UAT per route'),
    ('phase_3_access_rbac_hold', 3, 'admin_users/RBAC/system permissions', 'blocked', 'High-risk access path; requires role UAT and fail-closed evidence'),
    ('phase_4_assistant_hold', 4, 'assistant/chatbot records', 'blocked', 'Privacy-sensitive; requires assistant scope/RLS review'),
    ('phase_5_destructive_never_implicit', 5, 'archive/delete/drop/rename/exact replacement', 'blocked', 'Requires explicit written approval after dependency-zero and full browser console evidence')
) as phases(phase_key, phase_order, scope, status, note)
order by phase_order;

select * from (
  values
    ('no_direct_owner_schema_read_from_public_pages', 'Runtime public pages should use public wrappers/RPCs, not direct platform/core/assistant tables.'),
    ('wrapper_first_then_owner_internal', 'Owner schemas are internal authority; public remains stable surface.'),
    ('rollback_flag_required', 'Every reroute must include a controlled rollback path before Browser UAT.'),
    ('one_family_at_a_time', 'Do not reroute platform/core/assistant families together.'),
    ('no_waqf_assets_mutation', 'waqf_assets/waqf/awqaf_system remain out of this migration.')
) as rules(rule_key, rule_text);
