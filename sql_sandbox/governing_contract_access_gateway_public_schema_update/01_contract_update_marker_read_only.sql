select
  'governing_contract_access_gateway_public_schema_update' as package_key,
  'PALWAKF_GOVERNING_CONTRACT_ACCESS_GATEWAY_PUBLIC_SCHEMA_APPENDIX_READY_FOR_MERGE' as decision,
  false as ddl_dml_authorized,
  false as grant_revoke_authorized,
  false as production_approved,
  true as read_only,
  'Contract appendix marker only. No SQL mutation authorized.' as instruction;
