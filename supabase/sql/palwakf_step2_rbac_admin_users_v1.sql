-- PalWakf | Step 2 (admin_users RBAC)  v1
-- RUN AFTER Step 1 IN A NEW RUN.
--
-- Decision: admin_users is the single identity source.
--   - admin_users.id == auth.users.id (FK already exists)
--   - RBAC tables reference admin_users.id as user_id
-- Supports BOTH:
--   - superuser (admin_users.is_superuser = true OR role='super_admin')
--   - roles/permissions per system (user_system_roles / user_system_permissions)
--
-- Notes:
--   - This script is idempotent and safe to re-run.
--   - It does NOT drop your existing user_accounts table (can be removed later if you want).

-- ============================================================
-- 0) Ensure superuser flag on admin_users (keep role too)
-- ============================================================
alter table public.admin_users
  add column if not exists is_superuser boolean not null default false;

-- ============================================================
-- 1) Ensure dictionaries are seeded (platform_systems + platform_permissions)
--     Your schema uses name_ar/name_en NOT NULL, so we always seed them when present.
-- ============================================================

-- 1.1 platform_permissions seed (ALWAYS supplies name_ar if column exists)
do $$
declare
  has_name_ar boolean := exists(
    select 1 from pg_attribute
    where attrelid = 'public.platform_permissions'::regclass
      and attname = 'name_ar' and attnum > 0 and not attisdropped
  );
  has_name_en boolean := exists(
    select 1 from pg_attribute
    where attrelid = 'public.platform_permissions'::regclass
      and attname = 'name_en' and attnum > 0 and not attisdropped
  );
  has_title boolean := exists(
    select 1 from pg_attribute
    where attrelid = 'public.platform_permissions'::regclass
      and attname = 'title' and attnum > 0 and not attisdropped
  );
  has_description boolean := exists(
    select 1 from pg_attribute
    where attrelid = 'public.platform_permissions'::regclass
      and attname = 'description' and attnum > 0 and not attisdropped
  );
begin
  if has_name_ar then
    if has_name_en and has_title and has_description then
      execute $sql$
        insert into public.platform_permissions(key, name_ar, name_en, title, description) values
        ('manageUsers',     'إدارة المستخدمين',      'Manage Users',      'Manage users',      'Manage users'),
        ('manageSite',      'إدارة المحتوى',         'Manage Site',       'Manage site',       'Manage site content'),
        ('manageHome',      'إدارة الصفحة الرئيسية', 'Manage Home',       'Manage home',       'Manage homepage'),
        ('manageMapLayers', 'إدارة طبقات الخريطة',   'Manage Map Layers', 'Manage map layers', 'Manage map layers'),
        ('manageLandsCrud', 'إدارة الأراضي',         'Manage Lands',      'Manage lands CRUD', 'Manage lands CRUD'),
        ('viewReports',     'عرض التقارير',          'View Reports',      'View reports',      'View reports'),
        ('view',            'عرض',                   'View',              'View',              'View'),
        ('create',          'إضافة',                 'Create',            'Create',            'Create'),
        ('update',          'تعديل',                 'Update',            'Update',            'Update'),
        ('delete',          'حذف',                   'Delete',            'Delete',            'Delete')
        on conflict (key) do update set
          name_ar = excluded.name_ar,
          name_en = excluded.name_en,
          title = excluded.title,
          description = excluded.description;
      $sql$;
    elsif has_name_en and has_title then
      execute $sql$
        insert into public.platform_permissions(key, name_ar, name_en, title) values
        ('manageUsers',     'إدارة المستخدمين',      'Manage Users',      'Manage users'),
        ('manageSite',      'إدارة المحتوى',         'Manage Site',       'Manage site'),
        ('manageHome',      'إدارة الصفحة الرئيسية', 'Manage Home',       'Manage home'),
        ('manageMapLayers', 'إدارة طبقات الخريطة',   'Manage Map Layers', 'Manage map layers'),
        ('manageLandsCrud', 'إدارة الأراضي',         'Manage Lands',      'Manage lands CRUD'),
        ('viewReports',     'عرض التقارير',          'View Reports',      'View reports'),
        ('view',            'عرض',                   'View',              'View'),
        ('create',          'إضافة',                 'Create',            'Create'),
        ('update',          'تعديل',                 'Update',            'Update'),
        ('delete',          'حذف',                   'Delete',            'Delete')
        on conflict (key) do update set
          name_ar = excluded.name_ar,
          name_en = excluded.name_en,
          title = excluded.title;
      $sql$;
    elsif has_name_en then
      execute $sql$
        insert into public.platform_permissions(key, name_ar, name_en) values
        ('manageUsers',     'إدارة المستخدمين',      'Manage Users'),
        ('manageSite',      'إدارة المحتوى',         'Manage Site'),
        ('manageHome',      'إدارة الصفحة الرئيسية', 'Manage Home'),
        ('manageMapLayers', 'إدارة طبقات الخريطة',   'Manage Map Layers'),
        ('manageLandsCrud', 'إدارة الأراضي',         'Manage Lands'),
        ('viewReports',     'عرض التقارير',          'View Reports'),
        ('view',            'عرض',                   'View'),
        ('create',          'إضافة',                 'Create'),
        ('update',          'تعديل',                 'Update'),
        ('delete',          'حذف',                   'Delete')
        on conflict (key) do update set
          name_ar = excluded.name_ar,
          name_en = excluded.name_en;
      $sql$;
    else
      execute $sql$
        insert into public.platform_permissions(key, name_ar) values
        ('manageUsers',     'إدارة المستخدمين'),
        ('manageSite',      'إدارة المحتوى'),
        ('manageHome',      'إدارة الصفحة الرئيسية'),
        ('manageMapLayers', 'إدارة طبقات الخريطة'),
        ('manageLandsCrud', 'إدارة الأراضي'),
        ('viewReports',     'عرض التقارير'),
        ('view',            'عرض'),
        ('create',          'إضافة'),
        ('update',          'تعديل'),
        ('delete',          'حذف')
        on conflict (key) do update set
          name_ar = excluded.name_ar;
      $sql$;
    end if;
  else
    insert into public.platform_permissions(key) values
    ('manageUsers'),('manageSite'),('manageHome'),('manageMapLayers'),
    ('manageLandsCrud'),('viewReports'),('view'),('create'),('update'),('delete')
    on conflict (key) do nothing;
  end if;
