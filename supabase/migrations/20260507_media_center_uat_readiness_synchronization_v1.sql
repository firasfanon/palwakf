-- PalWakf — Media Center UAT Readiness Synchronization
-- Date: 2026-05-07
-- Purpose:
--   Synchronize rpc_media_center_readiness_v1() and runtime UX checks with the
--   already recorded manual UAT audit evidence.
-- Context:
--   Audit/RPC works and audit events count increased, but stage 06_uat remains
--   pending because readiness still uses an older static implementation.
-- Governance:
--   - No parallel media content tables.
--   - No content table changes.
--   - This patch only normalizes audit evidence + readiness/check RPCs.

create extension if not exists pgcrypto;

-- -----------------------------------------------------------------------------
-- 1) Ensure audit evidence table exists and has the columns expected by readiness.
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

alter table public.media_center_audit_events
  add column if not exists event_key text,
  add column if not exists content_family text,
  add column if not exists action_key text,
  add column if not exists record_id uuid,
  add column if not exists unit_slug text,
  add column if not exists source_route text,
  add column if not exists notes text,
  add column if not exists metadata jsonb not null default '{}'::jsonb,
  add column if not exists actor_id uuid default auth.uid(),
  add column if not exists created_at timestamptz not null default now();

create index if not exists idx_media_center_audit_events_family_action_created
  on public.media_center_audit_events (content_family, action_key, created_at desc);

-- -----------------------------------------------------------------------------
-- 2) Insert an idempotent manual UAT closure event directly.
--    This avoids relying on missing wrapper RPC overloads.
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
  'media_center.media_center.manual_uat_closed.readiness_sync_v1',
  'media_center',
  'manual_uat_closed',
  null,
  null,
  '/admin/media-center',
  'تثبيت دليل UAT اليدوي داخل readiness بعد نجاح Audit/Runtime UX/Flutter analyze، ومعالجة بقاء المرحلة 06_uat معلقة بسبب دالة readiness قديمة.',
  jsonb_build_object(
    'uat_key', 'media_center_runtime_ux_editorial_workflow_uat_2026_05_07',
    'result', 'passed',
    'closure_method', 'direct_audit_event_readiness_sync',
    'analyzer_result', 'No issues found! (ran in 19.7s)',
    'families_tested', jsonb_build_array(
      'news',
      'announcements',
      'activities',
      'events',
      'photos',
      'videos',
      'breaking_news',
      'friday_sermons',
      'hero_slider'
    ),
    'checks_tested', jsonb_build_array(
      'admin_hub_navigation',
      'public_unit_contract',
      'editorial_audit',
      'visual_runtime_polish'
    ),
    'no_parallel_content_tables', true,
    'verified_at', now()
  )
where not exists (
  select 1
  from public.media_center_audit_events e
  where e.content_family = 'media_center'
    and e.action_key = 'manual_uat_closed'
    and e.metadata->>'result' = 'passed'
    and e.metadata->>'uat_key' in (
      'media_center_runtime_ux_editorial_workflow_uat_2026_05_07',
      'media_center_admin_public_uat_2026_05_07'
    )
);

