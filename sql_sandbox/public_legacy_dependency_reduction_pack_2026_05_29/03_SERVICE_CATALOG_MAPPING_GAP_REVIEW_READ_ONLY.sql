-- Public Legacy Dependency Reduction Pack
-- 03_SERVICE_CATALOG_MAPPING_GAP_REVIEW_READ_ONLY.sql
-- Purpose: inspect why public.services cannot yet be removed/replaced by platform_services.
-- Read-only.

with public_services_summary as (
  select
    'public.services'::text as source_name,
    count(*)::bigint as row_count,
    jsonb_agg(to_jsonb(s)) filter (where true) as sample_rows
  from (
    select * from public.services limit 25
  ) s
),
platform_forms_summary as (
  select
    'platform_services.service_forms_registry'::text as source_name,
    count(*)::bigint as row_count,
    jsonb_agg(to_jsonb(f)) filter (where true) as sample_rows
  from (
    select * from platform_services.service_forms_registry limit 25
  ) f
),
summary as (
  select * from public_services_summary
  union all
  select * from platform_forms_summary
),
decision as (
  select
    'service_catalog_mapping_gap'::text as section,
    (select row_count from public_services_summary) as public_services_rows,
    (select row_count from platform_forms_summary) as platform_forms_rows,
    case
      when (select row_count from public_services_summary) = (select row_count from platform_forms_summary)
        then 'COUNT_MATCH_REVIEW_ROW_MAPPING_BEFORE_REWRITE'
      else 'COUNT_MISMATCH_DO_NOT_REWRITE_PUBLIC_SERVICES_RUNTIME_YET'
    end as mapping_decision,
    false as rewrite_authorized_by_this_script,
    false as delete_authorized_by_this_script,
    true as read_only
)
select
  'source_sample' as section,
  source_name,
  row_count,
  sample_rows,
  null::text as mapping_decision,
  false as rewrite_authorized_by_this_script,
  false as delete_authorized_by_this_script,
  true as read_only
from summary
union all
select
  section,
  'public.services_vs_platform_services.service_forms_registry' as source_name,
  public_services_rows as row_count,
  jsonb_build_object('public_services_rows', public_services_rows, 'platform_forms_rows', platform_forms_rows) as sample_rows,
  mapping_decision,
  rewrite_authorized_by_this_script,
  delete_authorized_by_this_script,
  read_only
from decision;
