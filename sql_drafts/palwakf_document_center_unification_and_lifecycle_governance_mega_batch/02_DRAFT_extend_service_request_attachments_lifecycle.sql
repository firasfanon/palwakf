
-- DRAFT ONLY - DO NOT APPLY WITHOUT EXPLICIT AUTHORIZATION
-- Lifecycle columns for platform_services.service_request_attachments.

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
