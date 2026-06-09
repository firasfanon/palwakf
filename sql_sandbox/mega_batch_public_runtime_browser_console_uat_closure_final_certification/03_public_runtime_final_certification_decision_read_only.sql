-- 03_public_runtime_final_certification_decision_read_only.sql
-- Read-only decision matrix. This script does not approve production.

with evidence as (
  select
    (select count(*) from public.v_media_news_compat_v1) as news_rows,
    (select count(*) from public.v_media_announcements_compat_v1) as announcement_rows,
    (select count(*) from public.v_services_catalog_compat_v1) as service_rows,
    (select count(*) from public.homepage_sections) as homepage_sections_rows,
    false as browser_console_evidence_submitted
)
select
  'public_runtime_final_certification_decision' as section,
  case
    when news_rows > 0
      and announcement_rows > 0
      and service_rows > 0
      and homepage_sections_rows > 0
      and browser_console_evidence_submitted
    then 'production-candidate-ready'
    else 'final-shell-certification-deferred-pending-browser-console-evidence'
  end as decision,
  jsonb_build_object(
    'news_rows', news_rows,
    'announcement_rows', announcement_rows,
    'service_rows', service_rows,
    'homepage_sections_rows', homepage_sections_rows,
    'browser_console_evidence_submitted', browser_console_evidence_submitted,
    'decision_scope', 'read-only decision helper; production remains not approved unless browser/console evidence is submitted'
  ) as decision_payload
from evidence;
