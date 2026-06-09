-- Database Wave B-1A — Locations Authority Gate Recheck
-- READ ONLY. No DDL. No DML. No migration.

with candidates(source_schema_name, object_name, owner_candidate) as (
  values
    ('gis','locations','spatial_authority_candidate'),
    ('public','locations','legacy_or_operational_locations')
)
select
  'locations_authority_gate_recheck' as section,
  c.source_schema_name,
  c.object_name,
  c.owner_candidate,
  exists(
    select 1 from information_schema.tables t
    where t.table_schema=c.source_schema_name
      and t.table_name=c.object_name
      and t.table_type='BASE TABLE'
  ) as table_exists,
  coalesce((
    select count(*) from information_schema.columns col
    where col.table_schema=c.source_schema_name and col.table_name=c.object_name
  ),0) as column_count,
  coalesce((
    select count(*) from information_schema.columns col
    where col.table_schema=c.source_schema_name
      and col.table_name=c.object_name
      and (lower(col.column_name) in ('geom','geometry','geog','centroid') or lower(col.udt_name) like '%geometry%')
  ),0) as spatial_hint_column_count,
  coalesce((
    select count(*) from pg_policies p
    where p.schemaname=c.source_schema_name and p.tablename=c.object_name
  ),0) as rls_policy_count,
  exists(select 1 from information_schema.tables where table_schema='public' and table_name='locations') as public_locations_exists,
  exists(select 1 from information_schema.tables where table_schema='gis' and table_name='locations') as gis_locations_exists,
  'authority_gate_required_before_wrapper_activation' as b1a_locations_decision
from candidates c
order by c.source_schema_name;
