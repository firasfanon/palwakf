-- Database Wave B-1A — Media Center Bootstrap Controlled Schema Apply UAT
-- Read-only verification after running 01_media_center_bootstrap_schema_apply.sql
with required_objects as (
  select * from (values
    ('content_items','BASE TABLE','sovereign_media_content_storage', true),
    ('content_assets','BASE TABLE','media_assets_and_gallery_support', true),
    ('editorial_events','BASE TABLE','workflow_audit_trace', true),
    ('content_publication_channels','BASE TABLE','public_admin_channel_mapping', true),
    ('content_category_map','BASE TABLE','taxonomy_mapping', false),
    ('v_content_items_public_v1','VIEW','published_only_public_facade', true),
    ('v_content_items_admin_v1','VIEW','admin_read_facade', true)
  ) as t(object_name, object_type, role_key, required_before_activation)
), info as (
  select
    ro.object_name,
    ro.object_type,
    ro.role_key,
    ro.required_before_activation,
    exists(select 1 from information_schema.schemata s where s.schema_name='media_center') as media_center_schema_exists,
    exists(
      select 1 from information_schema.tables it
      where it.table_schema='media_center'
        and it.table_name=ro.object_name
        and it.table_type=ro.object_type
    ) as object_exists,
    coalesce((
      select count(*)::int from information_schema.columns c
      where c.table_schema='media_center' and c.table_name=ro.object_name
    ),0) as column_count,
    coalesce((
      select c.relrowsecurity
      from pg_class c join pg_namespace n on n.oid=c.relnamespace
      where n.nspname='media_center' and c.relname=ro.object_name
    ), false) as rls_enabled,
    coalesce((
      select count(*)::int from pg_policies p
      where p.schemaname='media_center' and p.tablename=ro.object_name
    ),0) as rls_policy_count
  from required_objects ro
)
select
  'media_center_bootstrap_apply_uat' as section,
  object_name,
  object_type,
  role_key,
  required_before_activation,
  media_center_schema_exists,
  object_exists,
  column_count,
  rls_enabled,
  rls_policy_count,
  case
    when object_exists and object_type='BASE TABLE' and rls_enabled then 'passed_table_contract_with_rls'
    when object_exists and object_type='VIEW' then 'passed_view_contract'
    when object_exists then 'passed_object_contract'
    else 'failed_missing_required_object'
  end as apply_decision
from info
order by required_before_activation desc, object_type, object_name;
