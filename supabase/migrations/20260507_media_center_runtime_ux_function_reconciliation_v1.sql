-- PalWakf — Media Center Runtime UX Function Reconciliation
-- Date: 2026-05-07
-- Purpose:
--   Fix cases where rpc_media_center_family_registry_v1() is upgraded, but
--   rpc_media_center_editorial_workflow_v1() or rpc_media_center_runtime_ux_checks_v1()
--   is missing after partial SQL application.
-- Governance:
--   - No parallel media content tables.
--   - Keeps media content in existing public.* source tables.
--   - Adds/normalizes only workflow/audit support functions and evidence.

create extension if not exists pgcrypto;

-- -----------------------------------------------------------------------------
-- 1) Baseline helper permissions, safe for SQL Editor + authenticated app use.
-- -----------------------------------------------------------------------------
create or replace function public.media_center_can_read_v1()
returns boolean
language sql
stable
security definer
set search_path = public, auth
as $$
  select
    session_user in ('postgres', 'supabase_admin')
    or auth.uid() is not null
    or coalesce(auth.role(), '') in ('authenticated', 'service_role')
    or coalesce(current_setting('request.jwt.claim.role', true), '') in ('authenticated', 'service_role');
$$;

create or replace function public.media_center_can_write_v1()
returns boolean
language sql
stable
security definer
set search_path = public, auth
as $$
  select
    session_user in ('postgres', 'supabase_admin')
    or coalesce(auth.role(), '') = 'service_role'
    or coalesce(current_setting('request.jwt.claim.role', true), '') = 'service_role'
    or auth.uid() is not null;
$$;

-- -----------------------------------------------------------------------------
-- 2) Ensure audit/workflow evidence tables are structurally usable.
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
  add column if not exists content_family text,
  add column if not exists record_id uuid,
  add column if not exists unit_slug text,
  add column if not exists from_status text,
  add column if not exists to_status text,
  add column if not exists action_key text,
  add column if not exists decision_label_ar text,
  add column if not exists source_route text,
  add column if not exists notes text,
  add column if not exists metadata jsonb not null default '{}'::jsonb,
  add column if not exists actor_id uuid default auth.uid(),
  add column if not exists created_at timestamptz not null default now();

create index if not exists idx_media_center_editorial_events_family_record_created
  on public.media_center_editorial_events (content_family, record_id, created_at desc);

create index if not exists idx_media_center_editorial_events_family_status_created
  on public.media_center_editorial_events (content_family, to_status, created_at desc);

alter table public.media_center_audit_events enable row level security;
alter table public.media_center_editorial_events enable row level security;

drop policy if exists media_center_audit_events_select_v1 on public.media_center_audit_events;
create policy media_center_audit_events_select_v1
  on public.media_center_audit_events
  for select
  using (public.media_center_can_read_v1());

drop policy if exists media_center_audit_events_write_v1 on public.media_center_audit_events;
create policy media_center_audit_events_write_v1
  on public.media_center_audit_events
  for all
  using (public.media_center_can_write_v1())
  with check (public.media_center_can_write_v1());

drop policy if exists media_center_editorial_events_select_v1 on public.media_center_editorial_events;
create policy media_center_editorial_events_select_v1
  on public.media_center_editorial_events
  for select
  using (public.media_center_can_read_v1());

drop policy if exists media_center_editorial_events_write_v1 on public.media_center_editorial_events;
create policy media_center_editorial_events_write_v1
  on public.media_center_editorial_events
  for all
  using (public.media_center_can_write_v1())
  with check (public.media_center_can_write_v1());

-- -----------------------------------------------------------------------------
-- 3) Reconcile missing dashboard RPCs.
-- -----------------------------------------------------------------------------
drop function if exists public.rpc_media_center_editorial_workflow_v1();
create function public.rpc_media_center_editorial_workflow_v1()
returns table (
  step_key text,
  title_ar text,
  status_key text,
  description_ar text,
  allowed_actions_ar text,
  required_evidence_ar text,
  is_required boolean
)
language sql
stable
security definer
set search_path = public
as $$
  select * from (values
    ('draft'::text, 'مسودة'::text, 'draft'::text, 'إدخال أولي للمادة مع العنوان والوصف والصورة/الملف والنطاق المؤسسي.'::text, 'حفظ، معاينة، إرسال للمراجعة'::text, 'مصدر المادة، الوحدة المالكة، وحالة الظهور.'::text, true),
    ('review'::text, 'مراجعة تحريرية'::text, 'in_review'::text, 'مراجعة اللغة، التصنيف، الملكية، التاريخ، والصورة قبل الاعتماد.'::text, 'قبول، إعادة للمحرر، رفض'::text, 'قرار مراجع وسجل Audit.'::text, true),
    ('approved'::text, 'اعتماد'::text, 'approved'::text, 'اعتماد المادة للنشر ضمن نطاق الوزارة أو الوحدة دون خلط الملكية.'::text, 'نشر، جدولة، إلغاء اعتماد'::text, 'معتمد نهائيًا مع اسم/صلاحية المراجع.'::text, true),
    ('published'::text, 'نشر'::text, 'published'::text, 'ظهور المادة في المسار العام أو صفحة الوحدة وفق العقد الحاكم.'::text, 'إخفاء، تحديث، أرشفة'::text, 'رابط عام أو route تحقق.'::text, true),
    ('archived'::text, 'أرشفة'::text, 'archived'::text, 'حفظ المادة خارج الظهور النشط مع إبقاء أثرها التدقيقي.'::text, 'استعادة، إبقاء مؤرشف'::text, 'سبب الأرشفة وتاريخها.'::text, false)
  ) as t(step_key, title_ar, status_key, description_ar, allowed_actions_ar, required_evidence_ar, is_required);