end $$;

-- 1.2 platform_systems seed (key is enum public.system_key)
do $$
declare
  has_name_ar boolean := exists(
    select 1 from pg_attribute
    where attrelid = 'public.platform_systems'::regclass
      and attname = 'name_ar' and attnum > 0 and not attisdropped
  );
  has_name_en boolean := exists(
    select 1 from pg_attribute
    where attrelid = 'public.platform_systems'::regclass
      and attname = 'name_en' and attnum > 0 and not attisdropped
  );
  has_title boolean := exists(
    select 1 from pg_attribute
    where attrelid = 'public.platform_systems'::regclass
      and attname = 'title' and attnum > 0 and not attisdropped
  );
begin
  if has_name_ar and has_name_en then
    if has_title then
      execute $sql$
        insert into public.platform_systems(key, name_ar, name_en, title) values
        ('platformAdmin'::public.system_key, 'إدارة المنصة',        'Platform Admin', 'Platform Admin'),
        ('site'::public.system_key,          'الموقع',             'Site',           'Site'),
        ('mustakshif'::public.system_key,    'مستكشف الوقف',       'Mustakshif',     'Mustakshif'),
        ('adminData'::public.system_key,     'البيانات الإدارية',  'Admin Data',     'Admin Data'),
        ('lands'::public.system_key,         'الأراضي',            'Lands',          'Lands'),
        ('properties'::public.system_key,    'الأملاك',            'Properties',     'Properties'),
        ('cases'::public.system_key,         'القضايا',            'Cases',          'Cases'),
        ('tasks'::public.system_key,         'المهام',             'Tasks',          'Tasks'),
        ('mosques'::public.system_key,       'المساجد',            'Mosques',        'Mosques'),
        ('billing'::public.system_key,       'الفوترة',            'Billing',        'Billing')
        on conflict (key) do update set
          name_ar = excluded.name_ar,
          name_en = excluded.name_en,
          title   = excluded.title;
      $sql$;
    else
      execute $sql$
        insert into public.platform_systems(key, name_ar, name_en) values
        ('platformAdmin'::public.system_key, 'إدارة المنصة',        'Platform Admin'),
        ('site'::public.system_key,          'الموقع',             'Site'),
        ('mustakshif'::public.system_key,    'مستكشف الوقف',       'Mustakshif'),
        ('adminData'::public.system_key,     'البيانات الإدارية',  'Admin Data'),
        ('lands'::public.system_key,         'الأراضي',            'Lands'),
        ('properties'::public.system_key,    'الأملاك',            'Properties'),
        ('cases'::public.system_key,         'القضايا',            'Cases'),
        ('tasks'::public.system_key,         'المهام',             'Tasks'),
        ('mosques'::public.system_key,       'المساجد',            'Mosques'),
        ('billing'::public.system_key,       'الفوترة',            'Billing')
        on conflict (key) do update set
          name_ar = excluded.name_ar,
          name_en = excluded.name_en;
      $sql$;
    end if;
  elsif has_title then
    execute $sql$
      insert into public.platform_systems(key, title) values
      ('platformAdmin'::public.system_key,'Platform Admin'),
      ('site'::public.system_key,'Site'),
      ('mustakshif'::public.system_key,'Mustakshif'),
      ('adminData'::public.system_key,'Admin Data'),
      ('lands'::public.system_key,'Lands'),
      ('properties'::public.system_key,'Properties'),
      ('cases'::public.system_key,'Cases'),
      ('tasks'::public.system_key,'Tasks'),
      ('mosques'::public.system_key,'Mosques'),
      ('billing'::public.system_key,'Billing')
      on conflict (key) do update set title = excluded.title;
    $sql$;
  else
    execute $sql$
      insert into public.platform_systems(key) values
      ('platformAdmin'::public.system_key),
      ('site'::public.system_key),
      ('mustakshif'::public.system_key),
      ('adminData'::public.system_key),
      ('lands'::public.system_key),
      ('properties'::public.system_key),
      ('cases'::public.system_key),
      ('tasks'::public.system_key),
      ('mosques'::public.system_key),
      ('billing'::public.system_key)
      on conflict (key) do nothing;
    $sql$;
  end if;
