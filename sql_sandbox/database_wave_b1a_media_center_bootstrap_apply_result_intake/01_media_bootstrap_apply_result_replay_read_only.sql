-- Database Wave B-1A Media Center Bootstrap Apply Result Replay — READ ONLY
with expected(object_name, object_type, role_key, required_before_activation) as (
  values
    ('content_assets','BASE TABLE','media_assets_and_gallery_support',true),
    ('content_items','BASE TABLE','sovereign_media_content_storage',true),
    ('content_publication_channels','BASE TABLE','public_admin_channel_mapping',true),
    ('editorial_events','BASE TABLE','workflow_audit_trace',true),
    ('v_content_items_admin_v1','VIEW','admin_read_facade',true),
    ('v_content_items_public_v1','VIEW','published_only_public_facade',true),
    ('content_category_map','BASE TABLE','taxonomy_mapping',false)
), cols as (
  select table_schema, table_name, count(*)::int as column_count
  from information_schema.columns where table_schema='media_center' group by table_schema, table_name
), policies as (
  select schemaname, tablename, count(*)::int as policy_count
  from pg_policies where schemaname='media_center' group by schemaname, tablename
), rels as (
  select n.nspname as schema_name, c.relname as object_name, c.relkind, c.relrowsecurity
  from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='media_center'
)
select 'media_center_bootstrap_apply_replay' as section, e.object_name, e.object_type, e.role_key, e.required_before_activation,
  exists(select 1 from information_schema.schemata where schema_name='media_center') as media_center_schema_exists,
  (r.object_name is not null) as object_exists, coalesce(cols.column_count,0) as column_count,
  case when r.relkind in ('r','p') then r.relrowsecurity else false end as rls_enabled,
  coalesce(p.policy_count,0) as rls_policy_count,
  case when r.object_name is null then 'missing_contract'
       when e.object_type='BASE TABLE' and not r.relrowsecurity then 'failed_rls_not_enabled'
       when e.object_type='BASE TABLE' and coalesce(p.policy_count,0)=0 then 'failed_missing_rls_policy'
       else 'passed_contract_replay' end as replay_decision
from expected e
left join rels r on r.object_name=e.object_name
left join cols on cols.table_schema='media_center' and cols.table_name=e.object_name
left join policies p on p.schemaname='media_center' and p.tablename=e.object_name
order by e.required_before_activation desc, e.object_name;
