-- Database Wave B-0A
-- Hotspot conflict scan for public services/media/locations.
-- READ ONLY. No DDL. No DML. No waqf_assets mutation.

with hotspot(source_schema, object_name, target_owner_schema, owner_system, risk_reason) as (
  values
    ('public','services','platform_services','service_center','public service catalog should not remain sovereign in public'),
    ('public','servicepoints','platform_services_or_facilities','service_center','service points need owner decision'),
    ('public','serviceproviders','platform_services_or_facilities','service_center','service providers need owner decision'),
    ('public','servicetypes','platform_services','service_center','service taxonomy should map to platform_services'),
    ('public','home_services','platform_services_or_platform_content','service_center','homepage/service overlap requires mapping'),
    ('public','locations','gis','mustakshif_gis','location authority conflict public.locations vs gis.locations'),
    ('public','news','media_center','media_center','legacy media table candidate'),
    ('public','news_articles','media_center','media_center','legacy media table candidate'),
    ('public','announcements','media_center','media_center','legacy media table candidate'),
    ('public','activities','media_center','media_center','legacy media table candidate'),
    ('public','media_gallery_items','media_center','media_center','legacy media table candidate'),
    ('public','breaking_news','media_center','media_center','legacy media table candidate'),
    ('public','press_releases','media_center','media_center','legacy media table candidate'),
    ('public','official_statements','media_center','media_center','legacy media table candidate'),
    ('public','awareness_campaigns','media_center','media_center','legacy media table candidate'),
    ('public','sanctities_observatory_items','media_center','media_center','legacy media table candidate')
),
existing as (
  select
    h.*,
    c.table_type,
    to_regclass(format('%I.%I', h.source_schema, h.object_name)) is not null as exists_in_public,
    to_regclass(format('%I.%I', h.target_owner_schema, h.object_name)) is not null as same_name_exists_in_target,
    to_regnamespace(h.target_owner_schema) is not null as target_schema_exists
  from hotspot h
  left join information_schema.tables c
    on c.table_schema = h.source_schema and c.table_name = h.object_name
),
policies as (
  select schemaname, tablename, count(*)::int as policy_count
  from pg_policies
  where schemaname = 'public'
  group by schemaname, tablename
),
columns as (
  select table_schema, table_name, count(*)::int as column_count
  from information_schema.columns
  where table_schema = 'public'
  group by table_schema, table_name
)
select
  'public_conflict_hotspots' as section,
  e.source_schema,
  e.object_name,
  e.exists_in_public,
  e.table_type,
  coalesce(c.column_count,0) as column_count,
  coalesce(p.policy_count,0) as rls_policy_count,
  e.target_owner_schema,
  e.owner_system,
  e.target_schema_exists,
  e.same_name_exists_in_target,
  e.risk_reason,
  case
    when not e.exists_in_public then 'not_present_no_action'
    when e.object_name = 'locations' then 'manual_locations_authority_decision_required'
    when coalesce(p.policy_count,0) > 0 then 'high_risk_rls_runtime_mapping_required'
    when not e.target_schema_exists then 'bootstrap_target_schema_before_any_extraction'
    when e.same_name_exists_in_target then 'compare_contracts_before_wrap_or_merge'
    else 'candidate_for_wave_b1_compatibility_wrapper_design'
  end as b0a_decision
from existing e
left join policies p on p.schemaname = e.source_schema and p.tablename = e.object_name
left join columns c on c.table_schema = e.source_schema and c.table_name = e.object_name
order by e.exists_in_public desc, e.owner_system, e.object_name;
