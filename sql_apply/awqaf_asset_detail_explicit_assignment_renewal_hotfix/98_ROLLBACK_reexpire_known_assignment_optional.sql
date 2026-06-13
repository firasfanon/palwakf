-- 98_ROLLBACK_reexpire_known_assignment_optional.sql
-- OPTIONAL. Do not run unless rollback is explicitly required.
-- Restores the observed valid_until on the known assignment row only.

begin;

update waqf.waqf_asset_rbac_assignments
set
  valid_until = '2026-05-10 02:11:58.023223+00'::timestamptz,
  updated_at = now(),
  notes = concat_ws(E'\n', nullif(notes, ''), 'Rollback: re-expired by optional rollback script on ' || now()::text)
where id = '48fe3365-b2b2-48c2-86d2-d475414d7ca2'::uuid
  and user_id = '96f6cdc2-67f9-4352-b9f8-775ef509fed8'::uuid
  and permission_code = 'waqf.assets.super_admin'
  and scope_governorate_no is null
  and scope_lgu_code is null;

commit;

select
  'awqaf_asset_detail_assignment_renewal_optional_rollback_completed' as section,
  false as production_approved;
