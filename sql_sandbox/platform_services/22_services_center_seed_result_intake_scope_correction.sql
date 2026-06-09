-- PalWakf Platform — Services Center Seed Result Intake + Scope Correction
-- Date: 2026-05-09
-- Batch: Platform Development 4A — Scope Correction + Unit Services Route Exposure
-- Status: REVIEW ONLY. NO INSERTS.

select 'seed_preview_result_intake' as section,
       9::int as rows_that_would_insert,
       0::int as rows_that_would_skip,
       9::int as reviewed_rows,
       'User-provided insert_count_preview accepted as technical readiness only.' as note;

select 'scope_correction' as section,
       'public.services seed is only for general public/service gateway rows. Waqf property services are not included in this insert.' as decision;

with public_seed(title, icon, link, is_active, order_index, scope_note) as (
  values
    ('دليل الخدمات', 'list_alt', '/services', true, 10, 'عام'),
    ('بوابة الخدمات الإلكترونية', 'language', '/eservices', true, 20, 'عام/إلكتروني'),
    ('طلب خدمة أو وثيقة', 'assignment', '/services/request', true, 30, 'طلبات عامة'),
    ('متابعة طلب خدمة', 'manage_search', '/services/track', true, 40, 'متابعة عامة'),
    ('الشكاوى والملاحظات', 'feedback', '/complaints', true, 50, 'قناة مستقلة قائمة؛ ليست طلب خدمة'),
    ('الأنظمة والقوانين والتعليمات', 'gavel', '/legal-references', true, 60, 'مراجع رسمية'),
    ('الزكاة والتبرعات', 'volunteer_activism', '/zakat', true, 70, 'مالي/عام؛ ليس عقارات وقفية'),
    ('مواقيت الصلاة', 'schedule', '/prayer-times', true, 80, 'خدمة عامة'),
    ('القرآن الكريم', 'menu_book', '/quran', true, 90, 'خدمة عامة')
)
select 'corrected_public_seed_review' as section, *
from public_seed
order by order_index;

with deferred_scope(family_key, label_ar, suggested_route, status, reason) as (
  values
    ('waqf_property_services', 'خدمات العقارات الوقفية', '/properties or /services/waqf-properties', 'deferred', 'Requires approved property-service workflow and waqf_assets linkage policy.'),
    ('waqf_asset_requests', 'طلبات مرتبطة بأصل وقفي', null, 'deferred', 'waqf_assets sovereign table is not completed yet.'),
    ('unit_services_catalog', 'خدمات المديريات والوحدات', '/:unitSlug/services and /:unitSlug/eservices', 'route_exposed_in_code', 'Direct unit service routes added; not inserted into flat public.services because links are unit-scoped patterns.')
)
select 'deferred_or_separate_service_families' as section, *
from deferred_scope;

-- Duplicate review remains unchanged for the 9 public rows only.
with public_seed(title, icon, link, is_active, order_index) as (
  values
    ('دليل الخدمات', 'list_alt', '/services', true, 10),
    ('بوابة الخدمات الإلكترونية', 'language', '/eservices', true, 20),
    ('طلب خدمة أو وثيقة', 'assignment', '/services/request', true, 30),
    ('متابعة طلب خدمة', 'manage_search', '/services/track', true, 40),
    ('الشكاوى والملاحظات', 'feedback', '/complaints', true, 50),
    ('الأنظمة والقوانين والتعليمات', 'gavel', '/legal-references', true, 60),
    ('الزكاة والتبرعات', 'volunteer_activism', '/zakat', true, 70),
    ('مواقيت الصلاة', 'schedule', '/prayer-times', true, 80),
    ('القرآن الكريم', 'menu_book', '/quran', true, 90)
)
select 'corrected_insert_count_preview' as section,
       count(*) filter (where not exists (
         select 1 from public.services ps
         where ps.title = public_seed.title or ps.link = public_seed.link
       )) as rows_that_would_insert,
       count(*) filter (where exists (
         select 1 from public.services ps
         where ps.title = public_seed.title or ps.link = public_seed.link
       )) as rows_that_would_skip,
       count(*) as reviewed_rows
from public_seed;
