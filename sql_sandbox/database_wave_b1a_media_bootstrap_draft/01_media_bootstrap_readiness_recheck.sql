-- Database Wave B-1A Media Bootstrap Draft Pack
-- 01_media_bootstrap_readiness_recheck.sql
-- READ ONLY. No DDL/DML.

with targets(object_name) as (
  values
    ('activities'),
    ('announcements'),
    ('breaking_news'),
    ('media_gallery_items'),
    ('news'),
    ('news_articles')
), media_schema as (
  select exists(select 1 from information_schema.schemata where schema_name = 'media_center') as media_center_schema_exists
), media_counts as (
  select
    count(*) filter (where table_type = 'BASE TABLE') as media_center_table_count,
    count(*) filter (where table_type = 'VIEW') as media_center_view_count
  from information_schema.tables
  where table_schema = 'media_center'
), public_tables as (
  select table_name, count(*) as column_count
  from information_schema.columns
  where table_schema = 'public'
  group by table_name
), public_policies as (
  select tablename as table_name, count(*) as rls_policy_count
  from pg_policies
  where schemaname = 'public'
  group by tablename
)
select
  'media_bootstrap_readiness_recheck' as section,
  t.object_name,
  ms.media_center_schema_exists,
  mc.media_center_table_count,
  mc.media_center_view_count,
  (pt.table_name is not null) as public_table_exists,
  coalesce(pt.column_count, 0) as public_column_count,
  coalesce(pp.rls_policy_count, 0) as public_rls_policy_count,
  case
    when not ms.media_center_schema_exists then 'blocked_media_center_schema_missing'
    when mc.media_center_table_count < 3 then 'blocked_media_center_under_bootstrapped'
    else 'review_media_center_bootstrap_maturity'
  end as b1a_media_decision
from targets t
cross join media_schema ms
cross join media_counts mc
left join public_tables pt on pt.table_name = t.object_name
left join public_policies pp on pp.table_name = t.object_name
order by t.object_name;
