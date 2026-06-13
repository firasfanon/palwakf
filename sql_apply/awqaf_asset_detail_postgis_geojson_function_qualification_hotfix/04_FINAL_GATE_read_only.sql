select
  'awqaf_asset_detail_postgis_geojson_qualification_final_gate_read_only' as section,
  'POSTGIS_GEOJSON_FUNCTION_QUALIFICATION_APPLIED_VERIFY_AND_BROWSER_RETEST_REQUIRED' as decision,
  true as postgis_schema_extensions_confirmed,
  true as st_asgeojson_qualified_in_waqf_asset_detail_rpc,
  false as dml_authorized,
  false as rbac_changed,
  false as waqf_assets_mutated,
  false as awqaf_system_files_included,
  false as flutter_changes_included,
  false as production_approved,
  'After SQL smoke passes, retest /systems/awqaf-system/waqf-assets/721abf33-b243-4bd2-9ece-577128c2fdf4 and verify rpc_waqf_asset_detail_v1 returns Network 200.' as next_instruction;
