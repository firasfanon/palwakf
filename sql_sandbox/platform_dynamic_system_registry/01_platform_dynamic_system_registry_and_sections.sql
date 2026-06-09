-- Mega Batch N2.10
-- Dynamic System Registry + RBAC-Driven Module Onboarding
-- Creates platform.system_registry and platform.system_sections with role/permission catalog.
-- Does not touch waqf, waqf_assets, or awqaf_system schemas.

create schema if not exists platform;

create table if not exists platform.system_registry (
  id uuid primary key default gen_random_uuid(),
  system_key text not null unique,
  name_ar text not null,
  name_en text,
  description_ar text default '',
  category_key text not null default 'systems',
  module_type text not null default 'generic' check (module_type in ('generic','custom','external','service','section_group')),
  admin_route_path text,
  public_route_path text,
  external_url text,
  icon_key text not null default 'widgets',
  display_order integer not null default 100,
  is_active boolean not null default true,
  show_in_dashboard boolean not null default true,
  show_in_sidebar boolean not null default true,
  requires_permission boolean not null default true,
  is_sovereign boolean not null default false,
  metadata jsonb not null default '{}'::jsonb,
  created_by uuid,
  updated_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint system_registry_key_format check (system_key ~ '^[a-z][a-z0-9_]{2,63}$')
);

create table if not exists platform.system_sections (
  id uuid primary key default gen_random_uuid(),
  system_key text not null references platform.system_registry(system_key) on update cascade on delete cascade,
  section_key text not null,
  title_ar text not null,
  description_ar text default '',
  route_path text,
  section_type text not null default 'generic',
  icon_key text not null default 'section',
  display_order integer not null default 100,
  is_active boolean not null default true,
  show_in_dashboard boolean not null default true,
  show_in_sidebar boolean not null default true,
  required_permission_key text not null default 'read',
  metadata jsonb not null default '{}'::jsonb,
  created_by uuid,
  updated_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(system_key, section_key),
  constraint system_sections_key_format check (section_key ~ '^[a-z][a-z0-9_]{1,63}$')
);

create table if not exists platform.system_role_catalog (
  id uuid primary key default gen_random_uuid(),
  system_key text not null references platform.system_registry(system_key) on update cascade on delete cascade,
  role_key text not null,
  name_ar text not null,
  display_order integer not null default 100,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique(system_key, role_key)
);

create table if not exists platform.system_permission_catalog (
  id uuid primary key default gen_random_uuid(),
  system_key text not null references platform.system_registry(system_key) on update cascade on delete cascade,
  permission_key text not null,
  name_ar text not null,
  display_order integer not null default 100,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  unique(system_key, permission_key)
);

create table if not exists platform.system_user_roles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  system_key text not null references platform.system_registry(system_key) on update cascade on delete cascade,
  role_key text not null,
  scope_type text not null default 'global',
  scope_id uuid,
  is_active boolean not null default true,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id, system_key, role_key, scope_type, scope_id)
);

create table if not exists platform.system_user_permissions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  system_key text not null references platform.system_registry(system_key) on update cascade on delete cascade,
  permission_key text not null,
  allow boolean not null default true,
  scope_type text not null default 'global',
  scope_id uuid,
  created_by uuid,
  created_at timestamptz not null default now(),
  unique(user_id, system_key, permission_key, scope_type, scope_id)
);

