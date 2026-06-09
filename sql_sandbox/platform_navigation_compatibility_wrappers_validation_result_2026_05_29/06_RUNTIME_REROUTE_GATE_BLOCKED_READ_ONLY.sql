-- PalWakf Platform Navigation Runtime Reroute Gate
-- Read-only marker. Do not execute any Flutter reroute, archive, delete, or public legacy mutation from this script.

select
  'platform_navigation_runtime_reroute_gate_blocked_read_only' as section,
  'WRAPPERS_VALIDATED_RUNTIME_REROUTE_REQUIRES_EXPLICIT_AUTHORIZATION' as decision,
  false as flutter_runtime_switch_authorized,
  false as public_services_delete_authorized,
  false as public_home_services_delete_authorized,
  false as destructive_sql_authorized,
  false as production_approved,
  true as read_only;
