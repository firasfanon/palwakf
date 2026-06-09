-- PalWakf Platform Services Center
-- Sandbox Seed + Verification Queries
-- Date: 2026-05-08
-- Status: NON-PRODUCTION / SANDBOX ONLY

insert into platform_services.service_forms_registry (
  form_key,
  title_ar,
  service_key,
  audience,
  required_attachments,
  source_reference,
  version_no,
  public_visibility,
  internal_visibility,
  review_status
) values
  (
    'mosque_service_general_request_v1',
    'طلب خدمة عامة للمساجد',
    'mosques_services',
    'public',
    '[{"key":"id_document","label_ar":"إثبات شخصية"}]'::jsonb,
    'دليل الخدمات — مسودة',
    '1.0',
    true,
    true,
    'approved'
  ),
  (
    'official_document_request_v1',
    'طلب وثيقة أو إفادة رسمية',
    'official_documents',
    'public',
    '[{"key":"request_reason","label_ar":"سبب الطلب"}]'::jsonb,
    'المراجع الرسمية — مسودة',
    '1.0',
    true,
    true,
    'approved'
  )
on conflict (form_key) do update set
  title_ar = excluded.title_ar,
  service_key = excluded.service_key,
  required_attachments = excluded.required_attachments,
  source_reference = excluded.source_reference,
  public_visibility = excluded.public_visibility,
  internal_visibility = excluded.internal_visibility,
  review_status = excluded.review_status,
  updated_at = now();

-- Sandbox submit smoke test.
select public.rpc_services_submit_request_draft_v1(
  jsonb_build_object(
    'requester_type', 'citizen',
    'requester_name', 'مستخدم تجريبي',
    'requester_contact', 'demo@example.test',
    'service_key', 'official_documents',
    'form_key', 'official_document_request_v1',
    'request_summary', 'طلب إفادة رسمية لغرض الاختبار'
  )
) as submit_result;

-- Verify public forms wrapper.
select * from public.rpc_services_forms_public_v1();

-- Verify tracking wrapper using latest generated request.
select *
from public.rpc_services_track_request_public_v1(
  (select tracking_code from platform_services.service_requests order by created_at desc limit 1)
);

-- Verify sensitive fields are not exposed by public tracking wrapper:
-- Expected columns only: tracking_code, status, public_note, submitted_at, last_status_at.
