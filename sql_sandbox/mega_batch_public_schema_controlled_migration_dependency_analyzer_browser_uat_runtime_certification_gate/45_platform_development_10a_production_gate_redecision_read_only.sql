-- Platform Development 10A — Production Gate Re-Decision
-- READ ONLY. No executable function body. No permission grant. No DDL. No DML.

with gate(section, check_key, passed, note) as (
  values
    ('production_gate', 'authorization_token_received', true,
      'Execution token received.'),
    ('production_gate', 'all_exact_bodies_supplied', false,
      'All exact SQL bodies are still missing.'),
    ('production_gate', 'negative_uat_passed', false,
      'Negative UAT is not supplied or passed.'),
    ('production_gate', 'owner_write_rpcs_created', false,
      'Owner-write RPCs are not created.'),
    ('production_gate', 'grants_created', false,
      'No permissions are granted.'),
    ('production_gate', 'flutter_write_reroute_authorized', false,
      'Flutter write reroute remains blocked.'),
    ('production_gate', 'production_approved', false,
      'Production is not approved.'),
    ('production_gate', 'next_allowed_action', true,
      'Submit a single 10B executable candidate pack with exact bodies and evidence, or switch streams.')
)
select section, check_key, passed, note from gate;