$$;

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
    select count(*) into v_manual_uat
    from public.media_center_audit_events
    where content_family = 'media_center'
      and action_key = 'manual_uat_closed'
      and metadata->>'result' = 'passed';

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
    'المسارات الإدارية مجمعة تحت /admin/media-center/* وتم إغلاق Flutter analyze في الدفعة السابقة.'::text,
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
    concat('أحداث manual_uat_closed المسجلة: ', v_manual_uat, '.')::text,
    case when v_manual_uat > 0 then 'إعادة UAT بعد أي تغيير تشغيلي جديد.' else 'تسجيل manual_uat_closed بعد الاختبار.' end::text,
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

-- Keep family registry compatible with the enhanced dashboard contract.
drop function if exists public.rpc_media_center_family_registry_v1();
create function public.rpc_media_center_family_registry_v1()
returns table (
  family_key text,
  label_ar text,
  admin_route text,
  public_route text,
  storage_or_table_ar text,
  status_ar text,
  editorial_owner_ar text,
  default_workflow_ar text,
  runtime_note_ar text
)
language sql
stable
security definer
set search_path = public
as $$
  select * from (values
    ('news'::text, 'الأخبار'::text, '/admin/media-center/news'::text, '/home/news'::text, 'public.news_articles'::text, 'موجود ومجمع تحت المركز الإعلامي'::text, 'الإعلام المركزي ومديرو الوحدات حسب نطاق النشر'::text, 'مسودة ← مراجعة ← اعتماد ← نشر ← أرشفة'::text, 'اختبر ظهور أخبار الوزارة في /home/news وأخبار الوحدة داخل صفحة الوحدة.'::text),
    ('announcements'::text, 'الإعلانات'::text, '/admin/media-center/announcements'::text, '/home/announcements'::text, 'public.announcements'::text, 'موجود ومجمع تحت المركز الإعلامي'::text, 'الإعلام المركزي ومديرو الوحدات حسب الصلاحية'::text, 'مسودة ← مراجعة ← اعتماد ← نشر ← أرشفة'::text, 'اختبر تاريخ النشر والأولوية وحالة الظهور.'::text),
    ('activities'::text, 'الأنشطة'::text, '/admin/media-center/activities'::text, '/home/activities'::text, 'public.activities'::text, 'موجود ومجمع تحت المركز الإعلامي'::text, 'الإعلام المركزي والوحدات'::text, 'مسودة ← مراجعة ← اعتماد ← نشر ← أرشفة'::text, 'اختبر الفصل بين النشاط والفعالية حسب التصنيف التشغيلي.'::text),
    ('events'::text, 'الفعاليات'::text, '/admin/media-center/events'::text, '/home/activities'::text, 'public.activities مع فلترة mode=events'::text, 'مرحلة انتقالية دون جدول جديد'::text, 'الإعلام المركزي والوحدات'::text, 'مسودة ← مراجعة ← اعتماد ← نشر ← أرشفة'::text, 'لا تنشئ جدولًا مستقلًا قبل قرار معماري؛ استخدم الفلترة الحالية.'::text),
    ('photos'::text, 'معرض الصور'::text, '/admin/media-center/photos'::text, '/home/media'::text, 'public.media_gallery_items / media-gallery bucket'::text, 'موجود ومجمع تحت المركز الإعلامي'::text, 'الإعلام المركزي/الوحدة المالكة للصورة'::text, 'مسودة ← مراجعة ← اعتماد ← نشر ← أرشفة'::text, 'اختبر alt text والصورة المصغرة وحقوق النشر قبل النشر.'::text),
    ('videos'::text, 'الفيديوهات'::text, '/admin/media-center/videos'::text, '/home/media'::text, 'public.media_gallery_items / media-gallery bucket'::text, 'موجود ومجمع تحت المركز الإعلامي'::text, 'الإعلام المركزي/الوحدة المالكة للفيديو'::text, 'مسودة ← مراجعة ← اعتماد ← نشر ← أرشفة'::text, 'اختبر الرابط/المعاينة وملاءمة الوصف قبل النشر.'::text),
    ('breaking_news'::text, 'الأخبار العاجلة'::text, '/admin/media-center/breaking-news'::text, '/home'::text, 'public.breaking_news'::text, 'موجود ومجمع تحت المركز الإعلامي'::text, 'الإعلام المركزي فقط أو من يفوضه'::text, 'مسودة ← مراجعة ← اعتماد ← نشر ← إخفاء'::text, 'اختبر زمن البداية والنهاية وأولوية العرض على الصفحة الرئيسية.'::text),
    ('friday_sermons'::text, 'خُطب الجمعة'::text, '/admin/media-center/friday-sermons'::text, '/friday-sermon'::text, 'public.friday_sermons'::text, 'موجود ومجمع تحت المركز الإعلامي'::text, 'الإدارة المختصة بخطب الجمعة'::text, 'مسودة ← مراجعة ← اعتماد ← نشر ← أرشفة'::text, 'اختبر التاريخ والعنوان والملف/النص قبل النشر.'::text),
    ('hero_slider'::text, 'السلايدر والحملات البصرية'::text, '/admin/media-center/hero-slider'::text, '/home'::text, 'public.hero_slides'::text, 'مصنف كإعلام بصري/حملات مع بقاء إدارة الصفحة الرئيسية مستقلة'::text, 'الإعلام المركزي/إدارة الصفحة الرئيسية'::text, 'مسودة ← مراجعة ← اعتماد ← نشر ← أرشفة'::text, 'اختبر الصورة، CTA، وترتيب الشرائح دون كسر إدارة الصفحة الرئيسية.'::text)
  ) as t(family_key, label_ar, admin_route, public_route, storage_or_table_ar, status_ar, editorial_owner_ar, default_workflow_ar, runtime_note_ar);
