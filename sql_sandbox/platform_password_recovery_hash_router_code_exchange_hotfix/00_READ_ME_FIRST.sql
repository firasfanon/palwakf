-- Platform Password Recovery Hash Router Code Exchange Hotfix — read-only marker
-- No SQL execution is required for this hotfix.
select
  'platform_password_recovery_hash_router_code_exchange_hotfix' as package_key,
  'READ_ONLY_MARKER_NO_SQL_REQUIRED' as execution_mode,
  false as ddl_dml_authorized,
  false as grant_revoke_authorized,
  false as production_approved,
  true as read_only;
