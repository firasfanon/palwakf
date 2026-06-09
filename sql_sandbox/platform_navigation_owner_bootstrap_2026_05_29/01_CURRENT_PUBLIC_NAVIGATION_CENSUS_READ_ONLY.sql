with source_tables as (
  select 'public.services'::text as source_name, to_regclass('public.services') as oid
  union all
  select 'public.home_services', to_regclass('public.home_services')
), row_counts as (
  select
    st.source_name,
    st.oid is not null as source_present,
    case
      when st.source_name = 'public.services' and st.oid is not null then (select count(*)::bigint from public.services)
      when st.source_name = 'public.home_services' and st.oid is not null then (select count(*)::bigint from public.home_services)
      else 0::bigint
    end as row_count
  from source_tables st
), samples as (
  select 'public.services'::text as source_name, coalesce(jsonb_agg(to_jsonb(s) order by s.order_index nulls last, s.title nulls last), '[]'::jsonb) as sample_rows
  from (select * from public.services order by order_index nulls last, title nulls last limit 25) s
  where to_regclass('public.services') is not null
  union all
  select 'public.home_services'::text, coalesce(jsonb_agg(to_jsonb(h)), '[]'::jsonb)
  from (select * from public.home_services limit 25) h
  where to_regclass('public.home_services') is not null
)
select
  'platform_navigation_owner_bootstrap_census'::text as section,
  rc.source_name,
  rc.source_present,
  rc.row_count,
  coalesce(s.sample_rows, '[]'::jsonb) as sample_rows,
  false as migration_authorized_by_this_script,
  false as delete_authorized_by_this_script,
  false as destructive_sql_authorized,
  false as production_approved,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation,
  true as read_only
from row_counts rc
left join samples s on s.source_name = rc.source_name
order by rc.source_name;
