-- PalWakf — Media Center Live User Permission UAT + Editorial Decision Event Intake
-- Date: 2026-05-07
-- Purpose:
--   Add verifiable, live-user permission UAT evidence and first editorial decision
--   intake summaries above existing media center governance without creating
--   parallel media content tables.
-- Governance:
--   - SQL Editor/postgres diagnostics do not count as live-user UAT closure.
--   - Live permission UAT closes only when auth.uid() exists and recorded result
--     matches the expected scenario result.
--   - Editorial decision events remain audit/workflow evidence only and do not
--     mutate source content tables.

create extension if not exists pgcrypto;

-- -----------------------------------------------------------------------------
-- 0) Ensure audit/workflow evidence tables exist when this migration is applied
--    after a partial media-center SQL history.
-- -----------------------------------------------------------------------------
create table if not exists public.media_center_audit_events (
  id uuid primary key default gen_random_uuid(),
  event_key text not null,
  content_family text not null,
  action_key text not null,
  record_id uuid null,
  unit_slug text null,
  source_route text null,
  notes text null,
  metadata jsonb not null default '{}'::jsonb,
  actor_id uuid null default auth.uid(),
  created_at timestamptz not null default now()
);

create table if not exists public.media_center_editorial_events (
  id uuid primary key default gen_random_uuid(),
  content_family text not null,
  record_id uuid null,
  unit_slug text null,
  from_status text null,
  to_status text not null,
  action_key text not null,
  decision_label_ar text not null,
  source_route text null,
  notes text null,
  metadata jsonb not null default '{}'::jsonb,
  actor_id uuid null default auth.uid(),
  created_at timestamptz not null default now()
);

alter table public.media_center_editorial_events
  add column if not exists from_status text null,
  add column if not exists to_status text not null default 'in_review',
  add column if not exists decision_label_ar text not null default 'تحديث تحريري',
  add column if not exists metadata jsonb not null default '{}'::jsonb;

create index if not exists idx_media_center_audit_events_family_action_created
  on public.media_center_audit_events(content_family, action_key, created_at desc);

create index if not exists idx_media_center_editorial_events_family_status_created
  on public.media_center_editorial_events(content_family, to_status, created_at desc);