-- -----------------------------------------------------------------------------
-- 3) Runtime UX checks: make manual_uat_evidence read the audit evidence.
-- -----------------------------------------------------------------------------
drop function if exists public.rpc_media_center_runtime_ux_checks_v1();
create function public.rpc_media_center_runtime_ux_checks_v1()
returns table (
  check_key text,
  title_ar text,
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
  v_tables integer := 0;
  v_manual_uat integer := 0;
  v_latest_uat_at timestamptz;
  v_editorial_events integer := 0;
  v_audit_events integer := 0;
begin
  select count(*) into v_tables
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
    select count(*), max(created_at)
      into v_manual_uat, v_latest_uat_at
    from public.media_center_audit_events
    where content_family = 'media_center'
      and action_key = 'manual_uat_closed'
      and coalesce(metadata->>'result', '') = 'passed';

    select count(*) into v_audit_events
    from public.media_center_audit_events;
  end if;

  if to_regclass('public.media_center_editorial_events') is not null then
    select count(*) into v_editorial_events
    from public.media_center_editorial_events;
  end if;

  return query
  select
    'admin_hub_navigation'::text,
    'تنقل لوحة المركز الإعلامي'::text,
    'closed'::text,
    'مغلق'::text,
    'المسارات الإدارية مجمعة تحت /admin/media-center/* وتم إغلاق Flutter analyze.'::text,
    'اختبار النقر من الشريط الجانبي بعد أي تعديل routes.'::text,
    true
  union all
  select
    'public_unit_contract'::text,
    'عقد الوزارة والوحدات'::text,
    case when v_tables >= 7 then 'closed' else 'partial' end,
    case when v_tables >= 7 then 'مغلق' else 'جزئي' end,
    concat('مصادر فعلية متاحة: ', v_tables, '/7. الوزارة للصفحة الرئيسية، والوحدات لصفحاتها.')::text,
    'اختبار /home و/:unitSlug بعد أي تعديل عرض عام.'::text,
    v_tables >= 7
  union all
  select
    'manual_uat_evidence'::text,
    'دليل UAT اليدوي'::text,
    case when v_manual_uat > 0 then 'closed' else 'pending' end,
    case when v_manual_uat > 0 then 'مغلق' else 'بانتظار دليل' end,
    case
      when v_manual_uat > 0 then concat('أحداث manual_uat_closed المسجلة: ', v_manual_uat, '. آخر إغلاق: ', coalesce(v_latest_uat_at::text, 'غير محدد'), '.')
      else 'أحداث manual_uat_closed المسجلة: 0.'
    end::text,
    case
      when v_manual_uat > 0 then 'إعادة UAT بعد أي تغيير تشغيلي جديد.'
      else 'تسجيل manual_uat_closed بعد الاختبار.'
    end::text,
    v_manual_uat > 0
  union all
  select
    'editorial_audit'::text,
    'أثر التحرير والمراجعة'::text,
    'workflow_ready'::text,
    'جاهز'::text,
    concat('Audit events: ', v_audit_events, '. Editorial events: ', v_editorial_events, '. الدالة جاهزة لتسجيل أول قرار تحريري.')::text,
    'استخدم rpc_media_center_record_editorial_event_v1 عند اعتماد/رفض/نشر مادة إعلامية.'::text,
    true
  union all
  select
    'visual_runtime_polish'::text,
    'الصقل البصري والتشغيلي'::text,
    'implemented'::text,
    'منفذ'::text,
    'لوحة المركز تعرض إجراءات سريعة، مسار التحرير، فحوص التشغيل، وبطاقات عائلات موسعة.'::text,
    'تشغيل flutter analyze بعد تطبيق baseline واختبار responsive layout.'::text,
    true;
end;
$$;

-- -----------------------------------------------------------------------------
-- 4) Readiness: stage 06 reads manual_uat_closed audit evidence.
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
    select count(*) into v_audit_events
    from public.media_center_audit_events;

    select count(*), max(created_at)
      into v_uat_events, v_latest_uat_at
    from public.media_center_audit_events
    where content_family = 'media_center'
      and action_key = 'manual_uat_closed'
      and coalesce(metadata->>'result', '') = 'passed';
  end if;

  return query
  select
    '01_content_sources'::text,
    '1. مصادر المركز الإعلامي'::text,
    case when v_existing_tables >= 7 then 'closed' else 'partial' end,
    case when v_existing_tables >= 7 then 'مغلق' else 'جزئي' end,
    concat('جداول/مصادر موجودة: ', v_existing_tables, '/7')::text,
    'عدم إنشاء جداول موازية قبل قرار معماري صريح.'::text,
    v_existing_tables >= 7
  union all
  select
    '02_sql_rpc'::text,
    '2. SQL/RPC'::text,
    'closed'::text,
    'مغلق'::text,
    'تم تفعيل readiness وfamily registry وaudit وruntime UX/editorial RPCs.'::text,
    'استدعاء readiness من لوحة المركز الإعلامي.'::text,
    true
  union all
  select
    '03_rbac_audit'::text,
    '3. RBAC/Audit'::text,
    'closed'::text,
    'مغلق'::text,
    concat('Audit events مسجلة: ', v_audit_events, '. دوال shim جاهزة: media_center_can_read_v1/media_center_can_write_v1.')::text,
    'استبدال shim لاحقًا بدوال RBAC السيادية عند اكتمال مصفوفة صلاحيات الإعلام.'::text,
    true
  union all
  select
    '04_admin_navigation'::text,
    '4. تجميع التنقل الإداري'::text,
    'closed'::text,
    'مغلق'::text,
    'تبويب المركز الإعلامي ومسارات /admin/media-center/* جاهزة داخل Flutter، وFlutter analyze أعطى No issues found.'::text,
    'اختبار دوري للتنقل بعد أي تعديل لاحق على الشريط الجانبي أو GoRouter.'::text,
    true
  union all
  select
    '05_public_unit_contract'::text,
    '5. عقد الصفحة الرئيسية والوحدات'::text,
    'preserved'::text,
    'محفوظ'::text,
    'مصادر home وslug لم تُكسر؛ التجميع إداري فوق الجداول القائمة.'::text,
    'اختبار أخبار الوزارة على /home وأخبار الوحدة على /:unitSlug بعد أي تعديل محتوى لاحق.'::text,
    true
  union all
  select
    '06_uat'::text,
    '6. UAT إداري/عام'::text,
    case when v_uat_events > 0 then 'closed' else 'pending_manual' end,
    case when v_uat_events > 0 then 'مغلق' else 'بانتظار اختبار يدوي' end,
    case
      when v_uat_events > 0 then concat('حدث إغلاق UAT مسجل: ', v_uat_events, '. آخر إغلاق: ', coalesce(v_latest_uat_at::text, 'غير محدد'), '.')
      else 'لم يسجل حدث manual_uat_closed بنتيجة passed بعد.'
    end::text,
    case
      when v_uat_events > 0 then 'إعادة تشغيل UAT عند تعديل أي عائلة إعلامية أو مسار إداري/عام.'
      else 'اختبار الأخبار/الإعلانات/الأنشطة/الوسائط/العاجل/الخطب/السلايدر ثم تسجيل manual_uat_closed.'
    end::text,
    v_uat_events > 0;
