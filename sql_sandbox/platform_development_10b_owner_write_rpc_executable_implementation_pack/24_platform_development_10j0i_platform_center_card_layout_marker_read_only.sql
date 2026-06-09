-- Platform Development 10J-0I marker — read-only
-- Records that the 10J-0I Flutter-only platform-center card layout fix
-- does not perform SQL DML and preserves sovereign/auth boundaries.

select
  'platform_development_10j0i'::text as section,
  'platform_center_card_layout_fix_is_flutter_only'::text as check_key,
  true as passed,
  'No SQL production change is included in 10J-0I.'::text as note;

select
  'auth_boundary'::text as section,
  'no_auth_users_mutation_in_this_script'::text as check_key,
  true as passed,
  'Read-only marker only; no auth.users DML.'::text as note;

select
  'sovereign_boundary'::text as section,
  'no_waq_assets_mutation_in_this_script'::text as check_key,
  true as passed,
  'Read-only marker only; no waqf/waq_assets/awqaf_system DML.'::text as note;
