with required_schemas(schema_name) as (
  values
    ('complaints'),
    ('legacy_quarantine'),
    ('ministry_profile'),
    ('platform_access'),
    ('platform_experience'),
    ('platform_notifications'),
    ('platform_reporting'),
    ('religious_affairs')
), presence as (
  select
    r.schema_name,
    exists (
      select 1 from information_schema.schemata s
      where s.schema_name = r.schema_name
    ) as schema_present
  from required_schemas r
)
select
  'v4_wave0_missing_schema_presence_retest_detail' as section,
  schema_name,
  schema_present,
  false as apply_authorized_by_this_script,
  false as production_approved,
  true as read_only
from presence
order by schema_name;

with required_schemas(schema_name) as (
  values
    ('complaints'),('legacy_quarantine'),('ministry_profile'),('platform_access'),
    ('platform_experience'),('platform_notifications'),('platform_reporting'),('religious_affairs')
), presence as (
  select r.schema_name,
         exists (select 1 from information_schema.schemata s where s.schema_name = r.schema_name) as schema_present
  from required_schemas r
)
select
  'v4_wave0_missing_schema_presence_retest_summary' as section,
  count(*) as required_schema_count,
  count(*) filter (where schema_present) as present_schema_count,
  bool_and(schema_present) as all_required_schemas_present,
  false as apply_authorized_by_this_script,
  false as production_approved,
  true as read_only
from presence;
