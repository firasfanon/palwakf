-- PalWakf Platform — Mega Batch N2.32
-- 46_wave_b_cache_candidates_single_result_READ_ONLY_N2_32.sql
-- Purpose: Single-result read-only dependency/RLS/RPC/Flutter-gate collector for Wave B cache candidates.
-- Why: Some SQL editors display only the last SELECT; N2.31 SQL45 produced a separate sovereignty result, so the matrix evidence may not be visible.
-- Safety: SELECT-only. No DDL, no DML, no mutation to waqf/waqf_assets/awqaf_system.

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
      where v.view_definition ~* ('\\m' || c.object_name || '\\M')
    )::bigint as dependency_count,
    coalesce(string_agg(v.table_schema || '.' || v.table_name, ', ' order by v.table_schema, v.table_name)
      filter (where v.view_definition ~* ('\\m' || c.object_name || '\\M')), 'none') as dependencies
  from candidates c
  left join information_schema.views v on true
  group by c.object_name
),
matview_usage as (
  select
    c.object_name,
    count(*) filter (
      where mv.definition ~* ('\\m' || c.object_name || '\\M')
    )::bigint as dependency_count,
    coalesce(string_agg(mv.schemaname || '.' || mv.matviewname, ', ' order by mv.schemaname, mv.matviewname)
      filter (where mv.definition ~* ('\\m' || c.object_name || '\\M')), 'none') as dependencies
  from candidates c
  left join pg_matviews mv on true
  group by c.object_name
),
-- Only ordinary functions/procedures in non-system schemas.
-- pg_get_functiondef() is intentionally not called on aggregates/window/system functions.
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
      where fs.definition ~* ('\\m' || c.object_name || '\\M')
    )::bigint as dependency_count,
    coalesce(string_agg(fs.nspname || '.' || fs.proname || '(' || fs.args || ')', ', ' order by fs.nspname, fs.proname, fs.args)
      filter (where fs.definition ~* ('\\m' || c.object_name || '\\M')), 'none') as dependencies
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
    )::bigint as dependency_count,
    coalesce(string_agg(con.conname, ', ' order by con.conname)
      filter (where con.contype = 'f' and (con.conrelid = to_regclass(c.fqname) or con.confrelid = to_regclass(c.fqname))), 'none') as dependencies
  from candidates c
  left join pg_constraint con on true
  group by c.object_name
),
policy_usage as (
  select
    c.object_name,
    count(*) filter (
      where coalesce(pol.qual, '') ~* ('\\m' || c.object_name || '\\M')
         or coalesce(pol.with_check, '') ~* ('\\m' || c.object_name || '\\M')
    )::bigint as dependency_count,
    coalesce(string_agg(pol.schemaname || '.' || pol.tablename || ':' || pol.policyname, ', ' order by pol.schemaname, pol.tablename, pol.policyname)
      filter (where coalesce(pol.qual, '') ~* ('\\m' || c.object_name || '\\M') or coalesce(pol.with_check, '') ~* ('\\m' || c.object_name || '\\M')), 'none') as dependencies
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
    )::bigint as dependency_count,
    coalesce(string_agg(t.tgname, ', ' order by t.tgname)
      filter (where t.tgrelid = to_regclass(c.fqname) and not t.tgisinternal), 'none') as dependencies
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
        and view_definition not ~* '\\morg_units_cache\\M'
        and view_definition not ~* '\\mpwf_org_units_cache\\M'
    ) as public_org_units_not_cache_backed,
    coalesce((
      select view_definition
      from information_schema.views
      where table_schema = 'public'
        and table_name = 'org_units'
      limit 1
    ), '') as public_org_units_view_definition
),
matrix as (
  select
    rs.object_name,
    rs.fqname,
    rs.relation_exists,
    rs.relkind,
    rs.rls_enabled,
    rs.estimated_rows,
    (rs.relation_comment ilike '%deprecated%' or rs.relation_comment ilike '%not source%' or rs.relation_comment ilike '%cache%') as has_deprecation_comment,
    vu.dependency_count as view_dependency_count,
    vu.dependencies as view_dependencies,
    mu.dependency_count as matview_dependency_count,
    mu.dependencies as matview_dependencies,
    fu.dependency_count as function_dependency_count,
    fu.dependencies as function_dependencies,
    fku.dependency_count as fk_dependency_count,
    fku.dependencies as fk_dependencies,
    pu.dependency_count as policy_dependency_count,
    pu.dependencies as policy_dependencies,
    tu.dependency_count as trigger_count,
    tu.dependencies as triggers,
    pou.public_org_units_not_cache_backed,
    (
      rs.relation_exists
      and vu.dependency_count = 0
      and mu.dependency_count = 0
      and fu.dependency_count = 0
      and fku.dependency_count = 0
      and pu.dependency_count = 0
      and tu.dependency_count = 0
      and pou.public_org_units_not_cache_backed
    ) as strict_quarantine_gate_passed,
    concat_ws(' | ',
      'relkind=' || rs.relkind,
      'rows=' || rs.estimated_rows,
      'views=' || vu.dependencies,
      'matviews=' || mu.dependencies,
      'functions=' || fu.dependencies,
      'fks=' || fku.dependencies,
      'policies=' || pu.dependencies,
      'triggers=' || tu.dependencies
    ) as dependency_notes
  from rel_status rs
  left join view_usage vu on vu.object_name = rs.object_name
  left join matview_usage mu on mu.object_name = rs.object_name
  left join function_usage fu on fu.object_name = rs.object_name
  left join fk_usage fku on fku.object_name = rs.object_name
  left join policy_usage pu on pu.object_name = rs.object_name
  left join trigger_usage tu on tu.object_name = rs.object_name
  cross join public_org_units_view pou
),
checks as (
  select
    'sovereign_boundary'::text as section,
    'global'::text as target_object,
    'no_waq_assets_mutation_in_this_script'::text as check_key,
    true as passed,
    0::bigint as metric,
    'Read-only dependency audit only; no DDL/DML; no waqf/waqf_assets/awqaf_system mutation.'::text as note
  union all
  select 'n2_32_result_intake', 'sql45', 'sql45_only_sovereignty_row_received', true, 1,
         'The submitted evidence contains only the sovereignty row. This is accepted as a boundary check, not as a full dependency matrix.'
  union all
  select 'n2_32_decision', 'wave_b_cache_quarantine', 'execute_now_allowed', false, 0,
         'Execution remains blocked until candidate dependency rows are produced and reviewed from this single-result SQL.'
  union all
  select 'n2_32_decision', 'wave_b_cache_quarantine', 'decision', true, 0,
         'DEFER/SPLIT: split SQL evidence collection from quarantine execution. No cache table is moved/dropped/renamed in N2.32.'
  union all
  select 'candidate_matrix', object_name, 'relation_exists', relation_exists, case when relation_exists then 1 else 0 end, fqname || ' relation status: ' || relkind
  from matrix
  union all
  select 'candidate_matrix', object_name, 'has_deprecation_or_cache_comment', has_deprecation_comment, case when has_deprecation_comment then 1 else 0 end,
         'Comment marker helps classify cache/deprecated status; absence does not prove active usage.'
  from matrix
  union all
  select 'candidate_matrix', object_name, 'view_dependency_count_zero', view_dependency_count = 0, view_dependency_count, view_dependencies
  from matrix
  union all
  select 'candidate_matrix', object_name, 'matview_dependency_count_zero', matview_dependency_count = 0, matview_dependency_count, matview_dependencies
  from matrix
  union all
  select 'candidate_matrix', object_name, 'function_dependency_count_zero', function_dependency_count = 0, function_dependency_count, function_dependencies
  from matrix
  union all
  select 'candidate_matrix', object_name, 'fk_dependency_count_zero', fk_dependency_count = 0, fk_dependency_count, fk_dependencies
  from matrix
  union all
  select 'candidate_matrix', object_name, 'policy_dependency_count_zero', policy_dependency_count = 0, policy_dependency_count, policy_dependencies
  from matrix
  union all
  select 'candidate_matrix', object_name, 'trigger_count_zero', trigger_count = 0, trigger_count, triggers
  from matrix
  union all
  select 'candidate_matrix', object_name, 'public_org_units_not_cache_backed', public_org_units_not_cache_backed, case when public_org_units_not_cache_backed then 1 else 0 end,
         'public.org_units must remain backed by core.org_units compatibility view, not by cache tables.'
  from matrix
  union all
  select 'candidate_gate', object_name, 'strict_quarantine_gate_passed', strict_quarantine_gate_passed, case when strict_quarantine_gate_passed then 1 else 0 end,
         dependency_notes
  from matrix
)
select section, target_object, check_key, passed, metric, note
from checks
order by
  case section
    when 'sovereign_boundary' then 1
    when 'n2_32_result_intake' then 2
    when 'n2_32_decision' then 3
    when 'candidate_matrix' then 4
    when 'candidate_gate' then 5
    else 99
  end,
  target_object,
  check_key;
