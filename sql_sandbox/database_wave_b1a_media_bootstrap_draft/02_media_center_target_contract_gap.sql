-- Database Wave B-1A Media Bootstrap Draft Pack
-- 02_media_center_target_contract_gap.sql
-- READ ONLY. No DDL/DML.

with planned(object_name, object_type, role_key, required_before_activation) as (
  values
    ('content_items', 'BASE TABLE', 'sovereign_media_content_storage', true),
    ('content_assets', 'BASE TABLE', 'media_assets_and_gallery_support', true),
    ('editorial_events', 'BASE TABLE', 'workflow_audit_trace', true),
    ('content_publication_channels', 'BASE TABLE', 'public_admin_channel_mapping', true),
    ('content_category_map', 'BASE TABLE', 'taxonomy_mapping', false),
    ('v_content_items_admin_v1', 'VIEW', 'admin_read_facade', true),
    ('v_content_items_public_v1', 'VIEW', 'published_only_public_facade', true)
), existing as (
  select table_name as object_name, table_type as object_type
  from information_schema.tables
  where table_schema = 'media_center'
)
select
  'media_center_target_contract_gap' as section,
  p.object_name,
  p.object_type,
  p.role_key,
  p.required_before_activation,
  exists(select 1 from information_schema.schemata where schema_name = 'media_center') as media_center_schema_exists,
  (e.object_name is not null) as object_exists,
  case
    when e.object_name is not null then 'present_review_shape'
    when p.required_before_activation then 'missing_required_before_wrapper_activation'
    else 'missing_optional_before_extraction'
  end as bootstrap_gap_decision
from planned p
left join existing e on e.object_name = p.object_name
order by p.required_before_activation desc, p.object_name;
