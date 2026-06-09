-- Password Recovery Reset Update Session + Same Password Hotfix
-- READ ONLY marker only.
-- No SQL execution is required for this hotfix.
select
  'password_recovery_reset_update_session_same_password_hotfix' as section,
  false as ddl_dml_authorized,
  false as grant_revoke_authorized,
  false as production_approved,
  true as read_only;
