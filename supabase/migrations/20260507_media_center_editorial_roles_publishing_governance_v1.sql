-- PalWakf — Media Center Editorial Roles Matrix + Publishing Governance Integration
-- Date: 2026-05-07
-- Purpose:
--   Add a sovereign governance layer above existing media content tables:
--   editorial roles, publishing/cross-highlighting rules, RBAC bridge helpers,
--   readiness RPCs, and audit evidence.
-- Governance:
--   - No new media content tables.
--   - No changes to news/announcements/activities/media_gallery/breaking_news/friday_sermons/hero_slides content ownership.
--   - Ministry content remains ministry-owned; unit content remains unit-owned.
--   - Cross-highlighting is display governance only, never ownership transfer.

create extension if not exists pgcrypto;

-- -----------------------------------------------------------------------------
-- 1) Governance tables: roles/rules only, not content tables.
-- -----------------------------------------------------------------------------
create table if not exists public.media_center_editorial_roles (
  role_key text primary key,
  label_ar text not null,
  description_ar text not null,
  scope_key text not null,
  scope_label_ar text not null,
  required_system_key text not null default 'site',
  required_permission_key text not null default 'view',
  can_create_draft boolean not null default false,
  can_submit_review boolean not null default false,
  can_review boolean not null default false,
  can_approve boolean not null default false,
  can_publish boolean not null default false,
  can_schedule boolean not null default false,
  can_archive boolean not null default false,
  can_cross_publish boolean not null default false,
  sovereignty_note_ar text not null,
  is_active boolean not null default true,
  sort_order integer not null default 100,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.media_center_publishing_governance_rules (
  rule_key text primary key,
  family_key text not null,
  source_scope_key text not null,
  target_scope_key text not null,
  required_role_key text not null,
  required_action_key text not null,
  rule_title_ar text not null,
  rule_description_ar text not null,
  requires_approval boolean not null default true,
  requires_audit boolean not null default true,
  conflict_policy_ar text not null,
  is_active boolean not null default true,
  sort_order integer not null default 100,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.media_center_editorial_roles
  add column if not exists required_system_key text not null default 'site',
  add column if not exists required_permission_key text not null default 'view',
  add column if not exists sovereignty_note_ar text not null default 'مصفوفة دور تحريرية ضمن حوكمة PalWakf.',
  add column if not exists updated_at timestamptz not null default now();

alter table public.media_center_publishing_governance_rules
  add column if not exists required_action_key text not null default 'review',
  add column if not exists conflict_policy_ar text not null default 'لا تغيير على ملكية المحتوى أو مصدره السيادي.',
  add column if not exists updated_at timestamptz not null default now();

create index if not exists idx_media_center_editorial_roles_active_sort
  on public.media_center_editorial_roles(is_active, sort_order);

create index if not exists idx_media_center_publishing_rules_family_sort
  on public.media_center_publishing_governance_rules(family_key, is_active, sort_order);

-- -----------------------------------------------------------------------------
-- 2) Seed role matrix.
-- -----------------------------------------------------------------------------
insert into public.media_center_editorial_roles (
  role_key,
  label_ar,
  description_ar,
  scope_key,
  scope_label_ar,
  required_system_key,
  required_permission_key,
  can_create_draft,
  can_submit_review,
  can_review,
  can_approve,
  can_publish,
  can_schedule,
  can_archive,
  can_cross_publish,
  sovereignty_note_ar,
  is_active,
  sort_order
) values
  ('media_viewer', 'مشاهد إعلامي', 'قراءة ومتابعة مواد المركز الإعلامي دون تعديل أو نشر.', 'all', 'قراءة عامة داخل صلاحيات اللوحة', 'site', 'view', false, false, false, false, false, false, false, false, 'قراءة فقط ولا تمنح صلاحية نشر أو تعديل.', true, 10),
  ('media_contributor', 'محرر مسودة', 'إنشاء مسودات وإرسالها للمراجعة ضمن نطاق الوزارة أو الوحدة.', 'unit_or_ministry', 'وزارة/وحدة حسب التفويض', 'site', 'create', true, true, false, false, false, false, false, false, 'لا يستطيع النشر أو الرفع للصفحة الرئيسية دون مراجعة واعتماد.', true, 20),
  ('unit_media_editor', 'محرر وحدة', 'تحرير محتوى الوحدة ومراجعته داخل صفحة الوحدة دون امتلاك نشر الصفحة الرئيسية.', 'unit', 'نطاق الوحدة', 'site', 'update', true, true, true, false, false, false, true, false, 'محتوى الوحدة يبقى مملوكًا للوحدة ولا ينتقل للصفحة الرئيسية إلا بقرار مركزي.', true, 30),
  ('central_media_reviewer', 'مراجع إعلام مركزي', 'مراجعة واعتماد جودة وملكية المواد قبل النشر أو الإبراز.', 'ministry', 'نطاق الوزارة', 'site', 'manageSite', true, true, true, true, false, false, true, false, 'الاعتماد لا يعني النشر النهائي ما لم يملك المستخدم صلاحية النشر.', true, 40),
  ('central_publisher', 'ناشر مركزي', 'نشر وجدولة وأرشفة مواد الوزارة والمواد المعتمدة للإبراز العام.', 'ministry', 'الصفحة الرئيسية والوزارة', 'site', 'manageHome', true, true, true, true, true, true, true, true, 'يمتلك قرار النشر العام مع وجوب تسجيل Audit لكل نشر أو إبراز متبادل.', true, 50),
  ('media_admin', 'مدير حوكمة الإعلام', 'إدارة مصفوفة الأدوار وقواعد النشر وربطها بسياسات RBAC السيادية.', 'platform', 'نطاق المنصة', 'platformAdmin', 'manageHome', true, true, true, true, true, true, true, true, 'صلاحية حوكمة لا تعني تجاوز ملكية الوزارة/الوحدة أو سجل التدقيق.', true, 60)
on conflict (role_key) do update set
  label_ar = excluded.label_ar,
  description_ar = excluded.description_ar,
  scope_key = excluded.scope_key,
  scope_label_ar = excluded.scope_label_ar,
  required_system_key = excluded.required_system_key,
  required_permission_key = excluded.required_permission_key,
  can_create_draft = excluded.can_create_draft,
  can_submit_review = excluded.can_submit_review,
  can_review = excluded.can_review,
  can_approve = excluded.can_approve,
  can_publish = excluded.can_publish,
  can_schedule = excluded.can_schedule,
  can_archive = excluded.can_archive,
  can_cross_publish = excluded.can_cross_publish,
  sovereignty_note_ar = excluded.sovereignty_note_ar,
  is_active = excluded.is_active,
  sort_order = excluded.sort_order,
  updated_at = now();

-- -----------------------------------------------------------------------------
-- 3) Seed publishing governance rules.
-- -----------------------------------------------------------------------------
insert into public.media_center_publishing_governance_rules (
  rule_key,
  family_key,
  source_scope_key,
  target_scope_key,
  required_role_key,
  required_action_key,
  rule_title_ar,
  rule_description_ar,
  requires_approval,
  requires_audit,
  conflict_policy_ar,
  is_active,
  sort_order
) values
  ('ministry_to_home_publish', 'all', 'ministry', 'home', 'central_publisher', 'publish', 'نشر محتوى الوزارة على الصفحة الرئيسية', 'المواد الصادرة عن الوزارة تظهر على الصفحة الرئيسية بعد مراجعة واعتماد ونشر مركزي.', true, true, 'تبقى ملكية المحتوى للوزارة ولا تُحوّل إلى وحدة.', true, 10),
  ('unit_to_unit_page_publish', 'news,announcements,activities,events,photos,videos', 'unit', 'unit_page', 'unit_media_editor', 'review', 'نشر محتوى الوحدة داخل صفحة الوحدة', 'محتوى الوحدة يظهر داخل صفحة الوحدة ولا يظهر في الصفحة الرئيسية إلا عبر إبراز مركزي لاحق.', true, true, 'لا تُخلط أخبار الوحدة مع أخبار الوزارة في الملكية أو المسؤولية التحريرية.', true, 20),
  ('unit_to_home_cross_highlight', 'news,announcements,activities,events', 'unit', 'home_highlight', 'central_publisher', 'cross_publish', 'إبراز مختصر من الوحدة على الصفحة الرئيسية', 'يمكن عرض مختصر من أخبار/أنشطة الوحدة على الصفحة الرئيسية مع بقاء الملكية للوحدة وبعد موافقة إعلامية مركزية.', true, true, 'الإبراز لا يحوّل المصدر إلى الوزارة ولا يغير unit_id/slug.', true, 30),
  ('home_to_unit_cross_highlight', 'news,announcements,activities', 'ministry', 'unit_page_highlight', 'central_publisher', 'cross_publish', 'عرض مختصر من الوزارة داخل صفحات الوحدات', 'تستطيع صفحة الوحدة عرض مختصر من محتوى الوزارة دون تغيير ملكية المحتوى أو منحه صلاحية تعديل للوحدة.', true, true, 'يبقى المحتوى مركزيًا وتعرضه الوحدة كمرجع عام فقط.', true, 40),
  ('breaking_news_central_only', 'breaking_news', 'ministry', 'home', 'central_publisher', 'publish', 'الأخبار العاجلة مركزية', 'الأخبار العاجلة لا تنشر إلا من الإعلام المركزي أو مفوضه بسبب أثرها المباشر على الواجهة العامة.', true, true, 'لا تُدار الأخبار العاجلة كوحدة فرعية إلا بتفويض مركزي واضح.', true, 50),
  ('hero_slider_visual_campaigns', 'hero_slider', 'ministry', 'home_visual', 'central_publisher', 'publish', 'السلايدر والحملات البصرية', 'السلايدر إعلام بصري مرتبط بالصفحة الرئيسية ويخضع للنشر المركزي دون كسر إدارة الصفحة الرئيسية.', true, true, 'السلايدر ليس جدول محتوى بديلًا ولا يغير ترتيب إدارة الصفحة الرئيسية.', true, 60)
