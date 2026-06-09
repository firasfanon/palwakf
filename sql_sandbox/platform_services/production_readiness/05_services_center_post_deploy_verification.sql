-- PalWakf Platform Services Center
-- Production Data Layer Readiness Pack
-- 05 - Post-Deploy Verification
-- Date: 2026-05-08
-- Status: VERIFICATION / RUN AFTER APPROVED MIGRATION ONLY

select to_regnamespace('platform_services') as platform_services_schema;

select
  to_regclass('platform_services.service_forms_registry') as service_forms_registry,
  to_regclass('platform_services.service_requests') as service_requests,
  to_regclass('platform_services.service_request_status_events') as service_request_status_events,
  to_regclass('platform_services.service_request_attachments') as service_request_attachments;

select
  proname,
  pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'public'
  and proname like 'rpc_services_%'
order by proname;

select
  schemaname,
  tablename,
  policyname,
  cmd
from pg_policies
where schemaname = 'platform_services'
order by tablename, policyname;

select public.rpc_services_forms_public_v1();

-- Transactional smoke test: creates a request and rolls it back.
begin;
select public.rpc_services_submit_request_v1(jsonb_build_object(
  'service_key', 'mosque_services',
  'form_key', 'mosque_service_request_v1',
  'requester_type', 'citizen',
  'requester_name', 'اختبار مؤقت',
  'requester_contact', '0000000000',
  'request_summary', 'اختبار تحقق مؤقت يتم التراجع عنه'
)) as submit_result;
rollback;



-- Existing schema integration smoke check: these objects must remain untouched and available.
select
  to_regclass('public.services') as existing_services_catalog,
  to_regclass('public.pwf_complaints') as existing_complaints_channel,
  to_regclass('public.platform_permissions') as existing_platform_permissions,
  to_regclass('core.org_units') as existing_core_org_units,
  to_regclass('storage.objects') as existing_storage_objects;
