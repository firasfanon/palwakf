-- Database Wave B-0A
-- Public Ownership Inventory + Compatibility Classification + Readiness Audit
-- READ ONLY. No DDL. No DML. No waqf_assets mutation.

with public_objects as (
  select
    n.nspname as source_schema,
    c.relname as object_name,
    case c.relkind
      when 'r' then 'table'
      when 'p' then 'partitioned_table'
      when 'v' then 'view'
      when 'm' then 'materialized_view'
      when 'f' then 'foreign_table'
      else c.relkind::text
    end as object_type,
    obj_description(c.oid, 'pg_class') as object_comment,
    c.oid
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public'
    and c.relkind in ('r','p','v','m','f')
),
row_estimates as (
  select
    schemaname as source_schema,
    relname as object_name,
    n_live_tup::bigint as estimated_rows
  from pg_stat_user_tables
  where schemaname = 'public'
),
policies as (
  select
    schemaname as source_schema,
    tablename as object_name,
    count(*)::int as rls_policy_count
  from pg_policies
  where schemaname = 'public'
  group by schemaname, tablename
),
columns_scan as (
  select
    table_schema as source_schema,
    table_name as object_name,
    bool_or(column_name in ('geom','geometry','the_geom','centroid','lat','lng','longitude','latitude')) as has_spatial_columns,
    bool_or(column_name in ('status','workflow_status','review_status','published_at','is_published','public_visibility')) as has_publication_or_workflow_columns,
    bool_or(column_name in ('service_id','service_type_id','provider_id','service_request_id')) as has_service_columns,
    bool_or(column_name in ('headline','title','summary','body','content','media_url','image_url')) as has_content_columns,
    bool_or(column_name in ('waqf_asset_id','asset_id')) as has_waqf_asset_link,
    count(*)::int as column_count
  from information_schema.columns
  where table_schema = 'public'
  group by table_schema, table_name
),
classification as (
  select
    po.*,
    coalesce(re.estimated_rows, 0) as estimated_rows,
    coalesce(p.rls_policy_count, 0) as rls_policy_count,
    coalesce(cs.column_count, 0) as column_count,
    coalesce(cs.has_spatial_columns, false) as has_spatial_columns,
    coalesce(cs.has_publication_or_workflow_columns, false) as has_publication_or_workflow_columns,
    coalesce(cs.has_service_columns, false) as has_service_columns,
    coalesce(cs.has_content_columns, false) as has_content_columns,
    coalesce(cs.has_waqf_asset_link, false) as has_waqf_asset_link,
    case
      when po.object_name in ('services','servicepoints','serviceproviders','servicetypes','home_services') then 'platform_services'
      when po.object_name in ('news','news_articles','news_items','announcements','announcement_items','activities','media_gallery_items','breaking_news','press_releases','official_statements','awareness_campaigns','sanctities_observatory_items') then 'media_center'
      when po.object_name in ('center_content_items','homepage_sections','site_sections','public_pages','navigation_items') then 'platform_content_or_platform'
      when po.object_name in ('locations') then 'gis_or_unresolved_locations'
      when po.object_name like 'v_%' then 'public_facade'
      when po.object_name like 'rpc_%' then 'public_rpc_wrapper'
      when coalesce(cs.has_spatial_columns,false) then 'gis'
      when coalesce(cs.has_service_columns,false) then 'platform_services'
      when coalesce(cs.has_content_columns,false) then 'platform_content_or_media_center'
      when coalesce(cs.has_waqf_asset_link,false) then 'waqf_or_cross_system_reference'
      else 'unresolved'
    end as proposed_owner_system,
    case
      when po.object_type in ('view','materialized_view') or po.object_name like 'v_%' then 'compatibility-view-or-public-contract'
      when po.object_name in ('services','servicepoints','serviceproviders','servicetypes','home_services') then 'legacy-direct-table-services-quarantine-candidate'
      when po.object_name in ('news','news_articles','news_items','announcements','announcement_items','activities','media_gallery_items','breaking_news','press_releases','official_statements','awareness_campaigns','sanctities_observatory_items') then 'legacy-direct-table-media-quarantine-candidate'
      when po.object_name = 'locations' then 'unresolved-location-authority-review'
      when po.source_schema = 'public' and po.object_type = 'table' then 'legacy-direct-table-review-required'
      else 'approved-public-contract-or-unresolved'
    end as compatibility_state,
    case
      when coalesce(p.rls_policy_count, 0) > 0 then 'high'
      when po.object_name in ('services','locations','news','news_articles','announcements','activities') then 'high'
      when po.object_type in ('view','materialized_view') then 'medium'
      else 'medium'
    end as runtime_risk,
    case
      when po.object_name = 'locations' then 'manual_review_before_any_change'
      when coalesce(p.rls_policy_count, 0) > 0 then 'do_not_move_without_rls_and_runtime_plan'
      when po.object_type in ('view','materialized_view') then 'preserve_as_facade_or_version_contract'
      when po.object_name in ('services','servicepoints','serviceproviders','servicetypes','home_services') then 'map_to_platform_services_before_extraction'
      when po.object_name in ('news','news_articles','news_items','announcements','announcement_items','activities','media_gallery_items','breaking_news','press_releases','official_statements','awareness_campaigns','sanctities_observatory_items') then 'map_to_media_center_before_extraction'
      else 'classify_before_wave_b1'
    end as action_recommendation
  from public_objects po
  left join row_estimates re on re.source_schema = po.source_schema and re.object_name = po.object_name
  left join policies p on p.source_schema = po.source_schema and p.object_name = po.object_name
  left join columns_scan cs on cs.source_schema = po.source_schema and cs.object_name = po.object_name
)
select
  'public_ownership_inventory' as section,
  source_schema,
  object_name,
  object_type,
  estimated_rows,
  column_count,
  rls_policy_count,
  has_spatial_columns,
  has_publication_or_workflow_columns,
  has_service_columns,
  has_content_columns,
  has_waqf_asset_link,
  proposed_owner_system,
  compatibility_state,
  runtime_risk,
  action_recommendation
from classification
order by
  case runtime_risk when 'high' then 1 when 'medium' then 2 else 3 end,
  source_schema,
  object_name;
