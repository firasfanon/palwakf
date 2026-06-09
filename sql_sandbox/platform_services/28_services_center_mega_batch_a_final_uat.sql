-- PalWakf Platform — Mega Batch A
-- Platform Runtime Stabilization + Public Services Closure + Analyzer Intake
-- Date: 2026-05-09
-- Mode: read-only final UAT verification; no production writes.
-- Purpose:
--   1) Re-run the remaining SQL 27 checks in one consolidated script.
--   2) Verify catalog safety after Flutter-side hardening.
--   3) Preserve source-of-truth split:
--      public.homepage_sections = visibility/order/scope/settings
--      public.services = public catalog card data only

-- A01) Active public catalog rows expected after SQL 24.
select
  'mega_a_public_services_catalog_active_rows' as section,
  count(*) as active_services_count,
  case when count(*) >= 9 then 'pass' else 'review_needed' end as uat_status
from public.services
where is_active = true;

-- A02) Ordered active rows consumed by Flutter repository.
select
  'mega_a_public_services_catalog_ordered_rows' as section,
  id,
  title,
  icon,
  link,
  is_active,
  order_index
from public.services
where is_active = true
order by order_index asc, title asc;

-- A03) Route pattern links must not be active in global public catalog.
select
  'mega_a_route_pattern_links_rejected' as section,
  count(*) as rejected_count,
  case when count(*) = 0 then 'pass' else 'critical_review_needed' end as uat_status
from public.services
where is_active = true
  and coalesce(link, '') like '%/:%';

-- A04) Waqf property/asset services remain outside public.services until waqf_assets is sovereign-ready.
select
  'mega_a_waqf_property_rows_rejected' as section,
  count(*) as rejected_count,
  case when count(*) = 0 then 'pass' else 'critical_review_needed' end as uat_status
from public.services
where is_active = true
  and (
    lower(coalesce(title, '')) like '%عقار%'
    or lower(coalesce(title, '')) like '%عقارات%'
    or lower(coalesce(title, '')) like '%أصل وقفي%'
    or lower(coalesce(title, '')) like '%أصول وقفية%'
    or lower(coalesce(title, '')) like '%waqf_asset%'
    or lower(coalesce(title, '')) like '%waqf-assets%'
    or lower(coalesce(link, '')) like '%properties%'
    or lower(coalesce(link, '')) like '%property%'
    or lower(coalesce(link, '')) like '%waqf_asset%'
    or lower(coalesce(link, '')) like '%waqf-assets%'
  );

-- A05) Dynamic homepage section state for public services catalog.
select
  'mega_a_homepage_section_public_services_catalog' as section,
  id,
  section_name,
  settings,
  is_active,
  display_order,
  unit_id,
  case
    when is_active = true and display_order = 25 and unit_id is null then 'pass'
    when is_active = true then 'review_scope_or_order'
    else 'inactive_review_needed'
  end as uat_status
from public.homepage_sections
where section_name = 'pwf_public_services_catalog'
order by unit_id nulls first, display_order asc;

-- A06) Scope duplicate review: duplicate section_name + unit_id rows are cleanup candidates.
select
  'mega_a_homepage_section_scope_duplicates' as section,
  section_name,
  unit_id,
  count(*) as duplicate_count,
  'cleanup_candidate' as required_action
from public.homepage_sections
where section_name = 'pwf_public_services_catalog'
group by section_name, unit_id
having count(*) > 1
order by duplicate_count desc;

-- A07) Admin visibility control matrix.
select
  'mega_a_admin_visibility_control_matrix' as section,
  hs.section_name,
  hs.is_active,
  hs.display_order,
  hs.unit_id,
  case
    when hs.unit_id is null then 'central/public dynamic homepage scope'
    else 'unit/system scoped dynamic homepage row'
  end as scope_type,
  'public.homepage_sections controls visibility/order/scope; public.services controls catalog card data only' as control_rule
from public.homepage_sections hs
where hs.section_name = 'pwf_public_services_catalog'
order by hs.unit_id nulls first, hs.display_order;
