-- Database Wave B-0C — Runtime Dependency Validation
-- 02_public_runtime_hotspot_usage_read_only.sql
-- Purpose: database-side support check for public hotspot objects and target owner existence.
-- Read-only. No DDL/DML. No waqf_assets mutation.

with hotspots as (
  select * from (values
    ('services','platform_services'),('home_services','platform_services'),('servicetypes','platform_services'),('serviceproviders','platform_services'),('servicepoints','platform_services'),
    ('news_articles','media_center'),('news','media_center'),('activities','media_center'),('announcements','media_center'),('breaking_news','media_center'),('media_gallery_items','media_center'),
    ('locations','gis'),('homepage_sections','platform'),('site_pages','platform_content'),('user_system_roles','platform'),('user_system_permissions','platform'),('waqf_lands','waqf')
  ) as h(object_name,target_schema)
)
select
  'public_runtime_hotspot_usage' as section,
  h.object_name,
  h.target_schema,
  exists(select 1 from information_schema.schemata where schema_name=h.target_schema) as target_schema_exists,
  exists(select 1 from information_schema.tables where table_schema='public' and table_name=h.object_name) as public_table_exists,
  exists(select 1 from information_schema.views where table_schema='public' and table_name=h.object_name) as public_view_exists,
  coalesce((select count(*) from information_schema.columns where table_schema='public' and table_name=h.object_name),0) as public_column_count,
  coalesce((select count(*) from pg_policies where schemaname='public' and tablename=h.object_name),0) as public_rls_policy_count,
  case
    when h.object_name='locations' then 'authority_gate_required_before_wrapper_activation'
    when h.target_schema in ('waqf') then 'critical_read_only_boundary'
    when h.target_schema='media_center' then 'media_bootstrap_required_before_extraction'
    when h.target_schema='platform_services' then 'service_wrapper_design_then_runtime_validation'
    else 'classify_dependency_before_b1'
  end as b0c_decision
from hotspots h
order by h.target_schema, h.object_name;