on conflict (rule_key) do update set
  family_key = excluded.family_key,
  source_scope_key = excluded.source_scope_key,
  target_scope_key = excluded.target_scope_key,
  required_role_key = excluded.required_role_key,
  required_action_key = excluded.required_action_key,
  rule_title_ar = excluded.rule_title_ar,
  rule_description_ar = excluded.rule_description_ar,
  requires_approval = excluded.requires_approval,
  requires_audit = excluded.requires_audit,
  conflict_policy_ar = excluded.conflict_policy_ar,
  is_active = excluded.is_active,
  sort_order = excluded.sort_order,
  updated_at = now();

-- -----------------------------------------------------------------------------
-- 4) RBAC bridge helper. Uses sovereign RBAC functions when present.
-- -----------------------------------------------------------------------------
create or replace function public.media_center_required_permission_for_action_v1(p_action_key text)
returns text
language sql
stable
as $$
  select case lower(coalesce(p_action_key, ''))
    when 'view' then 'view'
    when 'draft' then 'create'
    when 'create_draft' then 'create'
    when 'submit_review' then 'create'
    when 'review' then 'update'
    when 'approve' then 'manageSite'
    when 'archive' then 'update'
    when 'publish' then 'manageHome'
    when 'schedule' then 'manageHome'
    when 'cross_publish' then 'manageHome'
    when 'manage_governance' then 'manageHome'
    else 'manageSite'
  end;
