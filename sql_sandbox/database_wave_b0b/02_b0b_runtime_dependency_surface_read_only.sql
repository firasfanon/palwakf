-- Database Wave B-0B
-- Runtime Dependency Surface — READ ONLY
-- Purpose: identify likely direct references to legacy public hotspots in views/functions.
-- NO DDL. NO DML. NO DROP. NO waqf_assets mutation.

with hotspots(object_name) as (
  values
    ('services'),('servicetypes'),('serviceproviders'),('servicepoints'),('home_services'),
    ('news'),('news_articles'),('announcements'),('activities'),('breaking_news'),('media_gallery_items'),
    ('locations')
), view_deps as (
  select
    n.nspname as dependent_schema,
    c.relname as dependent_object,
    'view_or_matview' as dependent_type,
    h.object_name as referenced_hotspot,
    pg_get_viewdef(c.oid, true) as definition_text
  from pg_class c
  join pg_namespace n on n.oid=c.relnamespace
  cross join hotspots h
  where c.relkind in ('v','m')
    and pg_get_viewdef(c.oid, true) ilike ('%' || h.object_name || '%')
), fn_deps as (
  select
    n.nspname as dependent_schema,
    p.proname as dependent_object,
    'function_or_rpc' as dependent_type,
    h.object_name as referenced_hotspot,
    pg_get_functiondef(p.oid) as definition_text
  from pg_proc p
  join pg_namespace n on n.oid=p.pronamespace
  cross join hotspots h
  where pg_get_functiondef(p.oid) ilike ('%' || h.object_name || '%')
), deps as (
  select * from view_deps
  union all
  select * from fn_deps
)
select
  'b0b_runtime_dependency_surface' as section,
  dependent_schema,
  dependent_object,
  dependent_type,
  referenced_hotspot,
  case
    when dependent_schema='public' then 'public_facade_or_rpc_surface'
    when dependent_schema in ('platform_services','media_center','platform_content','gis') then 'target_owner_or_adjacent_schema'
    else 'cross_schema_review_required'
  end as dependency_classification,
  case
    when dependent_schema='public' and dependent_object like 'v_%' then 'preserve_or_version_public_facade'
    when dependent_schema='public' then 'review_public_rpc_wrapper_before_extraction'
    else 'review_before_any_legacy_table_move'
  end as action_recommendation
from deps
order by referenced_hotspot, dependent_schema, dependent_object;
