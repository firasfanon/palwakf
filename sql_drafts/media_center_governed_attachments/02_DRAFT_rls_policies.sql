
-- DRAFT ONLY - DO NOT APPLY
-- Proposed RLS boundary for media_center.content_assets.

alter table media_center.content_assets enable row level security;

-- Public users should not read raw attachment registry directly.
-- Public consumption should pass through published content views/RPC only.

-- Example owner/admin read policy placeholder:
-- create policy content_assets_admin_read on media_center.content_assets
-- for select
-- to authenticated
-- using (
--   platform_access.current_user_has_permission('media_center.assets.read')
-- );

-- Example scoped write policy placeholder:
-- create policy content_assets_admin_insert on media_center.content_assets
-- for insert
-- to authenticated
-- with check (
--   platform_access.current_user_has_permission('media_center.assets.write')
-- );

-- Exact policy helper names must be validated against the live platform_access contract before apply.
