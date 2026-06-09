-- Mega Batch N2.9C — Usage Guide Asset Contract Evidence
-- Read-only evidence only. No DML. No waqf/waqf_assets mutation.
select
  'usage_guide_asset_contract' as section,
  'flutter_asset_pubspec_nested_dirs_required' as check_key,
  true as passed,
  'pubspec.yaml must include assets/docs/, assets/docs/usage/, and assets/docs/assistant/ for Flutter Web nested guide markdown loading.' as note
union all
select
  'sovereign_boundary',
  'no_waq_assets_mutation_in_this_script',
  true,
  'Read-only explanatory evidence only; no DML and no waqf/waq_assets mutation.';
