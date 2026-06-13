
-- DOCUMENT_LIFECYCLE_VIEW_REPLACE_ORDER_HOTFIX
-- AUTHORIZED APPLY HOTFIX FOR:
-- ERROR 42P16: cannot change name of view column "created_at" to "confidentiality_level"
--
-- Cause:
-- CREATE OR REPLACE VIEW cannot reorder/rename existing view columns.
--
-- Fix:
-- Drop only the public wrappers, then recreate them with lifecycle-aware columns.
--
-- Boundaries:
-- - No file deletion.
-- - No storage.objects mutation.
-- - No owner schema exposure.
-- - No RLS mutation.
-- - No service_role usage.
-- - No production approval.

begin;

create schema if not exists platform_documents;

create table if not exists platform_documents.document_types (
  id uuid primary key default gen_random_uuid(),
  system_key text not null,
  document_code text not null,
  name_ar text not null,
  name_en text null,
  document_category text not null default 'operational',
  retention_class text not null
    check (retention_class in (
      'transient',
      'operational',
      'long_term_reference',
      'legal_evidence',
      'public_media'
    )),
  confidentiality_level text not null default 'internal'
    check (confidentiality_level in ('public', 'internal', 'confidential', 'restricted')),
  retention_months integer null check (retention_months is null or retention_months >= 0),
  allow_delete boolean not null default false,
  requires_review boolean not null default true,
  requires_ocr boolean not null default false,
  requires_signature boolean not null default false,
  requires_versioning boolean not null default false,
  is_legal_evidence boolean not null default false,
  is_public_publishable boolean not null default false,
  allowed_mime_types text[] null,
  max_file_size_bytes bigint null check (max_file_size_bytes is null or max_file_size_bytes > 0),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (system_key, document_code)
);

insert into platform_documents.document_types (
  system_key,
  document_code,
  name_ar,
  name_en,
  document_category,
  retention_class,
  confidentiality_level,
  retention_months,
  allow_delete,
  requires_review,
  requires_ocr,
  requires_signature,
  requires_versioning,
  is_legal_evidence,
  is_public_publishable,
  allowed_mime_types,
  max_file_size_bytes
)
values
  (
    'platform_services',
    'SERVICE_ATTACHMENT_GENERAL',
    'مرفق خدمة عام',
    'General service attachment',
    'operational',
    'operational',
    'confidential',
    84,
    false,
    true,
    false,
    false,
    true,
    false,
    false,
    array['application/pdf','image/jpeg','image/png','image/webp','application/msword','application/vnd.openxmlformats-officedocument.wordprocessingml.document'],
    52428800
  ),
  (
    'platform_services',
    'SERVICE_ATTACHMENT_IDENTITY',
    'وثيقة هوية/تعريف',
    'Identity document',
    'identity',
    'long_term_reference',
    'restricted',
    null,
    false,
    true,
    true,
    false,
    true,
    false,
    false,
    array['application/pdf','image/jpeg','image/png','image/webp'],
    26214400
  ),
  (
    'platform_services',
    'SERVICE_ATTACHMENT_LEGAL_EVIDENCE',
    'وثيقة دليل قانوني',
    'Legal evidence document',
    'legal',
    'legal_evidence',
    'restricted',
    null,
    false,
    true,
    true,
    true,
    true,
    true,
    false,
    array['application/pdf','image/jpeg','image/png','image/webp','application/msword','application/vnd.openxmlformats-officedocument.wordprocessingml.document'],
    104857600
  ),
  (
    'media_center',
    'MEDIA_ASSET_PUBLIC',
    'أصل إعلامي عام',
    'Public media asset',
    'media',
    'public_media',
    'public',
    null,
    false,
    false,
    false,
    false,
    true,
    false,
    true,
    array['image/jpeg','image/png','image/webp','video/mp4','application/pdf'],
    209715200
  ),
  (
    'document_intelligence',
    'DOCUMENT_INTELLIGENCE_DERIVED',
    'مخرجات معالجة وثائقية',
    'Document intelligence derived artifact',
    'derived',
    'operational',
    'internal',
    36,
    false,
    true,
    false,
    false,
    true,
    false,
    false,
    array['application/json','text/plain','application/pdf','image/jpeg','image/png','image/webp'],
    104857600
  )
on conflict (system_key, document_code) do update
set
  name_ar = excluded.name_ar,
  name_en = excluded.name_en,
  document_category = excluded.document_category,
  retention_class = excluded.retention_class,
  confidentiality_level = excluded.confidentiality_level,
  retention_months = excluded.retention_months,
  allow_delete = excluded.allow_delete,
  requires_review = excluded.requires_review,
  requires_ocr = excluded.requires_ocr,
  requires_signature = excluded.requires_signature,
  requires_versioning = excluded.requires_versioning,
  is_legal_evidence = excluded.is_legal_evidence,
  is_public_publishable = excluded.is_public_publishable,
  allowed_mime_types = excluded.allowed_mime_types,
  max_file_size_bytes = excluded.max_file_size_bytes,
  active = true,
  updated_at = now();

alter table platform_services.service_request_attachments
  add column if not exists document_type_id uuid null references platform_documents.document_types(id),
  add column if not exists retention_class text null
    check (retention_class is null or retention_class in (
      'transient',
      'operational',
      'long_term_reference',
      'legal_evidence',
      'public_media'
    )),
  add column if not exists retention_until timestamptz null,
  add column if not exists legal_hold boolean not null default false,
  add column if not exists lifecycle_status text not null default 'active'
    check (lifecycle_status in ('active', 'archived', 'scheduled_for_delete', 'deleted')),
  add column if not exists confidentiality_level text null
    check (confidentiality_level is null or confidentiality_level in (
      'public',
      'internal',
      'confidential',
      'restricted'
    )),
  add column if not exists checksum_sha256 text null,
  add column if not exists is_original boolean not null default true,
  add column if not exists derived_from_attachment_id uuid null references platform_services.service_request_attachments(id),
  add column if not exists archived_at timestamptz null,
  add column if not exists deleted_at timestamptz null;

