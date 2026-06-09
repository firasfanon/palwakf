create table if not exists public.waqf_users (
  id text primary key,
  email text not null unique,
  full_name text,
  role text not null default 'viewer',
  permissions text[] not null default '{}'
);

create table if not exists public.home_config (
  id text primary key,
  hero_title text not null default '',
  hero_subtitle text not null default '',
  show_stats boolean not null default true,
  show_mini_map boolean not null default true,
  show_services boolean not null default true
);

create table if not exists public.site_settings (
  id text primary key,
  site_name text not null default 'مستكشف الوقف',
  primary_color_hex text not null default '#0A3D62',
  enable_dark_switch boolean not null default true,
  facebook text,
  twitter text,
  youtube text
);

insert into public.home_config (id) values ('default') on conflict (id) do nothing;
insert into public.site_settings (id) values ('default') on conflict (id) do nothing;
