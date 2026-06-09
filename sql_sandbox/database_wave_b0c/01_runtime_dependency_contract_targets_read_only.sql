-- Database Wave B-0C — Runtime Dependency Validation
-- 01_runtime_dependency_contract_targets_read_only.sql
-- Purpose: return the dependency target matrix that runtime code must be checked against.
-- Read-only. No DDL/DML. No waqf_assets mutation.

with targets as (
  select * from (values
    ('services','public','platform_services','service_center','public service catalog legacy dependency','high','map before any extraction'),
    ('home_services','public','platform_services_or_platform_content','service_center','homepage-service overlap dependency','medium','map homepage section separately'),
    ('servicetypes','public','platform_services','service_center','service taxonomy legacy dependency','medium','map before wrapper activation'),
    ('serviceproviders','public','platform_services_or_facilities','service_center','provider/facility ownership unresolved','medium','manual owner decision'),
    ('servicepoints','public','platform_services_or_facilities_or_gis','service_center','service point spatial/facility dependency','medium','manual owner decision'),
    ('news_articles','public','media_center','media_center','media article runtime dependency','high','media bootstrap and RLS plan required'),
    ('news','public','media_center','media_center','legacy media runtime dependency','high','wrapper design only'),
    ('activities','public','media_center','media_center','media activities runtime dependency','high','media bootstrap and RLS plan required'),
    ('announcements','public','media_center','media_center','media announcements runtime dependency','high','media bootstrap and RLS plan required'),
    ('breaking_news','public','media_center','media_center','breaking news dependency','medium','media bootstrap required'),
    ('media_gallery_items','public','media_center','media_center','gallery dependency','medium','media bootstrap required'),
    ('locations','public','gis','mustakshif_gis','locations authority conflict','high','locations authority gate must close first'),
    ('homepage_sections','public','platform_or_platform_content','platform_core','dynamic homepage dependency','high','do not move before platform registry decision'),
    ('site_pages','public','platform_content_or_platform','platform_core','public page/theme publish dependency','medium','map before extraction'),
    ('user_system_roles','public','platform','platform_core','RBAC legacy dependency','high','platform RBAC wrapper required'),
    ('user_system_permissions','public','platform','platform_core','RBAC legacy dependency','high','platform RBAC wrapper required'),
    ('waqf_lands','public','waqf_or_awqaf_system','awqaf_system','waqf legacy/cross-system sensitive dependency','critical','read-only; no Wave B migration')
  ) as t(object_name,source_schema_name,target_owner_schema,owner_system,dependency_reason,runtime_risk,b0c_decision)
)
select
  'runtime_dependency_contract_targets' as section,
  t.*,
  exists(select 1 from information_schema.tables where table_schema=t.source_schema_name and table_name=t.object_name)
    or exists(select 1 from information_schema.views where table_schema=t.source_schema_name and table_name=t.object_name) as object_exists_in_public
from targets t
order by case runtime_risk when 'critical' then 0 when 'high' then 1 when 'medium' then 2 else 3 end, object_name;
