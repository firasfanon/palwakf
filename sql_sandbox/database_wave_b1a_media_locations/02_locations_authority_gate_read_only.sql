-- Database Wave B-1A — Locations Authority Gate (READ ONLY)
-- This script only detects authority conflict. It does not decide or mutate ownership.

with location_targets(source_schema_name, object_name, owner_candidate) as (
  values
    ('public','locations','legacy_or_operational_locations'),
    ('gis','locations','spatial_authority_candidate')
), detected as (
  select
    t.source_schema_name,
    t.object_name,
    t.owner_candidate,
    exists (
      select 1
      from information_schema.tables it
      where it.table_schema = t.source_schema_name
        and it.table_name = t.object_name
    ) as table_exists,
    coalesce((
      select count(*)
      from information_schema.columns c
      where c.table_schema = t.source_schema_name
        and c.table_name = t.object_name
    ),0) as column_count,
    coalesce((
      select count(*)
      from information_schema.columns c
      where c.table_schema = t.source_schema_name
        and c.table_name = t.object_name
        and lower(c.column_name) in ('geom','geometry','geog','coordinates','lat','lng','latitude','longitude')
    ),0) as spatial_hint_column_count,
    coalesce((
      select count(*)
      from pg_policies p
      where p.schemaname = t.source_schema_name
        and p.tablename = t.object_name
    ),0) as rls_policy_count
  from location_targets t
), conflict as (
  select
    bool_or(source_schema_name = 'public' and table_exists) as public_locations_exists,
    bool_or(source_schema_name = 'gis' and table_exists) as gis_locations_exists
  from detected
)
select
  'locations_authority_gate' as section,
  d.source_schema_name,
  d.object_name,
  d.owner_candidate,
  d.table_exists,
  d.column_count,
  d.spatial_hint_column_count,
  d.rls_policy_count,
  c.public_locations_exists,
  c.gis_locations_exists,
  case
    when c.public_locations_exists and c.gis_locations_exists then 'authority_gate_required_before_wrapper_activation'
    when c.gis_locations_exists and not c.public_locations_exists then 'gis_locations_can_be_considered_authority_after_runtime_review'
    when c.public_locations_exists and not c.gis_locations_exists then 'public_locations_requires_manual_owner_decision'
    else 'no_locations_table_detected'
  end as b1a_locations_decision
from detected d
cross join conflict c
order by d.source_schema_name;
