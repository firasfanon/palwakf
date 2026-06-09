-- READ ONLY marker for browser retest evidence intake.
select
  'platform_access_gateway_browser_retest_gate' as section,
  'RETEST_REQUIRED_AFTER_RPC400_SAFE_FALLBACK' as decision,
  false as production_approved,
  true as read_only;
