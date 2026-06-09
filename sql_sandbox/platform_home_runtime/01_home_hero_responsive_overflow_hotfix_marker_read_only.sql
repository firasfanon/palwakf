-- Home Hero Responsive Overflow Hotfix marker — READ ONLY
-- This script intentionally performs no DDL, DML, GRANT, DROP, DELETE, UPDATE, INSERT, archive, or migration.
select
  'home_hero_responsive_overflow_hotfix_2026_05_31'::text as batch_key,
  'HOME_HERO_RESPONSIVE_OVERFLOW_HOTFIX_APPLIED_RETEST_REQUIRED'::text as decision,
  true as read_only,
  false as production_approved,
  true as no_waq_assets_mutation_in_this_script,
  true as no_awqaf_system_mutation_in_this_script,
  true as no_gis_mutation_in_this_script,
  true as no_platform_services_mutation_in_this_script;