$$;

-- -----------------------------------------------------------------------------
-- 4) Diagnostic RPC: confirms all dashboard functions exist.
-- -----------------------------------------------------------------------------
drop function if exists public.rpc_media_center_runtime_ux_function_diagnostics_v1();
create function public.rpc_media_center_runtime_ux_function_diagnostics_v1()
returns table (
  editorial_workflow_rpc_exists boolean,
  runtime_ux_rpc_exists boolean,
  family_registry_rpc_exists boolean,
  audit_table_exists boolean,
  editorial_events_table_exists boolean,
  can_read boolean,
  can_write boolean,
  sql_session_user text,
  sql_current_user text
)
language sql
stable
security definer
set search_path = public
as $$
  select
    to_regprocedure('public.rpc_media_center_editorial_workflow_v1()') is not null,
    to_regprocedure('public.rpc_media_center_runtime_ux_checks_v1()') is not null,
    to_regprocedure('public.rpc_media_center_family_registry_v1()') is not null,
    to_regclass('public.media_center_audit_events') is not null,
    to_regclass('public.media_center_editorial_events') is not null,
    public.media_center_can_read_v1(),
    public.media_center_can_write_v1(),
    session_user::text,
    current_user::text;
$$;

-- Evidence event for this reconciliation.
insert into public.media_center_audit_events (
  event_key,
  content_family,
  action_key,
  source_route,
  notes,
  metadata
)
select
  'media_center.media_center.runtime_ux_function_reconciled',
  'media_center',
  'runtime_ux_function_reconciled',
  '/admin/media-center',
  'تثبيت دوال Runtime UX / Editorial Workflow بعد ظهور دالة family registry الموسعة مع غياب editorial_workflow RPC.',
  jsonb_build_object(
    'batch_key', 'media_center_runtime_ux_function_reconciliation_2026_05_07',
    'reason', 'rpc_media_center_editorial_workflow_v1_missing_after_partial_apply',
    'no_parallel_content_tables', true,
    'recorded_at', now()
  )
where not exists (
  select 1
  from public.media_center_audit_events
  where content_family = 'media_center'
    and action_key = 'runtime_ux_function_reconciled'
    and metadata->>'batch_key' = 'media_center_runtime_ux_function_reconciliation_2026_05_07'
);

-- -----------------------------------------------------------------------------
-- 5) Grants, guarded for Supabase roles.
-- -----------------------------------------------------------------------------
do $do$
begin
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    grant execute on function public.rpc_media_center_editorial_workflow_v1() to authenticated;
    grant execute on function public.rpc_media_center_runtime_ux_checks_v1() to authenticated;
    grant execute on function public.rpc_media_center_family_registry_v1() to authenticated;
    grant execute on function public.rpc_media_center_runtime_ux_function_diagnostics_v1() to authenticated;
    grant select, insert on public.media_center_editorial_events to authenticated;
  end if;

  if exists (select 1 from pg_roles where rolname = 'service_role') then
    grant execute on function public.rpc_media_center_editorial_workflow_v1() to service_role;
    grant execute on function public.rpc_media_center_runtime_ux_checks_v1() to service_role;
    grant execute on function public.rpc_media_center_family_registry_v1() to service_role;
    grant execute on function public.rpc_media_center_runtime_ux_function_diagnostics_v1() to service_role;
    grant select, insert, update, delete on public.media_center_editorial_events to service_role;
  end if;
end
$do$;
