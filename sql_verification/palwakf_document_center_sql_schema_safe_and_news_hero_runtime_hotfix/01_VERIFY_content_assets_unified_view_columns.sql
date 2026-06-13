
-- READ ONLY
-- Verify the schema-safe content_assets assumptions used by the updated unified view draft.

select
  'media_center_content_assets_required_columns_for_unified_view' as section,
  required.column_name,
  exists (
    select 1
    from information_schema.columns c
    where c.table_schema = 'media_center'
      and c.table_name = 'content_assets'
      and c.column_name = required.column_name
  ) as column_present
from (
  values
    ('id'),
    ('filename'),
    ('url'),
    ('asset_type'),
    ('mime_type'),
    ('file_size_bytes'),
    ('storage_bucket'),
    ('storage_path'),
    ('content_item_id'),
    ('created_at')
) as required(column_name)
order by required.column_name;

select
  'media_center_content_assets_status_column_absent_expected' as section,
  not exists (
    select 1
    from information_schema.columns c
    where c.table_schema = 'media_center'
      and c.table_name = 'content_assets'
      and c.column_name = 'status'
  ) as status_column_absent_expected;
