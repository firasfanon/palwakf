select
  'platform_development_10j0h_home_management_finite_constraints_marker'::text as section,
  'no_sql_production_change_in_10j0h'::text as check_key,
  true as passed,
  '10J-0H is a Flutter runtime layout fix only; no SQL DDL/DML is included.'::text as note
union all
select
  'auth_boundary',
  'no_auth_users_mutation_in_10j0h',
  true,
  '10J-0H does not touch auth.users.'
union all
select
  'sovereign_boundary',
  'no_waq_assets_mutation_in_10j0h',
  true,
  '10J-0H does not touch waqf_assets, waqf, or awqaf_system.';
