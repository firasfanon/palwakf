
-- DRAFT ONLY - DO NOT APPLY
-- Path C: compatibility view for administrative identity authority.

create or replace view platform_access.v_admin_identity_authority_v1 as
select
  au.id,
  au.email,
  au.name,
  au.role,
  au.department,
  au.governorate,
  au.phone,
  au.avatar_url,
  au.is_active,
  au.is_superuser,
  au.username,
  au.unit_id,
  u.id is not null as has_auth_user_link,
  u.email as auth_email,
  au.created_at,
  au.updated_at
from platform_access.admin_users au
left join auth.users u
  on u.id = au.id;

-- Grant/select policy must be reviewed before apply.