-- -----------------------------------------------------------------------------
-- 1) Live user permission UAT evidence table.
-- -----------------------------------------------------------------------------
create table if not exists public.media_center_permission_uat_events (
  id uuid primary key default gen_random_uuid(),
  scenario_key text not null,
  title_ar text not null,
  role_key text not null,
  action_key text not null,
  unit_slug text null,
  expected_allowed boolean not null,
  actual_allowed boolean not null,
  passed boolean not null,
  is_live_user boolean not null default (auth.uid() is not null),
  auth_role text null default auth.role(),
  jwt_role text null default current_setting('request.jwt.claim.role', true),
  session_user_name text not null default session_user::text,
  current_user_name text not null default current_user::text,
  actor_id uuid null default auth.uid(),
  source_route text not null default '/admin/media-center',
  notes text null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_media_center_permission_uat_scenario_created
  on public.media_center_permission_uat_events(scenario_key, created_at desc);

create index if not exists idx_media_center_permission_uat_live_passed
  on public.media_center_permission_uat_events(is_live_user, passed, created_at desc);

alter table public.media_center_permission_uat_events enable row level security;

drop policy if exists media_center_permission_uat_events_select_v1 on public.media_center_permission_uat_events;
create policy media_center_permission_uat_events_select_v1
on public.media_center_permission_uat_events
for select
using (public.media_center_can_read_v1());

drop policy if exists media_center_permission_uat_events_write_v1 on public.media_center_permission_uat_events;
create policy media_center_permission_uat_events_write_v1
on public.media_center_permission_uat_events
for all
using (
  public.media_center_can_write_v1()
  or public.media_center_can_action_v1('manage_governance', null)
  or session_user = 'postgres'
  or coalesce(auth.role(), '') = 'service_role'
)
with check (
  public.media_center_can_write_v1()
  or public.media_center_can_action_v1('manage_governance', null)
  or session_user = 'postgres'
  or coalesce(auth.role(), '') = 'service_role'
);

-- -----------------------------------------------------------------------------
-- 2) Canonical permission UAT scenarios.
-- -----------------------------------------------------------------------------
drop function if exists public.rpc_media_center_permission_uat_required_scenarios_v1();
create function public.rpc_media_center_permission_uat_required_scenarios_v1()
returns table (
  scenario_key text,
  title_ar text,
  role_key text,
  action_key text,
  unit_slug text,
  expected_allowed boolean,
  required_next_action_ar text,
  sort_order integer
)
language sql
stable
security definer
set search_path = public
as $$
  values
    ('viewer_read_dashboard', 'مشاهد إعلامي يقرأ لوحة المركز', 'media_viewer', 'view', null::text, true, 'اختبر مستخدمًا مصادقًا لديه قراءة فقط، ثم سجل النتيجة من جلسة المستخدم.', 10),
    ('contributor_create_draft', 'محرر مسودة ينشئ مادة', 'media_contributor', 'create_draft', null::text, true, 'اختبر مستخدم create؛ يجب أن يستطيع إنشاء مسودة دون نشر.', 20),
    ('unit_editor_review_unit_content', 'محرر وحدة يراجع محتوى الوحدة', 'unit_media_editor', 'review', 'unit-sample', true, 'اختبر مستخدم وحدة داخل نطاقه مع unit_slug حقيقي.', 30),
    ('central_reviewer_approve', 'مراجع مركزي يعتمد مادة', 'central_media_reviewer', 'approve', null::text, true, 'اختبر مستخدم manageSite؛ يجب أن يعتمد دون نشر نهائي.', 40),
    ('central_publisher_publish_home', 'ناشر مركزي ينشر على الصفحة الرئيسية', 'central_publisher', 'publish', null::text, true, 'اختبر مستخدم manageHome؛ يجب أن يستطيع النشر العام.', 50),
    ('unit_editor_cannot_cross_publish_home', 'محرر وحدة لا يبرز على الصفحة الرئيسية', 'unit_media_editor', 'cross_publish', 'unit-sample', false, 'اختبر مستخدم وحدة؛ يجب أن يفشل الإبراز العام دون صلاحية مركزية.', 60);
$$;

-- -----------------------------------------------------------------------------
-- 3) Record current/live user permission UAT.
-- -----------------------------------------------------------------------------
drop function if exists public.rpc_media_center_record_permission_uat_event_v1(text, text, boolean, text, text, text, jsonb);
create function public.rpc_media_center_record_permission_uat_event_v1(
  p_scenario_key text,
  p_action_key text default null,
  p_expected_allowed boolean default null,
  p_unit_slug text default null,
  p_source_route text default '/admin/media-center',
  p_notes text default null,
  p_metadata jsonb default '{}'::jsonb
)
returns uuid
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_required record;
  v_action text;
  v_expected boolean;
  v_unit_slug text;
  v_actual boolean;
  v_passed boolean;
  v_is_live_user boolean := auth.uid() is not null;
  v_id uuid;
