select
  'platform_access_gateway_final_dependency_contract' as package_key,
  'DOCS_AND_READ_ONLY_CONTRACT_HANDOFF' as execution_mode,
  false as ddl_dml_authorized,
  false as grant_revoke_authorized,
  false as production_approved,
  true as read_only,
  'Platform Access Gateway is certified as staging dependency; systems must adopt without creating independent canonical login/recovery/forbidden flows.' as instruction;

select
  'platform_access_gateway_final_dependency_contract' as section,
  'PLATFORM_ACCESS_GATEWAY_FINAL_DEPENDENCY_CONTRACT_CERTIFIED_STAGING_CROSS_SYSTEM_ADOPTION_HANDOFF' as decision,
  true as platform_owned_login,
  true as platform_owned_recovery,
  true as platform_owned_forbidden,
  true as platform_owned_safe_return_path,
  true as platform_owned_actor_context,
  false as service_role_in_flutter_authorized,
  false as production_approved,
  true as read_only;
