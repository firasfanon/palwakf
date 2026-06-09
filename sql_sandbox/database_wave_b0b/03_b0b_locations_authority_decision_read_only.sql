-- Database Wave B-0B
-- Locations Authority Decision Scan — READ ONLY
-- Purpose: compare public.locations and gis.locations shape/existence before manual authority decision.
-- NO DDL. NO DML. NO DROP. NO waqf_assets mutation.

with candidates as (
  select 'public'::text as schema_name, 'locations'::text as table_name
  union all
  select 'gis', 'locations'
), shape as (
  select
    c.schema_name,
    c.table_name,
    exists(select 1 from information_schema.tables t where t.table_schema=c.schema_name and t.table_name=c.table_name) as table_exists,
    (select count(*)::int from information_schema.columns col where col.table_schema=c.schema_name and col.table_name=c.table_name) as column_count,
    exists(select 1 from information_schema.columns col where col.table_schema=c.schema_name and col.table_name=c.table_name and col.column_name in ('geom','geometry','the_geom')) as has_geometry_column,
    exists(select 1 from information_schema.columns col where col.table_schema=c.schema_name and col.table_name=c.table_name and col.column_name in ('lat','lng','latitude','longitude')) as has_lat_lng_columns,
    (select count(*)::int from pg_policies pp where pp.schemaname=c.schema_name and pp.tablename=c.table_name) as rls_policy_count
  from candidates c
)
select
  'b0b_locations_authority_decision_scan' as section,
  schema_name,
  table_name,
  table_exists,
  column_count,
  has_geometry_column,
  has_lat_lng_columns,
  rls_policy_count,
  case
    when schema_name='gis' and table_exists and (has_geometry_column or has_lat_lng_columns) then 'probable_spatial_authority'
    when schema_name='public' and table_exists and not has_geometry_column and not has_lat_lng_columns then 'probable_legacy_or_non_spatial_compatibility_surface'
    when table_exists then 'manual_review_required'
    else 'not_present'
  end as authority_hint,
  'manual_decision_required_before_extraction_or_wrapper_activation' as b0b_decision
from shape
order by schema_name;
