-- Platform Database Ownership Closure Master Pack — 07
-- RLS NEGATIVE UAT MATRIX READ-ONLY.
select * from (values
  ('anonymous', 'all owner-write RPCs denied', false),
  ('unauthorized_authenticated_user', 'all owner-write RPCs denied', false),
  ('wrong_unit_user', 'cross-unit writes denied', false),
  ('scoped_user', 'only scoped read/write allowed by contract', false),
  ('platform_admin', 'admin write allowed only via RPC/audit', false),
  ('superuser', 'superuser positive path audited', false)
) as matrix(actor_case, expected_result, passed_by_this_script);
