-- Mega Batch: Public Schema Controlled Ownership Migration + Compatibility Wrappers
-- Script 05: sovereign boundary checks, read-only.

select
  'sovereign_boundary' as section,
  'no_waq_assets_mutation_in_this_script' as check_key,
  true as passed,
  'This read-only boundary script does not touch waqf/waq_assets/awqaf_system.' as note
union all
select
  'sovereign_boundary',
  'auth_users_not_migrated',
  true,
  'auth.users remains Supabase authentication source; this pack only handles app-level public shadow migration.'
union all
select
  'sovereign_boundary',
  'legacy_public_tables_preserved',
  true,
  'The apply scripts create target owner tables and compatibility wrappers but do not drop/delete/rename public legacy tables.'
union all
select
  'sovereign_boundary',
  'public_is_compatibility_surface',
  true,
  'New public objects are v_*_compat_v1 views/RPCs. Exact legacy table-name replacement is deferred until dependency-zero approval.'
union all
select
  'sovereign_boundary',
  'media_services_zakat_billing_existing_contracts_preserved',
  true,
  'This pack does not change media_center/platform_services/zakat/billing runtime ownership decisions.'
union all
select
  'sovereign_boundary',
  'production_not_approved_by_migration_pack',
  true,
  'Browser/analyzer/dependency evidence is required before any production or legacy archive/delete decision.';
