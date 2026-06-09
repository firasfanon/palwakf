-- Database Wave B-1A — Media Wrapper Nonzero + Runtime Reroute Preflight
-- 01: Contract presence and shape check (READ ONLY)
-- Scope: checks required schemas/views/RPC/columns only. No DDL, no DML, no Flutter reroute.

with expected_objects as (
  select * from (values
    ('schema','media_center',null),
    ('table','media_center','content_items'),
    ('table','media_center','editorial_events'),
    ('view','media_center','v_content_items_public_v1'),
    ('view','public','v_media_content_compat_v1'),
    ('view','public','v_media_news_compat_v1'),
    ('view','public','v_media_announcements_compat_v1'),
    ('view','public','v_media_activities_compat_v1'),
    ('view','public','v_media_gallery_compat_v1')
  ) as t(object_type, schema_name, object_name)
), object_checks as (
  select
    'media_contract_presence' as section,
    object_type,
    case
      when object_type='schema' then schema_name
      else schema_name || '.' || object_name
    end as contract_name,
    case
      when object_type='schema' then to_regnamespace(schema_name) is not null
      else to_regclass(schema_name || '.' || object_name) is not null
    end as passed,
    case
      when object_type='schema' and to_regnamespace(schema_name) is not null then 'present'
      when object_type<>'schema' and to_regclass(schema_name || '.' || object_name) is not null then 'present'
      else 'missing_preflight_blocker'
    end as decision
  from expected_objects
), expected_columns as (
  select * from (values
    ('media_center','content_items','id'),
    ('media_center','content_items','content_key'),
    ('media_center','content_items','content_type'),
    ('media_center','content_items','title_ar'),
    ('media_center','content_items','status'),
    ('media_center','content_items','visibility_scope'),
    ('media_center','content_items','published_at'),
    ('media_center','content_items','legacy_source'),
    ('media_center','content_items','legacy_source_id'),
    ('public','v_media_content_compat_v1','id'),
    ('public','v_media_content_compat_v1','content_key'),
    ('public','v_media_content_compat_v1','content_type'),
    ('public','v_media_content_compat_v1','title_ar'),
    ('public','v_media_content_compat_v1','summary_ar'),
    ('public','v_media_content_compat_v1','category_key'),
    ('public','v_media_content_compat_v1','unit_slug'),
    ('public','v_media_content_compat_v1','published_at'),
    ('public','v_media_content_compat_v1','metadata'),
    ('public','v_media_content_compat_v1','source_schema_name'),
    ('public','v_media_content_compat_v1','compatibility_contract')
  ) as t(table_schema, table_name, column_name)
), column_checks as (
  select
    'media_contract_column_shape' as section,
    'column' as object_type,
    table_schema || '.' || table_name || '.' || column_name as contract_name,
    exists (
      select 1
      from information_schema.columns c
      where c.table_schema = expected_columns.table_schema
        and c.table_name = expected_columns.table_name
        and c.column_name = expected_columns.column_name
    ) as passed,
    case when exists (
      select 1
      from information_schema.columns c
      where c.table_schema = expected_columns.table_schema
        and c.table_name = expected_columns.table_name
        and c.column_name = expected_columns.column_name
    ) then 'present' else 'missing_preflight_blocker' end as decision
  from expected_columns
), rpc_check as (
  select
    'media_rpc_contract_presence' as section,
    'rpc' as object_type,
    'public.rpc_media_content_compat_v1(text,text,text,integer,integer)' as contract_name,
    to_regprocedure('public.rpc_media_content_compat_v1(text,text,text,integer,integer)') is not null as passed,
    case
      when to_regprocedure('public.rpc_media_content_compat_v1(text,text,text,integer,integer)') is not null then 'present'
      else 'missing_preflight_blocker'
    end as decision
)
select * from object_checks
union all select * from column_checks
union all select * from rpc_check
order by section, contract_name;
