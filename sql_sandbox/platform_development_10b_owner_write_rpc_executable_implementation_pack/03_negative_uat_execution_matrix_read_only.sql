-- Platform Development 10B
-- Negative UAT execution matrix placeholder / evidence intake.
-- Fill the evidence columns after browser and SQL/RLS role tests.

select * from (values
  ('anonymous', false, 'Must fail: no admin/core/platform write surfaces or sensitive wrappers. Evidence required: screenshot + console clean + denied RPC attempt.'),
  ('unauthorized_authenticated_user', false, 'Must fail: authenticated but unauthorized user cannot run owner-write RPCs.'),
  ('scoped_user', false, 'Must fail for role/permission grants outside permitted modules and system scope.'),
  ('unit_admin', false, 'Must fail for platform-wide unsafe controls and cross-unit writes.'),
  ('platform_admin', false, 'May access governed surfaces but must fail privilege escalation and unsafe self-lockout paths.'),
  ('superuser', false, 'May access planning/RBAC/core surfaces but must fail self-lockout denial tests.'),
  ('browser_console_clean', false, 'Required after running Flutter with --dart-define=PWF_OWNER_WRITE_RPC_WRITE_REROUTE=true in staging.'),
  ('production_approved', false, 'Production remains false until all negative UAT evidence passes.')
) as t(check_key, passed, note);
