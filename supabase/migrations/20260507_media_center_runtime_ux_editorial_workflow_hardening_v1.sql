-- PalWakf — Media Center Runtime UX Polishing + Editorial Workflow Hardening
-- Date: 2026-05-07
-- Scope:
--   1) Adds editorial workflow evidence without creating parallel media-content tables.
--   2) Adds runtime UX check RPCs for the Media Center dashboard.
--   3) Extends the family registry with operational ownership/workflow notes.
--   4) Preserves existing public/home/unit contracts and previously closed UAT readiness.

create extension if not exists pgcrypto;

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
  created_at timestamptz not null default now(),
  constraint media_center_editorial_events_family_check check (
    content_family in (
      'news',
      'announcements',
      'activities',
      'events',
      'photos',
      'videos',
      'breaking_news',
      'friday_sermons',
      'hero_slider',
      'media_center'
    )
  ),
  constraint media_center_editorial_events_to_status_check check (
    to_status in ('draft', 'in_review', 'needs_revision', 'approved', 'scheduled', 'published', 'hidden', 'rejected', 'archived')
  )
);

create index if not exists idx_media_center_editorial_events_family_record_created
  on public.media_center_editorial_events (content_family, record_id, created_at desc);

create index if not exists idx_media_center_editorial_events_family_status_created
  on public.media_center_editorial_events (content_family, to_status, created_at desc);

alter table public.media_center_editorial_events enable row level security;

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