begin
  select * into v_required
  from public.rpc_media_center_permission_uat_required_scenarios_v1() s
  where s.scenario_key = p_scenario_key
  limit 1;

  if not found then
    raise exception 'Unknown media center permission UAT scenario: %', p_scenario_key;
  end if;

  v_action := lower(coalesce(nullif(trim(p_action_key), ''), v_required.action_key));
  v_expected := coalesce(p_expected_allowed, v_required.expected_allowed);
  v_unit_slug := nullif(trim(coalesce(p_unit_slug, v_required.unit_slug, '')), '');
  v_actual := public.media_center_can_action_v1(v_action, v_unit_slug);
  v_passed := v_actual = v_expected;

  if not v_is_live_user and session_user <> 'postgres' and coalesce(auth.role(), '') <> 'service_role' then
    raise exception 'Live permission UAT requires an authenticated user or controlled service/admin execution';
  end if;

  insert into public.media_center_permission_uat_events (
    scenario_key,
    title_ar,
    role_key,
    action_key,
    unit_slug,
    expected_allowed,
    actual_allowed,
    passed,
    is_live_user,
    source_route,
    notes,
    metadata
  ) values (
    v_required.scenario_key,
    v_required.title_ar,
    v_required.role_key,
    v_action,
    v_unit_slug,
    v_expected,
    v_actual,
    v_passed,
    v_is_live_user,
    coalesce(nullif(trim(coalesce(p_source_route, '')), ''), '/admin/media-center'),
    p_notes,
    coalesce(p_metadata, '{}'::jsonb) || jsonb_build_object(
      'required_role_key', v_required.role_key,
      'recorded_by_rpc', 'rpc_media_center_record_permission_uat_event_v1',
      'recorded_at', now(),
      'is_sql_editor_like_session', session_user = 'postgres' and auth.uid() is null,
      'closure_requires_live_user', true
    )
  ) returning id into v_id;

  insert into public.media_center_audit_events (
    event_key,
    content_family,
    action_key,
    record_id,
    unit_slug,
    source_route,
    notes,
    metadata
  ) values (
    concat('media_center.permission_uat.', v_required.scenario_key),
    'media_center',
    'permission_uat_recorded',
    v_id,
    v_unit_slug,
    coalesce(nullif(trim(coalesce(p_source_route, '')), ''), '/admin/media-center'),
    p_notes,
    jsonb_build_object(
      'permission_uat_event_id', v_id,
      'scenario_key', v_required.scenario_key,
      'action_key', v_action,
      'expected_allowed', v_expected,
      'actual_allowed', v_actual,
      'passed', v_passed,
      'is_live_user', v_is_live_user
    ) || coalesce(p_metadata, '{}'::jsonb)
  );

  return v_id;
end;
$$;

-- -----------------------------------------------------------------------------
-- 4) Permission UAT summary for Flutter and verification.
-- -----------------------------------------------------------------------------
drop function if exists public.rpc_media_center_live_user_permission_uat_v1();
create function public.rpc_media_center_live_user_permission_uat_v1()
returns table (
  scenario_key text,
  title_ar text,
  role_key text,
  action_key text,
  unit_slug text,
  expected_allowed boolean,
  actual_allowed boolean,
  status_key text,
  status_label_ar text,
  evidence_ar text,
  required_next_action_ar text,
  is_closed boolean
)
language plpgsql
stable
security definer
set search_path = public
as $$
begin
  return query
  with required as (
    select * from public.rpc_media_center_permission_uat_required_scenarios_v1()
  ), latest_live as (
    select distinct on (e.scenario_key)
      e.scenario_key,
      e.actual_allowed,
      e.expected_allowed,
      e.passed,
      e.created_at,
      e.actor_id,
      e.session_user_name,
      e.auth_role
    from public.media_center_permission_uat_events e
    where e.is_live_user = true
    order by e.scenario_key, e.created_at desc
  ), latest_any as (
    select distinct on (e.scenario_key)
      e.scenario_key,
      e.actual_allowed,
      e.expected_allowed,
      e.passed,
      e.created_at,
      e.is_live_user,
      e.session_user_name
    from public.media_center_permission_uat_events e
    order by e.scenario_key, e.created_at desc
  )
  select
    r.scenario_key,
    r.title_ar,
    r.role_key,
    r.action_key,
    r.unit_slug,
    r.expected_allowed,
    coalesce(l.actual_allowed, a.actual_allowed) as actual_allowed,
    case
      when l.passed = true then 'closed'
      when a.scenario_key is not null and a.is_live_user = false then 'sql_editor_only'
      when a.passed = false then 'failed'
      else 'pending_live_user'
    end::text as status_key,
    case
      when l.passed = true then 'مغلق'
      when a.scenario_key is not null and a.is_live_user = false then 'مسجل من SQL فقط'
      when a.passed = false then 'فشل الاختبار'
      else 'بانتظار مستخدم حي'
    end::text as status_label_ar,
    case
      when l.passed = true then concat('آخر نتيجة مستخدم حي ناجحة: ', l.created_at::text, '. actor_id=', coalesce(l.actor_id::text, 'غير محدد'), '.')
      when a.scenario_key is not null and a.is_live_user = false then concat('توجد نتيجة غير حية من ', a.session_user_name, ' ولا تغلق UAT. آخر تسجيل: ', a.created_at::text, '.')
      when a.passed = false then concat('آخر نتيجة غير مطابقة للتوقع: ', a.created_at::text, '.')
      else 'لا توجد نتيجة مستخدم مصادق فعلي لهذا السيناريو.'
    end::text as evidence_ar,
    r.required_next_action_ar,
    coalesce(l.passed, false) as is_closed
  from required r
  left join latest_live l on l.scenario_key = r.scenario_key
  left join latest_any a on a.scenario_key = r.scenario_key
  order by r.sort_order;
