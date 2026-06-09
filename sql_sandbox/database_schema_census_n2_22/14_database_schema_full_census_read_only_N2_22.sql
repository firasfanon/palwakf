-- N2.22 READ ONLY — Database schema full census
-- Purpose: list schemas, tables, views, sizes, comments, and object counts.
-- No DML. No DDL. No waqf/waqf_assets/awqaf_system mutation.

with objects as (
  select
    n.nspname as schema_name,
    c.relname as object_name,
    case c.relkind
      when 'r' then 'table'
      when 'v' then 'view'
      when 'm' then 'materialized_view'
      when 'p' then 'partitioned_table'
      else c.relkind::text
    end as object_type,
    pg_total_relation_size(c.oid) as total_bytes,
    obj_description(c.oid) as comment
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname not in ('pg_catalog', 'information_schema')
    and c.relkind in ('r','v','m','p')
)
select * from objects
order by schema_name, object_type, object_name;

select
  table_schema,
  count(*) filter (where table_type = 'BASE TABLE') as tables_count,
  count(*) filter (where table_type = 'VIEW') as views_count
from information_schema.tables
where table_schema not in ('pg_catalog', 'information_schema')
group by table_schema
order by tables_count desc, views_count desc;

select
  'sovereign_boundary' as section,
  'no_waq_assets_mutation_in_this_script' as check_key,
  true as passed,
  'Read-only census only; no waqf/waqf_assets/awqaf_system DML.' as note;
