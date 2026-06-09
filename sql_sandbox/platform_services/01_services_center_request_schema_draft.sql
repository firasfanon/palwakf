-- PalWakf Platform Services Center
-- Request Data Contract + Schema Draft
-- Date: 2026-05-08
-- Status: NON-PRODUCTION / SANDBOX ONLY
-- Do not apply to production before RBAC, storage, and FK review.

create extension if not exists pgcrypto;

create schema if not exists platform_services;

comment on schema platform_services is
  'Draft internal schema for PalWakf Services Center request intake and forms registry. Public access must be via public RPC wrappers only.';

create table if not exists platform_services.service_forms_registry (
  id uuid primary key default gen_random_uuid(),
  form_key text not null unique,
  title_ar text not null,
  title_en text,
  service_key text not null,
  audience text not null default 'public'
    check (audience in ('public', 'internal', 'unit', 'mixed')),
  required_attachments jsonb not null default '[]'::jsonb,
  optional_attachments jsonb not null default '[]'::jsonb,
  source_reference text,
  legal_reference_key text,
  version_no text not null default '1.0',
  public_visibility boolean not null default false,
  internal_visibility boolean not null default true,
  review_status text not null default 'draft'
    check (review_status in ('draft', 'review', 'approved', 'archived')),
  effective_from date,
  effective_to date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  created_by uuid,
  updated_by uuid,
  notes text
);

comment on table platform_services.service_forms_registry is
  'Non-production draft registry for official service forms. Files may later link to Document Intelligence or Storage.';

create table if not exists platform_services.service_requests (
  id uuid primary key default gen_random_uuid(),
  tracking_code text not null unique,
  requester_type text not null default 'citizen'
    check (requester_type in ('citizen', 'entity', 'unit', 'staff')),
  requester_name text,
  requester_contact text,
  requester_reference text,
  service_key text not null,
  form_key text,
  unit_id uuid,
  waqf_asset_id uuid,
  request_summary text,
  payload jsonb not null default '{}'::jsonb,
  status text not null default 'received'
    check (status in (
      'received',
      'triage',
      'under_review',
      'waiting_applicant',
      'routed',
      'closed',
      'rejected',
      'cancelled',
      'duplicate'
    )),
  priority text not null default 'normal'
    check (priority in ('normal', 'high', 'urgent')),
  source_channel text not null default 'public_portal'
    check (source_channel in ('public_portal', 'admin', 'unit', 'import')),
  public_note text,
  internal_note text,
  created_by uuid,
  assigned_to uuid,
  task_id uuid,
  case_id uuid,
  payment_intent_id uuid,
  document_job_id uuid,
  submitted_at timestamptz not null default now(),
  last_status_at timestamptz not null default now(),
  closed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table platform_services.service_requests is
  'Non-production draft table for service request intake. Public tracking must not expose requester personal data.';

create index if not exists idx_service_requests_tracking_code
  on platform_services.service_requests (tracking_code);

create index if not exists idx_service_requests_status
  on platform_services.service_requests (status);

create index if not exists idx_service_requests_service_key
  on platform_services.service_requests (service_key);

create index if not exists idx_service_requests_unit_id
  on platform_services.service_requests (unit_id);

create index if not exists idx_service_requests_submitted_at
  on platform_services.service_requests (submitted_at desc);

create table if not exists platform_services.service_request_status_events (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references platform_services.service_requests(id) on delete cascade,
  from_status text,
  to_status text not null,
  public_note text,
  internal_note text,
  actor_id uuid,
  actor_label text,
  created_at timestamptz not null default now()
);

comment on table platform_services.service_request_status_events is
  'Status event log for service requests. This is not a replacement for platform audit logs.';

create index if not exists idx_service_request_status_events_request_id
  on platform_services.service_request_status_events (request_id, created_at desc);

create table if not exists platform_services.service_request_attachments (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references platform_services.service_requests(id) on delete cascade,
  attachment_key text not null,
  file_name text,
  mime_type text,
  storage_bucket text,
  storage_path text,
  document_job_id uuid,
  is_required boolean not null default false,
  review_status text not null default 'pending'
    check (review_status in ('pending', 'accepted', 'rejected', 'needs_replacement')),
  uploaded_by uuid,
  uploaded_at timestamptz not null default now(),
  notes text
);

comment on table platform_services.service_request_attachments is
  'Attachment metadata draft only. Storage bucket and document intelligence linkage require separate approval.';

create index if not exists idx_service_request_attachments_request_id
  on platform_services.service_request_attachments (request_id);