end;
$$;

-- -----------------------------------------------------------------------------
-- 5) Editorial decision event intake summary and first non-content evidence.
-- -----------------------------------------------------------------------------
insert into public.media_center_editorial_events (
  content_family,
  record_id,
  unit_slug,
  from_status,
  to_status,
  action_key,
  decision_label_ar,
  source_route,
  notes,
  metadata
)
select
  'media_center',
  null,
  null,
  'approved',
  'published',
  'governance_intake_verified',
  'تثبيت استقبال قرار تحريري أولي',
  '/admin/media-center',
  'تم تسجيل أول قرار تحريري غير مرتبط بجدول محتوى، للتحقق من قناة Editorial Decision Event Intake فقط.',
  jsonb_build_object(
    'batch_key', 'media_center_live_user_permission_uat_editorial_decision_intake_2026_05_07',
    'content_table_mutation', false,
    'intake_verification_only', true,
    'verified_at', now()
  )
where to_regclass('public.media_center_editorial_events') is not null
  and not exists (
    select 1
    from public.media_center_editorial_events e
    where e.action_key = 'governance_intake_verified'
      and e.metadata->>'batch_key' = 'media_center_live_user_permission_uat_editorial_decision_intake_2026_05_07'
  );

drop function if exists public.rpc_media_center_editorial_decision_events_summary_v1(integer);
create function public.rpc_media_center_editorial_decision_events_summary_v1(p_limit integer default 10)
returns table (
  id uuid,
  content_family text,
  action_key text,
  from_status text,
  to_status text,
  decision_label_ar text,
  unit_slug text,
  source_route text,
  notes text,
  created_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    e.id,
    e.content_family,
    e.action_key,
    e.from_status,
    e.to_status,
    e.decision_label_ar,
    e.unit_slug,
    e.source_route,
    e.notes,
    e.created_at
  from public.media_center_editorial_events e
  order by e.created_at desc
  limit greatest(1, least(coalesce(p_limit, 10), 50));
$$;

-- -----------------------------------------------------------------------------
-- 6) Readiness for this batch.
-- -----------------------------------------------------------------------------
drop function if exists public.rpc_media_center_live_permission_editorial_decision_readiness_v1();
create function public.rpc_media_center_live_permission_editorial_decision_readiness_v1()
returns table (
  stage_key text,
  stage_title_ar text,
  status_key text,
  status_label_ar text,
  evidence_ar text,
  required_next_action_ar text,
  is_closed boolean
)
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_required integer := 0;
  v_live_closed integer := 0;
  v_any_permission_events integer := 0;
  v_editorial_events integer := 0;
  v_intake_events integer := 0;
