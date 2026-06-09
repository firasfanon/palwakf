-- Database Wave B-0B
-- Compatibility Wrapper Design Contracts — READ ONLY
-- Purpose: list proposed compatibility wrappers/contracts before any extraction.
-- NO DDL. NO DML. NO DROP. NO waqf_assets mutation.

with targets(object_name, legacy_schema, proposed_owner_schema, owner_system, wrapper_contract_name, contract_kind, design_decision, runtime_risk, blocking_condition) as (
  values
    ('services','public','platform_services','service_center','public.v_compat_services_catalog_v1','view','design_wrapper_before_extraction','high','map public.services columns to platform_services catalog/forms without changing current runtime'),
    ('servicetypes','public','platform_services','service_center','public.v_compat_service_types_v1','view','design_wrapper_before_extraction','medium','confirm taxonomy source and route binding'),
    ('serviceproviders','public','platform_services_or_facilities','service_center','public.v_compat_service_providers_v1','view','defer_until_owner_schema_confirmed','medium','target schema/owner unresolved: provider/facility ownership'),
    ('servicepoints','public','platform_services_or_facilities','service_center','public.v_compat_service_points_v1','view','defer_until_owner_schema_confirmed','medium','target schema/owner unresolved: spatial/facility/service point authority'),
    ('home_services','public','platform_services_or_platform_content','service_center','public.v_compat_home_services_v1','view','defer_until_homepage_mapping_confirmed','medium','homepage display versus service catalog authority overlap'),
    ('news_articles','public','media_center','media_center','public.v_compat_media_news_articles_v1','view','design_wrapper_before_extraction','high','preserve editorial/RLS/runtime mappings'),
    ('news','public','media_center','media_center','public.v_compat_media_news_v1','view','design_wrapper_before_extraction','high','legacy public news table with limited/no RLS requires mapping'),
    ('announcements','public','media_center','media_center','public.v_compat_media_announcements_v1','view','design_wrapper_before_extraction','high','preserve publication visibility and workflow status'),
    ('activities','public','media_center','media_center','public.v_compat_media_activities_v1','view','design_wrapper_before_extraction','high','preserve public cards and activity archive runtime'),
    ('breaking_news','public','media_center','media_center','public.v_compat_media_breaking_news_v1','view','design_wrapper_before_extraction','high','RLS/publishing governance required'),
    ('media_gallery_items','public','media_center','media_center','public.v_compat_media_gallery_items_v1','view','design_wrapper_before_extraction','high','preserve media gallery admin/public runtime'),
    ('locations','public','gis','mustakshif_gis','public.v_compat_locations_v1','view','manual_decision_required','critical','authority conflict public.locations vs gis.locations must be resolved first')
), existing as (
  select
    t.*,
    exists(select 1 from information_schema.tables it where it.table_schema=t.legacy_schema and it.table_name=t.object_name) as legacy_table_exists,
    exists(select 1 from information_schema.schemata s where s.schema_name=t.proposed_owner_schema) as exact_target_schema_exists,
    exists(select 1 from information_schema.schemata s where t.proposed_owner_schema like s.schema_name || '%') as partial_target_schema_exists
  from targets t
)
select
  'b0b_wrapper_design_contracts' as section,
  object_name,
  legacy_schema,
  proposed_owner_schema,
  owner_system,
  wrapper_contract_name,
  contract_kind,
  legacy_table_exists,
  exact_target_schema_exists,
  partial_target_schema_exists,
  design_decision,
  runtime_risk,
  blocking_condition,
  'read_only_design_only_no_runtime_change' as b0b_scope
from existing
order by
  case runtime_risk when 'critical' then 0 when 'high' then 1 when 'medium' then 2 else 3 end,
  owner_system,
  object_name;
