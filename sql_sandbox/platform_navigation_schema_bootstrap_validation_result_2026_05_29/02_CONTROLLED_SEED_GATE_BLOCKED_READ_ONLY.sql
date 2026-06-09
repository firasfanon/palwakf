-- Controlled Seed Gate — READ ONLY
-- This script does not seed. It only declares the next gate.

select
  'platform_navigation_controlled_seed_gate' as section,
  'SEED_REQUIRES_EXPLICIT_OPERATOR_AUTHORIZATION' as decision,
  '03_CONTROLLED_SEED_FROM_PUBLIC_SERVICES_HOME_SERVICES_GUARDED_NOT_RUN.sql' as next_guarded_script,
  false as seed_authorized_by_this_script,
  false as public_services_mutation_authorized,
  false as public_home_services_mutation_authorized,
  false as destructive_sql_authorized,
  false as delete_authorized_by_this_script,
  false as runtime_switch_authorized,
  false as production_approved,
  true as read_only;
