
-- DRAFT ONLY - DO NOT APPLY WITHOUT EXPLICIT AUTHORIZATION
-- 02_DRAFT_content_attachments_rls_policy.sql

alter table media_center.content_attachments enable row level security;

-- Admin read/write policy draft.
-- Function names must be aligned with current platform_access helpers before apply.

create policy content_attachments_admin_read_draft
  on media_center.content_attachments
  for select
  using (
    exists (
      select 1
      from platform_access.admin_users au
      where au.id = auth.uid()
        and coalesce(au.is_active, true) = true
    )
  );

create policy content_attachments_admin_insert_draft
  on media_center.content_attachments
  for insert
  with check (
    exists (
      select 1
      from platform_access.admin_users au
      where au.id = auth.uid()
        and coalesce(au.is_active, true) = true
    )
  );

create policy content_attachments_admin_update_draft
  on media_center.content_attachments
  for update
  using (
    exists (
      select 1
      from platform_access.admin_users au
      where au.id = auth.uid()
        and coalesce(au.is_active, true) = true
    )
  )
  with check (
    exists (
      select 1
      from platform_access.admin_users au
      where au.id = auth.uid()
        and coalesce(au.is_active, true) = true
    )
  );

-- Public read should normally be exposed via a controlled public wrapper/view, not raw table grants.
