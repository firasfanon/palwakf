select * from (
  select 'public.v_services_catalog_compat_v1' as contract_name, count(*)::bigint as row_count, 'services public contract' as note from public.v_services_catalog_compat_v1
  union all select 'public.homepage_sections', count(*)::bigint, 'homepage dynamic shell controls' from public.homepage_sections
) s
union all
select 'services_decision', null::bigint,
       'platform_services remains owner; public.v_services_catalog_compat_v1 remains the public runtime contract; no servicepoints/serviceproviders reroute until ownership is separately certified';
