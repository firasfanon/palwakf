-- Script 03: Services legacy quarantine decision read-only
-- Purpose: finalize services ownership and quarantine legacy public tables.

with counts as (
  select
    case when to_regclass('public.v_services_catalog_compat_v1') is not null
      then (xpath('/row/count/text()', query_to_xml('select count(*) as count from public.v_services_catalog_compat_v1', false, true, '')))[1]::text::bigint else 0 end as services_catalog_rows,
    case when to_regclass('public.services') is not null
      then (xpath('/row/count/text()', query_to_xml('select count(*) as count from public.services', false, true, '')))[1]::text::bigint else null end as public_services_rows,
    case when to_regclass('public.servicepoints') is not null
      then (xpath('/row/count/text()', query_to_xml('select count(*) as count from public.servicepoints', false, true, '')))[1]::text::bigint else null end as servicepoints_rows,
    case when to_regclass('public.serviceproviders') is not null
      then (xpath('/row/count/text()', query_to_xml('select count(*) as count from public.serviceproviders', false, true, '')))[1]::text::bigint else null end as serviceproviders_rows,
    case when to_regclass('public.servicetypes') is not null
      then (xpath('/row/count/text()', query_to_xml('select count(*) as count from public.servicetypes', false, true, '')))[1]::text::bigint else null end as servicetypes_rows
)
select
  'services_legacy_quarantine_decision' as section,
  services_catalog_rows,
  public_services_rows,
  servicepoints_rows,
  serviceproviders_rows,
  servicetypes_rows,
  case when services_catalog_rows > 0
    then 'SERVICES_PUBLIC_CATALOG_STABLE_PLATFORM_SERVICES_OWNER_LEGACY_QUARANTINE_NO_DELETE'
    else 'SERVICES_CATALOG_NOT_READY_REQUIRES_PLATFORM_SERVICES_REVIEW'
  end as decision,
  'platform_services remains owner; public.v_services_catalog_compat_v1 remains runtime contract; legacy tables are preserved/quarantined, not deleted' as note
from counts;