end $$;

-- ============================================================
-- 2) RBAC tables referencing admin_users.id
-- ============================================================
create table if not exists public.user_system_roles (
  id bigserial primary key,
  user_id uuid not null,
  system_key public.system_key not null,
  role text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, system_key)
);

create table if not exists public.user_system_permissions (
  id bigserial primary key,
  user_id uuid not null,
  system_key public.system_key not null,
  permission_key text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, system_key, permission_key)
);

-- Re-wire FKs to admin_users (drop old ones if needed)
do $$
begin
  if exists (
    select 1 from pg_constraint
    where conname = 'user_system_roles_user_id_fkey'
      and conrelid = 'public.user_system_roles'::regclass
  ) then
    alter table public.user_system_roles drop constraint user_system_roles_user_id_fkey;
  end if;

  if exists (
    select 1 from pg_constraint
    where conname = 'user_system_permissions_user_id_fkey'
      and conrelid = 'public.user_system_permissions'::regclass
  ) then
    alter table public.user_system_permissions drop constraint user_system_permissions_user_id_fkey;
  end if;

  delete from public.user_system_roles usr
  where not exists (select 1 from public.admin_users au where au.id = usr.user_id);

  delete from public.user_system_permissions usp
  where not exists (select 1 from public.admin_users au where au.id = usp.user_id);

  alter table public.user_system_roles
    add constraint user_system_roles_user_id_fkey
    foreign key (user_id) references public.admin_users(id) on delete cascade;

  alter table public.user_system_permissions
    add constraint user_system_permissions_user_id_fkey
    foreign key (user_id) references public.admin_users(id) on delete cascade;

  if not exists (
    select 1 from pg_constraint
    where conname = 'user_system_roles_system_key_fkey'
      and conrelid = 'public.user_system_roles'::regclass
  ) then
    alter table public.user_system_roles
      add constraint user_system_roles_system_key_fkey
      foreign key (system_key) references public.platform_systems(key) on delete cascade;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'user_system_permissions_system_key_fkey'
      and conrelid = 'public.user_system_permissions'::regclass
  ) then
    alter table public.user_system_permissions
      add constraint user_system_permissions_system_key_fkey
      foreign key (system_key) references public.platform_systems(key) on delete cascade;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'user_system_permissions_permission_key_fkey'
      and conrelid = 'public.user_system_permissions'::regclass
  ) then
    alter table public.user_system_permissions
      add constraint user_system_permissions_permission_key_fkey
      foreign key (permission_key) references public.platform_permissions(key) on delete cascade;
  end if;
end $$;

