-- 02_APPLY_renew_or_insert_super_admin_assignment.sql
-- DML target: waqf.waqf_asset_rbac_assignments only.
-- Strategy:
--   1) Renew existing active/non-revoked matching assignment, preferably the known expired row.
--   2) Insert one global super_admin assignment only if no active/non-revoked matching row exists.

begin;

with renewed as (
  update waqf.waqf_asset_rbac_assignments a
     set valid_until = null,
         is_active = true,
         revoked_at = null,
         revoked_by = null,
         notes = concat_ws(E'\n', nullif(a.notes, ''), 'Renewed by Awqaf Asset Detail explicit assignment renewal hotfix on ' || now()::text),
         updated_at = now()
   where a.user_id = '96f6cdc2-67f9-4352-b9f8-775ef509fed8'::uuid
     and a.permission_code = 'waqf.assets.super_admin'
     and a.scope_governorate_no is null
     and a.scope_lgu_code is null
     and a.revoked_at is null
     and a.id = '48fe3365-b2b2-48c2-86d2-d475414d7ca2'::uuid
  returning a.id
),
fallback_renewed as (
  update waqf.waqf_asset_rbac_assignments a
     set valid_until = null,
         is_active = true,
         revoked_at = null,
         revoked_by = null,
         notes = concat_ws(E'\n', nullif(a.notes, ''), 'Renewed by Awqaf Asset Detail explicit assignment renewal hotfix fallback on ' || now()::text),
         updated_at = now()
   where not exists (select 1 from renewed)
     and a.user_id = '96f6cdc2-67f9-4352-b9f8-775ef509fed8'::uuid
     and a.permission_code = 'waqf.assets.super_admin'
     and a.scope_governorate_no is null
     and a.scope_lgu_code is null
     and a.revoked_at is null
  returning a.id
),
inserted as (
  insert into waqf.waqf_asset_rbac_assignments (
    id,
    user_id,
    permission_code,
    scope_governorate_no,
    scope_lgu_code,
    is_active,
    valid_from,
    valid_until,
    granted_by,
    grant_reason,
    revoked_at,
    revoked_by,
    notes,
    created_at,
    updated_at
  )
  select
    gen_random_uuid(),
    '96f6cdc2-67f9-4352-b9f8-775ef509fed8'::uuid,
    'waqf.assets.super_admin',
    null,
    null,
    true,
    now(),
    null,
    null,
    'Awqaf Asset Detail explicit assignment renewal hotfix',
    null,
    null,
    'Inserted because no active/non-revoked global super_admin assignment existed for target user.',
    now(),
    now()
  where not exists (select 1 from renewed)
    and not exists (select 1 from fallback_renewed)
    and not exists (
      select 1
      from waqf.waqf_asset_rbac_assignments a
      where a.user_id = '96f6cdc2-67f9-4352-b9f8-775ef509fed8'::uuid
        and a.permission_code = 'waqf.assets.super_admin'
        and a.scope_governorate_no is null
        and a.scope_lgu_code is null
        and a.is_active = true
        and a.revoked_at is null
        and a.valid_from <= now()
        and (a.valid_until is null or a.valid_until > now())
    )
  returning id
)
select
  'awqaf_asset_detail_assignment_renewal_apply_result' as section,
  (select count(*) from renewed) as known_assignment_rows_renewed,
  (select count(*) from fallback_renewed) as fallback_rows_renewed,
  (select count(*) from inserted) as rows_inserted,
  false as production_approved;

commit;