drop function if exists public.rpc_media_center_record_editorial_event_v1(text, uuid, text, text, text, text, text, text, text, jsonb);
create function public.rpc_media_center_record_editorial_event_v1(
  p_content_family text,
  p_record_id uuid default null,
  p_unit_slug text default null,
  p_from_status text default null,
  p_to_status text default 'in_review',
  p_action_key text default 'workflow_update',
  p_decision_label_ar text default 'تحديث تحريري',
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
  v_id uuid;
  v_family text := lower(trim(coalesce(p_content_family, 'media_center')));
  v_to_status text := lower(trim(coalesce(p_to_status, 'in_review')));
begin
  if not public.media_center_can_write_v1() then
    raise exception 'Not allowed to record media center editorial event';
  end if;

  if v_family not in ('news', 'announcements', 'activities', 'events', 'photos', 'videos', 'breaking_news', 'friday_sermons', 'hero_slider', 'media_center') then
    raise exception 'Unsupported media center content family: %', v_family;
  end if;

  if v_to_status not in ('draft', 'in_review', 'needs_revision', 'approved', 'scheduled', 'published', 'hidden', 'rejected', 'archived') then
    raise exception 'Unsupported media center workflow status: %', v_to_status;
  end if;

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
  ) values (
    v_family,
    p_record_id,
    nullif(trim(coalesce(p_unit_slug, '')), ''),
    nullif(lower(trim(coalesce(p_from_status, ''))), ''),
    v_to_status,
    lower(trim(coalesce(p_action_key, 'workflow_update'))),
    coalesce(nullif(trim(coalesce(p_decision_label_ar, '')), ''), 'تحديث تحريري'),
    coalesce(nullif(trim(coalesce(p_source_route, '')), ''), '/admin/media-center'),
    p_notes,
    coalesce(p_metadata, '{}'::jsonb) || jsonb_build_object(
      'recorded_by_rpc', 'rpc_media_center_record_editorial_event_v1',
      'recorded_at', now()
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
    concat('media_center.', v_family, '.', lower(trim(coalesce(p_action_key, 'workflow_update')))),
    v_family,
    lower(trim(coalesce(p_action_key, 'workflow_update'))),
    p_record_id,
    nullif(trim(coalesce(p_unit_slug, '')), ''),
    coalesce(nullif(trim(coalesce(p_source_route, '')), ''), '/admin/media-center'),
    p_notes,
    coalesce(p_metadata, '{}'::jsonb) || jsonb_build_object(
      'editorial_event_id', v_id,
      'from_status', nullif(lower(trim(coalesce(p_from_status, ''))), ''),
      'to_status', v_to_status,
      'decision_label_ar', coalesce(nullif(trim(coalesce(p_decision_label_ar, '')), ''), 'تحديث تحريري')
    )
  );

  return v_id;
end;
$$;

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
  values
    ('draft', 'مسودة', 'draft', 'إدخال أولي للمادة مع العنوان والوصف والصورة/الملف والنطاق المؤسسي.', 'حفظ، معاينة، إرسال للمراجعة', 'مصدر المادة، الوحدة المالكة، وحالة الظهور.', true),
    ('review', 'مراجعة تحريرية', 'in_review', 'مراجعة اللغة، التصنيف، الملكية، التاريخ، والصورة قبل الاعتماد.', 'قبول، إعادة للمحرر، رفض', 'قرار مراجع وسجل Audit.', true),
    ('approved', 'اعتماد', 'approved', 'اعتماد المادة للنشر ضمن نطاق الوزارة أو الوحدة دون خلط الملكية.', 'نشر، جدولة، إلغاء اعتماد', 'معتمد نهائيًا مع اسم/صلاحية المراجع.', true),
    ('published', 'نشر', 'published', 'ظهور المادة في المسار العام أو صفحة الوحدة وفق العقد الحاكم.', 'إخفاء، تحديث، أرشفة', 'رابط عام أو route تحقق.', true),
    ('archived', 'أرشفة', 'archived', 'حفظ المادة خارج الظهور النشط مع إبقاء أثرها التدقيقي.', 'استعادة، إبقاء مؤرشف', 'سبب الأرشفة وتاريخها.', false);
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
  v_tables integer;
  v_manual_uat integer;
  v_editorial_events integer;
  v_audit_events integer;
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

  select count(*) into v_manual_uat
  from public.media_center_audit_events
  where content_family = 'media_center'
    and action_key = 'manual_uat_closed'
    and metadata->>'result' = 'passed';

  select count(*) into v_audit_events from public.media_center_audit_events;
  select count(*) into v_editorial_events from public.media_center_editorial_events;

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
    concat('مصادر فعلية متاحة: ', v_tables, '/7. الوزارة للصفحة الرئيسية، والوحدات لصفحاتها.'),
    'اختبار /home و/:unitSlug بعد أي تعديل عرض عام.'::text,
    v_tables >= 7
  union all
  select
    'manual_uat_evidence'::text,
    'دليل UAT اليدوي'::text,
    case when v_manual_uat > 0 then 'closed' else 'pending' end,
    case when v_manual_uat > 0 then 'مغلق' else 'بانتظار دليل' end,
    concat('أحداث manual_uat_closed المسجلة: ', v_manual_uat, '.'),
    case when v_manual_uat > 0 then 'إعادة UAT بعد أي تغيير تشغيلي جديد.' else 'تسجيل manual_uat_closed بعد الاختبار.' end,
    v_manual_uat > 0
  union all
  select
    'editorial_audit'::text,
    'أثر التحرير والمراجعة'::text,
    'workflow_ready'::text,
    'جاهز'::text,
    concat('Audit events: ', v_audit_events, '. Editorial events: ', v_editorial_events, '. الدالة جاهزة لتسجيل أول قرار تحريري.'),
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
  values
    ('news', 'الأخبار', '/admin/media-center/news', '/home/news', 'public.news_articles', 'موجود ومجمع تحت المركز الإعلامي', 'الإعلام المركزي ومديرو الوحدات حسب نطاق النشر', 'مسودة ← مراجعة ← اعتماد ← نشر ← أرشفة', 'اختبر ظهور أخبار الوزارة في /home/news وأخبار الوحدة داخل صفحة الوحدة.'),
    ('announcements', 'الإعلانات', '/admin/media-center/announcements', '/home/announcements', 'public.announcements', 'موجود ومجمع تحت المركز الإعلامي', 'الإعلام المركزي ومديرو الوحدات حسب الصلاحية', 'مسودة ← مراجعة ← اعتماد ← نشر ← أرشفة', 'اختبر تاريخ النشر والأولوية وحالة الظهور.'),
    ('activities', 'الأنشطة', '/admin/media-center/activities', '/home/activities', 'public.activities', 'موجود ومجمع تحت المركز الإعلامي', 'الإعلام المركزي والوحدات', 'مسودة ← مراجعة ← اعتماد ← نشر ← أرشفة', 'اختبر الفصل بين النشاط والفعالية حسب التصنيف التشغيلي.'),
    ('events', 'الفعاليات', '/admin/media-center/events', '/home/activities', 'public.activities مع فلترة mode=events', 'مرحلة انتقالية دون جدول جديد', 'الإعلام المركزي والوحدات', 'مسودة ← مراجعة ← اعتماد ← نشر ← أرشفة', 'لا تنشئ جدولًا مستقلًا قبل قرار معماري؛ استخدم الفلترة الحالية.'),
    ('photos', 'معرض الصور', '/admin/media-center/photos', '/home/media', 'public.media_gallery_items / media-gallery bucket', 'موجود ومجمع تحت المركز الإعلامي', 'الإعلام المركزي/الوحدة المالكة للصورة', 'مسودة ← مراجعة ← اعتماد ← نشر ← أرشفة', 'اختبر alt text والصورة المصغرة وحقوق النشر قبل النشر.'),
    ('videos', 'الفيديوهات', '/admin/media-center/videos', '/home/media', 'public.media_gallery_items / media-gallery bucket', 'موجود ومجمع تحت المركز الإعلامي', 'الإعلام المركزي/الوحدة المالكة للفيديو', 'مسودة ← مراجعة ← اعتماد ← نشر ← أرشفة', 'اختبر الرابط/المعاينة وملاءمة الوصف قبل النشر.'),
    ('breaking_news', 'الأخبار العاجلة', '/admin/media-center/breaking-news', '/home', 'public.breaking_news', 'موجود ومجمع تحت المركز الإعلامي', 'الإعلام المركزي فقط أو من يفوضه', 'مسودة ← مراجعة ← اعتماد ← نشر ← إخفاء', 'اختبر زمن البداية والنهاية وأولوية العرض على الصفحة الرئيسية.'),
    ('friday_sermons', 'خُطب الجمعة', '/admin/media-center/friday-sermons', '/friday-sermon', 'public.friday_sermons', 'موجود ومجمع تحت المركز الإعلامي', 'الإدارة المختصة بخطب الجمعة', 'مسودة ← مراجعة ← اعتماد ← نشر ← أرشفة', 'اختبر التاريخ والعنوان والملف/النص قبل النشر.'),
    ('hero_slider', 'السلايدر والحملات البصرية', '/admin/media-center/hero-slider', '/home', 'public.hero_slides', 'مصنف كإعلام بصري/حملات مع بقاء إدارة الصفحة الرئيسية مستقلة', 'الإعلام المركزي/إدارة الصفحة الرئيسية', 'مسودة ← مراجعة ← اعتماد ← نشر ← أرشفة', 'اختبر الصورة، CTA، وترتيب الشرائح دون كسر إدارة الصفحة الرئيسية.');
$$;

insert into public.media_center_audit_events (
  event_key,
  content_family,
  action_key,
  source_route,
  notes,
  metadata
)
select
  'media_center.media_center.runtime_ux_editorial_workflow_hardened',
  'media_center',
  'runtime_ux_editorial_workflow_hardened',
  '/admin/media-center',
  'تسجيل Evidence لتطوير صقل تجربة تشغيل المركز الإعلامي وتقوية سير التحرير دون إنشاء جداول محتوى موازية.',
  jsonb_build_object(
    'batch_key', 'media_center_runtime_ux_polishing_editorial_workflow_hardening_2026_05_07',
    'scope', jsonb_build_array('runtime_ux', 'editorial_workflow', 'family_registry_extension', 'dashboard_polishing'),
    'governance', 'no_parallel_media_content_tables',
    'recorded_at', now()
  )
where not exists (
  select 1
  from public.media_center_audit_events
  where content_family = 'media_center'
    and action_key = 'runtime_ux_editorial_workflow_hardened'
    and metadata->>'batch_key' = 'media_center_runtime_ux_polishing_editorial_workflow_hardening_2026_05_07'
);

do $do$
begin
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    grant execute on function public.rpc_media_center_record_editorial_event_v1(text, uuid, text, text, text, text, text, text, text, jsonb) to authenticated;
    grant execute on function public.rpc_media_center_editorial_workflow_v1() to authenticated;
    grant execute on function public.rpc_media_center_runtime_ux_checks_v1() to authenticated;
    grant execute on function public.rpc_media_center_family_registry_v1() to authenticated;
    grant select, insert on public.media_center_editorial_events to authenticated;
  end if;

  if exists (select 1 from pg_roles where rolname = 'service_role') then
    grant execute on function public.rpc_media_center_record_editorial_event_v1(text, uuid, text, text, text, text, text, text, text, jsonb) to service_role;
    grant execute on function public.rpc_media_center_editorial_workflow_v1() to service_role;
    grant execute on function public.rpc_media_center_runtime_ux_checks_v1() to service_role;
    grant execute on function public.rpc_media_center_family_registry_v1() to service_role;
    grant select, insert, update, delete on public.media_center_editorial_events to service_role;
  end if;
end
$do$;
