-- PalWakf Platform — Mega Batch M
-- Service Center Production Backend + Request Workflow Completion
-- File: 01_platform_services_schema_rpc_workflow_production_readiness.sql
-- Date: 2026-05-11
-- Scope: platform_services only + public RPC wrappers.
-- Safety: does not touch waqf schema, awqaf_system, mustakshif, cases, tasks, or billing tables.

create extension if not exists pgcrypto;

create schema if not exists platform_services;

comment on schema platform_services is
  'Internal operational schema for PalWakf Service Center requests, forms, public tracking, workflow events, and attachment metadata. Public access is through public RPC wrappers only.';

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

drop trigger if exists trg_service_forms_registry_updated_at_v1 on platform_services.service_forms_registry;
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
  unit_slug text,
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
    check (priority in ('low', 'normal', 'high', 'urgent')),
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

alter table platform_services.service_requests add column if not exists unit_slug text;

comment on table platform_services.service_requests is
  'Service Center request intake. Public tracking must not expose personal data, raw payload, internal notes, assignees, or attachments.';
comment on column platform_services.service_requests.waqf_asset_id is
  'Nullable future sovereign link to waqf_assets. Mega Batch M does not create FK or mutate waqf schema.';

drop trigger if exists trg_service_requests_updated_at_v1 on platform_services.service_requests;
create trigger trg_service_requests_updated_at_v1
before update on platform_services.service_requests
for each row execute function platform_services.set_updated_at_v1();

create index if not exists idx_service_requests_tracking_code on platform_services.service_requests (tracking_code);
create index if not exists idx_service_requests_status on platform_services.service_requests (status);
create index if not exists idx_service_requests_priority on platform_services.service_requests (priority);
create index if not exists idx_service_requests_service_key on platform_services.service_requests (service_key);
create index if not exists idx_service_requests_unit_id on platform_services.service_requests (unit_id);
create index if not exists idx_service_requests_unit_slug on platform_services.service_requests (unit_slug);
create index if not exists idx_service_requests_assigned_unit_id on platform_services.service_requests (assigned_unit_id);
create index if not exists idx_service_requests_submitted_at on platform_services.service_requests (submitted_at desc);

