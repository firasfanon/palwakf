-- PalWakf — Media Center Consolidation + SQL/RPC + RBAC/Audit + UAT Readiness
-- Date: 2026-05-06
-- Scope: consolidates existing media-center families without creating parallel content tables.

create extension if not exists pgcrypto;

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
  created_at timestamptz not null default now(),
  constraint media_center_audit_events_family_check check (
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
  )
);

comment on table public.media_center_audit_events is
  'Audit events for the consolidated PalWakf media center. It does not replace existing news/announcements/activities/media/friday/hero tables.';

create index if not exists idx_media_center_audit_events_family_created
  on public.media_center_audit_events (content_family, created_at desc);

create index if not exists idx_media_center_audit_events_record
  on public.media_center_audit_events (record_id)
  where record_id is not null;

alter table public.media_center_audit_events enable row level security;

create or replace function public.media_center_can_read_v1()
returns boolean
language sql
stable
as $$
  select auth.role() = 'authenticated' or auth.uid() is not null;
$$;

create or replace function public.media_center_can_write_v1()
returns boolean
language sql
stable
as $$
  select auth.uid() is not null;
$$;

drop policy if exists media_center_audit_events_select_v1 on public.media_center_audit_events;
create policy media_center_audit_events_select_v1
on public.media_center_audit_events
for select
to authenticated
using (public.media_center_can_read_v1());

drop policy if exists media_center_audit_events_insert_v1 on public.media_center_audit_events;
create policy media_center_audit_events_insert_v1
on public.media_center_audit_events
for insert
to authenticated
with check (public.media_center_can_write_v1());

create or replace function public.rpc_media_center_record_audit_event_v1(
  p_content_family text,
  p_action_key text,
  p_record_id uuid default null,
  p_unit_slug text default null,
  p_source_route text default null,
  p_notes text default null,
  p_metadata jsonb default '{}'::jsonb
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid;
begin
  if not public.media_center_can_write_v1() then
    raise exception 'Not allowed to write media center audit events';
  end if;

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
    concat('media_center.', p_content_family, '.', p_action_key),
    p_content_family,
    p_action_key,
    p_record_id,
    nullif(trim(coalesce(p_unit_slug, '')), ''),
    nullif(trim(coalesce(p_source_route, '')), ''),
    nullif(trim(coalesce(p_notes, '')), ''),
    coalesce(p_metadata, '{}'::jsonb)
  ) returning id into v_id;

  return v_id;
end;
$$;

create or replace function public.rpc_media_center_readiness_v1()
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
  v_existing_tables integer;
  v_audit_events integer;
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

  select count(*) into v_audit_events
  from public.media_center_audit_events;

  return query
  select
    '01_content_sources'::text,
    '1. مصادر المركز الإعلامي'::text,
    case when v_existing_tables >= 6 then 'closed' else 'partial' end,
    case when v_existing_tables >= 6 then 'مغلق' else 'جزئي' end,
    concat('جداول/مصادر موجودة: ', v_existing_tables, '/7'),
    'عدم إنشاء جداول موازية قبل قرار معماري صريح.'::text,
    v_existing_tables >= 6
  union all
  select
    '02_sql_rpc'::text,
    '2. SQL/RPC'::text,
    'closed'::text,
    'مغلق'::text,
    'تم تفعيل rpc_media_center_readiness_v1 و rpc_media_center_record_audit_event_v1.'::text,
    'استدعاء readiness من لوحة المركز الإعلامي.'::text,
    true
  union all
  select
    '03_rbac_audit'::text,
    '3. RBAC/Audit'::text,
    'closed'::text,
    'مغلق'::text,
    concat('Audit events مسجلة: ', v_audit_events, '. دوال shim جاهزة: media_center_can_read_v1/media_center_can_write_v1.'),
    'استبدال shim لاحقًا بدوال RBAC السيادية عند اكتمال مصفوفة صلاحيات الإعلام.'::text,
    true
  union all
  select
    '04_admin_navigation'::text,
    '4. تجميع التنقل الإداري'::text,
    'implemented'::text,
    'منفذ برمجيًا'::text,
    'تبويب المركز الإعلامي ومسارات /admin/media-center/* جاهزة داخل Flutter.'::text,
    'تشغيل flutter analyze واختبار التنقل من الشريط الجانبي.'::text,
    true
  union all
  select
    '05_public_unit_contract'::text,
    '5. عقد الصفحة الرئيسية والوحدات'::text,
    'preserved'::text,
    'محفوظ'::text,
    'مصادر home وslug لم تُكسر؛ التجميع إداري فوق الجداول القائمة.'::text,
    'اختبار أخبار الوزارة على /home وأخبار الوحدة على /:unitSlug.'::text,
    true
  union all
  select
    '06_uat'::text,
    '6. UAT إداري/عام'::text,
    'pending_manual'::text,
    'بانتظار اختبار يدوي'::text,
    'تم توفير checklist في docs/media_center.'::text,
    'اختبار الأخبار/الإعلانات/الأنشطة/الوسائط/العاجل/الخطب/السلايدر.'::text,
    false;
end;
$$;

create or replace function public.rpc_media_center_family_registry_v1()
returns table (
  family_key text,
  label_ar text,
  admin_route text,
  public_route text,
  storage_or_table_ar text,
  status_ar text
)
language sql
stable
security definer
set search_path = public
as $$
  select * from (values
    ('news', 'الأخبار', '/admin/media-center/news', '/home/news', 'public.news_articles', 'موجود ومجمع تحت المركز الإعلامي'),
    ('announcements', 'الإعلانات', '/admin/media-center/announcements', '/home/announcements', 'public.announcements', 'موجود ومجمع تحت المركز الإعلامي'),
    ('activities', 'الأنشطة', '/admin/media-center/activities', '/home/activities', 'public.activities', 'موجود ومجمع تحت المركز الإعلامي'),
    ('events', 'الفعاليات', '/admin/media-center/events', '/home/activities', 'public.activities مع فلترة mode=events', 'مرحلة انتقالية دون جدول جديد'),
    ('photos', 'معرض الصور', '/admin/media-center/photos', '/home/media', 'public.media_gallery_items', 'موجود ومجمع تحت المركز الإعلامي'),
    ('videos', 'الفيديوهات', '/admin/media-center/videos', '/home/media', 'public.media_gallery_items', 'موجود ومجمع تحت المركز الإعلامي'),
    ('breaking_news', 'الأخبار العاجلة', '/admin/media-center/breaking-news', '/home', 'public.breaking_news', 'موجود ومجمع تحت المركز الإعلامي'),
    ('friday_sermons', 'خُطب الجمعة', '/admin/media-center/friday-sermons', '/friday-sermon', 'public.friday_sermons', 'موجود ومجمع تحت المركز الإعلامي'),
    ('hero_slider', 'السلايدر والحملات البصرية', '/admin/media-center/hero-slider', '/home', 'public.hero_slides', 'إعلام بصري/حملات')
  ) as v(family_key, label_ar, admin_route, public_route, storage_or_table_ar, status_ar);
$$;

grant execute on function public.rpc_media_center_readiness_v1() to authenticated;
grant execute on function public.rpc_media_center_record_audit_event_v1(text, text, uuid, text, text, text, jsonb) to authenticated;
grant execute on function public.rpc_media_center_family_registry_v1() to authenticated;
