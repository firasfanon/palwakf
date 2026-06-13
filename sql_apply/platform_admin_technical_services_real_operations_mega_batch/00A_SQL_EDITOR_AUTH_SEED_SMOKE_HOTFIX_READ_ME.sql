-- Platform Admin Technical Services — SQL Editor Auth / Seed / Smoke Hotfix
--
-- Why this hotfix exists:
--   1) 04_SEED_initial_health_release_records.sql previously called:
--        public.rpc_platform_technical_health_snapshot_refresh_v1()
--      from SQL Editor context. That RPC intentionally requires auth.uid().
--      SQL Editor has auth.uid() = null unless a JWT context is simulated.
--
--   2) 06_AUTHENTICATED_RPC_SMOKE_TEMPLATE.sql used '<AUTH_USER_UUID_HERE>'.
--      Running it without replacing the placeholder causes invalid uuid syntax.
--
-- This hotfix:
--   - Keeps the backend contract unchanged.
--   - Replaces seed health refresh with direct guarded catalog upsert, no auth required.
--   - Adds a concrete smoke script for the known browser/admin user:
--       96f6cdc2-67f9-4352-b9f8-775ef509fed8
--
-- It DOES NOT:
--   - weaken runtime RPC auth.
--   - bypass browser authorization.
--   - execute backup/restore.
--   - activate maintenance mode.
--   - mutate waqf.waqf_assets.
--   - approve production.

select
  'platform_technical_sql_editor_auth_seed_smoke_hotfix_read_me_first' as section,
  'SEED_AND_SMOKE_CORRECTION_ONLY' as execution_mode,
  true as backend_contract_already_prepared,
  true as seed_script_corrected_for_sql_editor,
  true as smoke_script_concretized_for_known_user,
  false as runtime_auth_weakened,
  false as backup_restore_execution,
  false as maintenance_mode_global_activation,
  false as sovereign_business_data_mutation,
  false as production_approved,
  'Run this readme, then rerun corrected 04, 05, 06A, 07.' as instruction;
