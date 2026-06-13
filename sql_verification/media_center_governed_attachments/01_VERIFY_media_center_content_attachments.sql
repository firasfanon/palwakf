
-- READ ONLY
-- Media Center Governed Attachments verification.

select
  'media_center_content_attachments_table' as section,
  exists (
    select 1
    from information_schema.tables
    where table_schema = 'media_center'
      and table_name = 'content_attachments'
      and table_type = 'BASE TABLE'
  ) as table_present;

select
  'media_center_content_attachments_columns' as section,
  column_name,
  data_type,
  is_nullable
from information_schema.columns
where table_schema = 'media_center'
  and table_name = 'content_attachments'
order by ordinal_position;

select
  'media_center_content_attachments_policies' as section,
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
from pg_policies
where schemaname = 'media_center'
  and tablename = 'content_attachments'
order by policyname;

select
  'media_center_content_attachments_public_wrapper' as section,
  exists (
    select 1
    from information_schema.views
    where table_schema = 'public'
      and table_name = 'v_media_center_content_attachments_public_v1'
  ) as public_wrapper_present;
