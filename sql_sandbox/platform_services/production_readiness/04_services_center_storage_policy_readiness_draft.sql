-- PalWakf Platform Services Center
-- Production Data Layer Readiness Pack
-- 04 - Storage Policy Readiness Draft
-- Date: 2026-05-08
-- Status: TEMPLATE / DO NOT RUN UNTIL STORAGE DECISION IS APPROVED
-- Purpose: Define expected bucket and policy direction for service request attachments.
-- This file is intentionally conservative and may require adaptation to existing storage policy names.

-- Proposed bucket name:
--   services-request-attachments
-- Proposed storage path convention:
--   requests/{request_id}/{attachment_id}/{safe_file_name}
-- Proposed rule:
--   Public users upload only through controlled RPC/signed upload flow, not direct anonymous table access.
--   Admin reviewers read via authenticated policies and platform RBAC.

-- Optional bucket creation template. Review before applying.
-- insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
-- values (
--   'services-request-attachments',
--   'services-request-attachments',
--   false,
--   10485760,
--   array['application/pdf','image/png','image/jpeg','image/webp']
-- )
-- on conflict (id) do update set
--   public = excluded.public,
--   file_size_limit = excluded.file_size_limit,
--   allowed_mime_types = excluded.allowed_mime_types;

-- Policy templates intentionally commented until final RBAC helper exists.
-- create policy services_request_attachments_admin_read_v1
-- on storage.objects
-- for select
-- to authenticated
-- using (
--   bucket_id = 'services-request-attachments'
--   and platform_services.can_admin_read_requests_v1()
-- );

-- create policy services_request_attachments_admin_write_v1
-- on storage.objects
-- for insert
-- to authenticated
-- with check (
--   bucket_id = 'services-request-attachments'
--   and platform_services.can_admin_read_requests_v1()
-- );

