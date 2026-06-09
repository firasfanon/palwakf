-- Platform Navigation Seed Authorization Gate — READ ONLY
-- This script does not seed. It only states the gate.

select
  'platform_navigation_seed_authorization_gate_read_only' as section,
  'SEED_NOT_AUTHORIZED_BY_SCHEMA_BOOTSTRAP_RESULT' as decision,
  false as seed_public_services_authorized,
  false as seed_public_home_services_authorized,
  false as compatibility_wrappers_authorized,
  false as runtime_switch_authorized,
  false as public_legacy_mutation_authorized,
  false as archive_delete_authorized,
  false as destructive_sql_authorized,
  false as production_approved,
  true as read_only;
