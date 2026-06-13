
-- DRAFT ONLY - DO NOT APPLY
-- Path D: bridge table when platform_access.admin_users.id cannot equal auth.users.id.

create table if not exists platform_access.admin_user_auth_links (
  id uuid primary key default gen_random_uuid(),
  admin_user_id uuid not null references platform_access.admin_users(id),
  auth_user_id uuid not null references auth.users(id),
  link_status text not null default 'active' check (link_status in ('active', 'revoked')),
  linked_by uuid null,
  linked_at timestamptz not null default now(),
  revoked_at timestamptz null,
  unique (admin_user_id, auth_user_id)
);

create index if not exists idx_admin_user_auth_links_admin_user_id
  on platform_access.admin_user_auth_links(admin_user_id);

create index if not exists idx_admin_user_auth_links_auth_user_id
  on platform_access.admin_user_auth_links(auth_user_id);

-- RLS, audit, and migration plan must be reviewed before apply.
