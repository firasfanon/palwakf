-- PalWakf Platform Development 4G
-- Public Services Catalog Runtime UAT + Admin Visibility Control Review
-- Date: 2026-05-09
-- Mode: read-only verification; no production writes.
-- Purpose: verify SQL 24 execution, DB-controlled homepage visibility, and public services catalog safety.

-- 01) Confirm active public services catalog rows.
select
  'uat_public_services_catalog_active_rows' as section,
  count(*) as active_services_count
from public.services
where is_active = true;

-- 02) List active catalog rows in the exact display order consumed by Flutter.
select
  'uat_public_services_catalog_ordered_rows' as section,
  id,
  title,
  icon,
  link,
  is_active,
  order_index
from public.services
where is_active = true
order by order_index, title;

-- 03) Reject route-pattern links in the public global catalog.
select
  'uat_route_pattern_links_rejected' as section,
  count(*) as rejected_count
from public.services
where is_active = true
  and coalesce(link, '') like '%/:%';

-- 04) Reject waqf-property scoped rows from public.services.
select
  'uat_waqf_property_rows_rejected' as section,
  count(*) as rejected_count
from public.services
where is_active = true
  and (
    lower(coalesce(title, '')) like '%عقار%'
    or lower(coalesce(title, '')) like '%عقارات%'
    or lower(coalesce(title, '')) like '%waqf_asset%'
    or lower(coalesce(link, '')) like '%properties%'
    or lower(coalesce(link, '')) like '%waqf_asset%'
  );

-- 05) Confirm dynamic homepage section state for the central/public scope.
select
  'uat_homepage_section_public_services_catalog' as section,
  id,
  section_name,
  settings,
  is_active,
  display_order,
  unit_id
from public.homepage_sections
where section_name = 'pwf_public_services_catalog'
order by unit_id nulls first, display_order;

-- 06) Scope collision review: the same section may exist for central and unit scopes,
-- but duplicate rows for the same unit_id + section_name should be treated as a cleanup candidate.
select
  'uat_homepage_section_scope_duplicates' as section,
  section_name,
  unit_id,
  count(*) as duplicate_count
from public.homepage_sections
where section_name = 'pwf_public_services_catalog'
group by section_name, unit_id
having count(*) > 1
order by duplicate_count desc;

-- 07) Admin visibility control review matrix: shows who controls visibility/order/scope.
select
  'uat_admin_visibility_control_matrix' as section,
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
