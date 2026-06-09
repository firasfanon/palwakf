with missing_schema_matrix(target_schema, public_table_count, future_create_schema_sql_not_authorized) as (
  values
    ('complaints', 4, 'CREATE SCHEMA IF NOT EXISTS complaints;'),
    ('legacy_quarantine', 2, 'CREATE SCHEMA IF NOT EXISTS legacy_quarantine;'),
    ('ministry_profile', 3, 'CREATE SCHEMA IF NOT EXISTS ministry_profile;'),
    ('platform_access', 9, 'CREATE SCHEMA IF NOT EXISTS platform_access;'),
    ('platform_experience', 11, 'CREATE SCHEMA IF NOT EXISTS platform_experience;'),
    ('platform_notifications', 1, 'CREATE SCHEMA IF NOT EXISTS platform_notifications;'),
    ('platform_reporting', 1, 'CREATE SCHEMA IF NOT EXISTS platform_reporting;'),
    ('religious_affairs', 3, 'CREATE SCHEMA IF NOT EXISTS religious_affairs;')
)
select
  'v4_missing_target_schema_creation_authorization_gate' as section,
  target_schema,
  public_table_count,
  'PENDING_OPERATOR_AUTHORIZATION' as schema_creation_authorization_status,
  future_create_schema_sql_not_authorized,
  false as create_schema_authorized_by_this_script,
  false as apply_authorized_by_this_script,
  false as destructive_sql_authorized,
  false as production_approved,
  true as read_only
from missing_schema_matrix
order by target_schema;