create index if not exists idx_service_request_attachments_document_type_id
  on platform_services.service_request_attachments(document_type_id);

create index if not exists idx_service_request_attachments_retention_class
  on platform_services.service_request_attachments(retention_class);

create index if not exists idx_service_request_attachments_lifecycle_status
  on platform_services.service_request_attachments(lifecycle_status);

create index if not exists idx_document_types_system_code
  on platform_documents.document_types(system_key, document_code);

with classification as (
  select
    sra.id,
    case
      when lower(coalesce(sra.attachment_key, '')) like '%identity%'
        or lower(coalesce(sra.attachment_key, '')) like '%id%'
        or lower(coalesce(sra.attachment_key, '')) like '%passport%'
        or lower(coalesce(sra.attachment_key, '')) like '%هوية%'
        or lower(coalesce(sra.attachment_key, '')) like '%جواز%'
        then 'SERVICE_ATTACHMENT_IDENTITY'
      when lower(coalesce(sra.attachment_key, '')) like '%deed%'
        or lower(coalesce(sra.attachment_key, '')) like '%court%'
        or lower(coalesce(sra.attachment_key, '')) like '%legal%'
        or lower(coalesce(sra.attachment_key, '')) like '%حجة%'
        or lower(coalesce(sra.attachment_key, '')) like '%سند%'
        or lower(coalesce(sra.attachment_key, '')) like '%قرار%'
        or lower(coalesce(sra.attachment_key, '')) like '%محكمة%'
        then 'SERVICE_ATTACHMENT_LEGAL_EVIDENCE'
      else 'SERVICE_ATTACHMENT_GENERAL'
    end as document_code
  from platform_services.service_request_attachments sra
)
update platform_services.service_request_attachments sra
set
  document_type_id = dt.id,
  retention_class = dt.retention_class,
  confidentiality_level = dt.confidentiality_level,
  retention_until = case
    when dt.retention_months is null then null
    else coalesce(sra.uploaded_at, now()) + make_interval(months => dt.retention_months)
  end,
  legal_hold = case
    when dt.is_legal_evidence then true
    else coalesce(sra.legal_hold, false)
  end,
  lifecycle_status = coalesce(sra.lifecycle_status, 'active')
from classification c
join platform_documents.document_types dt
  on dt.system_key = 'platform_services'
 and dt.document_code = c.document_code
where sra.id = c.id
  and (
    sra.document_type_id is null
    or sra.retention_class is null
    or sra.confidentiality_level is null
  );

-- This is the actual hotfix for ERROR 42P16.
drop view if exists public.v_document_center_service_attachments_v1;
drop view if exists public.v_document_center_media_assets_v1;

create view public.v_document_center_service_attachments_v1 as
select
  sra.id,
  coalesce(sra.file_name, sra.attachment_key) as title,
  sra.request_id,
  sra.attachment_key,
  sra.file_name,
  sra.mime_type,
  sra.file_size_bytes,
  sra.storage_bucket,
  sra.storage_path,
  sra.document_job_id,
  sra.review_status,
  sra.uploaded_by,
  sra.uploaded_at,
  coalesce(sra.retention_class, dt.retention_class, 'operational') as retention_class,
  coalesce(sra.confidentiality_level, dt.confidentiality_level, 'confidential') as confidentiality_level,
  coalesce(sra.lifecycle_status, 'active') as lifecycle_status,
  coalesce(sra.legal_hold, false) as legal_hold,
  sra.retention_until,
  dt.document_code,
  dt.name_ar as document_type_name_ar
from platform_services.service_request_attachments sra
left join platform_documents.document_types dt
  on dt.id = sra.document_type_id
where coalesce(sra.lifecycle_status, 'active') <> 'deleted';

create view public.v_document_center_media_assets_v1 as
select
  ca.id,
  coalesce(ca.filename, ca.url, ca.asset_type, 'أصل إعلامي') as title,
  ca.content_item_id,
  ca.asset_type,
  ca.url,
  ca.storage_bucket,
  ca.storage_path,
  ca.filename,
  ca.mime_type,
  ca.file_size_bytes,
  'active'::text as status,
  'public_media'::text as retention_class,
  'public'::text as confidentiality_level,
  'active'::text as lifecycle_status,
  false as legal_hold,
  null::timestamptz as retention_until,
  'MEDIA_ASSET_PUBLIC'::text as document_code,
  'أصل إعلامي عام'::text as document_type_name_ar,
  ca.created_at
from media_center.content_assets ca;

comment on view public.v_document_center_service_attachments_v1 is
  'PalWakf Document Center lifecycle-aware wrapper for service request attachments.';

comment on view public.v_document_center_media_assets_v1 is
  'PalWakf Document Center lifecycle-aware wrapper for media center content assets.';

grant select on public.v_document_center_service_attachments_v1 to authenticated;
grant select on public.v_document_center_media_assets_v1 to authenticated;

commit;

select
  'document_lifecycle_view_replace_order_hotfix_result' as section,
  to_regclass('platform_documents.document_types') is not null as document_types_table_present,
  to_regclass('public.v_document_center_service_attachments_v1') is not null as service_wrapper_present,
  to_regclass('public.v_document_center_media_assets_v1') is not null as media_wrapper_present,
  (select count(*)::bigint from platform_documents.document_types) as document_type_count,
  (select count(*)::bigint from platform_services.service_request_attachments where document_type_id is not null) as classified_service_attachment_count,
  false as production_approved;