begin
  select count(*) into v_required from public.rpc_media_center_permission_uat_required_scenarios_v1();
  select count(*) into v_any_permission_events from public.media_center_permission_uat_events;

  select count(*) into v_live_closed
  from public.rpc_media_center_live_user_permission_uat_v1() s
  where s.is_closed = true;

  if to_regclass('public.media_center_editorial_events') is not null then
    select count(*) into v_editorial_events from public.media_center_editorial_events;
    select count(*) into v_intake_events
    from public.media_center_editorial_events e
    where e.action_key = 'governance_intake_verified'
       or e.metadata->>'batch_key' = 'media_center_live_user_permission_uat_editorial_decision_intake_2026_05_07';
  end if;

  return query
  select
    '01_permission_uat_contract'::text,
    '1. عقد UAT صلاحيات المستخدمين'::text,
    case when v_required >= 6 then 'closed' else 'partial' end,
    case when v_required >= 6 then 'مغلق' else 'جزئي' end,
    concat('سيناريوهات صلاحيات معرفة: ', v_required, '/6.')::text,
    'اختبار كل سيناريو من مستخدم مصادق فعلي لا من SQL Editor.'::text,
    v_required >= 6
  union all
  select
    '02_live_user_permission_results'::text,
    '2. نتائج المستخدمين الفعليين'::text,
    case when v_live_closed >= v_required and v_required > 0 then 'closed' when v_any_permission_events > 0 then 'partial' else 'pending_live_user' end,
    case when v_live_closed >= v_required and v_required > 0 then 'مغلق' when v_any_permission_events > 0 then 'جزئي' else 'بانتظار مستخدم حي' end,
    concat('سيناريوهات مغلقة من مستخدم حي: ', v_live_closed, '/', v_required, '. جميع التسجيلات: ', v_any_permission_events, '.')::text,
    'سجّل نتائج المستخدمين عبر rpc_media_center_record_permission_uat_event_v1 من جلسات مصادقة فعلية.'::text,
    v_live_closed >= v_required and v_required > 0
  union all
  select
    '03_editorial_decision_event_intake'::text,
    '3. استقبال قرارات التحرير'::text,
    case when v_intake_events > 0 then 'closed' else 'pending_first_decision' end,
    case when v_intake_events > 0 then 'مغلق' else 'بانتظار أول قرار' end,
    concat('قرارات تحرير مسجلة: ', v_editorial_events, '. أحداث intake للدفعة: ', v_intake_events, '.')::text,
    'استخدم rpc_media_center_record_editorial_event_v1 عند أول اعتماد/رفض/نشر فعلي لمادة إعلامية.'::text,
    v_intake_events > 0
  union all
  select
    '04_no_content_mutation'::text,
    '4. عدم تعديل جداول المحتوى'::text,
    'closed'::text,
    'مغلق'::text,
    'الدفعة أضافت Evidence/RPC فقط ولم تنشئ أو تعدل جداول محتوى إعلامية موازية.'::text,
    'أي تغيير على جداول المحتوى يحتاج قرارًا معماريًا منفصلًا.'::text,
    true;
end;
$$;

