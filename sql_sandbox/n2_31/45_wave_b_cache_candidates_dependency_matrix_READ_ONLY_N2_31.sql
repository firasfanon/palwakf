-- PalWakf Platform — N2.31.1 Hotfix
-- 45_wave_b_cache_candidates_dependency_matrix_READ_ONLY_N2_31.sql
-- Purpose: Read-only dependency/RLS/RPC matrix for public.org_units_cache and public.pwf_org_units_cache.
-- Fix: Avoid pg_get_functiondef() on aggregate/window/system functions such as pg_catalog.array_agg.
-- Safety: SELECT-only. No DDL, no DML, no mutation to waqf/waqf_assets/awqaf_system.

with candidates(source_schema, object_name, fqname) as (
  values
    ('public','org_units_cache','public.org_units_cache'),
    ('public','pwf_org_units_cache','public.pwf_org_units_cache')
),
rel as (
  select
    c.*,
    to_regclass(c.fqname) as oid
  from candidates c
),
rel_status as (
  select
    r.source_schema,
    r.object_name,
    r.fqname,
    r.oid is not null as relation_exists,
    coalesce(pc.relkind::text, 'missing') as relkind,
    coalesce(pc.relrowsecurity, false) as rls_enabled,
    coalesce(obj_description(r.oid), '') as relation_comment,
    coalesce(s.n_live_tup, 0)::bigint as estimated_rows
  from rel r
  left join pg_class pc on pc.oid = r.oid
  left join pg_stat_user_tables s on s.relid = r.oid
),
view_usage as (
  select
    c.object_name,
    count(*) filter (
      where v.view_definition ilike '%' || c.object_name || '%'
    ) as view_dependency_count,
    string_agg(v.table_schema || '.' || v.table_name, ', ' order by v.table_schema, v.table_name)
      filter (where v.view_definition ilike '%' || c.object_name || '%') as view_dependencies
  from candidates c
  left join information_schema.views v on true
  group by c.object_name
),
matview_usage as (
  select
    c.object_name,
    count(*) filter (
      where mv.definition ilike '%' || c.object_name || '%'
    ) as matview_dependency_count,
    string_agg(mv.schemaname || '.' || mv.matviewname, ', ' order by mv.schemaname, mv.matviewname)
      filter (where mv.definition ilike '%' || c.object_name || '%') as matview_dependencies
  from candidates c
  left join pg_matviews mv on true
  group by c.object_name
),
-- Only inspect ordinary functions/procedures in non-system schemas.
-- pg_get_functiondef() fails on aggregates/window functions; excluding pg_catalog also prevents built-ins such as array_agg.
function_source as (
  select
    p.oid,
    n.nspname,
    p.proname,
    oidvectortypes(p.proargtypes) as args,
    pg_get_functiondef(p.oid) as definition
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where p.prokind in ('f', 'p')
    and n.nspname not in ('pg_catalog', 'information_schema')
    and n.nspname not like 'pg_toast%'
),
function_usage as (
  select
    c.object_name,
    count(*) filter (
      where fs.definition ilike '%' || c.object_name || '%'
    ) as function_dependency_count,
    string_agg(fs.nspname || '.' || fs.proname || '(' || fs.args || ')', ', ' order by fs.nspname, fs.proname, fs.args)
      filter (where fs.definition ilike '%' || c.object_name || '%') as function_dependencies
  from candidates c
  left join function_source fs on true
  group by c.object_name
),
fk_usage as (
  select
    c.object_name,
    count(*) filter (
      where con.contype = 'f'
        and (con.conrelid = to_regclass(c.fqname) or con.confrelid = to_regclass(c.fqname))
    ) as fk_dependency_count,
    string_agg(con.conname, ', ' order by con.conname)
      filter (where con.contype = 'f' and (con.conrelid = to_regclass(c.fqname) or con.confrelid = to_regclass(c.fqname))) as fk_dependencies
  from candidates c
  left join pg_constraint con on true
  group by c.object_name
),
policy_usage as (
  select
    c.object_name,
    count(*) filter (
      where coalesce(pol.qual, '') ilike '%' || c.object_name || '%'
         or coalesce(pol.with_check, '') ilike '%' || c.object_name || '%'
    ) as policy_dependency_count,
    string_agg(pol.schemaname || '.' || pol.tablename || ':' || pol.policyname, ', ' order by pol.schemaname, pol.tablename, pol.policyname)
      filter (where coalesce(pol.qual, '') ilike '%' || c.object_name || '%' or coalesce(pol.with_check, '') ilike '%' || c.object_name || '%') as policy_dependencies
  from candidates c
  left join pg_policies pol on true
  group by c.object_name
),
trigger_usage as (
  select
    c.object_name,
    count(*) filter (
      where t.tgrelid = to_regclass(c.fqname)
        and not t.tgisinternal
    ) as trigger_count,
    string_agg(t.tgname, ', ' order by t.tgname)
      filter (where t.tgrelid = to_regclass(c.fqname) and not t.tgisinternal) as triggers
  from candidates c
  left join pg_trigger t on true
  group by c.object_name
),
public_org_units_view as (
  select
    exists (
      select 1
      from information_schema.views
      where table_schema = 'public'
        and table_name = 'org_units'
        and view_definition not ilike '%org_units_cache%'
        and view_definition not ilike '%pwf_org_units_cache%'
    ) as public_org_units_not_cache_backed,
    coalesce((
      select view_definition
      from information_schema.views
      where table_schema = 'public'
        and table_name = 'org_units'
      limit 1
    ), '') as public_org_units_view_definition
)
select
  'n2_31_cache_candidate_dependency_matrix' as section,
  rs.object_name as target_object,
  rs.relation_exists,
  rs.relkind,
  rs.rls_enabled,
  rs.estimated_rows,
  (rs.relation_comment ilike '%deprecated%' or rs.relation_comment ilike '%not source%' or rs.relation_comment ilike '%cache%') as has_deprecation_comment,
  coalesce(vu.view_dependency_count, 0) as view_dependency_count,
  coalesce(mu.matview_dependency_count, 0) as matview_dependency_count,
  coalesce(fu.function_dependency_count, 0) as function_dependency_count,
  coalesce(fku.fk_dependency_count, 0) as fk_dependency_count,
  coalesce(pu.policy_dependency_count, 0) as policy_dependency_count,
  coalesce(tu.trigger_count, 0) as trigger_count,
  pou.public_org_units_not_cache_backed,
  (
    rs.relation_exists
    and coalesce(fku.fk_dependency_count, 0) = 0
    and coalesce(pu.policy_dependency_count, 0) = 0
    and coalesce(tu.trigger_count, 0) = 0
    and pou.public_org_units_not_cache_backed
  ) as minimum_candidate_gate_passed,
  concat_ws(' | ',
    'views=' || coalesce(vu.view_dependencies, 'none'),
    'matviews=' || coalesce(mu.matview_dependencies, 'none'),
    'functions=' || coalesce(fu.function_dependencies, 'none'),
    'fks=' || coalesce(fku.fk_dependencies, 'none'),
    'policies=' || coalesce(pu.policy_dependencies, 'none'),
    'triggers=' || coalesce(tu.triggers, 'none')
  ) as dependency_notes
from rel_status rs
left join view_usage vu on vu.object_name = rs.object_name
left join matview_usage mu on mu.object_name = rs.object_name
left join function_usage fu on fu.object_name = rs.object_name
left join fk_usage fku on fku.object_name = rs.object_name
left join policy_usage pu on pu.object_name = rs.object_name
left join trigger_usage tu on tu.object_name = rs.object_name
cross join public_org_units_view pou
order by rs.object_name;

-- Sovereign safety assertion.
select
  'sovereign_boundary' as section,
  'no_waq_assets_mutation_in_this_script' as check_key,
  true as passed,
  'Read-only dependency audit only; no DDL/DML; no waqf/waqf_assets/awqaf_system mutation.' as note;
