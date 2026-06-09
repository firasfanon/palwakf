-- PalWakf Platform Services Center
-- RLS Policy Draft
-- Date: 2026-05-08
-- Status: NON-PRODUCTION / SANDBOX ONLY
-- This draft intentionally uses conservative deny-by-default table policies.
-- UI should use public RPC wrappers. Admin access requires platform RBAC helper review.

alter table platform_services.service_forms_registry enable row level security;
alter table platform_services.service_requests enable row level security;
alter table platform_services.service_request_status_events enable row level security;
alter table platform_services.service_request_attachments enable row level security;

-- Drop draft policies if re-running in sandbox.
drop policy if exists service_forms_registry_deny_direct_v1 on platform_services.service_forms_registry;
drop policy if exists service_requests_deny_direct_v1 on platform_services.service_requests;
drop policy if exists service_request_status_events_deny_direct_v1 on platform_services.service_request_status_events;
drop policy if exists service_request_attachments_deny_direct_v1 on platform_services.service_request_attachments;

create policy service_forms_registry_deny_direct_v1
on platform_services.service_forms_registry
for all
using (false)
with check (false);

create policy service_requests_deny_direct_v1
on platform_services.service_requests
for all
using (false)
with check (false);

create policy service_request_status_events_deny_direct_v1
on platform_services.service_request_status_events
for all
using (false)
with check (false);

create policy service_request_attachments_deny_direct_v1
on platform_services.service_request_attachments
for all
using (false)
with check (false);

-- Production review note:
-- Replace deny-only draft with platform RBAC policies after confirming the actual helper name.
-- Expected permission patterns:
--   services.requests.view.ministry
--   services.requests.create.public
--   services.requests.triage.ministry
--   services.requests.assign.ministry
--   services.requests.close.ministry
--   services.forms.manage.ministry
--   services.forms.publish.ministry
