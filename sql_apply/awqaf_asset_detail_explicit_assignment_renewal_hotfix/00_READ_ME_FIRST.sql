-- Awqaf Asset Detail — Explicit Assignment Renewal Hotfix
--
-- Authorization:
--   Explicit DML authorization for assignment renewal hotfix.
--
-- Target user:
--   96f6cdc2-67f9-4352-b9f8-775ef509fed8
--
-- Target permission:
--   waqf.assets.super_admin
--
-- Target scope:
--   scope_governorate_no = null
--   scope_lgu_code       = null
--
-- Target runtime smoke asset:
--   721abf33-b243-4bd2-9ece-577128c2fdf4
--
-- This pack DOES:
--   - preflight user/permission/asset/assignment
--   - renew the expired super_admin assignment if found
--   - insert a replacement assignment only if no matching active non-revoked row exists
--   - verify assignment and run authenticated RPC smoke
--
-- This pack DOES NOT:
--   - alter waqf.has_waqf_asset_permission_v1
--   - alter public.rpc_waqf_asset_detail_v1
--   - grant SELECT on waqf.waqf_assets
--   - mutate waqf.waqf_assets
--   - add Flutter or Awqaf System files
--   - approve production

select
  'awqaf_asset_detail_assignment_renewal_read_me_first' as section,
  'EXPLICIT_ASSIGNMENT_RENEWAL_DML_ONLY' as execution_mode,
  true as dml_authorized_for_waqf_asset_rbac_assignments_only,
  false as waqf_function_change_authorized,
  false as waqf_assets_table_grant_authorized,
  false as waqf_assets_mutation_authorized,
  false as awqaf_system_files_included,
  false as flutter_changes_included,
  false as production_approved,
  'Run 00-05. Do not run 98 rollback unless explicitly needed.' as instruction;
