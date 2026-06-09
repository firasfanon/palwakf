-- N2.26 READ ONLY: Locations Result Intake
select
  'locations_result_intake' as section,
  n.nspname as schema_name,
  c.relname as table_name,
  case c.relkind when 'r' then 'table' when 'v' then 'view' else c.relkind::text end as object_type,
  pg_total_relation_size(c.oid) as total_bytes,
  (select count(*) from information_schema.columns col where col.table_schema=n.nspname and col.table_name=c.relname) as columns_count,
  'manual_review' as decision
from pg_class c
join pg_namespace n on n.oid=c.relnamespace
where (n.nspname,c.relname) in (('gis','locations'),('public','locations'))
order by n.nspname;
