-- PalWakf — Zakat Donation Requests v2
-- Ensures helper function pwf_require_home_unit_id exists (security definer) and sets default unit_id.
begin;

create extension if not exists pgcrypto;

create or replace function public.pwf_require_home_unit_id()
returns uuid
language plpgsql
security definer
set search_path = public, core
as $$
declare
  v uuid;
begin
  select id into v
  from core.org_units
  where lower(coalesce(slug,'')) = 'home'
     or upper(coalesce(code,'')) = 'HOME'
  order by updated_at desc nulls last
  limit 1;

  if v is null then
    raise exception 'HOME unit not found in core.org_units';
  end if;

  return v;
end $$;

create table if not exists public.zakat_donation_requests (
  id uuid primary key default gen_random_uuid(),
  unit_id uuid not null references core.org_units(id) on delete restrict default public.pwf_require_home_unit_id(),
  donation_option text not null,
  amount numeric(14,2) not null,
  currency text not null default 'ILS',
  donor_name text,
  donor_phone text,
  note text,
  status text not null default 'submitted',
  created_at timestamptz not null default now(),
  created_by uuid references auth.users(id) on delete set null
);

alter table public.zakat_donation_requests
  alter column unit_id set default public.pwf_require_home_unit_id();

create index if not exists zakat_donation_requests_unit_created_idx
  on public.zakat_donation_requests(unit_id, created_at desc);

alter table public.zakat_donation_requests enable row level security;

drop policy if exists "zakat_donation_requests_public_insert" on public.zakat_donation_requests;
create policy "zakat_donation_requests_public_insert"
on public.zakat_donation_requests for insert
with check (true);

drop policy if exists "zakat_donation_requests_admin_select" on public.zakat_donation_requests;
create policy "zakat_donation_requests_admin_select"
on public.zakat_donation_requests for select
using (exists (select 1 from public.admin_users au where au.id = auth.uid() and au.is_active = true));

commit;