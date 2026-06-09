-- Database Wave B-1A — Media Center Bootstrap Readiness (READ ONLY)
-- No DDL, no DML, no table movement, no wrapper activation.

with expected_media_tables(object_name) as (
  values
    ('activities'),
    ('announcements'),
    ('breaking_news'),
    ('media_gallery_items'),
    ('news'),
    ('news_articles')
), media_schema as (
  select exists (
    select 1 from information_schema.schemata where schema_name = 'media_center'
  ) as media_center_schema_exists
), media_schema_counts as (
  select
    count(*) filter (where c.relkind = 'r') as media_center_table_count,
    count(*) filter (where c.relkind = 'v') as media_center_view_count,
    count(*) filter (where c.relkind = 'm') as media_center_materialized_view_count
  from pg_namespace n
  join pg_class c on c.relnamespace = n.oid
  where n.nspname = 'media_center'
), public_media as (
  select
    e.object_name,
    exists (
      select 1
      from information_schema.tables t
      where t.table_schema = 'public'
        and t.table_name = e.object_name
    ) as public_table_exists,
    coalesce((
      select count(*)
      from information_schema.columns col
      where col.table_schema = 'public'
        and col.table_name = e.object_name
    ),0) as public_column_count,
    coalesce((
      select count(*)
      from pg_policies p
      where p.schemaname = 'public'
        and p.tablename = e.object_name
    ),0) as public_rls_policy_count
  from expected_media_tables e
)
select
  'media_center_bootstrap_readiness' as section,
  p.object_name,
  m.media_center_schema_exists,
  c.media_center_table_count,
  c.media_center_view_count,
  c.media_center_materialized_view_count,
  p.public_table_exists,
  p.public_column_count,
  p.public_rls_policy_count,
  case
    when not m.media_center_schema_exists then 'blocked_media_center_schema_missing'
    when c.media_center_table_count < 2 then 'blocked_media_center_under_bootstrapped'
    when p.public_table_exists then 'legacy_public_media_table_detected_bootstrap_required'
    else 'no_public_legacy_table_detected'
  end as b1a_media_decision
from public_media p
cross join media_schema m
cross join media_schema_counts c
order by p.object_name;
