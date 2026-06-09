-- Platform Navigation Runtime Source Certification Column Census — READ ONLY
-- Purpose: inspect actual owner-wrapper columns visible to PostgREST before/after Flutter retest.
-- No DDL/DML/GRANT/DROP. No public legacy mutation. No production approval.

select
  'platform_navigation_runtime_source_certification_column_census_read_only' as section,
  table_schema,
  table_name,
  ordinal_position,
  column_name,
  data_type
from information_schema.columns
where table_schema = 'public'
  and table_name in (
    'v_platform_navigation_services_catalog_from_owner_v1',
    'v_platform_navigation_home_services_from_owner_v1',
    'v_services_catalog_compat_v1'
  )
order by table_name, ordinal_position;