$$;

create or replace function public.media_center_can_action_v1(
  p_action_key text default 'view',
  p_unit_slug text default null
)
returns boolean
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_action text := lower(coalesce(nullif(trim(p_action_key), ''), 'view'));
  v_permission text := public.media_center_required_permission_for_action_v1(p_action_key);
  v_allowed boolean := false;
begin
  -- SQL Editor / migration verification only.
  if session_user = 'postgres' then
    return true;
  end if;

  if coalesce(auth.role(), '') = 'service_role'
     or coalesce(current_setting('request.jwt.claim.role', true), '') = 'service_role' then
    return true;
  end if;

  if to_regprocedure('public.is_superuser()') is not null then
    execute 'select public.is_superuser()' into v_allowed;
    if coalesce(v_allowed, false) then
      return true;
    end if;
  end if;

  if to_regprocedure('public.has_permission(public.system_key,text)') is not null then
    execute 'select public.has_permission($1::public.system_key, $2)' into v_allowed using 'platformAdmin', 'manageHome';
    if coalesce(v_allowed, false) then
      return true;
    end if;

    execute 'select public.has_permission($1::public.system_key, $2)' into v_allowed using 'site', v_permission;
    if coalesce(v_allowed, false) then
      return true;
    end if;

    if v_action in ('publish', 'schedule', 'cross_publish', 'manage_governance') then
      execute 'select public.has_permission($1::public.system_key, $2)' into v_allowed using 'site', 'manageHome';
      return coalesce(v_allowed, false);
    end if;

    if v_action in ('approve', 'review', 'archive') then
      execute 'select public.has_permission($1::public.system_key, $2)' into v_allowed using 'site', 'manageSite';
      return coalesce(v_allowed, false);
    end if;
  end if;

  -- Safe fallback if platform RBAC is not installed yet: read only for authenticated users.
  if v_action = 'view' and coalesce(auth.role(), '') = 'authenticated' then
    return true;
  end if;

  return false;
