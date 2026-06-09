-- Mega Batch Public Platform Runtime Consolidation
-- 01_public_runtime_contract_presence_read_only.sql
-- Read-only contract presence and count checks. No DML.

select 'public_runtime_contract_presence' as section,
       'public.v_media_news_compat_v1' as contract_name,
       to_regclass('public.v_media_news_compat_v1') is not null as passed,
       case when to_regclass('public.v_media_news_compat_v1') is not null then 'present' else 'missing' end as decision
union all
select 'public_runtime_contract_presence', 'public.v_media_announcements_compat_v1',
       to_regclass('public.v_media_announcements_compat_v1') is not null,
       case when to_regclass('public.v_media_announcements_compat_v1') is not null then 'present' else 'missing' end
union all
select 'public_runtime_contract_presence', 'public.v_services_catalog_compat_v1',
       to_regclass('public.v_services_catalog_compat_v1') is not null,
       case when to_regclass('public.v_services_catalog_compat_v1') is not null then 'present' else 'missing' end
union all
select 'public_runtime_contract_presence', 'public.homepage_sections',
       to_regclass('public.homepage_sections') is not null,
       case when to_regclass('public.homepage_sections') is not null then 'present' else 'missing' end;
