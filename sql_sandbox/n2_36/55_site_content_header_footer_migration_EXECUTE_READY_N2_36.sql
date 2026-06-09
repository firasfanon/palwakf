-- Mega Batch N2.36
-- 55_site_content_header_footer_migration_EXECUTE_READY_N2_36.sql
-- Purpose: first real domain migration candidate from public -> site_content.
-- Scope: public.header_settings and public.footer_settings only.
-- Safety: DDL with public compatibility views + rollback script. No waqf/waqf_assets/awqaf_system mutation.

begin;

create schema if not exists site_content;
comment on schema site_content is 'PalWakf site content source-of-truth schema for website/home/header/footer/public surface configuration.';

do $$
declare
  target_name text;
  relation_oid oid;
  rel_kind char;
  owner_oid oid;
  existing_target_oid oid;
  dependent_views integer;
  dependent_matviews integer;
begin
  foreach target_name in array array['header_settings', 'footer_settings'] loop
    select c.oid, c.relkind, c.relowner
      into relation_oid, rel_kind, owner_oid
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = target_name;

    select c.oid
      into existing_target_oid
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'site_content'
      and c.relname = target_name;

    if relation_oid is null then
      raise notice 'Skip public.%: source relation is missing.', target_name;
      continue;
    end if;

    if rel_kind = 'v' and existing_target_oid is not null then
      raise notice 'Skip public.%: already converted to compatibility view over site_content.', target_name;
      continue;
    end if;

    if rel_kind not in ('r','p') then
      raise exception 'Blocked site_content migration for public.%: expected table/partitioned table, found relkind=%', target_name, rel_kind;
    end if;

    if existing_target_oid is not null then
      raise exception 'Blocked site_content migration for public.%: site_content.% already exists.', target_name, target_name;
    end if;

    select
      count(distinct dep_view.oid) filter (where dep_view.relkind = 'v'),
      count(distinct dep_view.oid) filter (where dep_view.relkind = 'm')
    into dependent_views, dependent_matviews
    from pg_depend d
    join pg_rewrite r on r.oid = d.objid
    join pg_class dep_view on dep_view.oid = r.ev_class and dep_view.oid <> relation_oid
    where d.refobjid = relation_oid;

    if coalesce(dependent_views, 0) <> 0 or coalesce(dependent_matviews, 0) <> 0 then
      raise exception 'Blocked site_content migration for public.%: dependent_views=%, dependent_matviews=%. Split dependencies before moving.',
        target_name, coalesce(dependent_views, 0), coalesce(dependent_matviews, 0);
    end if;

    execute format('alter table public.%I set schema site_content', target_name);
    execute format('comment on table site_content.%I is %L', target_name,
      'Source-of-truth table moved from public to site_content by PalWakf N2.36. Public name is a compatibility view.');
    execute format('create or replace view public.%I with (security_invoker=true) as select * from site_content.%I', target_name, target_name);
    execute format('comment on view public.%I is %L', target_name,
      'Compatibility view preserving legacy public contract after N2.36 site_content migration.');
    execute format('grant select on public.%I to anon, authenticated', target_name);
    execute format('grant insert, update, delete on public.%I to authenticated', target_name);
  end loop;
end $$;

commit;
