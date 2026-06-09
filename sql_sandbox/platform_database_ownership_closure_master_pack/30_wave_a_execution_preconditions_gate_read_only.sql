-- Platform Database Dependency Wave A
-- 30: execution preconditions gate (read-only)
-- Purpose: make the non-negotiable preconditions explicit before any guarded body is prepared.

select * from (values
  ('wave_a_execution_preconditions_gate', 'exact_body_review_complete', false, 'SQL 25 body export has been supplied, but the final approved replacement bodies are not yet authorized.'),
  ('wave_a_execution_preconditions_gate', 'candidate_scope_limited_to_access_helpers', true, 'Candidate scope is narrowed to assistant/core/tasks access helper families; operational DML/import functions are excluded.'),
  ('wave_a_execution_preconditions_gate', 'rls_negative_uat_accepted', false, 'Anonymous, unauthorized, wrong-unit, scoped, platform-admin, and superuser evidence is still required.'),
  ('wave_a_execution_preconditions_gate', 'browser_console_clean_accepted', false, 'Admin/public/system route browser and network evidence is still required.'),
  ('wave_a_execution_preconditions_gate', 'backup_restore_point_supplied', false, 'A real backup/restore point is required before any guarded execution.'),
  ('wave_a_execution_preconditions_gate', 'governance_token_supplied', false, 'Explicit governance token is required before any guarded execution.'),
  ('wave_a_execution_preconditions_gate', 'execution_authorized', false, 'Blocked.'),
  ('wave_a_execution_preconditions_gate', 'production_gate', false, 'NOT_APPROVED.')
) as t(section, gate_key, passed, note);