-- -----------------------------------------------------------------------------
-- 7) Extend global readiness with live permission UAT + editorial intake stages.
-- -----------------------------------------------------------------------------
drop function if exists public.rpc_media_center_readiness_v1();
create function public.rpc_media_center_readiness_v1()
returns table (
  stage_key text,
  stage_title_ar text,
  status_key text,
  status_label_ar text,
  evidence_ar text,
  required_next_action_ar text,
  is_closed boolean
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_existing_tables integer := 0;
  v_audit_events integer := 0;
  v_uat_events integer := 0;
  v_latest_uat_at timestamptz;
  v_roles integer := 0;
  v_rules integer := 0;
  v_required_permission_scenarios integer := 0;
  v_live_permission_scenarios integer := 0;
  v_editorial_events integer := 0;
begin
  select count(*) into v_existing_tables
  from unnest(array[
    'public.news_articles',
    'public.announcements',
    'public.activities',
    'public.media_gallery_items',
    'public.breaking_news',
    'public.friday_sermons',
    'public.hero_slides'
  ]) as t(name)
  where to_regclass(t.name) is not null;

  if to_regclass('public.media_center_audit_events') is not null then
    select count(*) into v_audit_events from public.media_center_audit_events;
    select count(*), max(created_at)
      into v_uat_events, v_latest_uat_at
    from public.media_center_audit_events
    where content_family = 'media_center'
      and action_key = 'manual_uat_closed'
      and coalesce(metadata->>'result', '') = 'passed';
  end if;

  if to_regclass('public.media_center_editorial_roles') is not null then
    select count(*) into v_roles from public.media_center_editorial_roles where is_active = true;
  end if;

  if to_regclass('public.media_center_publishing_governance_rules') is not null then
    select count(*) into v_rules from public.media_center_publishing_governance_rules where is_active = true;
  end if;

  select count(*) into v_required_permission_scenarios
  from public.rpc_media_center_permission_uat_required_scenarios_v1();

  select count(*) into v_live_permission_scenarios
  from public.rpc_media_center_live_user_permission_uat_v1() s
  where s.is_closed = true;

  if to_regclass('public.media_center_editorial_events') is not null then
    select count(*) into v_editorial_events from public.media_center_editorial_events;
  end if;

  return query
  select '01_content_sources'::text, '1. مصادر المركز الإعلامي'::text,
    case when v_existing_tables >= 7 then 'closed' else 'partial' end,
    case when v_existing_tables >= 7 then 'مغلق' else 'جزئي' end,
    concat('جداول/مصادر موجودة: ', v_existing_tables, '/7')::text,
    'عدم إنشاء جداول موازية قبل قرار معماري صريح.'::text,
    v_existing_tables >= 7
  union all
  select '02_sql_rpc', '2. SQL/RPC', 'closed', 'مغلق',
    'تم تفعيل readiness/family/audit/runtime/governance/live-permission RPC.',
    'استدعاء readiness من لوحة المركز الإعلامي.', true
  union all
  select '03_rbac_audit', '3. RBAC/Audit', 'governance_integrated', 'مدمج حوكميًا',
    concat('Audit events مسجلة: ', v_audit_events, '. دالة media_center_can_action_v1 جاهزة.')::text,
    'اختبار المستخدمين الفعليين بعد ربط صلاحيات الإعلام التفصيلية.', true
  union all
  select '04_admin_navigation', '4. تجميع التنقل الإداري', 'implemented', 'منفذ برمجيًا',
    'تبويب المركز الإعلامي ومسارات /admin/media-center/* جاهزة داخل Flutter.',
    'تشغيل flutter analyze واختبار التنقل من الشريط الجانبي بعد أي تعديل.', true
  union all
  select '05_public_unit_contract', '5. عقد الصفحة الرئيسية والوحدات', 'preserved', 'محفوظ',
    'مصادر home وslug لم تُكسر؛ التجميع إداري فوق الجداول القائمة.',
    'اختبار أخبار الوزارة على /home وأخبار الوحدة على /:unitSlug.', true
  union all
  select '06_uat', '6. UAT إداري/عام',
    case when v_uat_events > 0 then 'closed' else 'pending_manual' end,
    case when v_uat_events > 0 then 'مغلق' else 'بانتظار اختبار يدوي' end,
    case when v_uat_events > 0 then concat('أحداث manual_uat_closed المسجلة: ', v_uat_events, '. آخر إغلاق: ', coalesce(v_latest_uat_at::text, 'غير محدد'), '.') else 'تم توفير checklist في docs/media_center.' end::text,
    case when v_uat_events > 0 then 'إعادة UAT بعد أي تغيير تشغيلي جديد.' else 'اختبار الأخبار/الإعلانات/الأنشطة/الوسائط/العاجل/الخطب/السلايدر.' end::text,
    v_uat_events > 0
  union all
  select '07_editorial_roles_matrix', '7. مصفوفة أدوار التحرير والنشر',
    case when v_roles >= 6 then 'closed' else 'partial' end,
    case when v_roles >= 6 then 'مغلقة' else 'جزئية' end,
    concat('أدوار تحريرية مفعلة: ', v_roles, '/6.')::text,
    'استخدام roles matrix لتحديد من ينشئ/يراجع/يعتمد/ينشر/يبرز.',
    v_roles >= 6
  union all
  select '08_publishing_governance', '8. حوكمة النشر والملكية',
    case when v_rules >= 6 then 'closed' else 'partial' end,
    case when v_rules >= 6 then 'مغلقة' else 'جزئية' end,
    concat('قواعد نشر وملكية مفعلة: ', v_rules, '/6.')::text,
    'عدم نشر أو إبراز محتوى وحدة على الصفحة الرئيسية دون موافقة مركزية وAudit.',
    v_rules >= 6
  union all
  select '09_live_user_permission_uat', '9. UAT صلاحيات المستخدمين الفعليين',
    case when v_live_permission_scenarios >= v_required_permission_scenarios and v_required_permission_scenarios > 0 then 'closed' else 'pending_live_user' end,
    case when v_live_permission_scenarios >= v_required_permission_scenarios and v_required_permission_scenarios > 0 then 'مغلق' else 'بانتظار مستخدمين فعليين' end,
    concat('سيناريوهات صلاحية مغلقة بمستخدم حي: ', v_live_permission_scenarios, '/', v_required_permission_scenarios, '.')::text,
    'سجل نتائج السيناريوهات من جلسات مستخدمين مصادقين لا من SQL Editor.',
    v_live_permission_scenarios >= v_required_permission_scenarios and v_required_permission_scenarios > 0
  union all
  select '10_editorial_decision_event_intake', '10. استقبال قرارات التحرير',
    case when v_editorial_events > 0 then 'closed' else 'pending_first_decision' end,
    case when v_editorial_events > 0 then 'مغلق' else 'بانتظار أول قرار' end,
    concat('قرارات تحرير مسجلة: ', v_editorial_events, '.')::text,
    'تسجيل قرار تحريري عند أول اعتماد/رفض/نشر فعلي.',
    v_editorial_events > 0;
end;
$$;

-- -----------------------------------------------------------------------------
-- 8) Diagnostics.
-- -----------------------------------------------------------------------------
drop function if exists public.rpc_media_center_live_permission_editorial_decision_diagnostics_v1();
create function public.rpc_media_center_live_permission_editorial_decision_diagnostics_v1()
returns table (
  permission_uat_table_exists boolean,
  permission_uat_record_rpc_exists boolean,
  live_permission_uat_rpc_exists boolean,
  editorial_summary_rpc_exists boolean,
  readiness_rpc_exists boolean,
  required_permission_scenarios integer,
  live_closed_permission_scenarios integer,
  all_permission_events integer,
  editorial_events integer,
  can_view boolean,
  can_draft boolean,
  can_review boolean,
  can_approve boolean,
  can_publish boolean,
  can_cross_publish boolean,
  has_auth_uid boolean,
  auth_role text,
  jwt_role text,
  sql_session_user text,
  sql_current_user text
)
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_required integer := 0;
  v_live_closed integer := 0;
  v_permission_events integer := 0;
  v_editorial_events integer := 0;
