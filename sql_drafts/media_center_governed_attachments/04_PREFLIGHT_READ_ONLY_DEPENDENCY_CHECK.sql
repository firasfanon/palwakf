
-- READ ONLY - safe diagnostic before any future attachment apply.

select
  table_schema,
  table_name
from information_schema.tables
where table_schema = 'media_center'
  and table_name in (
    'content_assets',
    'content_items',
    'news_articles',
    'announcements',
    'activities',
    'media_gallery_items',
    'media_center_audit_events'
  )
order by table_name;

select
  table_schema,
  table_name,
  column_name,
  data_type,
  is_nullable
from information_schema.columns
where table_schema = 'media_center'
  and table_name in (
    'content_assets',
    'content_items',
    'news_articles',
    'announcements',
    'activities',
    'media_gallery_items',
    'media_center_audit_events'
  )
order by table_name, ordinal_position;
