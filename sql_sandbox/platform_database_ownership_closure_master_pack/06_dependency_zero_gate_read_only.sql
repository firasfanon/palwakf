-- Platform Database Ownership Closure Master Pack — 06
-- DEPENDENCY-ZERO GATE READ-ONLY.
with expected_blockers as (
  select * from (values
    ('flutter_direct_legacy_table_references'),
    ('db_views_or_functions_depending_on_public_legacy'),
    ('missing_owner_schema_or_shadow_target'),
    ('missing_public_compatibility_view_or_rpc'),
    ('browser_console_errors_after_reroute'),
    ('rls_negative_uat_not_passed')
  ) as v(blocker_family)
)
select 'dependency_zero_gate' as section,
       blocker_family,
       'must_be_zero_or_accepted_before_archive_delete_exact_replacement' as required_decision,
       false as dependency_zero_certified,
       false as production_approved
from expected_blockers;
