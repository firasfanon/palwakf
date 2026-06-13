select
  'awqaf_asset_detail_assignment_renewal_final_gate_read_only' as section,
  'EXPLICIT_ASSIGNMENT_RENEWAL_APPLIED_VERIFY_AND_BROWSER_RETEST_REQUIRED' as decision,
  true as target_user_assignment_renewal_prepared,
  true as super_admin_global_scope_prepared,
  false as waqf_function_changed,
  false as waqf_assets_table_granted,
  false as waqf_assets_mutated,
  false as awqaf_system_files_included,
  false as flutter_changes_included,
  false as production_approved,
  'After 03/04 pass, retest /systems/awqaf-system/waqf-assets/721abf33-b243-4bd2-9ece-577128c2fdf4 in browser and verify rpc_waqf_asset_detail_v1 returns 200.' as next_instruction;
