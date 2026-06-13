-- Platform Admin Technical Services — Real Operations Mega Batch
--
-- Scope:
--   Real backend contract for the admin technical services dashboard.
--
-- This batch creates:
--   - platform_technical schema
--   - governed operational tables
--   - RLS fail-closed policies
--   - SECURITY DEFINER RPCs exposed through public schema
--   - health snapshot refresh based on catalog/RPC presence
--   - initial deployment/health records
--
-- It DOES NOT:
--   - execute backup export
--   - execute restore
--   - activate maintenance mode globally
--   - deploy to Vercel
--   - mutate sovereign business data such as waqf.waqf_assets
--   - use service_role from Flutter
--   - approve production

select
  'platform_admin_technical_services_real_operations_read_me_first' as section,
  'REAL_BACKEND_CONTRACT_AND_FLUTTER_BINDING' as execution_mode,
  true as ddl_authorized_in_pack,
  true as guarded_dml_seed_in_pack,
  false as backup_restore_execution,
  false as maintenance_mode_global_activation,
  false as service_role_from_flutter,
  false as waqf_assets_mutation,
  false as production_approved,
  'Run 00-08 in order. Do not run 98 rollback unless explicitly required.' as instruction;
