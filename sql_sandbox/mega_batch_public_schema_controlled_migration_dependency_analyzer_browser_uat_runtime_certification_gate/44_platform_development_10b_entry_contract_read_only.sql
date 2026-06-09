-- Platform Development 10A — 10B Entry Contract
-- READ ONLY. No executable function body. No permission grant. No DDL. No DML.

with entry_contract(section, check_key, passed, note) as (
  values
    ('development_10b_entry_contract', 'explicit_token_required', true,
      'The explicit execution token was supplied, but remains conditional.'),
    ('development_10b_entry_contract', 'exact_bodies_required', true,
      'All eight exact SQL bodies must be submitted as a single reviewable pack.'),
    ('development_10b_entry_contract', 'negative_uat_required', true,
      'Full actor-case evidence is mandatory before execution.'),
    ('development_10b_entry_contract', 'audit_contract_required', true,
      'Every future write function must emit a controlled audit/admin event.'),
    ('development_10b_entry_contract', 'locked_search_path_required', true,
      'Any elevated execution body must lock search path to trusted schemas only.'),
    ('development_10b_entry_contract', 'rollback_flag_required', true,
      'Repository write reroute must be behind one explicit rollback flag.'),
    ('development_10b_entry_contract', 'self_lockout_guard_required', true,
      'Self-lockout and privilege escalation guards are mandatory.'),
    ('development_10b_entry_contract', 'implementation_may_start_now', false,
      'Execution may not start from 10A because exact bodies and evidence are absent.')
)
select section, check_key, passed, note from entry_contract;