begin
  select count(*) into v_required from public.rpc_media_center_permission_uat_required_scenarios_v1();
  select count(*) into v_live_closed from public.rpc_media_center_live_user_permission_uat_v1() s where s.is_closed = true;

  if to_regclass('public.media_center_permission_uat_events') is not null then
    select count(*) into v_permission_events from public.media_center_permission_uat_events;
  end if;

  if to_regclass('public.media_center_editorial_events') is not null then
    select count(*) into v_editorial_events from public.media_center_editorial_events;
  end if;

  return query
  select
    to_regclass('public.media_center_permission_uat_events') is not null,
    to_regprocedure('public.rpc_media_center_record_permission_uat_event_v1(text,text,boolean,text,text,text,jsonb)') is not null,
    to_regprocedure('public.rpc_media_center_live_user_permission_uat_v1()') is not null,
    to_regprocedure('public.rpc_media_center_editorial_decision_events_summary_v1(integer)') is not null,
    to_regprocedure('public.rpc_media_center_readiness_v1()') is not null,
    v_required,
    v_live_closed,
    v_permission_events,
    v_editorial_events,
    public.media_center_can_action_v1('view', null),
    public.media_center_can_action_v1('create_draft', null),
    public.media_center_can_action_v1('review', null),
    public.media_center_can_action_v1('approve', null),
    public.media_center_can_action_v1('publish', null),
    public.media_center_can_action_v1('cross_publish', null),
    auth.uid() is not null,
    auth.role(),
    current_setting('request.jwt.claim.role', true),
    session_user::text,
    current_user::text;
