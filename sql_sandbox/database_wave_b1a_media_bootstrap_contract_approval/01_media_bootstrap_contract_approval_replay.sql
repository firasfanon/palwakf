-- Database Wave B-1A Media Bootstrap Contract Approval
-- 01_media_bootstrap_contract_approval_replay.sql
-- Read-only replay of media bootstrap readiness. No DDL/DML.

with media_objects(object_name) as (
  values
    ('activities'),
    ('announcements'),
    ('breaking_news'),
    ('media_gallery_items'),
    ('news'),
    ('news_articles')
), media_schema as (
  select exists(select 1 from information_schema.schemata where schema_name='media_center') as exists_flag
), media_counts as (
  select
    count(*) filter (where table_type='BASE TABLE') as table_count,
    count(*) filter (where table_type='VIEW') as view_count
  from information_schema.tables
  where table_schema='media_center'
), public_contract as (
  select
    mo.object_name,
    exists(select 1 from information_schema.tables t where t.table_schema='public' and t.table_name=mo.object_name) as public_table_exists,
    coalesce((select count(*) from information_schema.columns c where c.table_schema='public' and c.table_name=mo.object_name),0) as public_column_count,
    coalesce((select count(*) from pg_policies p where p.schemaname='public' and p.tablename=mo.object_name),0) as public_rls_policy_count
  from media_objects mo
)
select
  'media_bootstrap_contract_approval_replay' as section,
  pc.object_name,
  ms.exists_flag as media_center_schema_exists,
  mc.table_count as media_center_table_count,
  mc.view_count as media_center_view_count,
  pc.public_table_exists,
  pc.public_column_count,
  pc.public_rls_policy_count,
  case
    when mc.table_count < 5 or mc.view_count < 2 then 'contract_approved_but_bootstrap_apply_required'
    else 'bootstrap_contracts_present_ready_for_wrapper_uat'
  end as b1a_media_contract_decision
from public_contract pc
cross join media_schema ms
cross join media_counts mc
order by pc.object_name;
