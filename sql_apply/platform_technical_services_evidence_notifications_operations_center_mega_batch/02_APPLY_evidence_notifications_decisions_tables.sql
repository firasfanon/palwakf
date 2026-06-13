begin;

create table if not exists platform_technical.technical_service_evidence (
  id uuid primary key default gen_random_uuid(),
  request_id uuid references platform_technical.technical_service_requests(id) on delete cascade,
  evidence_type text not null check (evidence_type in ('screenshot','network','console','sql_result','document','link','other')),
  title text not null,
  description text,
  url text,
  storage_bucket text,
  storage_path text,
  checksum text,
  captured_at timestamptz,
  uploaded_by uuid,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists platform_technical.technical_notifications (
  id uuid primary key default gen_random_uuid(),
  target_user_id uuid,
  notification_type text not null check (notification_type in ('request','approval','maintenance','backup','deployment','health','audit','system')),
  severity text not null default 'info' check (severity in ('info','warning','error','critical')),
  title text not null,
  message text not null,
  related_request_id uuid,
  is_read boolean not null default false,
  created_at timestamptz not null default now(),
  read_at timestamptz
);

create table if not exists platform_technical.technical_operation_decisions (
  id uuid primary key default gen_random_uuid(),
  request_id uuid references platform_technical.technical_service_requests(id) on delete set null,
  decision_type text not null check (decision_type in ('approve','reject','defer','escalate','close','rollback_required','uat_required')),
  decision_label text not null,
  decision_reason text,
  decided_by uuid,
  decided_at timestamptz not null default now(),
  payload jsonb not null default '{}'::jsonb
);

create index if not exists idx_technical_service_evidence_request_time
  on platform_technical.technical_service_evidence(request_id, created_at desc);
create index if not exists idx_technical_notifications_target_read
  on platform_technical.technical_notifications(target_user_id, is_read, created_at desc);
create index if not exists idx_technical_operation_decisions_request_time
  on platform_technical.technical_operation_decisions(request_id, decided_at desc);

alter table platform_technical.technical_service_evidence enable row level security;
alter table platform_technical.technical_notifications enable row level security;
alter table platform_technical.technical_operation_decisions enable row level security;

grant select on platform_technical.technical_service_evidence to authenticated;
grant select on platform_technical.technical_notifications to authenticated;
grant select on platform_technical.technical_operation_decisions to authenticated;

drop policy if exists technical_service_evidence_select_authenticated on platform_technical.technical_service_evidence;
create policy technical_service_evidence_select_authenticated on platform_technical.technical_service_evidence
for select to authenticated using (auth.uid() is not null);

drop policy if exists technical_notifications_select_authenticated on platform_technical.technical_notifications;
create policy technical_notifications_select_authenticated on platform_technical.technical_notifications
for select to authenticated using (auth.uid() is not null and (target_user_id is null or target_user_id = auth.uid()));

drop policy if exists technical_operation_decisions_select_authenticated on platform_technical.technical_operation_decisions;
create policy technical_operation_decisions_select_authenticated on platform_technical.technical_operation_decisions
for select to authenticated using (auth.uid() is not null);

commit;

select
  'platform_technical_evidence_notifications_tables_applied' as section,
  true as evidence_table_created,
  true as notifications_table_created,
  true as decisions_table_created,
  true as rls_enabled,
  false as production_approved;