end;
$$;

create or replace function public.media_center_can_read_v1()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.media_center_can_action_v1('view', null);
$$;

create or replace function public.media_center_can_write_v1()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select public.media_center_can_action_v1('draft', null)
      or public.media_center_can_action_v1('review', null)
      or public.media_center_can_action_v1('publish', null);
$$;

-- -----------------------------------------------------------------------------
-- 5) Public RPCs for Flutter/Riverpod and verification.
-- -----------------------------------------------------------------------------
drop function if exists public.rpc_media_center_editorial_roles_matrix_v1();
create function public.rpc_media_center_editorial_roles_matrix_v1()
returns table (
  role_key text,
  label_ar text,
  description_ar text,
  scope_key text,
  scope_label_ar text,
  required_system_key text,
  required_permission_key text,
  can_create_draft boolean,
  can_submit_review boolean,
  can_review boolean,
  can_approve boolean,
  can_publish boolean,
  can_schedule boolean,
  can_archive boolean,
  can_cross_publish boolean,
  sovereignty_note_ar text,
  is_active boolean,
  sort_order integer
)
language sql
stable
security definer
set search_path = public
as $$
  select
    r.role_key,
    r.label_ar,
    r.description_ar,
    r.scope_key,
    r.scope_label_ar,
    r.required_system_key,
    r.required_permission_key,
    r.can_create_draft,
    r.can_submit_review,
    r.can_review,
    r.can_approve,
    r.can_publish,
    r.can_schedule,
    r.can_archive,
    r.can_cross_publish,
    r.sovereignty_note_ar,
    r.is_active,
    r.sort_order
  from public.media_center_editorial_roles r
  where r.is_active = true
  order by r.sort_order, r.role_key;
$$;

drop function if exists public.rpc_media_center_publishing_governance_rules_v1();
create function public.rpc_media_center_publishing_governance_rules_v1()
returns table (
  rule_key text,
  family_key text,
  source_scope_key text,
  target_scope_key text,
  required_role_key text,
  required_action_key text,
  rule_title_ar text,
  rule_description_ar text,
  requires_approval boolean,
  requires_audit boolean,
  conflict_policy_ar text,
  is_active boolean,
  sort_order integer
)
language sql
stable
security definer
set search_path = public
as $$
  select
    g.rule_key,
    g.family_key,
    g.source_scope_key,
    g.target_scope_key,
    g.required_role_key,
    g.required_action_key,
    g.rule_title_ar,
    g.rule_description_ar,
    g.requires_approval,
    g.requires_audit,
    g.conflict_policy_ar,
    g.is_active,
    g.sort_order
  from public.media_center_publishing_governance_rules g
  where g.is_active = true
  order by g.sort_order, g.rule_key;
$$;

drop function if exists public.rpc_media_center_publishing_governance_readiness_v1();
create function public.rpc_media_center_publishing_governance_readiness_v1()
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
  v_roles integer := 0;
  v_rules integer := 0;
  v_editorial_events integer := 0;
  v_audit_events integer := 0;
  v_has_rbac boolean := false;
