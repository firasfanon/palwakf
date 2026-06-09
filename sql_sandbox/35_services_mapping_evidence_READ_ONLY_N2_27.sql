-- PalWakf N2.27
-- Read-only services mapping evidence.

select
  'services_mapping_evidence' as section,
  t.table_schema,
  t.table_name,
  t.table_type,
  case
    when t.table_name = 'services' then 'platform_services'
    when t.table_name = 'home_services' then 'platform_services_or_platform_content'
    when t.table_name in ('servicepoints','serviceproviders','servicetypes') then 'platform_services_or_facilities_module'
    else 'manual_review'
  end as proposed_owner,
  coalesce(p.policy_count, 0) as rls_policy_count
from information_schema.tables t
left join (
  select schemaname, tablename, count(*) as policy_count
  from pg_policies
  group by schemaname, tablename
) p on p.schemaname = t.table_schema and p.tablename = t.table_name
where t.table_schema = 'public'
  and t.table_name in ('services','home_services','servicepoints','serviceproviders','servicetypes')
order by t.table_name;
