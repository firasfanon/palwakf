-- Document Intelligence — schema and tables draft
-- Status: non-production draft / adapt to real platform schema
-- Target schema for data tables: assistant
-- IMPORTANT:
-- 1) Keep original uploaded file as highest visual reference
-- 2) public is for RPC wrappers only
-- 3) Adapt RBAC functions to real platform permission helpers

create schema if not exists assistant;

create extension if not exists pgcrypto;

create table if not exists assistant.document_jobs (
  id uuid primary key default gen_random_uuid(),
  source_system text not null,
  source_record_id uuid null,
  mode text not null check (mode in (
    'MODE_RESTORE_ONLY',
    'MODE_RESTORE_OCR',
    'MODE_RESTORE_HTR',
    'MODE_STRUCTURED_EXTRACTION',
    'MODE_EVIDENCE_LINKING'
  )),
  status text not null default 'draft' check (status in (
    'draft',
    'machine_processed',
    'needs_review',
    'reviewed',
    'approved',
    'rejected'
  )),
  document_type_primary text null,
  document_type_secondary jsonb not null default '[]'::jsonb,
  sensitivity_level text not null default 'general' check (sensitivity_level in (
    'general',
    'historical',
    'legal',
    'financial',
    'identity',
    'evidence'
  )),
  requested_by uuid null,
  requested_at timestamptz not null default now(),
  processed_at timestamptz null,
  engine_version text not null default 'udrx_v2',
  review_required boolean not null default true,
  waqf_asset_id uuid null,
  case_id uuid null,
  billing_record_id uuid null,
  task_id uuid null,
  historical_reference_id uuid null,
  map_evidence_snapshot_id uuid null,
  metadata jsonb not null default '{}'::jsonb
);

create index if not exists idx_document_jobs_source_system on assistant.document_jobs(source_system);
create index if not exists idx_document_jobs_status on assistant.document_jobs(status);
create index if not exists idx_document_jobs_mode on assistant.document_jobs(mode);
create index if not exists idx_document_jobs_waqf_asset_id on assistant.document_jobs(waqf_asset_id);
create index if not exists idx_document_jobs_case_id on assistant.document_jobs(case_id);

create table if not exists assistant.document_files (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references assistant.document_jobs(id) on delete cascade,
  file_role text not null check (file_role in ('original','restored','high_contrast','thumbnail')),
  storage_bucket text not null,
  storage_path text not null,
  mime_type text not null,
  checksum text null,
  page_count int not null default 1 check (page_count > 0),
  created_at timestamptz not null default now()
);

create index if not exists idx_document_files_job_id on assistant.document_files(job_id);
create index if not exists idx_document_files_role on assistant.document_files(file_role);

create table if not exists assistant.document_pages (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references assistant.document_jobs(id) on delete cascade,
  page_no int not null check (page_no > 0),
  width_px int null,
  height_px int null,
  has_handwriting boolean not null default false,
  has_table boolean not null default false,
  has_stamp boolean not null default false,
  has_signature boolean not null default false,
  page_confidence text null check (page_confidence in ('high','medium','low','unreadable')),
  created_at timestamptz not null default now(),
  unique(job_id, page_no)
);

create table if not exists assistant.document_transcriptions (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references assistant.document_jobs(id) on delete cascade,
  page_no int not null check (page_no > 0),
  printed_text text null,
  handwritten_text text null,
  full_text text null,
  document_confidence text null check (document_confidence in ('high','medium','low','unreadable')),
  created_at timestamptz not null default now(),
  unique(job_id, page_no)
);

create table if not exists assistant.document_uncertain_segments (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references assistant.document_jobs(id) on delete cascade,
  page_no int not null check (page_no > 0),
  region_id text not null,
  raw_text text not null,
  reason text not null,
  confidence text not null check (confidence in ('high','medium','low','unreadable')),
  bbox jsonb null,
  created_at timestamptz not null default now()
);

create index if not exists idx_document_uncertain_segments_job_id on assistant.document_uncertain_segments(job_id);

create table if not exists assistant.document_structured_fields (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references assistant.document_jobs(id) on delete cascade,
  field_name text not null,
  raw_value text null,
  normalized_value text null,
  confidence text not null check (confidence in ('high','medium','low','unreadable')),
  page_no int null,
  region_id text null,
  bbox jsonb null,
  created_at timestamptz not null default now()
);

create index if not exists idx_document_structured_fields_job_id on assistant.document_structured_fields(job_id);
create index if not exists idx_document_structured_fields_field_name on assistant.document_structured_fields(field_name);

create table if not exists assistant.document_candidate_links (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references assistant.document_jobs(id) on delete cascade,
  entity_type text not null check (entity_type in (
    'waqf_asset',
    'case',
    'billing_record',
    'task',
    'historical_reference',
    'map_evidence_snapshot'
  )),
  entity_id uuid not null,
  match_basis jsonb not null default '[]'::jsonb,
  confidence text not null check (confidence in ('high','medium','low','unreadable')),
  requires_review boolean not null default true,
  created_at timestamptz not null default now()
);

create index if not exists idx_document_candidate_links_job_id on assistant.document_candidate_links(job_id);
create index if not exists idx_document_candidate_links_entity_type on assistant.document_candidate_links(entity_type);

create table if not exists assistant.document_reviews (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references assistant.document_jobs(id) on delete cascade,
  review_status text not null check (review_status in (
    'draft',
    'needs_review',
    'reviewed',
    'approved',
    'rejected'
  )),
  reviewed_by uuid null,
  reviewed_at timestamptz null,
  notes text null,
  field_corrections jsonb not null default '{}'::jsonb,
  approved_links jsonb not null default '[]'::jsonb,
  rejected_links jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_document_reviews_job_id on assistant.document_reviews(job_id);

create table if not exists assistant.document_audit_events (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references assistant.document_jobs(id) on delete cascade,
  event_type text not null,
  actor_id uuid null,
  event_payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_document_audit_events_job_id on assistant.document_audit_events(job_id);

alter table assistant.document_jobs enable row level security;
alter table assistant.document_files enable row level security;
alter table assistant.document_pages enable row level security;
alter table assistant.document_transcriptions enable row level security;
alter table assistant.document_uncertain_segments enable row level security;
alter table assistant.document_structured_fields enable row level security;
alter table assistant.document_candidate_links enable row level security;
alter table assistant.document_reviews enable row level security;
alter table assistant.document_audit_events enable row level security;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'assistant'
      and tablename = 'document_jobs'
      and policyname = 'document_jobs_select_authenticated_v1'
  ) then
    create policy document_jobs_select_authenticated_v1
      on assistant.document_jobs
      for select
      to authenticated
      using (true);
  end if;
end$$;