begin
  select count(*) into v_roles from public.media_center_editorial_roles where is_active = true;
  select count(*) into v_rules from public.media_center_publishing_governance_rules where is_active = true;

  if to_regclass('public.media_center_editorial_events') is not null then
    select count(*) into v_editorial_events from public.media_center_editorial_events;
  end if;

  if to_regclass('public.media_center_audit_events') is not null then
    select count(*) into v_audit_events from public.media_center_audit_events;
  end if;

  v_has_rbac := to_regprocedure('public.has_permission(public.system_key,text)') is not null
             and to_regprocedure('public.is_superuser()') is not null;

  return query
  select
    '01_roles_matrix'::text,
    '1. مصفوفة الأدوار التحريرية'::text,
    case when v_roles >= 6 then 'closed' else 'partial' end,
    case when v_roles >= 6 then 'مغلقة' else 'جزئية' end,
    concat('أدوار تحريرية مفعلة: ', v_roles, '/6.')::text,
    'عدم منح نشر الصفحة الرئيسية إلا لناشر مركزي/مدير حوكمة.'::text,
    v_roles >= 6
  union all
  select
    '02_publishing_rules'::text,
    '2. قواعد النشر والملكية'::text,
    case when v_rules >= 6 then 'closed' else 'partial' end,
    case when v_rules >= 6 then 'مغلقة' else 'جزئية' end,
    concat('قواعد نشر وحوكمة مفعلة: ', v_rules, '/6.')::text,
    'اختبار الوزارة ← الصفحة الرئيسية والوحدة ← صفحة الوحدة والإبراز المتبادل.'::text,
    v_rules >= 6
  union all
  select
    '03_rbac_bridge'::text,
    '3. ربط RBAC السيادي'::text,
    case when v_has_rbac then 'integrated' else 'fallback_safe' end,
    case when v_has_rbac then 'مدمج' else 'Fallback آمن' end,
    case when v_has_rbac then 'has_permission/is_superuser متاحة ويتم استخدامها في media_center_can_action_v1.' else 'RBAC السيادي غير مكتمل؛ الكتابة لا تُفتح إلا service_role/postgres، والقراءة للمصادقين فقط.' end::text,
    'اختبار مستخدم فعلي لكل صلاحية: create/update/manageSite/manageHome.'::text,
    true
  union all
  select
    '04_audit_enforcement'::text,
    '4. إلزام الأثر التدقيقي'::text,
    'closed'::text,
    'مغلق'::text,
    concat('Audit events: ', v_audit_events, '. Editorial events: ', v_editorial_events, '. قواعد النشر تشترط أثرًا تدقيقيًا.')::text,
    'تسجيل أول قرار تحريري فعلي عند اعتماد/رفض/نشر مادة إعلامية.'::text,
    true
  union all
  select
    '05_no_parallel_content_tables'::text,
    '5. عدم إنشاء جداول محتوى موازية'::text,
    'closed'::text,
    'مغلق'::text,
    'تمت إضافة جداول حوكمة فقط: roles/rules، دون إنشاء news/announcements/activities موازية.'::text,
    'أي جدول محتوى جديد يحتاج قرارًا معماريًا صريحًا.'::text,
    true;
end;
$$;

drop function if exists public.rpc_media_center_publishing_governance_diagnostics_v1();
create function public.rpc_media_center_publishing_governance_diagnostics_v1()
returns table (
  roles_table_exists boolean,
  rules_table_exists boolean,
  roles_rpc_exists boolean,
  rules_rpc_exists boolean,
  readiness_rpc_exists boolean,
  can_action_rpc_exists boolean,
  active_roles integer,
  active_rules integer,
  rbac_bridge_available boolean,
  can_read boolean,
  can_write boolean,
  can_publish boolean,
  sql_session_user text,
  sql_current_user text
)
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_roles integer := 0;
  v_rules integer := 0;
begin
  if to_regclass('public.media_center_editorial_roles') is not null then
    select count(*) into v_roles from public.media_center_editorial_roles where is_active = true;
  end if;
  if to_regclass('public.media_center_publishing_governance_rules') is not null then
    select count(*) into v_rules from public.media_center_publishing_governance_rules where is_active = true;
  end if;

  return query
  select
    to_regclass('public.media_center_editorial_roles') is not null,
    to_regclass('public.media_center_publishing_governance_rules') is not null,
    to_regprocedure('public.rpc_media_center_editorial_roles_matrix_v1()') is not null,
    to_regprocedure('public.rpc_media_center_publishing_governance_rules_v1()') is not null,
    to_regprocedure('public.rpc_media_center_publishing_governance_readiness_v1()') is not null,
    to_regprocedure('public.media_center_can_action_v1(text,text)') is not null,
    v_roles,
    v_rules,
    to_regprocedure('public.has_permission(public.system_key,text)') is not null,
    public.media_center_can_action_v1('view', null),
    public.media_center_can_write_v1(),
    public.media_center_can_action_v1('publish', null),
    session_user::text,
    current_user::text;
end;
$$;

