-- 01_public_runtime_final_contract_counts_read_only.sql
-- Read-only. Verifies final public runtime shell contract counts.

select 'public_runtime_final_counts' as section, 'media_news_compat_rows' as check_key, count(*)::bigint as row_count
from public.v_media_news_compat_v1
union all
select 'public_runtime_final_counts', 'media_announcements_compat_rows', count(*)::bigint
from public.v_media_announcements_compat_v1
union all
select 'public_runtime_final_counts', 'services_catalog_compat_rows', count(*)::bigint
from public.v_services_catalog_compat_v1
union all
select 'public_runtime_final_counts', 'homepage_sections_rows', count(*)::bigint
from public.homepage_sections;
