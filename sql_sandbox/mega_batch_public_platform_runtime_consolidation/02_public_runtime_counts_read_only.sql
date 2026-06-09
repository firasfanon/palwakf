-- Mega Batch Public Platform Runtime Consolidation
-- 02_public_runtime_counts_read_only.sql
-- Read-only candidate count checks. No DML.

do $$
begin
  raise notice 'Run each SELECT below independently if your SQL editor stops on missing optional views.';
end $$;

select 'public_runtime_counts' as section,
       'media_news_compat_rows' as check_key,
       count(*)::bigint as row_count
from public.v_media_news_compat_v1
union all
select 'public_runtime_counts', 'media_announcements_compat_rows', count(*)::bigint
from public.v_media_announcements_compat_v1
union all
select 'public_runtime_counts', 'services_catalog_compat_rows', count(*)::bigint
from public.v_services_catalog_compat_v1
union all
select 'public_runtime_counts', 'homepage_sections_rows', count(*)::bigint
from public.homepage_sections;
