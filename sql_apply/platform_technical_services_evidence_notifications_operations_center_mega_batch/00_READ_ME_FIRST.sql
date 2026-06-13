-- Platform Technical Services — Evidence, Notifications & Operations Center Mega Batch
select
  'platform_technical_evidence_notifications_read_me_first' as section,
  'EVIDENCE_NOTIFICATIONS_OPERATIONS_CENTER_EXTENSION' as execution_mode,
  true as evidence_tables_prepared,
  true as notification_tables_prepared,
  true as operation_decision_tables_prepared,
  true as dashboard_enrichment_prepared,
  false as backup_restore_execution,
  false as maintenance_mode_global_activation,
  false as service_role_from_flutter,
  false as sovereign_business_data_mutation,
  false as production_approved,
  'Run 00-06. This extends evidence/notifications only.' as instruction;
