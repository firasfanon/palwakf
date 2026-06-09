-- PalWakf — Hotfix: Sync core.org_units -> public.org_units
begin;

do $$
declare
  cols text;
  upd  text;
  q    text;
  has_pk boolean;
begin
  if to_regclass('core.org_units') is null then
    raise exception 'Missing core.org_units.';
  end if;

  if to_regclass('public.org_units') is null then
    execute 'create table public.org_units (like core.org_units including all)';
  end if;

  select exists (
    select 1
    from pg_constraint c
    join pg_class t on t.oid=c.conrelid
    join pg_namespace n on n.oid=t.relnamespace
    where n.nspname='public' and t.relname='org_units' and c.contype='p'
  ) into has_pk;

  if not has_pk then
    execute 'alter table public.org_units add constraint org_units_pkey primary key (id)';
  end if;

  select string_agg(format('%I', p.column_name), ',')
    into cols
  from information_schema.columns p
  where p.table_schema='public' and p.table_name='org_units'
    and exists (
      select 1 from information_schema.columns c
      where c.table_schema='core' and c.table_name='org_units' and c.column_name=p.column_name
    );

  if cols is null or cols = '' then
    raise exception 'No common columns between core.org_units and public.org_units.';
  end if;

  select string_agg(format('%I = excluded.%I', p.column_name, p.column_name), ',')
    into upd
  from information_schema.columns p
  where p.table_schema='public' and p.table_name='org_units'
    and p.column_name <> 'id'
    and exists (
      select 1 from information_schema.columns c
      where c.table_schema='core' and c.table_name='org_units' and c.column_name=p.column_name
    );

  q := format(
    'insert into public.org_units (%s) select %s from core.org_units on conflict (id) do update set %s',
    cols, cols, upd
  );

  execute q;
end $$;

commit;