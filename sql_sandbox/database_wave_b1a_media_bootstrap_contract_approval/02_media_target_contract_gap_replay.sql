-- Database Wave B-1A Media Bootstrap Contract Approval
-- 02_media_target_contract_gap_replay.sql
-- Read-only gap replay for required media_center target contracts.

with required_objects(object_name, object_type, role_key, required_before_activation) as (
  values
    ('content_items', 'BASE TABLE', 'sovereign_media_content_storage', true),
    ('content_assets', 'BASE TABLE', 'media_assets_and_gallery_support', true),
    ('editorial_events', 'BASE TABLE', 'workflow_audit_trace', true),
    ('content_publication_channels', 'BASE TABLE', 'public_admin_channel_mapping', true),
    ('content_category_map', 'BASE TABLE', 'taxonomy_mapping', false),
    ('v_content_items_admin_v1', 'VIEW', 'admin_read_facade', true),
    ('v_content_items_public_v1', 'VIEW', 'published_only_public_facade', true)
)
select
  'media_center_target_contract_gap_replay' as section,
  r.object_name,
  r.object_type,
  r.role_key,
  r.required_before_activation,
  exists(select 1 from information_schema.schemata where schema_name='media_center') as media_center_schema_exists,
  exists(
    select 1
    from information_schema.tables t
    where t.table_schema='media_center'
      and t.table_name=r.object_name
      and t.table_type=r.object_type
  ) as object_exists,
  case
    when r.required_before_activation and not exists(
      select 1 from information_schema.tables t
      where t.table_schema='media_center'
        and t.table_name=r.object_name
        and t.table_type=r.object_type
    ) then 'missing_required_before_wrapper_activation'
    when not r.required_before_activation and not exists(
      select 1 from information_schema.tables t
      where t.table_schema='media_center'
        and t.table_name=r.object_name
        and t.table_type=r.object_type
    ) then 'missing_optional_before_extraction'
    else 'present'
  end as bootstrap_gap_decision
from required_objects r
order by r.required_before_activation desc, r.object_type, r.object_name;
