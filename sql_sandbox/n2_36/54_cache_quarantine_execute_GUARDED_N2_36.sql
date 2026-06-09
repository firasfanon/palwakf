-- Mega Batch N2.36
-- 54_cache_quarantine_execute_GUARDED_N2_36.sql
-- Purpose: guarded quarantine for public.org_units_cache and public.pwf_org_units_cache.
-- This is DDL, not read-only. Run ONLY after SQL53 shows execute_candidate_gate_passed=true for both cache rows.
-- Safety: no waqf/waqf_assets/awqaf_system mutation. Creates compatibility views in public after moving tables.

begin;

create schema if not exists legacy_archive;
comment on schema legacy_archive is 'PalWakf legacy/deprecated objects quarantined after dependency gates. Do not drop without a later explicit governance decision.';

do $$
declare
  target_name text;
  relation_oid oid;
  rel_kind char;
  view_count integer;
  matview_count integer;
  fk_count integer;
  policy_count integer;
  trigger_count integer;
  function_hit_count integer;
  org_units_is_safe boolean;
begin
  select exists (
    select 1
    from information_schema.views v
    where v.table_schema = 'public'
      and v.table_name = 'org_units'
      and not (coalesce(v.view_definition, '') ~* '\morg_units_cache\M')
      and not (coalesce(v.view_definition, '') ~* '\mpwf_org_units_cache\M')
  ) into org_units_is_safe;

  if not org_units_is_safe then
    raise exception 'Blocked: public.org_units still appears cache-backed or is missing as a compatibility view.';
  end if;

  foreach target_name in array array['org_units_cache', 'pwf_org_units_cache'] loop
    select c.oid, c.relkind
      into relation_oid, rel_kind
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = target_name;

    if relation_oid is null then
      raise notice 'Skip %.%: relation does not exist in public.', 'public', target_name;
      continue;
    end if;

    if rel_kind not in ('r','p') then
      raise notice 'Skip %.%: relation is %, expected table/partitioned table. It may already be quarantined or converted to compatibility view.', 'public', target_name, rel_kind;
      continue;
    end if;

    select
      count(distinct dep_view.oid) filter (where dep_view.relkind = 'v'),
      count(distinct dep_view.oid) filter (where dep_view.relkind = 'm')
    into view_count, matview_count
    from pg_depend d
    join pg_rewrite r on r.oid = d.objid
    join pg_class dep_view on dep_view.oid = r.ev_class and dep_view.oid <> relation_oid
    where d.refobjid = relation_oid;

    select count(*)
      into fk_count
    from pg_constraint con
    where con.contype = 'f'
      and (con.conrelid = relation_oid or con.confrelid = relation_oid);

    select count(*)
      into policy_count
    from pg_policy pol
    where pol.polrelid = relation_oid;

    select count(*)
      into trigger_count
    from pg_trigger tg
    where tg.tgrelid = relation_oid
      and not tg.tgisinternal;

    select count(distinct p.oid)
      into function_hit_count
    from pg_proc p
    join pg_namespace pn on pn.oid = p.pronamespace
    where p.prokind in ('f','p')
      and pn.nspname not in ('pg_catalog','information_schema')
      and pn.nspname not like 'pg_toast%'
      and coalesce(pg_get_functiondef(p.oid), '') ~* ('\m' || target_name || '\M');

    if coalesce(view_count, 0) <> 0
       or coalesce(matview_count, 0) <> 0
       or coalesce(fk_count, 0) <> 0
       or coalesce(policy_count, 0) <> 0
       or coalesce(trigger_count, 0) <> 0
       or coalesce(function_hit_count, 0) <> 0 then
      raise exception 'Blocked quarantine for public.%: view_deps=%, matview_deps=%, fk=%, policies=%, triggers=%, function_hits=%',
        target_name,
        coalesce(view_count, 0),
        coalesce(matview_count, 0),
        coalesce(fk_count, 0),
        coalesce(policy_count, 0),
        coalesce(trigger_count, 0),
        coalesce(function_hit_count, 0);
    end if;

    execute format('alter table public.%I set schema legacy_archive', target_name);
    execute format('comment on table legacy_archive.%I is %L', target_name,
      'Quarantined by PalWakf N2.36 after strict dependency gate; retained for rollback/audit only.');
    execute format('create or replace view public.%I with (security_invoker=true) as select * from legacy_archive.%I', target_name, target_name);
    execute format('comment on view public.%I is %L', target_name,
      'Compatibility view after N2.36 quarantine. Not a source-of-truth table; plan removal only after a later UAT-backed decision.');
    execute format('grant select on public.%I to anon, authenticated', target_name);
  end loop;
end $$;

commit;
