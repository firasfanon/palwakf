-- NOT EXECUTABLE APPLY.
-- This file intentionally contains no DDL/DML/GRANT/REVOKE.
-- It is a placeholder documenting the conditions required before any future staging apply.
select
  '90_guarded_staging_apply_placeholder'::text as section,
  false as executable_apply_body_present,
  'NO_APPLY_BODY_INCLUDED'::text as status,
  'Requires explicit owner approval, exact rewritten body diff, negative UAT, browser smoke, rollback/no-rollback decision, and execution token.'::text as required_before_future_apply,
  false as production_approved,
  true as read_only;
