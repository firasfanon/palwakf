select
  'platform_technical_workflow_closure_final_gate_read_only' as section,
  'PLATFORM_TECHNICAL_OPERATIONAL_WORKFLOW_EXTENSION_PREPARED_UAT_REQUIRED' as decision,
  true as request_lifecycle_rpcs_prepared,
  true as backup_metadata_rpc_prepared,
  true as maintenance_transition_rpcs_prepared,
  true as public_maintenance_status_rpc_prepared,
  true as audit_filter_rpc_prepared,
  false as backup_restore_execution,
  false as maintenance_mode_global_activation,
  false as service_role_from_flutter,
  false as sovereign_business_data_mutation,
  false as production_approved,
  'Run authenticated workflow smoke and browser UAT; then capture Console/Network evidence.' as next_instruction;
