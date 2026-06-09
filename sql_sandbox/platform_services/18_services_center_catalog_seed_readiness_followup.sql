-- 18_services_center_catalog_seed_readiness_followup.sql
-- Purpose: read-only follow-up for Services Center catalog seed readiness.
-- Safe: no CREATE / ALTER / INSERT / UPDATE / DELETE / DROP.

select
  'service_catalog_current_counts' as section,
  'public' as schema_name,
  'services' as table_name,
  count(*)::bigint as row_count
from public.services
union all
select 'service_catalog_current_counts', 'public', 'servicetypes', count(*)::bigint from public.servicetypes
union all
select 'service_catalog_current_counts', 'public', 'serviceproviders', count(*)::bigint from public.serviceproviders
union all
select 'service_catalog_current_counts', 'public', 'servicepoints', count(*)::bigint from public.servicepoints;

select
  'services_sample_for_seed_mapping' as section,
  id::text,
  title,
  icon,
  link,
  is_active,
  order_index
from public.services
order by order_index nulls last, title
limit 50;

select
  'servicetypes_sample_for_taxonomy_mapping' as section,
  id,
  name,
  unit
from public.servicetypes
order by id
limit 50;

select
  'service_catalog_required_next_actions' as section,
  action_key,
  action_ar
from (
  values
    ('define_taxonomy', 'تعريف تصنيف خدمات PalWakf الرسمي قبل الإدخال'),
    ('prepare_seed', 'تجهيز seed مراجَع لخدمات الجمهور والخدمات الإلكترونية'),
    ('map_routes', 'ربط كل خدمة بمسار عام أو نموذج طلب أو رابط خارجي'),
    ('separate_complaints', 'إبقاء الشكاوى ضمن pwf_complaints وعدم خلطها مع طلبات الخدمات'),
    ('document_policy', 'ربط مرفقات الخدمات لاحقًا مع Document Intelligence لا مع جدول شكاوى')
) as t(action_key, action_ar);