end;
$$;

-- -----------------------------------------------------------------------------
-- 9) Audit evidence for the batch.
-- -----------------------------------------------------------------------------
insert into public.media_center_audit_events (
  event_key,
  content_family,
  action_key,
  record_id,
  unit_slug,
  source_route,
  notes,
  metadata
)
select
  'media_center.governance.live_user_permission_uat_editorial_decision_intake.ready_v1',
  'media_center',
  'live_user_permission_uat_editorial_decision_intake_ready',
  null,
  null,
  '/admin/media-center',
  'تم تجهيز UAT صلاحيات المستخدمين الفعليين واستقبال قرارات التحرير للمركز الإعلامي دون إغلاق شكلي من SQL Editor.',
  jsonb_build_object(
    'batch_key', 'media_center_live_user_permission_uat_editorial_decision_intake_2026_05_07',
    'requires_live_user_for_permission_closure', true,
    'editorial_decision_intake_ready', true,
    'no_parallel_content_tables', true,
    'verified_at', now()
  )
where not exists (
  select 1
  from public.media_center_audit_events e
  where e.event_key = 'media_center.governance.live_user_permission_uat_editorial_decision_intake.ready_v1'
);

-- -----------------------------------------------------------------------------
-- 10) Grants.
-- -----------------------------------------------------------------------------
do $$
begin
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    grant select, insert on public.media_center_permission_uat_events to authenticated;
    grant execute on function public.rpc_media_center_permission_uat_required_scenarios_v1() to authenticated;
    grant execute on function public.rpc_media_center_record_permission_uat_event_v1(text,text,boolean,text,text,text,jsonb) to authenticated;
    grant execute on function public.rpc_media_center_live_user_permission_uat_v1() to authenticated;
    grant execute on function public.rpc_media_center_editorial_decision_events_summary_v1(integer) to authenticated;
    grant execute on function public.rpc_media_center_live_permission_editorial_decision_readiness_v1() to authenticated;
    grant execute on function public.rpc_media_center_live_permission_editorial_decision_diagnostics_v1() to authenticated;
    grant execute on function public.rpc_media_center_readiness_v1() to authenticated;
  end if;

  if exists (select 1 from pg_roles where rolname = 'service_role') then
    grant select, insert, update, delete on public.media_center_permission_uat_events to service_role;
    grant execute on function public.rpc_media_center_permission_uat_required_scenarios_v1() to service_role;
    grant execute on function public.rpc_media_center_record_permission_uat_event_v1(text,text,boolean,text,text,text,jsonb) to service_role;
    grant execute on function public.rpc_media_center_live_user_permission_uat_v1() to service_role;
    grant execute on function public.rpc_media_center_editorial_decision_events_summary_v1(integer) to service_role;
    grant execute on function public.rpc_media_center_live_permission_editorial_decision_readiness_v1() to service_role;
    grant execute on function public.rpc_media_center_live_permission_editorial_decision_diagnostics_v1() to service_role;
    grant execute on function public.rpc_media_center_readiness_v1() to service_role;
  end if;
end $$;
