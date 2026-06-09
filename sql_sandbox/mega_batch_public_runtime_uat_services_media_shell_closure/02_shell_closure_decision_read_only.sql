-- Mega Batch Public Runtime UAT + Services/Media Shell Closure
-- 02_shell_closure_decision_read_only.sql
-- READ ONLY. Produces the closure decision based on current contract counts.

with counts as (
  select
    (select count(*) from public.v_media_news_compat_v1) as news_rows,
    (select count(*) from public.v_media_announcements_compat_v1) as announcement_rows,
    (select count(*) from public.v_services_catalog_compat_v1) as services_rows,
    (select count(*) from public.homepage_sections) as homepage_sections_rows
)
select
  'public_runtime_shell_closure_decision' as section,
  case
    when news_rows > 0 and announcement_rows > 0 and services_rows > 0 and homepage_sections_rows > 0
      then 'services-media-shell-sql-uat-accepted'
    else 'services-media-shell-sql-uat-blocked'
  end as decision,
  jsonb_build_object(
    'news_rows', news_rows,
    'announcement_rows', announcement_rows,
    'services_rows', services_rows,
    'homepage_sections_rows', homepage_sections_rows,
    'decision_scope', 'SQL contract closure only; browser/console UAT still required',
    'production_gate', 'production-not-approved'
  ) as decision_payload
from counts;
