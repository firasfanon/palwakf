-- PalWakf Platform — Mega Batch N2.34
-- 49_cache_candidates_strict_gate_single_result_READ_ONLY_N2_34.sql
-- Purpose: Strict single-result dependency gate for public.org_units_cache and public.pwf_org_units_cache.
-- Safety: SELECT-only. No DDL/DML. No waqf/waqf_assets/awqaf_system mutation.
-- Fixes parser risk by using: not (coalesce(view_definition, '') ~* pattern)

with candidates(source_schema, object_name, fqname) as (
  values
    ('public','org_units_cache','public.org_units_cache'),
    ('public','pwf_org_units_cache','public.pwf_org_units_cache')
),
rel as (
  select c.*, to_regclass(c.fqname) as oid
  from candidates c
),
rel_status as (
  select
    r.source_schema,
    r.object_name,
    r.fqname,
    r.oid,
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
      where coalesce(v.view_definition, '') ~* ('\m' || c.object_name || '\M')
    )::bigint as dependency_count,
    coalesce(string_agg(v.table_schema || '.' || v.table_name, ', ' order by v.table_schema, v.table_name)
      filter (where coalesce(v.view_definition, '') ~* ('\m' || c.object_name || '\M')), 'none') as dependencies
  from candidates c
  left join information_schema.views v on true
  group by c.object_name
),
matview_usage as (
  select
    c.object_name,
    count(*) filter (
      where coalesce(mv.definition, '') ~* ('\m' || c.object_name || '\M')
    )::bigint as dependency_count,
    coalesce(string_agg(mv.schemaname || '.' || mv.matviewname, ', ' order by mv.schemaname, mv.matviewname)
      filter (where coalesce(mv.definition, '') ~* ('\m' || c.object_name || '\M')), 'none') as dependencies
  from candidates c
  left join pg_matviews mv on true
  group by c.object_name
),
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
      where coalesce(fs.definition, '') ~* ('\m' || c.object_name || '\M')
    )::bigint as dependency_count,
    coalesce(string_agg(fs.nspname || '.' || fs.proname || '(' || fs.args || ')', ', ' order by fs.nspname, fs.proname, fs.args)
      filter (where coalesce(fs.definition, '') ~* ('\m' || c.object_name || '\M')), 'none') as dependencies
  from candidates c
  left join function_source fs on true
  group by c.object_name
),
fk_usage as (
  select
    c.object_name,
    count(*)::bigint as dependency_count,
    coalesce(string_agg(con.conrelid::regclass::text || '.' || con.conname, ', ' order by con.conrelid::regclass::text, con.conname), 'none') as dependencies
  from candidates c
  join rel r on r.object_name = c.object_name
  left join pg_constraint con on con.confrelid = r.oid and con.contype = 'f'
  group by c.object_name
),
policy_usage as (
  select
    c.object_name,
    count(*) filter (
      where pol.tablename = c.object_name and pol.schemaname = c.source_schema
    )::bigint as dependency_count,
    coalesce(string_agg(pol.schemaname || '.' || pol.tablename || '.' || pol.policyname, ', ' order by pol.schemaname, pol.tablename, pol.policyname)
      filter (where pol.tablename = c.object_name and pol.schemaname = c.source_schema), 'none') as dependencies
  from candidates c
  left join pg_policies pol on true
  group by c.object_name
),
trigger_usage as (
  select
    c.object_name,
    count(*) filter (where t.tgrelid = r.oid and not t.tgisinternal)::bigint as dependency_count,
    coalesce(string_agg(t.tgname, ', ' order by t.tgname)
      filter (where t.tgrelid = r.oid and not t.tgisinternal), 'none') as dependencies
  from candidates c
  join rel r on r.object_name = c.object_name
  left join pg_trigger t on true
  group by c.object_name
),
public_org_units_contract as (
  select
    count(*) filter (
      where table_schema='public'
        and table_name='org_units'
        and not (coalesce(view_definition, '') ~* '\morg_units_cache\M')
        and not (coalesce(view_definition, '') ~* '\mpwf_org_units_cache\M')
    )::bigint as public_org_units_not_cache_backed_count
  from information_schema.views
),
matrix as (
  select
    rs.object_name,
    rs.relation_exists,
    rs.relkind,
    rs.rls_enabled,
    rs.estimated_rows,
    rs.relation_comment,
    vu.dependency_count as view_dependency_count,
    vu.dependencies as view_dependencies,
    mv.dependency_count as matview_dependency_count,
    mv.dependencies as matview_dependencies,
    fu.dependency_count as function_dependency_count,
    fu.dependencies as function_dependencies,
    fk.dependency_count as fk_dependency_count,
    fk.dependencies as fk_dependencies,
    pu.dependency_count as policy_dependency_count,
    pu.dependencies as policy_dependencies,
    tu.dependency_count as trigger_dependency_count,
    tu.dependencies as trigger_dependencies,
    (select public_org_units_not_cache_backed_count > 0 from public_org_units_contract) as public_org_units_not_cache_backed,
    rs.relation_exists
      and vu.dependency_count = 0
      and mv.dependency_count = 0
      and fu.dependency_count = 0
      and fk.dependency_count = 0
      and pu.dependency_count = 0
      and tu.dependency_count = 0
      and (select public_org_units_not_cache_backed_count > 0 from public_org_units_contract) as strict_quarantine_gate_passed
  from rel_status rs
  join view_usage vu using (object_name)
  join matview_usage mv using (object_name)
  join function_usage fu using (object_name)
  join fk_usage fk using (object_name)
  join policy_usage pu using (object_name)
  join trigger_usage tu using (object_name)
),
rows_out as (
  select 'sovereign_boundary'::text as section, 'no_waq_assets_mutation_in_this_script'::text as check_key, true as passed,
         'Read-only strict cache dependency audit only; no DDL/DML; no waqf/waqf_assets/awqaf_system mutation.'::text as note
  union all
  select 'cache_candidate:' || object_name, 'relation_exists', relation_exists, 'relkind=' || relkind || '; estimated_rows=' || estimated_rows::text || '; comment=' || coalesce(relation_comment, '') from matrix
  union all select 'cache_candidate:' || object_name, 'view_dependency_count_zero', view_dependency_count = 0, 'count=' || view_dependency_count::text || '; deps=' || view_dependencies from matrix
  union all select 'cache_candidate:' || object_name, 'matview_dependency_count_zero', matview_dependency_count = 0, 'count=' || matview_dependency_count::text || '; deps=' || matview_dependencies from matrix
  union all select 'cache_candidate:' || object_name, 'function_dependency_count_zero', function_dependency_count = 0, 'count=' || function_dependency_count::text || '; deps=' || function_dependencies from matrix
  union all select 'cache_candidate:' || object_name, 'fk_dependency_count_zero', fk_dependency_count = 0, 'count=' || fk_dependency_count::text || '; deps=' || fk_dependencies from matrix
  union all select 'cache_candidate:' || object_name, 'policy_dependency_count_zero', policy_dependency_count = 0, 'count=' || policy_dependency_count::text || '; policies=' || policy_dependencies from matrix
  union all select 'cache_candidate:' || object_name, 'trigger_dependency_count_zero', trigger_dependency_count = 0, 'count=' || trigger_dependency_count::text || '; triggers=' || trigger_dependencies from matrix
  union all select 'cache_candidate:' || object_name, 'public_org_units_not_cache_backed', public_org_units_not_cache_backed, 'public.org_units view must not depend on cache candidates.' from matrix
  union all select 'cache_candidate:' || object_name, 'strict_quarantine_gate_passed', strict_quarantine_gate_passed, 'Execution allowed only if all dependency counts are zero and compatibility view is not cache-backed.' from matrix
)
select section, check_key, passed, note
from rows_out
order by section, check_key;
