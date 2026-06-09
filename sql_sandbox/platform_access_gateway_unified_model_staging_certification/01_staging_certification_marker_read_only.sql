-- Read-only certification marker for documentation/UAT intake.
select
  'PLATFORM_ACCESS_GATEWAY_UNIFIED_MODEL_CERTIFIED_STAGING_PASSWORD_RECOVERY_SUCCESS_ACCEPTED' as decision,
  'EXTERNAL_EMAIL_CLIENT_MAY_OPEN_NEW_TAB_NOT_A_PLATFORM_ACCESS_BLOCKER' as same_tab_limitation,
  false as service_role_frontend_authorized,
  false as rbac_bypass_authorized,
  false as production_approved,
  true as read_only;
