select
  'awqaf_system_7_role_unit_evidence_closure' as package_key,
  'READ_ONLY_EVIDENCE_CLOSURE_ONLY' as execution_mode,
  false as ddl_dml_authorized,
  false as grant_revoke_authorized,
  false as production_approved,
  true as read_only,
  'Run 01-05 only. Do not run any write, review, apply, archive, drop, or public base table creation.' as instruction;
