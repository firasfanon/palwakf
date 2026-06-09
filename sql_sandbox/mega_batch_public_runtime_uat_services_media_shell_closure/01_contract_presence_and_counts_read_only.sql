-- Mega Batch Public Runtime UAT + Services/Media Shell Closure
-- 01_contract_presence_and_counts_read_only.sql
-- READ ONLY. No DML. No production approval.

select 'public_runtime_contract_presence' as section,
       'public.v_media_news_compat_v1' as contract_name,
       to_regclass('public.v_media_news_compat_v1') is not null as passed,
       case when to_regclass('public.v_media_news_compat_v1') is not null then 'present' else 'missing' end as decision
union all
select 'public_runtime_contract_presence','public.v_media_announcements_compat_v1',to_regclass('public.v_media_announcements_compat_v1') is not null,case when to_regclass('public.v_media_announcements_compat_v1') is not null then 'present' else 'missing' end
union all
select 'public_runtime_contract_presence','public.v_services_catalog_compat_v1',to_regclass('public.v_services_catalog_compat_v1') is not null,case when to_regclass('public.v_services_catalog_compat_v1') is not null then 'present' else 'missing' end
union all
select 'public_runtime_contract_presence','public.homepage_sections',to_regclass('public.homepage_sections') is not null,case when to_regclass('public.homepage_sections') is not null then 'present' else 'missing' end;

select 'public_runtime_counts' as section, 'media_news_compat_rows' as check_key, count(*)::bigint as row_count from public.v_media_news_compat_v1
union all
select 'public_runtime_counts','media_announcements_compat_rows',count(*)::bigint from public.v_media_announcements_compat_v1
union all
select 'public_runtime_counts','services_catalog_compat_rows',count(*)::bigint from public.v_services_catalog_compat_v1
union all
select 'public_runtime_counts','homepage_sections_rows',count(*)::bigint from public.homepage_sections;
