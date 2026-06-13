select
  'platform_role_permission_map_final_gate_read_only' as section,
  'PLATFORM_ROLE_PERMISSION_MAP_CREATED_AND_SEEDED_INTEGRATION_NOT_APPLIED' as decision,
  true as platform_role_permission_map_created,
  true as awqaf_assets_permission_seed_prepared,
  false as waqf_permission_function_changed,
  false as direct_waqf_assignment_changed,
  false as waqf_assets_table_granted,
  false as awqaf_system_files_included,
  false as flutter_changes_included,
  false as production_approved,
  'Next: separately decide runtime integration or explicit assignment renewal.' as next_instruction;
