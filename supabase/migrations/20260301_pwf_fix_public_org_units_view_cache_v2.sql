-- PalWakf — Hotfix (V2): public.org_units is a VIEW (not a table)
-- Fix: create org_units_cache (table), repoint view to it, and provide refresh function.
begin;

do $do$
declare
  rk char;
begin
  select c.relkind into rk
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public' and c.relname = 'org_units';

  if rk is null then
    raise exception 'public.org_units not found (table/view expected).';
  end if;

  if rk = 'v' then
    -- Create cache table with same columns as existing VIEW output
    if to_regclass('public.org_units_cache') is null then
      execute 'create table public.org_units_cache as select * from public.org_units where false';
    end if;

    -- Ensure PK on cache (id) if column exists
    if exists (
      select 1 from information_schema.columns
      where table_schema='public' and table_name='org_units_cache' and column_name='id'
    ) then
      if not exists (
        select 1
        from pg_constraint c
        join pg_class t on t.oid=c.conrelid
        join pg_namespace n on n.oid=t.relnamespace
        where n.nspname='public' and t.relname='org_units_cache' and c.contype='p'
      ) then
        execute 'alter table public.org_units_cache add constraint org_units_cache_pkey primary key (id)';
      end if;
    else
      raise exception 'public.org_units_cache has no column "id" (cannot set primary key).';
    end if;

    -- Repoint view to cache (keep the name public.org_units)
    execute 'create or replace view public.org_units as select * from public.org_units_cache';
  end if;
end
$do$;

-- Refresh function (works after cache table exists)
create or replace function public.pwf_refresh_org_units_cache()
returns void
language plpgsql
security definer
set search_path = public, core
as $func$
declare
  cols text;
  q text;
begin
  if to_regclass('public.org_units_cache') is null then
    raise exception 'public.org_units_cache not found. Run the hotfix DO block first.';
  end if;

  if to_regclass('core.org_units') is null then
    raise exception 'Missing core.org_units.';
  end if;

  select string_agg(format('%I', p.column_name), ',')
    into cols
  from information_schema.columns p
  where p.table_schema='public' and p.table_name='org_units_cache'
    and exists (
      select 1 from information_schema.columns c
      where c.table_schema='core' and c.table_name='org_units' and c.column_name=p.column_name
    );

  if cols is null or cols = '' then
    raise exception 'No common columns between public.org_units_cache and core.org_units.';
  end if;

  execute 'truncate table public.org_units_cache';
  q := format('insert into public.org_units_cache (%s) select %s from core.org_units', cols, cols);
  execute q;
end;
$func$;

-- Run one refresh now (safe even if org_units was a table; it will error only if cache not created)
do $do2$
begin
  if to_regclass('public.org_units_cache') is not null then
    perform public.pwf_refresh_org_units_cache();
  end if;
end
$do2$;

commit;