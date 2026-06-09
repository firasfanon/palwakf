-- SQL 26 — Services Center Post Execution Runtime Verification
-- Date: 2026-05-09
-- Purpose: read-only verification after SQL 24 approved seed execution.
-- Safe to run. No writes.

select
  'post_execution_public_services_count' as section,
  count(*) as active_services_count
from public.services
where is_active = true;

select
  'post_execution_public_services_rows' as section,
  title,
  icon,
  link,
  is_active,
  order_index
from public.services
where is_active = true
order by order_index, title;

select
  'post_execution_homepage_section' as section,
  id,
  section_name,
  is_active,
  display_order,
  settings,
  unit_id
from public.homepage_sections
where section_name = 'pwf_public_services_catalog'
order by unit_id nulls first, display_order;

select
  'route_pattern_links_rejected_for_public_services_after_execution' as section,
  count(*) as rejected_count
from public.services
where is_active = true
  and (
    link like '/:%'
    or link like '%:unitSlug%'
    or link like '%{unitSlug}%'
  );

select
  'waqf_property_rows_rejected_for_public_services_after_execution' as section,
  count(*) as rejected_count
from public.services
where is_active = true
  and (
    lower(coalesce(link, '')) like '%propert%'
    or lower(coalesce(link, '')) like '%waqf_asset%'
    or coalesce(title, '') like '%عقار%'
    or coalesce(title, '') like '%أصل وقفي%'
    or coalesce(title, '') like '%العقارات الوقفية%'
  );
