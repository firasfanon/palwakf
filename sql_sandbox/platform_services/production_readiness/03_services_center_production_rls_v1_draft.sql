-- PalWakf Platform Services Center
-- Production Data Layer Readiness Pack
-- 03 - Production RLS Migration Draft
-- Date: 2026-05-08
-- Status: PRODUCTION-READINESS DRAFT / DO NOT RUN UNTIL APPROVED
-- Policy: direct table access is denied; controlled access is through SECURITY DEFINER RPC wrappers.

alter table platform_services.service_forms_registry enable row level security;
alter table platform_services.service_requests enable row level security;
alter table platform_services.service_request_status_events enable row level security;
alter table platform_services.service_request_attachments enable row level security;

alter table platform_services.service_forms_registry force row level security;
alter table platform_services.service_requests force row level security;
alter table platform_services.service_request_status_events force row level security;
alter table platform_services.service_request_attachments force row level security;

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

revoke all on all tables in schema platform_services from anon, authenticated;
revoke all on schema platform_services from anon;
revoke all on schema platform_services from authenticated;

-- Required production RBAC patterns before admin actions become real:
--   services.requests.view.ministry
--   services.requests.triage.ministry
--   services.requests.assign.ministry
--   services.requests.status.update.ministry
--   services.requests.close.ministry
--   services.forms.manage.ministry
--   services.forms.publish.ministry
--   services.attachments.review.ministry

