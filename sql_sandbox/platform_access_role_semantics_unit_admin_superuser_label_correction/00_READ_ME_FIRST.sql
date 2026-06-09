-- Platform Access Role Semantics Unit Admin Superuser Label Correction
-- READ ONLY marker.
-- No DDL/DML/GRANT/REVOKE. Do not execute any write operation from this pack.
select
  'platform_access_role_semantics_unit_admin_superuser_label_correction' as section,
  'READ_ONLY_MARKER_NO_DB_MUTATION' as decision,
  false as ddl_dml_authorized,
  false as grant_revoke_authorized,
  false as production_approved,
  true as read_only;
