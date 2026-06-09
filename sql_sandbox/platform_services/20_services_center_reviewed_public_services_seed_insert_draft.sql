-- PalWakf Platform — Services Center Reviewed public.services Seed Insert Draft
-- Date: 2026-05-09
-- Batch: Platform Development — Services Center Taxonomy Approval + Reviewed Seed Draft
-- Status: REVIEWED DRAFT / SAFE REVIEW MODE BY DEFAULT
-- IMPORTANT: This file performs NO INSERT by default.
-- Purpose: show the reviewed seed rows and provide a commented insert block for explicit future approval.

select 'services_center_reviewed_public_services_seed' as section,
       'review-only' as execution_mode,
       'No production insert is executed by this script. Uncomment the insert block only after explicit approval.' as note;

-- Reviewed seed values for the lightweight public.services catalog.
-- Current known columns: id uuid, title text, icon text, link text, is_active boolean, order_index integer.
with reviewed_seed(title, icon, link, is_active, order_index, family_key, endpoint_type, service_key) as (
  values
    ('دليل الخدمات', 'list_alt', '/services', true, 10, 'public_services', 'public_page', 'services_directory'),
    ('بوابة الخدمات الإلكترونية', 'language', '/eservices', true, 20, 'e_services', 'public_page', 'e_services_portal'),
    ('طلب خدمة أو وثيقة', 'assignment', '/services/request', true, 30, 'requests_forms', 'request_entry', 'service_request_entry'),
    ('متابعة طلب خدمة', 'manage_search', '/services/track', true, 40, 'inquiries_tracking', 'tracking', 'service_request_tracking'),
    ('الشكاوى والملاحظات', 'feedback', '/complaints', true, 50, 'complaints_feedback', 'existing_channel', 'complaints_feedback'),
    ('الأنظمة والقوانين والتعليمات', 'gavel', '/legal-references', true, 60, 'official_references', 'public_page', 'official_references'),
    ('الزكاة والتبرعات', 'volunteer_activism', '/zakat', true, 70, 'financial_services', 'feature_service', 'zakat_donations'),
    ('مواقيت الصلاة', 'schedule', '/prayer-times', true, 80, 'public_services', 'feature_service', 'prayer_times'),
    ('القرآن الكريم', 'menu_book', '/quran', true, 90, 'public_services', 'feature_service', 'quran_service'),
    ('خدمات المديريات والوحدات', 'account_tree', '/:unitSlug/services', false, 100, 'unit_services', 'unit_route_pattern', 'unit_services_directory')
)
select * from reviewed_seed order by order_index;

-- Pre-insert duplicate review. This is safe and read-only.
with reviewed_seed(title, icon, link, is_active, order_index) as (
  values
    ('دليل الخدمات', 'list_alt', '/services', true, 10),
    ('بوابة الخدمات الإلكترونية', 'language', '/eservices', true, 20),
    ('طلب خدمة أو وثيقة', 'assignment', '/services/request', true, 30),
    ('متابعة طلب خدمة', 'manage_search', '/services/track', true, 40),
    ('الشكاوى والملاحظات', 'feedback', '/complaints', true, 50),
    ('الأنظمة والقوانين والتعليمات', 'gavel', '/legal-references', true, 60),
    ('الزكاة والتبرعات', 'volunteer_activism', '/zakat', true, 70),
    ('مواقيت الصلاة', 'schedule', '/prayer-times', true, 80),
    ('القرآن الكريم', 'menu_book', '/quran', true, 90),
    ('خدمات المديريات والوحدات', 'account_tree', '/:unitSlug/services', false, 100)
)
select 'duplicate_review' as section,
       s.title,
       s.link,
       case when exists (
         select 1 from public.services ps
         where ps.title = s.title or ps.link = s.link
       ) then 'would_skip_existing_title_or_link'
       else 'would_insert_after_explicit_approval'
       end as review_result
from reviewed_seed s
order by s.order_index;

/*
-- APPROVED EXECUTION BLOCK — DO NOT UNCOMMENT WITHOUT EXPLICIT USER/PLATFORM APPROVAL.
-- Expected table columns: id, title, icon, link, is_active, order_index.
-- If public.services.id has a default UUID generator, remove id/gen_random_uuid() as needed.

insert into public.services (id, title, icon, link, is_active, order_index)
select gen_random_uuid(), s.title, s.icon, s.link, s.is_active, s.order_index
from (
  values
    ('دليل الخدمات', 'list_alt', '/services', true, 10),
    ('بوابة الخدمات الإلكترونية', 'language', '/eservices', true, 20),
    ('طلب خدمة أو وثيقة', 'assignment', '/services/request', true, 30),
    ('متابعة طلب خدمة', 'manage_search', '/services/track', true, 40),
    ('الشكاوى والملاحظات', 'feedback', '/complaints', true, 50),
    ('الأنظمة والقوانين والتعليمات', 'gavel', '/legal-references', true, 60),
    ('الزكاة والتبرعات', 'volunteer_activism', '/zakat', true, 70),
    ('مواقيت الصلاة', 'schedule', '/prayer-times', true, 80),
    ('القرآن الكريم', 'menu_book', '/quran', true, 90),
    ('خدمات المديريات والوحدات', 'account_tree', '/:unitSlug/services', false, 100)
) as s(title, icon, link, is_active, order_index)
where not exists (
  select 1 from public.services ps
  where ps.title = s.title or ps.link = s.link
);

-- Post-insert verification:
select id, title, icon, link, is_active, order_index
from public.services
where link in (
  '/services', '/eservices', '/services/request', '/services/track', '/complaints',
  '/legal-references', '/zakat', '/prayer-times', '/quran', '/:unitSlug/services'
)
order by order_index;
*/
