-- PalWakf Platform Services Center
-- Production Data Layer Readiness Pack
-- 01 - Production Schema Migration Draft
-- Date: 2026-05-08
-- Status: PRODUCTION-READINESS DRAFT / DO NOT RUN UNTIL APPROVED
-- Notes:
--   1. This file contains no demo seed data.
--   2. External sovereign links are nullable and not forced here.
--   3. Public access must be through public RPC wrappers only.


-- Integration review note after production preflight:
--   Existing tables public.services, public.servicetypes, public.serviceproviders,
--   public.servicepoints, public.pwf_complaints, platform permission tables,
--   core.org_units, and storage.objects were detected.
--   This migration must not duplicate those responsibilities.
--   service_key remains a soft mapping to public.services until column/PK review is approved.
--   complaint flows must link to or route to public.pwf_complaints, not replace it.

create extension if not exists pgcrypto;

create schema if not exists platform_services;

comment on schema platform_services is
  'Internal schema for PalWakf Services Center service requests, forms registry, tracking events, and attachment metadata. Public exposure must be through controlled RPC wrappers only.';

create or replace function platform_services.set_updated_at_v1()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table if not exists platform_services.service_forms_registry (
  id uuid primary key default gen_random_uuid(),
  form_key text not null unique,
  title_ar text not null,
  title_en text,
  service_key text not null,
  service_family text not null default 'general',
  audience text not null default 'public'
    check (audience in ('public', 'internal', 'unit', 'mixed')),
  public_visibility boolean not null default false,
  internal_visibility boolean not null default true,
  review_status text not null default 'draft'
    check (review_status in ('draft', 'review', 'approved', 'archived')),
  required_attachments jsonb not null default '[]'::jsonb,
  optional_attachments jsonb not null default '[]'::jsonb,
  form_schema jsonb not null default '{}'::jsonb,
  source_reference text,
  legal_reference_key text,
  document_source_id uuid,
  version_no text not null default '1.0',
  effective_from date,
  effective_to date,
  created_by uuid,
  updated_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  notes text
);

comment on table platform_services.service_forms_registry is
  'Official forms registry for Services Center. It describes form metadata and attachment rules; it does not store the uploaded files themselves.';

create trigger trg_service_forms_registry_updated_at_v1
before update on platform_services.service_forms_registry
for each row execute function platform_services.set_updated_at_v1();

create table if not exists platform_services.service_requests (
  id uuid primary key default gen_random_uuid(),
  tracking_code text not null unique,
  requester_type text not null default 'citizen'
    check (requester_type in ('citizen', 'entity', 'unit', 'staff')),
  requester_name text,
  requester_contact text,
  requester_reference text,
  requester_identity_hint text,
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
  assigned_unit_id uuid,
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
  'Service request intake table. Public tracking must never expose requester_name, contact, reference, internal notes, assignee, attachments, or raw payload.';


comment on column platform_services.service_forms_registry.service_key is
  'Soft integration key for existing public.services until the final service catalog PK/key contract is approved.';
comment on column platform_services.service_requests.service_key is
  'Soft integration key for existing public.services. Do not use this table as a duplicate service catalog.';
comment on column platform_services.service_requests.requester_reference is
  'Optional requester reference. Do not expose through public tracking RPC.';


create trigger trg_service_requests_updated_at_v1
before update on platform_services.service_requests
for each row execute function platform_services.set_updated_at_v1();

create index if not exists idx_service_requests_tracking_code
  on platform_services.service_requests (tracking_code);
create index if not exists idx_service_requests_status
  on platform_services.service_requests (status);
create index if not exists idx_service_requests_priority
  on platform_services.service_requests (priority);
create index if not exists idx_service_requests_service_key
  on platform_services.service_requests (service_key);
create index if not exists idx_service_requests_unit_id
  on platform_services.service_requests (unit_id);
create index if not exists idx_service_requests_assigned_unit_id
  on platform_services.service_requests (assigned_unit_id);
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
  'Status-event ledger for service requests. This complements but does not replace platform audit logging.';

create index if not exists idx_service_request_status_events_request_id
  on platform_services.service_request_status_events (request_id, created_at desc);

create table if not exists platform_services.service_request_attachments (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references platform_services.service_requests(id) on delete cascade,
  attachment_key text not null,
  file_name text,
  mime_type text,
  file_size_bytes bigint,
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
  'Attachment metadata only. Binary files must stay in approved Storage buckets and may later link to document_intelligence.';

create index if not exists idx_service_request_attachments_request_id
  on platform_services.service_request_attachments (request_id);
create index if not exists idx_service_request_attachments_review_status
  on platform_services.service_request_attachments (review_status);

-- Sovereign link policy:
-- waqf_asset_id remains nullable and without hard FK until waqf_assets is production-complete and governed.
comment on column platform_services.service_requests.waqf_asset_id is
  'Nullable future sovereign link to waqf_assets. Do not replace with non-sovereign parcel/location identifiers.';