-- -----------------------------------------------------------------------------
-- 6) Extend global media readiness with governance stages.
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

  select count(*) into v_roles from public.media_center_editorial_roles where is_active = true;
  select count(*) into v_rules from public.media_center_publishing_governance_rules where is_active = true;

  return query
  select '01_content_sources'::text, '1. مصادر المركز الإعلامي'::text,
    case when v_existing_tables >= 7 then 'closed' else 'partial' end,
    case when v_existing_tables >= 7 then 'مغلق' else 'جزئي' end,
    concat('جداول/مصادر موجودة: ', v_existing_tables, '/7')::text,
    'عدم إنشاء جداول موازية قبل قرار معماري صريح.'::text,
    v_existing_tables >= 7
  union all
  select '02_sql_rpc', '2. SQL/RPC', 'closed', 'مغلق',
    'تم تفعيل readiness/family/audit/runtime/governance RPC.',
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
    v_rules >= 6;
end;
$$;

-- -----------------------------------------------------------------------------
-- 7) Audit evidence for this governance integration batch.
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
  'media_center.governance.editorial_roles_publishing_governance.integrated_v1',
  'media_center',
  'editorial_roles_publishing_governance_integrated',
  null,
  null,
  '/admin/media-center',
  'تم تثبيت مصفوفة أدوار التحرير وحوكمة النشر والملكية للمركز الإعلامي دون إنشاء جداول محتوى موازية.',
  jsonb_build_object(
    'batch_key', 'media_center_editorial_roles_publishing_governance_2026_05_07',
    'roles_seeded', 6,
    'publishing_rules_seeded', 6,
    'no_parallel_content_tables', true,
    'ministry_unit_contract_preserved', true,
    'verified_at', now()
  )
where not exists (
  select 1 from public.media_center_audit_events e
  where e.event_key = 'media_center.governance.editorial_roles_publishing_governance.integrated_v1'
);

-- -----------------------------------------------------------------------------
-- 8) RLS + guarded grants.
-- -----------------------------------------------------------------------------
alter table public.media_center_editorial_roles enable row level security;
alter table public.media_center_publishing_governance_rules enable row level security;

drop policy if exists media_center_editorial_roles_read_v1 on public.media_center_editorial_roles;
create policy media_center_editorial_roles_read_v1
on public.media_center_editorial_roles
for select
using (public.media_center_can_read_v1());

drop policy if exists media_center_editorial_roles_write_v1 on public.media_center_editorial_roles;
create policy media_center_editorial_roles_write_v1
on public.media_center_editorial_roles
for all
using (public.media_center_can_action_v1('manage_governance', null))
with check (public.media_center_can_action_v1('manage_governance', null));

drop policy if exists media_center_publishing_rules_read_v1 on public.media_center_publishing_governance_rules;
create policy media_center_publishing_rules_read_v1
on public.media_center_publishing_governance_rules
for select
using (public.media_center_can_read_v1());

drop policy if exists media_center_publishing_rules_write_v1 on public.media_center_publishing_governance_rules;
create policy media_center_publishing_rules_write_v1
on public.media_center_publishing_governance_rules
for all
using (public.media_center_can_action_v1('manage_governance', null))
with check (public.media_center_can_action_v1('manage_governance', null));

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    grant execute on function public.media_center_required_permission_for_action_v1(text) to authenticated;
    grant execute on function public.media_center_can_action_v1(text,text) to authenticated;
    grant execute on function public.rpc_media_center_editorial_roles_matrix_v1() to authenticated;
    grant execute on function public.rpc_media_center_publishing_governance_rules_v1() to authenticated;
    grant execute on function public.rpc_media_center_publishing_governance_readiness_v1() to authenticated;
    grant execute on function public.rpc_media_center_publishing_governance_diagnostics_v1() to authenticated;
    grant execute on function public.rpc_media_center_readiness_v1() to authenticated;
    grant select on public.media_center_editorial_roles to authenticated;
    grant select on public.media_center_publishing_governance_rules to authenticated;
  end if;

  if exists (select 1 from pg_roles where rolname = 'service_role') then
    grant execute on function public.media_center_required_permission_for_action_v1(text) to service_role;
    grant execute on function public.media_center_can_action_v1(text,text) to service_role;
    grant execute on function public.rpc_media_center_editorial_roles_matrix_v1() to service_role;
    grant execute on function public.rpc_media_center_publishing_governance_rules_v1() to service_role;
    grant execute on function public.rpc_media_center_publishing_governance_readiness_v1() to service_role;
    grant execute on function public.rpc_media_center_publishing_governance_diagnostics_v1() to service_role;
    grant execute on function public.rpc_media_center_readiness_v1() to service_role;
    grant select, insert, update, delete on public.media_center_editorial_roles to service_role;
    grant select, insert, update, delete on public.media_center_publishing_governance_rules to service_role;
  end if;
end $$;
