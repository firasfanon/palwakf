-- Mega Batch N2.36
-- 56_site_content_header_footer_ROLLBACK_READY_N2_36.sql
-- Purpose: rollback for SQL55 only. Do not run unless Browser/UAT/analyzer evidence requires reverting.
-- Safety: returns header_settings/footer_settings from site_content to public and drops compatibility views.

begin;

do $$
declare
  target_name text;
  public_kind char;
  target_oid oid;
begin
  foreach target_name in array array['header_settings', 'footer_settings'] loop
    select c.relkind
      into public_kind
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = target_name;

    select c.oid
      into target_oid
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'site_content'
      and c.relname = target_name
      and c.relkind in ('r','p');

    if target_oid is null then
      raise notice 'Skip rollback %.%: site_content source table missing.', 'site_content', target_name;
      continue;
    end if;

    if public_kind = 'v' then
      execute format('drop view public.%I', target_name);
    elsif public_kind is not null then
      raise exception 'Blocked rollback for %: public object exists and is not a compatibility view. relkind=%', target_name, public_kind;
    end if;

    execute format('alter table site_content.%I set schema public', target_name);
    execute format('comment on table public.%I is %L', target_name,
      'Rolled back from site_content to public by PalWakf N2.36 rollback script.');
  end loop;
end $$;

commit;
