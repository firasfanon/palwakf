-- Platform Navigation Owner Schema Bootstrap Validation Result Intake
-- Date: 2026-05-29
-- Mode: READ ONLY
-- Purpose: Record the accepted validation status for the platform_navigation owner schema.

select
  'platform_navigation_schema_bootstrap_validation_result_intake' as section,
  'VALIDATION_ACCEPTED_OWNER_SCHEMA_READY_FOR_CONTROLLED_SEED_GATE' as decision,
  true as home_entries_present,
  true as route_entries_present,
  true as service_entries_present,
  true as entry_key_present,
  true as route_path_present,
  true as sort_order_present,
  0 as home_entries_count,
  0 as route_entries_count,
  0 as service_entries_count,
  false as public_services_mutated_by_this_script,
  false as public_home_services_mutated_by_this_script,
  false as destructive_sql_authorized,
  false as delete_authorized_by_this_script,
  false as production_approved,
  true as read_only;
