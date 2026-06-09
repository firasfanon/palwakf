-- Platform Access Gateway Unified Model Staging Certification
-- Read-only marker only. No DDL/DML/GRANT/REVOKE.
select
  'platform_access_gateway_unified_model_staging_certification' as section,
  'CERTIFIED_STAGING_PASSWORD_RECOVERY_SUCCESS_ACCEPTED' as decision,
  false as production_approved,
  true as read_only;