create table if not exists platform.system_registry_events (
  id uuid primary key default gen_random_uuid(),
  event_key text not null,
  system_key text,
  section_key text,
  actor_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_system_registry_active_order on platform.system_registry(is_active, display_order, system_key);
create index if not exists idx_system_sections_system_active_order on platform.system_sections(system_key, is_active, display_order, section_key);
create index if not exists idx_system_user_roles_user on platform.system_user_roles(user_id, is_active, system_key);
create index if not exists idx_system_user_permissions_user on platform.system_user_permissions(user_id, allow, system_key);

alter table platform.system_registry enable row level security;
alter table platform.system_sections enable row level security;
alter table platform.system_role_catalog enable row level security;
alter table platform.system_permission_catalog enable row level security;
alter table platform.system_user_roles enable row level security;
alter table platform.system_user_permissions enable row level security;
alter table platform.system_registry_events enable row level security;

-- Conservative read policies for authenticated admins; write remains through security-definer RPC.
drop policy if exists system_registry_read_authenticated on platform.system_registry;
create policy system_registry_read_authenticated on platform.system_registry for select to authenticated using (true);

drop policy if exists system_sections_read_authenticated on platform.system_sections;
create policy system_sections_read_authenticated on platform.system_sections for select to authenticated using (true);

drop policy if exists system_role_catalog_read_authenticated on platform.system_role_catalog;
create policy system_role_catalog_read_authenticated on platform.system_role_catalog for select to authenticated using (true);

drop policy if exists system_permission_catalog_read_authenticated on platform.system_permission_catalog;
create policy system_permission_catalog_read_authenticated on platform.system_permission_catalog for select to authenticated using (true);

drop policy if exists system_user_roles_self_read on platform.system_user_roles;
create policy system_user_roles_self_read on platform.system_user_roles for select to authenticated using (user_id = auth.uid());

drop policy if exists system_user_permissions_self_read on platform.system_user_permissions;
create policy system_user_permissions_self_read on platform.system_user_permissions for select to authenticated using (user_id = auth.uid());

create or replace view public.v_platform_system_registry as
select
  system_key,
  name_ar,
  name_en,
  description_ar,
  category_key,
  module_type,
  coalesce(nullif(admin_route_path, ''), '/admin/systems/' || system_key) as admin_route_path,
  public_route_path,
  external_url,
  icon_key,
  display_order,
  is_active,
  show_in_dashboard,
  show_in_sidebar,
  requires_permission,
  is_sovereign,
  metadata
from platform.system_registry
where is_active = true;

create or replace view public.v_platform_system_sections as
select
  system_key,
  section_key,
  title_ar,
  description_ar,
  coalesce(nullif(route_path, ''), '/admin/systems/' || system_key || '/sections/' || section_key) as route_path,
  section_type,
  icon_key,
  display_order,
  is_active,
  show_in_dashboard,
  show_in_sidebar,
  required_permission_key,
  metadata
from platform.system_sections
where is_active = true;

create or replace function public.pwf_platform_user_can_manage_system_registry_v1()
returns boolean
language sql
stable
security definer
set search_path = public, platform
as $$
  select exists (
    select 1
    from public.admin_users au
    where au.id = auth.uid()
      and au.is_active is true
      and (
        au.is_superuser is true
        or lower(coalesce(au.role, '')) in ('super_admin','superuser')
        or exists (
          select 1 from public.user_system_permissions p
          where p.user_id = au.id
            and p.allow is true
            and p.system_key::text in ('platformAdmin','platform_admin','admin')
            and p.permission_key in ('manageSystems','manageUsers','manageSite')
        )
        or exists (
          select 1 from public.user_system_roles r
          where r.user_id = au.id
            and r.system_key::text in ('platformAdmin','platform_admin','admin')
            and r.role::text in ('superuser','admin')
        )
      )
  );
$$;

create or replace function public.pwf_platform_system_registry_seed_defaults_v1()
returns jsonb
language plpgsql
security definer
set search_path = public, platform
as $$
begin
  if not public.pwf_platform_user_can_manage_system_registry_v1() then
    return jsonb_build_object('success', false, 'message_ar', 'غير مصرح بإدارة سجل الأنظمة.');
  end if;

  insert into platform.system_registry(system_key, name_ar, name_en, description_ar, category_key, module_type, admin_route_path, icon_key, display_order, requires_permission, is_sovereign, metadata)
  values
    ('training_center', 'مركز التدريب', 'Training Center', 'نظام تدريبي ديناميكي تجريبي يثبت onboard من لوحة التحكم.', 'systems', 'generic', '/admin/systems/training_center', 'service', 900, true, false, '{"seed_batch":"n2_10"}'::jsonb)
  on conflict (system_key) do nothing;

  insert into platform.system_sections(system_key, section_key, title_ar, description_ar, route_path, section_type, icon_key, display_order, required_permission_key, metadata)
  values
    ('training_center', 'requests', 'طلبات التدريب', 'قسم ديناميكي داخل مركز التدريب.', '/admin/systems/training_center/sections/requests', 'generic', 'section', 10, 'read', '{"seed_batch":"n2_10"}'::jsonb),
    ('training_center', 'reports', 'تقارير التدريب', 'قسم تقارير ديناميكي داخل مركز التدريب.', '/admin/systems/training_center/sections/reports', 'generic', 'audit', 20, 'viewReports', '{"seed_batch":"n2_10"}'::jsonb)
  on conflict (system_key, section_key) do nothing;

  insert into platform.system_role_catalog(system_key, role_key, name_ar, display_order)
  values
    ('training_center', 'owner', 'مالك النظام', 1),
    ('training_center', 'manager', 'مدير النظام', 2),
    ('training_center', 'operator', 'مشغل', 3),
    ('training_center', 'viewer', 'مشاهد', 4)
  on conflict (system_key, role_key) do nothing;

  insert into platform.system_permission_catalog(system_key, permission_key, name_ar, display_order)
  values
    ('training_center', 'read', 'قراءة', 1),
    ('training_center', 'create', 'إنشاء', 2),
    ('training_center', 'update', 'تعديل', 3),
    ('training_center', 'delete', 'حذف', 4),
    ('training_center', 'viewReports', 'عرض التقارير', 5),
    ('training_center', 'manage', 'إدارة النظام', 6)
  on conflict (system_key, permission_key) do nothing;

  return jsonb_build_object('success', true, 'message_ar', 'تم seed الافتراضي لسجل الأنظمة الديناميكي.');
end;
$$;

create or replace function public.pwf_platform_system_registry_list_v1()
returns jsonb
language sql
stable
security definer
set search_path = public, platform
as $$
  select coalesce(jsonb_agg(system_payload order by (system_payload->>'display_order')::int, system_payload->>'system_key'), '[]'::jsonb)
  from (
    select jsonb_build_object(
      'system_key', s.system_key,
      'name_ar', s.name_ar,
      'name_en', s.name_en,
      'description_ar', s.description_ar,
      'category_key', s.category_key,
      'module_type', s.module_type,
      'admin_route_path', coalesce(nullif(s.admin_route_path, ''), '/admin/systems/' || s.system_key),
      'public_route_path', s.public_route_path,
      'external_url', s.external_url,
      'icon_key', s.icon_key,
      'display_order', s.display_order,
      'is_active', s.is_active,
      'show_in_dashboard', s.show_in_dashboard,
      'show_in_sidebar', s.show_in_sidebar,
      'requires_permission', s.requires_permission,
      'is_sovereign', s.is_sovereign,
      'metadata', s.metadata,
      'sections', coalesce((
        select jsonb_agg(jsonb_build_object(
          'system_key', sec.system_key,
          'section_key', sec.section_key,
          'title_ar', sec.title_ar,
          'description_ar', sec.description_ar,
          'route_path', coalesce(nullif(sec.route_path, ''), '/admin/systems/' || sec.system_key || '/sections/' || sec.section_key),
          'section_type', sec.section_type,
          'icon_key', sec.icon_key,
          'display_order', sec.display_order,
          'is_active', sec.is_active,
          'show_in_dashboard', sec.show_in_dashboard,
          'show_in_sidebar', sec.show_in_sidebar,
          'required_permission_key', sec.required_permission_key,
          'metadata', sec.metadata
        ) order by sec.display_order, sec.section_key)
        from platform.system_sections sec
        where sec.system_key = s.system_key
      ), '[]'::jsonb)
    ) as system_payload
    from platform.system_registry s
    order by s.display_order, s.system_key
  ) q;
$$;

create or replace function public.pwf_platform_system_sections_list_v1(p_system_key text)
returns jsonb
language sql
stable
security definer
set search_path = public, platform
as $$
  select coalesce(jsonb_agg(jsonb_build_object(
    'system_key', sec.system_key,
    'section_key', sec.section_key,
    'title_ar', sec.title_ar,
    'description_ar', sec.description_ar,
    'route_path', coalesce(nullif(sec.route_path, ''), '/admin/systems/' || sec.system_key || '/sections/' || sec.section_key),
    'section_type', sec.section_type,
    'icon_key', sec.icon_key,
    'display_order', sec.display_order,
    'is_active', sec.is_active,
    'show_in_dashboard', sec.show_in_dashboard,
    'show_in_sidebar', sec.show_in_sidebar,
    'required_permission_key', sec.required_permission_key,
    'metadata', sec.metadata
  ) order by sec.display_order, sec.section_key), '[]'::jsonb)
  from platform.system_sections sec
  where sec.system_key = p_system_key
    and sec.is_active is true;
$$;

create or replace function public.pwf_platform_visible_systems_for_user_v1(p_user_id uuid default auth.uid())
returns jsonb
language sql
stable
security definer
set search_path = public, platform
as $$
  with current_admin as (
    select id, is_active, is_superuser, role
    from public.admin_users
    where id = coalesce(p_user_id, auth.uid())
      and is_active is true
  ), elevated as (
    select exists (
      select 1 from current_admin au
      where au.is_superuser is true or lower(coalesce(au.role,'')) in ('super_admin','superuser')
    ) or public.pwf_platform_user_can_manage_system_registry_v1() as allowed
  ), visible_systems as (
    select s.*
    from platform.system_registry s
    cross join elevated e
    where s.is_active is true
      and (
        e.allowed
        or s.requires_permission is false
        or exists (select 1 from platform.system_user_roles r where r.user_id = coalesce(p_user_id, auth.uid()) and r.system_key = s.system_key and r.is_active is true)
        or exists (select 1 from platform.system_user_permissions p where p.user_id = coalesce(p_user_id, auth.uid()) and p.system_key = s.system_key and p.allow is true)
      )
  )
  select coalesce(jsonb_agg(system_payload order by (system_payload->>'display_order')::int, system_payload->>'system_key'), '[]'::jsonb)
  from (
    select jsonb_build_object(
      'system_key', s.system_key,
      'name_ar', s.name_ar,
      'name_en', s.name_en,
      'description_ar', s.description_ar,
      'category_key', s.category_key,
      'module_type', s.module_type,
      'admin_route_path', coalesce(nullif(s.admin_route_path, ''), '/admin/systems/' || s.system_key),
      'public_route_path', s.public_route_path,
      'external_url', s.external_url,
      'icon_key', s.icon_key,
      'display_order', s.display_order,
      'is_active', s.is_active,
      'show_in_dashboard', s.show_in_dashboard,
      'show_in_sidebar', s.show_in_sidebar,
      'requires_permission', s.requires_permission,
      'is_sovereign', s.is_sovereign,
      'metadata', s.metadata,
      'sections', coalesce((
        select jsonb_agg(jsonb_build_object(
          'system_key', sec.system_key,
          'section_key', sec.section_key,
          'title_ar', sec.title_ar,
          'description_ar', sec.description_ar,
          'route_path', coalesce(nullif(sec.route_path, ''), '/admin/systems/' || sec.system_key || '/sections/' || sec.section_key),
          'section_type', sec.section_type,
          'icon_key', sec.icon_key,
          'display_order', sec.display_order,
          'is_active', sec.is_active,
          'show_in_dashboard', sec.show_in_dashboard,
          'show_in_sidebar', sec.show_in_sidebar,
          'required_permission_key', sec.required_permission_key,
          'metadata', sec.metadata
        ) order by sec.display_order, sec.section_key)
        from platform.system_sections sec
        cross join elevated e
        where sec.system_key = s.system_key
          and sec.is_active is true
          and (
            e.allowed
            or exists (
              select 1 from platform.system_user_permissions p
              where p.user_id = coalesce(p_user_id, auth.uid())
                and p.system_key = s.system_key
                and p.allow is true
                and p.permission_key in (sec.required_permission_key, 'read', 'manage')
            )
          )
      ), '[]'::jsonb)
    ) as system_payload
    from visible_systems s
  ) q;
$$;

create or replace function public.pwf_platform_system_upsert_v1(
  p_system_key text,
  p_name_ar text,
  p_name_en text default null,
  p_description_ar text default '',
  p_category_key text default 'systems',
  p_module_type text default 'generic',
  p_admin_route_path text default null,
  p_public_route_path text default null,
  p_external_url text default null,
  p_icon_key text default 'widgets',
  p_display_order integer default 100,
  p_is_active boolean default true,
  p_show_in_dashboard boolean default true,
  p_show_in_sidebar boolean default true,
  p_requires_permission boolean default true,
  p_is_sovereign boolean default false,
  p_metadata jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, platform
as $$
begin
  if not public.pwf_platform_user_can_manage_system_registry_v1() then
    return jsonb_build_object('success', false, 'message_ar', 'غير مصرح بإدارة سجل الأنظمة.');
  end if;

  insert into platform.system_registry(
    system_key, name_ar, name_en, description_ar, category_key, module_type,
    admin_route_path, public_route_path, external_url, icon_key, display_order,
    is_active, show_in_dashboard, show_in_sidebar, requires_permission, is_sovereign,
    metadata, created_by, updated_by
  ) values (
    lower(trim(p_system_key)), p_name_ar, p_name_en, coalesce(p_description_ar,''), coalesce(nullif(p_category_key,''),'systems'),
    coalesce(nullif(p_module_type,''),'generic'), p_admin_route_path, p_public_route_path, p_external_url,
    coalesce(nullif(p_icon_key,''),'widgets'), coalesce(p_display_order,100), coalesce(p_is_active,true),
    coalesce(p_show_in_dashboard,true), coalesce(p_show_in_sidebar,true), coalesce(p_requires_permission,true),
    coalesce(p_is_sovereign,false), coalesce(p_metadata,'{}'::jsonb), auth.uid(), auth.uid()
  )
  on conflict (system_key) do update set
    name_ar = excluded.name_ar,
    name_en = excluded.name_en,
    description_ar = excluded.description_ar,
    category_key = excluded.category_key,
    module_type = excluded.module_type,
    admin_route_path = excluded.admin_route_path,
    public_route_path = excluded.public_route_path,
    external_url = excluded.external_url,
    icon_key = excluded.icon_key,
    display_order = excluded.display_order,
    is_active = excluded.is_active,
    show_in_dashboard = excluded.show_in_dashboard,
    show_in_sidebar = excluded.show_in_sidebar,
    requires_permission = excluded.requires_permission,
    is_sovereign = excluded.is_sovereign,
    metadata = excluded.metadata,
    updated_by = auth.uid(),
    updated_at = now();

  insert into platform.system_registry_events(event_key, system_key, actor_id, metadata)
  values ('system_upsert', lower(trim(p_system_key)), auth.uid(), coalesce(p_metadata,'{}'::jsonb));

  insert into platform.system_role_catalog(system_key, role_key, name_ar, display_order)
  values
    (lower(trim(p_system_key)), 'owner', 'مالك النظام', 1),
    (lower(trim(p_system_key)), 'manager', 'مدير النظام', 2),
    (lower(trim(p_system_key)), 'operator', 'مشغل', 3),
    (lower(trim(p_system_key)), 'viewer', 'مشاهد', 4)
  on conflict (system_key, role_key) do nothing;

  insert into platform.system_permission_catalog(system_key, permission_key, name_ar, display_order)
  values
    (lower(trim(p_system_key)), 'read', 'قراءة', 1),
    (lower(trim(p_system_key)), 'create', 'إنشاء', 2),
    (lower(trim(p_system_key)), 'update', 'تعديل', 3),
    (lower(trim(p_system_key)), 'delete', 'حذف', 4),
    (lower(trim(p_system_key)), 'viewReports', 'عرض التقارير', 5),
    (lower(trim(p_system_key)), 'manage', 'إدارة النظام', 6)
  on conflict (system_key, permission_key) do nothing;

  return jsonb_build_object('success', true, 'message_ar', 'تم حفظ النظام الديناميكي.', 'system_key', lower(trim(p_system_key)));
end;
$$;

create or replace function public.pwf_platform_system_section_upsert_v1(
  p_system_key text,
  p_section_key text,
  p_title_ar text,
  p_description_ar text default '',
  p_route_path text default null,
  p_section_type text default 'generic',
  p_icon_key text default 'section',
  p_display_order integer default 100,
  p_is_active boolean default true,
  p_show_in_dashboard boolean default true,
  p_show_in_sidebar boolean default true,
  p_required_permission_key text default 'read',
  p_metadata jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, platform
as $$
begin
  if not public.pwf_platform_user_can_manage_system_registry_v1() then
    return jsonb_build_object('success', false, 'message_ar', 'غير مصرح بإدارة أقسام النظام.');
  end if;

  if not exists (select 1 from platform.system_registry where system_key = lower(trim(p_system_key))) then
    return jsonb_build_object('success', false, 'message_ar', 'النظام غير موجود في platform.system_registry.');
  end if;

  insert into platform.system_sections(
    system_key, section_key, title_ar, description_ar, route_path, section_type,
    icon_key, display_order, is_active, show_in_dashboard, show_in_sidebar,
    required_permission_key, metadata, created_by, updated_by
  ) values (
    lower(trim(p_system_key)), lower(trim(p_section_key)), p_title_ar, coalesce(p_description_ar,''),
    p_route_path, coalesce(nullif(p_section_type,''),'generic'), coalesce(nullif(p_icon_key,''),'section'),
    coalesce(p_display_order,100), coalesce(p_is_active,true), coalesce(p_show_in_dashboard,true),
    coalesce(p_show_in_sidebar,true), coalesce(nullif(p_required_permission_key,''),'read'),
    coalesce(p_metadata,'{}'::jsonb), auth.uid(), auth.uid()
  )
  on conflict (system_key, section_key) do update set
    title_ar = excluded.title_ar,
    description_ar = excluded.description_ar,
    route_path = excluded.route_path,
    section_type = excluded.section_type,
    icon_key = excluded.icon_key,
    display_order = excluded.display_order,
    is_active = excluded.is_active,
    show_in_dashboard = excluded.show_in_dashboard,
    show_in_sidebar = excluded.show_in_sidebar,
    required_permission_key = excluded.required_permission_key,
    metadata = excluded.metadata,
    updated_by = auth.uid(),
    updated_at = now();

  insert into platform.system_registry_events(event_key, system_key, section_key, actor_id, metadata)
  values ('section_upsert', lower(trim(p_system_key)), lower(trim(p_section_key)), auth.uid(), coalesce(p_metadata,'{}'::jsonb));

  insert into platform.system_permission_catalog(system_key, permission_key, name_ar, display_order)
  values (lower(trim(p_system_key)), coalesce(nullif(p_required_permission_key,''),'read'), 'صلاحية قسم: ' || p_title_ar, 100)
  on conflict (system_key, permission_key) do nothing;

  return jsonb_build_object('success', true, 'message_ar', 'تم حفظ القسم الديناميكي.', 'system_key', lower(trim(p_system_key)), 'section_key', lower(trim(p_section_key)));
end;
$$;

grant usage on schema platform to authenticated;
grant select on platform.system_registry, platform.system_sections, platform.system_role_catalog, platform.system_permission_catalog to authenticated;
grant select on platform.system_user_roles, platform.system_user_permissions to authenticated;
grant select on public.v_platform_system_registry, public.v_platform_system_sections to anon, authenticated;
grant execute on function public.pwf_platform_user_can_manage_system_registry_v1() to authenticated;
grant execute on function public.pwf_platform_system_registry_seed_defaults_v1() to authenticated;
grant execute on function public.pwf_platform_system_registry_list_v1() to authenticated;
grant execute on function public.pwf_platform_system_sections_list_v1(text) to authenticated;
grant execute on function public.pwf_platform_visible_systems_for_user_v1(uuid) to authenticated;
grant execute on function public.pwf_platform_system_upsert_v1(text,text,text,text,text,text,text,text,text,text,integer,boolean,boolean,boolean,boolean,boolean,jsonb) to authenticated;
grant execute on function public.pwf_platform_system_section_upsert_v1(text,text,text,text,text,text,text,integer,boolean,boolean,boolean,text,jsonb) to authenticated;
