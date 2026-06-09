-- PalWakf | Step 1 (RUN ALONE)
-- Add missing enum values to public.system_key
-- IMPORTANT: Run this in a separate "Run" in Supabase SQL Editor, then run Step 2 in a NEW Run.

do $$
declare
  v text;
  vals text[] := array[
    'platformAdmin','site','mustakshif','adminData','lands',
    'properties','cases','tasks','mosques','billing'
  ];
begin
  if exists(
    select 1
    from pg_type t
    join pg_namespace n on n.oid = t.typnamespace
    where n.nspname='public' and t.typname='system_key'
  ) then
    foreach v in array vals loop
      begin
        execute format('alter type public.system_key add value if not exists %L', v);
      exception when others then
        null;
      end;
    end loop;
  end if;
end $$;
