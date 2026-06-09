-- Mega Batch: Zakat Public Page PWF-SIS Visual Harmonization + Official Config Contract
-- Read-only marker. This script does not create, alter, insert, update, or delete.

select
  'zakat_official_config_contract' as section,
  'canonical_route' as check_key,
  '/home/zakat' as value,
  'The page is canonical under /home/*; /zakat is legacy alias only.' as note;

select
  'zakat_official_config_contract' as section,
  'dedicated_public_config_wrapper_pending' as check_key,
  exists (
    select 1
    from information_schema.views
    where table_schema = 'platform_services'
      and table_name = 'v_zakat_public_config_v1'
  ) as passed,
  'False is acceptable for this batch: the Dart contract declares the current governed fallback, but full production certification requires a future official wrapper/RPC.' as note;

select
  'sovereign_boundary' as section,
  'no_waq_assets_mutation_in_this_script' as check_key,
  true as passed,
  'Read-only marker only; no waqf/waqf_assets/awqaf_system DML.' as note;
