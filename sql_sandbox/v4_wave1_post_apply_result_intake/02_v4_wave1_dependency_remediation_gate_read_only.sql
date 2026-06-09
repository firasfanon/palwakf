-- V4 Wave1 Dependency Remediation Gate (read-only marker)
select
  'v4_wave1_dependency_remediation_gate' as section,
  'FUNCTION_RPC_TEXT_DEPENDENCIES_REMAIN' as dependency_status,
  'CLASSIFY_READ_SAFE_VS_WRITE_RISK_BEFORE_PRODUCTION_OR_VIEW_REMOVAL' as required_action,
  false as production_approved,
  true as read_only;
