-- Platform Technical Services — Operational Workflow Closure Mega Batch
select
  'platform_technical_workflow_closure_read_me_first' as section,
  'REAL_OPERATIONAL_WORKFLOW_EXTENSION' as execution_mode,
  true as workflow_rpcs_prepared,
  true as backup_metadata_rpc_prepared,
  true as maintenance_status_rpc_prepared,
  false as backup_restore_execution,
  false as maintenance_mode_global_activation,
  false as service_role_from_flutter,
  false as sovereign_business_data_mutation,
  false as production_approved,
  'Run 00-05 in order. This extends workflow only; it does not execute backup/restore or close the site.' as instruction;
