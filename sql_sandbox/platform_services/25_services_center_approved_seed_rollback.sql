-- PalWakf Platform Development 4E
-- Services Center Approved Seed Rollback Draft
-- Date: 2026-05-09
-- Status: ROLLBACK DRAFT — EXECUTE ONLY IF 4E SEED WAS APPLIED BY MISTAKE
-- Scope:
--   Removes only the central 4E public.services seed rows and the central homepage section row.
--   Does not remove any future unit-scoped rows for pwf_public_services_catalog.

begin;

delete from public.services
where link in ('/services', '/eservices', '/services/request', '/services/track', '/complaints', '/legal-references', '/zakat', '/prayer-times', '/quran')
  and title in ('دليل الخدمات', 'بوابة الخدمات الإلكترونية', 'طلب خدمة أو وثيقة', 'متابعة طلب خدمة', 'الشكاوى والملاحظات', 'الأنظمة والقوانين والتعليمات', 'الزكاة والتبرعات', 'مواقيت الصلاة', 'القرآن الكريم');

delete from public.homepage_sections
where section_name = 'pwf_public_services_catalog'
  and unit_id is null;

commit;

select 'rollback_public_services_remaining' as section,
       id,
       title,
       link,
       is_active,
       order_index
from public.services
where link in ('/services', '/eservices', '/services/request', '/services/track', '/complaints', '/legal-references', '/zakat', '/prayer-times', '/quran')
order by order_index asc, title asc;

select 'rollback_homepage_section_remaining' as section,
       id,
       section_name,
       settings,
       is_active,
       display_order,
       unit_id
from public.homepage_sections
where section_name = 'pwf_public_services_catalog'
order by unit_id nulls first, display_order asc;
