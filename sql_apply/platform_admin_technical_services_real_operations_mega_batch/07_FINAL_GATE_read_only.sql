-- 07_FINAL_GATE_read_only.sql
-- Final gate after dashboard RPC created_at order hotfix.

select
  'platform_technical_real_operations_final_gate_read_only' as section,
  'REAL_TECHNICAL_SERVICES_DASHBOARD_RPC_CREATED_AT_ORDER_HOTFIX_PREPARED_SMOKE_REQUIRED' as decision,
  true as backend_tables_prepared,
  true as rpc_contracts_prepared,
  true as dashboard_rpc_body_hotfixed,
  true as flutter_binding_prepared,
  true as audit_events_prepared,
  true as sql_editor_safe_seed_prepared,
  false as runtime_auth_weakened,
  false as backup_restore_execution,
  false as maintenance_mode_global_activation,
  false as sovereign_business_data_mutation,
  false as production_approved,
  'Run 03A then 06C. If 06C passes, continue to flutter analyze and browser UAT.' as next_instruction;
