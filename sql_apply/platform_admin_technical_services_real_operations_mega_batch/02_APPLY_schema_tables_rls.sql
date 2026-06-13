-- 02_APPLY_schema_tables_rls.sql

begin;

create schema if not exists platform_technical;

create table if not exists platform_technical.technical_service_requests (
  id uuid primary key default gen_random_uuid(),
  service_type text not null check (service_type in ('backup','restore','maintenance','health','deployment','audit','other')),
  action_type text not null,
  title text not null,
  description text,
  status text not null default 'requested' check (status in ('draft','requested','approved','rejected','in_progress','completed','failed','cancelled')),
  approval_status text not null default 'pending' check (approval_status in ('pending','approved','rejected','not_required')),
  risk_level text not null default 'medium' check (risk_level in ('low','medium','high','critical')),
  requested_by uuid,
  requested_at timestamptz not null default now(),
  scheduled_for timestamptz,
  approved_by uuid,
  approved_at timestamptz,
  payload jsonb not null default '{}'::jsonb,
  result jsonb not null default '{}'::jsonb,
  rollback_plan text,
  evidence_urls text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists platform_technical.maintenance_windows (
  id uuid primary key default gen_random_uuid(),
  request_id uuid references platform_technical.technical_service_requests(id) on delete set null,
  title text not null,
  message_ar text,
  message_en text,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  affected_surfaces text[] not null default '{}',
  status text not null default 'planned' check (status in ('planned','approved','active','completed','cancelled')),
  created_by uuid,
  approved_by uuid,
  approved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint maintenance_window_time_check check (ends_at > starts_at)
);

create table if not exists platform_technical.backup_registry (
  id uuid primary key default gen_random_uuid(),
  request_id uuid references platform_technical.technical_service_requests(id) on delete set null,
  backup_kind text not null check (backup_kind in ('database','files','config','full','other')),
  provider text not null default 'manual',
  backup_label text not null,
  object_ref text,
  status text not null default 'recorded' check (status in ('recorded','verified','failed','expired')),
  started_at timestamptz,
  completed_at timestamptz,
  size_bytes bigint,
  checksum text,
  retention_until timestamptz,
  recorded_by uuid,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists platform_technical.health_checks (
  id uuid primary key default gen_random_uuid(),
  check_key text not null unique,
  check_group text not null,
  label text not null,
  status text not null default 'unknown' check (status in ('healthy','degraded','blocked','unknown')),
  details jsonb not null default '{}'::jsonb,
  last_checked_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists platform_technical.release_records (
  id uuid primary key default gen_random_uuid(),
  release_tag text not null,
  git_commit_hash text,
  flutter_version text,
  dart_version text,
  hosting_provider text not null default 'vercel',
  deploy_url text,
  status text not null default 'recorded' check (status in ('recorded','verified','failed','rolled_back')),
  created_by uuid,
  created_at timestamptz not null default now(),
  notes text
);

create table if not exists platform_technical.audit_events (
  id uuid primary key default gen_random_uuid(),
  event_type text not null,
  actor_user_id uuid,
  service_type text,
  request_id uuid,
  severity text not null default 'info' check (severity in ('debug','info','warning','error','critical')),
  message text not null,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_technical_service_requests_service_status
  on platform_technical.technical_service_requests(service_type, status, created_at desc);

create index if not exists idx_maintenance_windows_status_time
  on platform_technical.maintenance_windows(status, starts_at desc);

create index if not exists idx_backup_registry_kind_status
  on platform_technical.backup_registry(backup_kind, status, created_at desc);

create index if not exists idx_audit_events_type_time
  on platform_technical.audit_events(event_type, created_at desc);

alter table platform_technical.technical_service_requests enable row level security;
alter table platform_technical.maintenance_windows enable row level security;
alter table platform_technical.backup_registry enable row level security;
alter table platform_technical.health_checks enable row level security;
alter table platform_technical.release_records enable row level security;
alter table platform_technical.audit_events enable row level security;

grant usage on schema platform_technical to authenticated;

-- Direct table grants are intentionally read-only. Writes must go through RPCs.
grant select on platform_technical.technical_service_requests to authenticated;
grant select on platform_technical.maintenance_windows to authenticated;
grant select on platform_technical.backup_registry to authenticated;
grant select on platform_technical.health_checks to authenticated;
grant select on platform_technical.release_records to authenticated;
grant select on platform_technical.audit_events to authenticated;

drop policy if exists technical_service_requests_select_authenticated on platform_technical.technical_service_requests;
create policy technical_service_requests_select_authenticated
on platform_technical.technical_service_requests
for select to authenticated
using (auth.uid() is not null);

drop policy if exists maintenance_windows_select_authenticated on platform_technical.maintenance_windows;
create policy maintenance_windows_select_authenticated
on platform_technical.maintenance_windows
for select to authenticated
using (auth.uid() is not null);

drop policy if exists backup_registry_select_authenticated on platform_technical.backup_registry;
create policy backup_registry_select_authenticated
on platform_technical.backup_registry
for select to authenticated
using (auth.uid() is not null);

drop policy if exists health_checks_select_authenticated on platform_technical.health_checks;
create policy health_checks_select_authenticated
on platform_technical.health_checks
for select to authenticated
using (auth.uid() is not null);

drop policy if exists release_records_select_authenticated on platform_technical.release_records;
create policy release_records_select_authenticated
on platform_technical.release_records
for select to authenticated
using (auth.uid() is not null);

drop policy if exists audit_events_select_authenticated on platform_technical.audit_events;
create policy audit_events_select_authenticated
on platform_technical.audit_events
for select to authenticated
using (auth.uid() is not null);

commit;

select
  'platform_technical_schema_tables_rls_applied' as section,
  true as schema_created,
  true as rls_enabled,
  true as read_grants_added,
  false as backup_restore_execution,
  false as production_approved;