-- ============================================================
-- 3) Helper functions based on admin_users (auth.uid == admin_users.id)
-- ============================================================
create or replace function public.current_admin_user_id()
returns uuid
language sql
stable
as $func$
  select au.id
  from public.admin_users au
  where au.id = auth.uid()
  limit 1;
$func$;

create or replace function public.is_superuser()
returns boolean
language sql
stable
as $func$
  select coalesce(
    (select (au.is_superuser = true or au.role = 'super_admin')
     from public.admin_users au
     where au.id = auth.uid()
     limit 1),
    false
  );
$func$;

create or replace function public.is_active_user()
returns boolean
language sql
stable
as $func$
  select coalesce(
    (select au.is_active
     from public.admin_users au
     where au.id = auth.uid()
     limit 1),
    false
  );
$func$;

create or replace function public.has_permission(p_system_key public.system_key, p_permission_key text)
returns boolean
language sql
stable
as $func$
  select public.is_superuser()
  or exists (
    select 1
    from public.user_system_permissions usp
    where usp.user_id = auth.uid()
      and usp.system_key = p_system_key
      and usp.permission_key = p_permission_key
  );
$func$;

create or replace function public.has_system_role(p_system_key public.system_key, p_role text)
returns boolean
language sql
stable
as $func$
  select public.is_superuser()
  or exists (
    select 1
    from public.user_system_roles usr
    where usr.user_id = auth.uid()
      and usr.system_key = p_system_key
      and (usr.role)::text = p_role
  );
$func$;

-- ============================================================
-- 4) RLS policies (minimal + admin write on platformAdmin)
-- ============================================================
alter table public.admin_users enable row level security;
alter table public.user_system_roles enable row level security;
alter table public.user_system_permissions enable row level security;
alter table public.platform_systems enable row level security;
alter table public.platform_permissions enable row level security;

drop policy if exists "platform_systems_read" on public.platform_systems;
create policy "platform_systems_read"
on public.platform_systems
for select
to authenticated
using (true);

drop policy if exists "platform_permissions_read" on public.platform_permissions;
create policy "platform_permissions_read"
on public.platform_permissions
for select
to authenticated
using (true);

drop policy if exists "admin_users_read_own" on public.admin_users;
create policy "admin_users_read_own"
on public.admin_users
for select
to authenticated
using (public.is_superuser() or id = auth.uid());

drop policy if exists "user_system_roles_read_own" on public.user_system_roles;
create policy "user_system_roles_read_own"
on public.user_system_roles
for select
to authenticated
using (public.is_superuser() or user_id = auth.uid());

drop policy if exists "user_system_permissions_read_own" on public.user_system_permissions;
create policy "user_system_permissions_read_own"
on public.user_system_permissions
for select
to authenticated
using (public.is_superuser() or user_id = auth.uid());

drop policy if exists "user_system_roles_admin_write" on public.user_system_roles;
create policy "user_system_roles_admin_write"
on public.user_system_roles
for all
to authenticated
using (public.is_superuser() or public.has_permission('platformAdmin'::public.system_key, 'manageUsers'))
with check (public.is_superuser() or public.has_permission('platformAdmin'::public.system_key, 'manageUsers'));

drop policy if exists "user_system_permissions_admin_write" on public.user_system_permissions;
create policy "user_system_permissions_admin_write"
on public.user_system_permissions
for all
to authenticated
using (public.is_superuser() or public.has_permission('platformAdmin'::public.system_key, 'manageUsers'))
with check (public.is_superuser() or public.has_permission('platformAdmin'::public.system_key, 'manageUsers'));

-- ============================================================
-- 5) Bootstrap (RUN AFTER YOU LOG IN) - auth.uid() is admin_users.id
-- ============================================================
-- insert into public.user_system_roles(user_id, system_key, role)
-- values (auth.uid(), 'platformAdmin'::public.system_key, 'admin')
-- on conflict (user_id, system_key) do update set role = excluded.role;
--
-- insert into public.user_system_permissions(user_id, system_key, permission_key)
-- values
-- (auth.uid(), 'platformAdmin'::public.system_key, 'manageUsers'),
-- (auth.uid(), 'platformAdmin'::public.system_key, 'manageSite'),
-- (auth.uid(), 'platformAdmin'::public.system_key, 'manageHome')
-- on conflict do nothing;
--
-- Optional:
-- update public.admin_users set is_superuser = true where id = auth.uid();
