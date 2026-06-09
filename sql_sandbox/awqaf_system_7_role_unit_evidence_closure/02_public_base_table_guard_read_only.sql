select
  'public_base_table_guard_read_only' as section,
  count(*) filter (where table_schema = 'public' and table_type = 'BASE TABLE') as public_base_table_count,
  false as create_public_base_table_authorized,
  false as production_approved,
  true as read_only
from information_schema.tables
where table_schema = 'public';
