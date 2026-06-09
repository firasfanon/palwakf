select
  'platform_development_10k'::text as section,
  'global_all_pages_layout_contract_marker'::text as check_key,
  true as passed,
  'Read-only marker only; Flutter layout contract batch; no SQL/DML executed.'::text as note
union all
select
  'sovereign_boundary',
  'no_waq_assets_mutation_in_this_script',
  true,
  'Read-only SELECT only; no waqf/waq_assets/awqaf_system DML.'
union all
select
  'auth_boundary',
  'no_auth_users_mutation_in_this_script',
  true,
  'Read-only SELECT only; no auth.users DML.';
