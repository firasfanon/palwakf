-- Public Services Legacy Compatibility Repair — read-only contract diagnostic
-- No DDL/DML/GRANT/DROP. No waqf/awqaf_system/GIS mutation.

with objects as (
  select * from (values
    ('public.services', to_regclass('public.services') is not null),
    ('public.home_services', to_regclass('public.home_services') is not null),
    ('public.v_services_catalog_compat_v1', to_regclass('public.v_services_catalog_compat_v1') is not null),
    ('public.rpc_services_catalog_compat_v1', to_regprocedure('public.rpc_services_catalog_compat_v1()') is not null)
  ) as t(object_name, present)
), columns as (
  select
    table_schema || '.' || table_name as object_name,
    string_agg(column_name, ', ' order by ordinal_position) as columns_present
  from information_schema.columns
  where table_schema = 'public'
    and table_name in ('v_services_catalog_compat_v1', 'services', 'home_services')
  group by table_schema, table_name
)
select
  'public_services_legacy_compatibility_repair_contract' as section,
  o.object_name,
  o.present,
  c.columns_present,
  'read_only_no_mutation' as decision
from objects o
left join columns c on c.object_name = o.object_name
order by o.object_name;
