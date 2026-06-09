-- N2.23 — Public Tables Dependency Audit Read-only
-- Use before moving any public table to archive/system schema.

with public_tables as (
  select c.oid, n.nspname as schema_name, c.relname as table_name
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public'
    and c.relkind in ('r','p','m')
), view_deps as (
  select
    source_table.oid as source_oid,
    count(distinct dependent_view.oid) as dependent_view_count,
    string_agg(distinct dependent_ns.nspname || '.' || dependent_view.relname, ', ' order by dependent_ns.nspname || '.' || dependent_view.relname) as dependent_views
  from pg_depend d
  join pg_rewrite r on r.oid = d.objid
  join pg_class dependent_view on dependent_view.oid = r.ev_class
  join pg_namespace dependent_ns on dependent_ns.oid = dependent_view.relnamespace
  join pg_class source_table on source_table.oid = d.refobjid
  join pg_namespace source_ns on source_ns.oid = source_table.relnamespace
  where source_ns.nspname = 'public'
  group by source_table.oid
), fk_deps as (
  select
    confrelid as source_oid,
    count(*) as referenced_by_fk_count,
    string_agg(conrelid::regclass::text || '.' || conname, ', ' order by conrelid::regclass::text || '.' || conname) as fk_references
  from pg_constraint
  where contype = 'f'
  group by confrelid
), rls as (
  select schemaname as schema_name, tablename as table_name, count(*) as rls_policy_count
  from pg_policies
  where schemaname = 'public'
  group by schemaname, tablename
)
select
  p.schema_name,
  p.table_name,
  coalesce(v.dependent_view_count, 0) as dependent_view_count,
  coalesce(v.dependent_views, '') as dependent_views,
  coalesce(f.referenced_by_fk_count, 0) as referenced_by_fk_count,
  coalesce(f.fk_references, '') as fk_references,
  coalesce(r.rls_policy_count, 0) as rls_policy_count,
  case
    when coalesce(v.dependent_view_count, 0) > 0 or coalesce(f.referenced_by_fk_count, 0) > 0 or coalesce(r.rls_policy_count, 0) > 0 then 'do_not_move_without_plan'
    when p.table_name ilike '%cache%' or p.table_name ilike '%backup%' or p.table_name ilike '%old%' or p.table_name ilike '%test%' or p.table_name ilike '%uat%' then 'archive_candidate_after_flutter_rpc_check'
    else 'manual_review'
  end as movement_gate
from public_tables p
left join view_deps v on v.source_oid = p.oid
left join fk_deps f on f.source_oid = p.oid
left join rls r on r.schema_name = p.schema_name and r.table_name = p.table_name
order by movement_gate desc, p.table_name;