create table if not exists platform_services.service_request_status_events (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references platform_services.service_requests(id) on delete cascade,
  from_status text,
  to_status text not null,
  action_key text,
  public_note text,
  internal_note text,
  actor_id uuid,
  actor_label text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_service_request_status_events_request_id
  on platform_services.service_request_status_events (request_id, created_at desc);
create index if not exists idx_service_request_status_events_action_key
  on platform_services.service_request_status_events (action_key);

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

create index if not exists idx_service_request_attachments_request_id
  on platform_services.service_request_attachments (request_id);
create index if not exists idx_service_request_attachments_review_status
  on platform_services.service_request_attachments (review_status);

-- Seed reviewed baseline forms. Idempotent.
insert into platform_services.service_forms_registry (
  form_key, title_ar, service_key, service_family, audience,
  public_visibility, internal_visibility, review_status,
  required_attachments, optional_attachments, source_reference, legal_reference_key, version_no, notes
) values
  ('general_service_request_v1', 'نموذج طلب خدمة عامة', 'general_service', 'services_center', 'public', true, true, 'approved', '["إثبات شخصية عند الحاجة", "مرفقات داعمة حسب نوع الخدمة"]'::jsonb, '[]'::jsonb, 'Mega Batch M seed', 'services_center_policy', '1.0', 'Seed for public Service Center request entry.'),
  ('certificate_request_v1', 'نموذج طلب إفادة أو وثيقة', 'document_certificate', 'documents', 'public', true, true, 'approved', '["إثبات شخصية", "بيانات المرجع أو العقار إن وجدت"]'::jsonb, '["تفويض إن وجد"]'::jsonb, 'Mega Batch M seed', 'document_reference_policy', '1.0', 'Seed for certificate/document requests.'),
  ('transaction_followup_v1', 'نموذج متابعة معاملة', 'request_followup', 'tracking', 'public', true, true, 'approved', '["رقم متابعة سابق إن وجد"]'::jsonb, '[]'::jsonb, 'Mega Batch M seed', 'services_followup_policy', '1.0', 'Seed for follow-up requests.'),
  ('feedback_notice_v1', 'نموذج ملاحظة أو بلاغ', 'complaint_feedback', 'feedback', 'public', true, true, 'approved', '["صور أو مستندات داعمة إن وجدت"]'::jsonb, '[]'::jsonb, 'Mega Batch M seed', 'complaints_policy', '1.0', 'Seed for notes/feedback routing; does not replace pwf_complaints.'),
  ('legal_reference_request_v1', 'نموذج طلب مرجع تنظيمي', 'legal_reference', 'legal_references', 'public', true, true, 'approved', '["وصف المرجع المطلوب"]'::jsonb, '["ملف أو رابط داعم"]'::jsonb, 'Mega Batch M seed', 'legal_references_policy', '1.0', 'Seed for official reference requests.'),
  ('event_service_request_v1', 'نموذج طلب خدمة فعالية', 'event_service', 'events', 'public', true, true, 'approved', '["وصف الفعالية", "الجهة الطالبة"]'::jsonb, '["دعوة أو برنامج مقترح"]'::jsonb, 'Mega Batch M seed', 'events_policy', '1.0', 'Seed for event-related service requests.')
on conflict (form_key) do update set
  title_ar = excluded.title_ar,
  service_key = excluded.service_key,
  service_family = excluded.service_family,
  audience = excluded.audience,
  public_visibility = excluded.public_visibility,
  internal_visibility = excluded.internal_visibility,
  review_status = excluded.review_status,
  required_attachments = excluded.required_attachments,
  optional_attachments = excluded.optional_attachments,
  source_reference = excluded.source_reference,
  legal_reference_key = excluded.legal_reference_key,
  version_no = excluded.version_no,
  notes = excluded.notes,
  updated_at = now();

create or replace function platform_services.generate_tracking_code_v1()
returns text
language sql
as $$
  select 'PWF-' || to_char(now(), 'YYYYMMDD') || '-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8));
$$;

create or replace function platform_services.can_admin_read_requests_v1()
returns boolean
language sql
stable
security definer
set search_path = public, platform_services
as $$
  select auth.uid() is not null;
$$;

create or replace function platform_services.can_admin_write_requests_v1()
returns boolean
language sql
stable
security definer
set search_path = public, platform_services
as $$
  select auth.uid() is not null;
$$;

create or replace function platform_services.next_status_for_action_v1(p_status text, p_action text)
returns text
language sql
immutable
as $$
  select case
    when p_status = 'received' and p_action = 'start_triage' then 'triage'
    when p_status = 'received' and p_action = 'reject' then 'rejected'
    when p_status = 'triage' and p_action = 'start_review' then 'under_review'
    when p_status = 'triage' and p_action = 'request_info' then 'waiting_applicant'
    when p_status = 'triage' and p_action = 'reject' then 'rejected'
    when p_status = 'under_review' and p_action = 'route' then 'routed'
    when p_status = 'under_review' and p_action = 'request_info' then 'waiting_applicant'
    when p_status = 'under_review' and p_action = 'close' then 'closed'
    when p_status = 'under_review' and p_action = 'reject' then 'rejected'
    when p_status = 'waiting_applicant' and p_action = 'start_review' then 'under_review'
    when p_status = 'waiting_applicant' and p_action = 'close' then 'closed'
    when p_status = 'routed' and p_action = 'close' then 'closed'
    when p_action = 'cancel' and p_status not in ('closed', 'rejected', 'cancelled') then 'cancelled'
    else null
  end;
$$;

create or replace function public.rpc_services_submit_request_v1(payload jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public, platform_services
as $$
declare
  v_tracking_code text;
  v_request_id uuid;
  v_service_key text;
  v_form_key text;
  v_requester_type text;
  v_request_summary text;
  v_unit_slug text;
begin
  if payload is null or jsonb_typeof(payload) <> 'object' then
    return jsonb_build_object('success', false, 'message_ar', 'صيغة الطلب غير صحيحة.');
  end if;

  v_service_key := nullif(payload->>'service_key', '');
  v_form_key := nullif(payload->>'form_key', '');
  v_requester_type := coalesce(nullif(payload->>'requester_type', ''), 'citizen');
  v_request_summary := nullif(payload->>'request_summary', '');
  v_unit_slug := coalesce(nullif(payload->>'unit_slug', ''), 'home');

  if v_service_key is null then
    return jsonb_build_object('success', false, 'message_ar', 'مفتاح الخدمة مطلوب.');
  end if;

  if v_requester_type not in ('citizen', 'entity', 'unit', 'staff') then
    return jsonb_build_object('success', false, 'message_ar', 'صفة مقدم الطلب غير صحيحة.');
  end if;

  v_tracking_code := platform_services.generate_tracking_code_v1();

  insert into platform_services.service_requests (
    tracking_code,
    requester_type,
    requester_name,
    requester_contact,
    requester_reference,
    service_key,
    form_key,
    request_summary,
    unit_slug,
    payload,
    source_channel,
    status,
    public_note
  ) values (
    v_tracking_code,
    v_requester_type,
    nullif(payload->>'requester_name', ''),
    nullif(payload->>'requester_contact', ''),
    nullif(payload->>'requester_reference', ''),
    v_service_key,
    v_form_key,
    v_request_summary,
    v_unit_slug,
    coalesce(payload - 'requester_name' - 'requester_contact' - 'requester_reference' - 'requester_identity_hint', '{}'::jsonb),
    'public_portal',
    'received',
    'تم استلام الطلب مبدئيًا وهو بانتظار الفرز.'
  ) returning id into v_request_id;

  insert into platform_services.service_request_status_events (
    request_id, from_status, to_status, action_key, public_note, actor_label
  ) values (
    v_request_id, null, 'received', 'submit_public_request', 'تم استلام الطلب مبدئيًا.', 'public_portal'
  );

  return jsonb_build_object(
    'ok', true,
    'success', true,
    'request_id', v_request_id,
    'tracking_code', v_tracking_code,
    'status', 'received',
    'source', 'rpc',
    'message_ar', 'تم استلام الطلب مبدئيًا. احتفظ برقم المتابعة.'
  );
end;
$$;

create or replace function public.rpc_services_submit_request_draft_v1(payload jsonb)
returns jsonb
language sql
security definer
set search_path = public, platform_services
as $$
  select public.rpc_services_submit_request_v1(payload);
$$;

create or replace function public.rpc_services_track_request_public_v1(p_tracking_code text)
returns table (
  tracking_code text,
  status text,
  public_note text,
  submitted_at timestamptz,
  last_status_at timestamptz
)
language sql
security definer
set search_path = public, platform_services
as $$
  select
    r.tracking_code,
    r.status,
    coalesce(r.public_note, 'الطلب قيد المتابعة.') as public_note,
    r.submitted_at,
    r.last_status_at
  from platform_services.service_requests r
  where r.tracking_code = p_tracking_code
  limit 1;
$$;

create or replace function public.rpc_services_forms_public_v1()
returns table (
  form_key text,
  title_ar text,
  service_key text,
  audience text,
  required_attachments jsonb,
  version_no text,
  source_reference text
)
language sql
security definer
set search_path = public, platform_services
as $$
  select
    f.form_key,
    f.title_ar,
    f.service_key,
    f.audience,
    f.required_attachments,
    f.version_no,
    f.source_reference
  from platform_services.service_forms_registry f
  where f.public_visibility = true
    and f.review_status = 'approved'
    and (f.effective_to is null or f.effective_to >= current_date)
  order by f.service_family, f.service_key, f.title_ar;
$$;

create or replace function public.rpc_services_admin_request_queue_v1(
  p_status text default null,
  p_limit integer default 100
)
returns table (
  id uuid,
  tracking_code text,
  service_key text,
  form_key text,
  requester_type text,
  requester_label text,
  service_label_ar text,
  form_title_ar text,
  request_summary text,
  status text,
  priority text,
  assigned_to text,
  assigned_unit_id uuid,
  submitted_at timestamptz,
  last_status_at timestamptz,
  updated_at_label text,
  source_channel text
)
language sql
security definer
set search_path = public, platform_services
as $$
  select
    r.id,
    r.tracking_code,
    r.service_key,
    r.form_key,
    r.requester_type,
    case r.requester_type
      when 'entity' then 'مؤسسة / جهة'
      when 'unit' then 'وحدة / مديرية'
      when 'staff' then 'موظف'
      else 'مواطن / فرد'
    end as requester_label,
    coalesce(f.title_ar, r.service_key) as service_label_ar,
    coalesce(f.title_ar, r.form_key, 'نموذج خدمة') as form_title_ar,
    r.request_summary,
    r.status,
    r.priority,
    coalesce(r.assigned_unit_id::text, 'مركز الخدمات') as assigned_to,
    r.assigned_unit_id,
    r.submitted_at,
    r.last_status_at,
    to_char(r.last_status_at at time zone 'Asia/Hebron', 'YYYY-MM-DD HH24:MI') as updated_at_label,
    r.source_channel
  from platform_services.service_requests r
  left join platform_services.service_forms_registry f on f.form_key = r.form_key
  where platform_services.can_admin_read_requests_v1()
    and (p_status is null or p_status = 'all' or r.status = p_status)
  order by r.submitted_at desc
  limit greatest(1, least(coalesce(p_limit, 100), 200));
$$;

create or replace function public.rpc_services_admin_request_queue_draft_v1()
returns table (
  id uuid,
  tracking_code text,
  service_key text,
  form_key text,
  requester_type text,
  request_summary text,
  status text,
  priority text,
  assigned_unit_id uuid,
  submitted_at timestamptz,
  last_status_at timestamptz,
  source_channel text
)
language sql
security definer
set search_path = public, platform_services
as $$
  select
    q.id, q.tracking_code, q.service_key, q.form_key, q.requester_type,
    q.request_summary, q.status, q.priority, q.assigned_unit_id,
    q.submitted_at, q.last_status_at, q.source_channel
  from public.rpc_services_admin_request_queue_v1(null, 100) q;
$$;

create or replace function public.rpc_services_admin_transition_request_v1(
  p_tracking_code text,
  p_action text,
  p_public_note text default null,
  p_internal_note text default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, platform_services
as $$
declare
  v_request platform_services.service_requests%rowtype;
  v_next_status text;
begin
  if not platform_services.can_admin_write_requests_v1() then
    return jsonb_build_object('success', false, 'message_ar', 'لا توجد صلاحية لتحديث حالة الطلب.');
  end if;

  select * into v_request
  from platform_services.service_requests
  where tracking_code = p_tracking_code
  for update;

  if not found then
    return jsonb_build_object('success', false, 'message_ar', 'لم يتم العثور على الطلب.');
  end if;

  v_next_status := platform_services.next_status_for_action_v1(v_request.status, p_action);
  if v_next_status is null then
    return jsonb_build_object(
      'success', false,
      'message_ar', 'انتقال غير مسموح من الحالة الحالية.',
      'status', v_request.status
    );
  end if;

  update platform_services.service_requests
  set status = v_next_status,
      public_note = coalesce(p_public_note, public_note),
      internal_note = coalesce(p_internal_note, internal_note),
      last_status_at = now(),
      closed_at = case when v_next_status in ('closed', 'rejected', 'cancelled') then now() else closed_at end,
      updated_at = now()
  where id = v_request.id;

  insert into platform_services.service_request_status_events (
    request_id, from_status, to_status, action_key, public_note, internal_note, actor_id, actor_label
  ) values (
    v_request.id,
    v_request.status,
    v_next_status,
    p_action,
    p_public_note,
    p_internal_note,
    auth.uid(),
    'platform_services_admin'
  );

  return jsonb_build_object(
    'success', true,
    'tracking_code', v_request.tracking_code,
    'status', v_next_status,
    'message_ar', 'تم تحديث حالة الطلب بنجاح.'
  );
end;
$$;

alter table platform_services.service_forms_registry enable row level security;
alter table platform_services.service_requests enable row level security;
alter table platform_services.service_request_status_events enable row level security;
alter table platform_services.service_request_attachments enable row level security;

-- Do not FORCE RLS here: SECURITY DEFINER RPC wrappers owned by the table owner must remain able
-- to perform controlled reads/writes while direct anon/auth table access is denied by policies and grants.

drop policy if exists service_forms_registry_deny_direct_v1 on platform_services.service_forms_registry;
drop policy if exists service_requests_deny_direct_v1 on platform_services.service_requests;
drop policy if exists service_request_status_events_deny_direct_v1 on platform_services.service_request_status_events;
drop policy if exists service_request_attachments_deny_direct_v1 on platform_services.service_request_attachments;

create policy service_forms_registry_deny_direct_v1
on platform_services.service_forms_registry for all using (false) with check (false);
create policy service_requests_deny_direct_v1
on platform_services.service_requests for all using (false) with check (false);
create policy service_request_status_events_deny_direct_v1
on platform_services.service_request_status_events for all using (false) with check (false);
create policy service_request_attachments_deny_direct_v1
on platform_services.service_request_attachments for all using (false) with check (false);

revoke all on all tables in schema platform_services from anon, authenticated;
revoke all on schema platform_services from anon;
revoke all on schema platform_services from authenticated;

grant execute on function public.rpc_services_forms_public_v1() to anon, authenticated;
grant execute on function public.rpc_services_track_request_public_v1(text) to anon, authenticated;
grant execute on function public.rpc_services_submit_request_v1(jsonb) to anon, authenticated;
grant execute on function public.rpc_services_submit_request_draft_v1(jsonb) to anon, authenticated;
grant execute on function public.rpc_services_admin_request_queue_v1(text, integer) to authenticated;
grant execute on function public.rpc_services_admin_request_queue_draft_v1() to authenticated;
grant execute on function public.rpc_services_admin_transition_request_v1(text, text, text, text) to authenticated;
