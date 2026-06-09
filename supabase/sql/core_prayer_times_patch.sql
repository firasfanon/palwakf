-- =========================================================
-- PalWakf (Sovereign) - Core Prayer Times Module (DB + RLS)
-- Schemas: core.*
-- Identity source: public.admin_users linked to auth.users
-- RLS: Public read; admin_users can write; users own settings/devices
-- =========================================================

create schema if not exists core;

create extension if not exists pgcrypto;

-- ---------------------------------------------------------
-- helpers
-- ---------------------------------------------------------
create or replace function core.pwf_touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- IMPORTANT:
-- adjust linkage column (default: au.id) if your public.admin_users uses another name
create or replace function core.pwf_is_admin_user()
returns boolean
language sql
stable
security definer
set search_path = public, core
as $$
  select exists (
    select 1
    from public.admin_users au
    where au.id = auth.uid()
  );
$$;

revoke all on function core.pwf_is_admin_user() from public;
grant execute on function core.pwf_is_admin_user() to anon, authenticated;

grant usage on schema core to anon, authenticated;

-- ---------------------------------------------------------
-- calc methods (DB-driven)
-- ---------------------------------------------------------
create table if not exists core.prayer_calc_methods (
  code        text primary key,
  name_ar     text not null,
  name_en     text not null,
  params      jsonb not null default '{}'::jsonb,
  is_active   boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

drop trigger if exists trg_prayer_calc_methods_touch on core.prayer_calc_methods;
create trigger trg_prayer_calc_methods_touch
before update on core.prayer_calc_methods
for each row execute function core.pwf_touch_updated_at();

insert into core.prayer_calc_methods (code, name_ar, name_en, params)
values
  ('umm_al_qura', 'أم القرى', 'Umm al-Qura', '{"notes":"KSA"}'::jsonb),
  ('egyptian',    'الهيئة المصرية', 'Egyptian', '{"notes":"Egypt"}'::jsonb),
  ('karachi',     'كراتشي', 'Karachi', '{"notes":"Pakistan"}'::jsonb),
  ('mwl',         'رابطة العالم الإسلامي', 'MWL', '{"notes":"Muslim World League"}'::jsonb)
on conflict (code) do nothing;

alter table core.prayer_calc_methods enable row level security;

drop policy if exists "prayer_calc_methods_select_public" on core.prayer_calc_methods;
create policy "prayer_calc_methods_select_public"
on core.prayer_calc_methods
for select
using (true);

drop policy if exists "prayer_calc_methods_write_admin" on core.prayer_calc_methods;
create policy "prayer_calc_methods_write_admin"
on core.prayer_calc_methods
for all
to authenticated
using ((select core.pwf_is_admin_user()))
with check ((select core.pwf_is_admin_user()));

grant select on core.prayer_calc_methods to anon, authenticated;
grant insert, update, delete on core.prayer_calc_methods to authenticated;

-- ---------------------------------------------------------
-- cities / locations
-- ---------------------------------------------------------
create table if not exists core.prayer_cities (
  id          uuid primary key default gen_random_uuid(),
  key         text not null unique,
  name_ar     text not null,
  name_en     text not null,
  lat         double precision not null,
  lng         double precision not null,
  tz          text not null default 'Asia/Hebron',
  is_active   boolean not null default true,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

drop trigger if exists trg_prayer_cities_touch on core.prayer_cities;
create trigger trg_prayer_cities_touch
before update on core.prayer_cities
for each row execute function core.pwf_touch_updated_at();

insert into core.prayer_cities (key, name_ar, name_en, lat, lng, tz)
values
  ('jerusalem', 'القدس', 'Jerusalem', 31.7683, 35.2137, 'Asia/Hebron'),
  ('gaza',      'غزة', 'Gaza',        31.5017, 34.4668, 'Asia/Hebron'),
  ('ramallah',  'رام الله', 'Ramallah', 31.9038, 35.2034, 'Asia/Hebron'),
  ('hebron',    'الخليل', 'Hebron',   31.5326, 35.0998, 'Asia/Hebron')
on conflict (key) do nothing;

create index if not exists idx_prayer_cities_active on core.prayer_cities (is_active);

alter table core.prayer_cities enable row level security;

drop policy if exists "prayer_cities_select_public" on core.prayer_cities;
create policy "prayer_cities_select_public"
on core.prayer_cities
for select
using (true);

drop policy if exists "prayer_cities_write_admin" on core.prayer_cities;
create policy "prayer_cities_write_admin"
on core.prayer_cities
for all
to authenticated
using ((select core.pwf_is_admin_user()))
with check ((select core.pwf_is_admin_user()));

grant select on core.prayer_cities to anon, authenticated;
grant insert, update, delete on core.prayer_cities to authenticated;

-- ---------------------------------------------------------
-- daily prayer times (authoritative: city+day+method)
-- ---------------------------------------------------------
create table if not exists core.prayer_times_daily (
  city_id     uuid not null references core.prayer_cities(id) on delete cascade,
  day         date not null,
  method_code text not null references core.prayer_calc_methods(code) on delete restrict,
  fajr        time not null,
  sunrise     time not null,
  dhuhr       time not null,
  asr         time not null,
  maghrib     time not null,
  isha        time not null,
  source      text not null default 'generated',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  primary key (city_id, day, method_code)
);

drop trigger if exists trg_prayer_times_daily_touch on core.prayer_times_daily;
create trigger trg_prayer_times_daily_touch
before update on core.prayer_times_daily
for each row execute function core.pwf_touch_updated_at();

create index if not exists idx_prayer_times_daily_day on core.prayer_times_daily (day);
create index if not exists idx_prayer_times_daily_city on core.prayer_times_daily (city_id);

alter table core.prayer_times_daily enable row level security;

drop policy if exists "prayer_times_daily_select_public" on core.prayer_times_daily;
create policy "prayer_times_daily_select_public"
on core.prayer_times_daily
for select
using (true);

drop policy if exists "prayer_times_daily_write_admin" on core.prayer_times_daily;
create policy "prayer_times_daily_write_admin"
on core.prayer_times_daily
for all
to authenticated
using ((select core.pwf_is_admin_user()))
with check ((select core.pwf_is_admin_user()));

grant select on core.prayer_times_daily to anon, authenticated;
grant insert, update, delete on core.prayer_times_daily to authenticated;

-- ---------------------------------------------------------
-- per-user settings
-- ---------------------------------------------------------
create table if not exists core.user_prayer_settings (
  user_id               uuid primary key,
  city_id               uuid references core.prayer_cities(id),
  method_code           text references core.prayer_calc_methods(code),
  notifications_enabled boolean not null default false,
  remind_before_minutes int not null default 10 check (remind_before_minutes between 0 and 120),
  tz                    text not null default 'Asia/Hebron',
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now()
);

drop trigger if exists trg_user_prayer_settings_touch on core.user_prayer_settings;
create trigger trg_user_prayer_settings_touch
before update on core.user_prayer_settings
for each row execute function core.pwf_touch_updated_at();

alter table core.user_prayer_settings enable row level security;

drop policy if exists "user_prayer_settings_select_own_or_admin" on core.user_prayer_settings;
create policy "user_prayer_settings_select_own_or_admin"
on core.user_prayer_settings
for select
using ((select auth.uid()) = user_id or (select core.pwf_is_admin_user()));

drop policy if exists "user_prayer_settings_insert_own" on core.user_prayer_settings;
create policy "user_prayer_settings_insert_own"
on core.user_prayer_settings
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "user_prayer_settings_update_own" on core.user_prayer_settings;
create policy "user_prayer_settings_update_own"
on core.user_prayer_settings
for update
to authenticated
using ((select auth.uid()) = user_id or (select core.pwf_is_admin_user()))
with check ((select auth.uid()) = user_id or (select core.pwf_is_admin_user()));

grant select on core.user_prayer_settings to authenticated;
grant insert, update on core.user_prayer_settings to authenticated;

-- ---------------------------------------------------------
-- devices/subscriptions for push notifications (tokens/subscription json)
-- ---------------------------------------------------------
create table if not exists core.user_push_devices (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null,
  platform     text not null check (platform in ('web','android','ios')),
  token        text,
  subscription jsonb,
  is_active    boolean not null default true,
  last_seen_at timestamptz,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  constraint uq_user_platform_token unique (user_id, platform, token)
);

drop trigger if exists trg_user_push_devices_touch on core.user_push_devices;
create trigger trg_user_push_devices_touch
before update on core.user_push_devices
for each row execute function core.pwf_touch_updated_at();

alter table core.user_push_devices enable row level security;

drop policy if exists "user_push_devices_select_own_or_admin" on core.user_push_devices;
create policy "user_push_devices_select_own_or_admin"
on core.user_push_devices
for select
using ((select auth.uid()) = user_id or (select core.pwf_is_admin_user()));

drop policy if exists "user_push_devices_insert_own" on core.user_push_devices;
create policy "user_push_devices_insert_own"
on core.user_push_devices
for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "user_push_devices_update_own" on core.user_push_devices;
create policy "user_push_devices_update_own"
on core.user_push_devices
for update
to authenticated
using ((select auth.uid()) = user_id or (select core.pwf_is_admin_user()))
with check ((select auth.uid()) = user_id or (select core.pwf_is_admin_user()));

grant select on core.user_push_devices to authenticated;
grant insert, update, delete on core.user_push_devices to authenticated;

-- ---------------------------------------------------------
-- notification log (audit-friendly)
-- ---------------------------------------------------------
create table if not exists core.prayer_notification_log (
  id          bigserial primary key,
  user_id     uuid not null,
  city_id     uuid references core.prayer_cities(id),
  method_code text references core.prayer_calc_methods(code),
  prayer_key  text not null check (prayer_key in ('fajr','dhuhr','asr','maghrib','isha')),
  event_at    timestamptz not null,
  sent_at     timestamptz,
  status      text not null default 'pending' check (status in ('pending','sent','failed','skipped')),
  error       text,
  created_at  timestamptz not null default now()
);

create index if not exists idx_prayer_notif_log_user_day on core.prayer_notification_log (user_id, event_at);

alter table core.prayer_notification_log enable row level security;

drop policy if exists "prayer_notification_log_select_own_or_admin" on core.prayer_notification_log;
create policy "prayer_notification_log_select_own_or_admin"
on core.prayer_notification_log
for select
using ((select auth.uid()) = user_id or (select core.pwf_is_admin_user()));

drop policy if exists "prayer_notification_log_write_admin_only" on core.prayer_notification_log;
create policy "prayer_notification_log_write_admin_only"
on core.prayer_notification_log
for all
to authenticated
using ((select core.pwf_is_admin_user()))
with check ((select core.pwf_is_admin_user()));

grant select on core.prayer_notification_log to authenticated;
grant insert, update, delete on core.prayer_notification_log to authenticated;
grant usage, select on sequence core.prayer_notification_log_id_seq to authenticated;

-- ---------------------------------------------------------
-- convenience view: "today" per city+method (city-local date)
-- ---------------------------------------------------------
create or replace view core.v_prayer_times_today as
select
  c.key as city_key,
  c.name_ar,
  c.name_en,
  t.method_code,
  t.day,
  t.fajr, t.sunrise, t.dhuhr, t.asr, t.maghrib, t.isha,
  c.tz
from core.prayer_times_daily t
join core.prayer_cities c on c.id = t.city_id
where t.day = (now() at time zone c.tz)::date;
