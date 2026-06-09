-- Database Wave B-1A — Media Bootstrap Readiness Recheck
-- READ ONLY. No DDL. No DML. No migration.

with media_targets(object_name) as (
  values
    ('activities'),
    ('announcements'),
    ('breaking_news'),
    ('media_gallery_items'),
    ('news'),
    ('news_articles')
),
media_center_stats as (
  select
    exists(select 1 from information_schema.schemata where schema_name='media_center') as media_center_schema_exists,
    (select count(*) from information_schema.tables where table_schema='media_center' and table_type='BASE TABLE') as media_center_table_count,
    (select count(*) from information_schema.views where table_schema='media_center') as media_center_view_count
)
select
  'media_bootstrap_readiness_recheck' as section,
  mt.object_name,
  mcs.media_center_schema_exists,
  mcs.media_center_table_count,
  mcs.media_center_view_count,
  exists(
    select 1 from information_schema.tables t
    where t.table_schema='public'
      and t.table_name=mt.object_name
      and t.table_type='BASE TABLE'
  ) as public_table_exists,
  coalesce((
    select count(*) from information_schema.columns c
    where c.table_schema='public' and c.table_name=mt.object_name
  ),0) as public_column_count,
  coalesce((
    select count(*) from pg_policies p
    where p.schemaname='public' and p.tablename=mt.object_name
  ),0) as public_rls_policy_count,
  case
    when mcs.media_center_schema_exists is false then 'blocked_media_center_schema_missing'
    when mcs.media_center_table_count < 3 then 'blocked_media_center_under_bootstrapped'
    else 'requires_editorial_rls_runtime_certification'
  end as b1a_media_decision
from media_targets mt
cross join media_center_stats mcs
order by mt.object_name;
