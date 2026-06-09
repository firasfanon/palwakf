-- PalWakf — Hotfix: public.org_units is a VIEW (not a table)
-- Fix: create a cache table and repoint the view to it, then refresh from core.org_units.
-- This makes dropdowns that read from public.org_units see ALL units.

begin;

do $$
declare
  rk char;
begin
  select c.relkind into rk
  from pg_class c
  join pg_namespace n on n.oid=c.relnamespace
  where n.nspname='public' and c.relname='org_units';

  if rk is null then
    raise exception 'public.org_units not found (table/view expected).';
  end if;

  if rk = 'v' then
    -- 1) Create cache table with SAME columns as the existing view
    if to_regclass('public.org_units_cache') is null then
      execute 'create table public.org_units_cache as select * from public.org_units where false';
    end if;

    -- 2) Ensure PK on cache (id)
    if not exists (
      select 1
      from pg_constraint c
      join pg_class t on t.oid=c.conrelid
      join pg_namespace n on n.oid=t.relnamespace
      where n.nspname='public' and t.relname='org_units_cache' and c.contype='p'
    ) then
      -- only add if column exists
      if exists (
        select 1 from information_schema.columns
        where table_schema='public' and table_name='org_units_cache' and column_name='id'
      ) then
        execute 'alter table public.org_units_cache add constraint org_units_cache_pkey primary key (id)';
      else
        raise exception 'public.org_units_cache has no column "id" (cannot set primary key).';
      end if;
    end if;

    -- 3) Refresh function (security definer) to fill cache from core.org_units using common columns
    execute $fn$
      create or replace function public.pwf_refresh_org_units_cache()
      returns void
      language plpgsql
      security definer
      set search_path = public, core
      as $$
      declare
        cols text;
        q text;
      begin
        if to_regclass('core.org_units') is null then
          raise exception 'Missing core.org_units.';
        end if;

        -- common columns between cache and core.org_units
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
      end
      $$;
    $fn$;

    -- 4) Repoint view to cache (preserves name public.org_units)
    execute 'create or replace view public.org_units as select * from public.org_units_cache';

    -- 5) Do one refresh now
    perform public.pwf_refresh_org_units_cache();

  elsif rk in ('r','p') then
    -- public.org_units is a TABLE (or partitioned) — your upsert migration applies.
    null;

  else
    raise exception 'public.org_units relkind=% is not supported by this hotfix.', rk;
  end if;
end $$;

commit;