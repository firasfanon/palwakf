
-- DRAFT ONLY - DO NOT APPLY WITHOUT EXPLICIT AUTHORIZATION
-- Document type and lifecycle registry.

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
