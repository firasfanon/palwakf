-- PalWakf Platform Development 4C
-- Services Center Source-of-Truth Wiring + Reserved Route Hardening
-- Date: 2026-05-09
-- Purpose: read-only verification for public.services before optional production seed execution.
-- This script performs no INSERT/UPDATE/DELETE.

-- 01) Verify expected public.services shape.
select
  'public_services_columns' as section,
  column_name,
  data_type,
  is_nullable
from information_schema.columns
where table_schema = 'public'
  and table_name = 'services'
  and column_name in ('id', 'title', 'icon', 'link', 'is_active', 'order_index')
order by ordinal_position;

-- 02) Verify current active rows that the new Flutter provider will read.
select
  'active_public_services_catalog' as section,
  id,
  title,
  icon,
  link,
  is_active,
  order_index
from public.services
where is_active is true
order by order_index asc, title asc;

-- 03) Flag unsupported route-pattern links that should not appear in public.services.
select
  'route_pattern_links_rejected_by_ui' as section,
  id,
  title,
  link
from public.services
where coalesce(link, '') like '%/:%'
order by order_index asc, title asc;

-- 04) Distinguish public services from deferred waqf property services.
select
  'waqf_property_scope_warning' as section,
  id,
  title,
  link,
  'Do not use public.services for waqf property/asset workflows until waqf_assets is complete.' as note
from public.services
where lower(coalesce(title, '')) similar to '%(عقار|عقارات|أصل|أصول|asset|property)%'
   or lower(coalesce(link, '')) similar to '%(property|properties|waqf-assets|waqf_asset)%'
order by order_index asc, title asc;