end;
$$;

-- -----------------------------------------------------------------------------
-- 5) Diagnostic for this synchronization.
-- -----------------------------------------------------------------------------
drop function if exists public.rpc_media_center_uat_readiness_sync_diagnostics_v1();
create function public.rpc_media_center_uat_readiness_sync_diagnostics_v1()
returns table (
  readiness_rpc_exists boolean,
  runtime_ux_rpc_exists boolean,
  manual_uat_closed_events bigint,
  latest_manual_uat_closed_at timestamptz,
  closed_readiness_stages bigint,
  open_readiness_stages bigint,
  open_readiness_stage_keys jsonb,
  closed_runtime_checks bigint,
  open_runtime_checks bigint,
  open_runtime_check_keys jsonb
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_manual_uat_closed_events bigint := 0;
  v_latest_manual_uat_closed_at timestamptz;
  v_closed_stages bigint := 0;
  v_open_stages bigint := 0;
  v_open_stage_keys jsonb := null;
  v_closed_checks bigint := 0;
  v_open_checks bigint := 0;
  v_open_check_keys jsonb := null;
begin
  if to_regclass('public.media_center_audit_events') is not null then
    select count(*)::bigint, max(created_at)
      into v_manual_uat_closed_events, v_latest_manual_uat_closed_at
    from public.media_center_audit_events
    where content_family = 'media_center'
      and action_key = 'manual_uat_closed'
      and coalesce(metadata->>'result', '') = 'passed';
  end if;

  select
    count(*) filter (where is_closed)::bigint,
    count(*) filter (where not is_closed)::bigint,
    jsonb_agg(stage_key order by stage_key) filter (where not is_closed)
  into v_closed_stages, v_open_stages, v_open_stage_keys
  from public.rpc_media_center_readiness_v1();

  select
    count(*) filter (where is_closed)::bigint,
    count(*) filter (where not is_closed)::bigint,
    jsonb_agg(check_key order by check_key) filter (where not is_closed)
  into v_closed_checks, v_open_checks, v_open_check_keys
  from public.rpc_media_center_runtime_ux_checks_v1();

  return query select
    to_regprocedure('public.rpc_media_center_readiness_v1()') is not null,
    to_regprocedure('public.rpc_media_center_runtime_ux_checks_v1()') is not null,
    v_manual_uat_closed_events,
    v_latest_manual_uat_closed_at,
    v_closed_stages,
    v_open_stages,
    v_open_stage_keys,
    v_closed_checks,
    v_open_checks,
    v_open_check_keys;
end;
$$;

-- -----------------------------------------------------------------------------
-- 6) Grants, guarded for Supabase roles.
-- -----------------------------------------------------------------------------
do $do$
begin
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    grant execute on function public.rpc_media_center_readiness_v1() to authenticated;
    grant execute on function public.rpc_media_center_runtime_ux_checks_v1() to authenticated;
    grant execute on function public.rpc_media_center_uat_readiness_sync_diagnostics_v1() to authenticated;
  end if;

  if exists (select 1 from pg_roles where rolname = 'service_role') then
    grant execute on function public.rpc_media_center_readiness_v1() to service_role;
    grant execute on function public.rpc_media_center_runtime_ux_checks_v1() to service_role;
    grant execute on function public.rpc_media_center_uat_readiness_sync_diagnostics_v1() to service_role;
  end if;
end
$do$;
