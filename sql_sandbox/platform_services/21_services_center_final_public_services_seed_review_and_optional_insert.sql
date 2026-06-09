-- PalWakf Platform — Services Center Final public.services Seed Review + Optional Insert
-- Date: 2026-05-09
-- Batch: Platform Development 3 — Services Center Final Seed Review + Optional Insert Authorization Pack
-- Status: SAFE REVIEW MODE BY DEFAULT
-- IMPORTANT: This file performs NO INSERT unless the APPROVED EXECUTION BLOCK is manually uncommented.
-- Required authorization phrase before execution:
-- أوافق صراحة على تنفيذ إدخال seed النهائي في public.services وفق ملف 21_services_center_final_public_services_seed_review_and_optional_insert.sql

select 'services_center_final_seed_review' as section,
       'review-only' as execution_mode,
       'No production insert is executed by the active statements in this script.' as note;

-- 1) Table shape review: safe read-only.
select 'public_services_table_shape' as section,
       column_name,
       data_type,
       is_nullable,
       column_default
from information_schema.columns
where table_schema = 'public'
  and table_name = 'services'
order by ordinal_position;

-- 2) Final insert-ready seed: safe read-only.
with final_seed(title, icon, link, is_active, order_index, family_key, endpoint_type, service_key) as (
  values
    ('دليل الخدمات', 'list_alt', '/services', true, 10, 'public_services', 'public_page', 'services_directory'),
    ('بوابة الخدمات الإلكترونية', 'language', '/eservices', true, 20, 'e_services', 'public_page', 'e_services_portal'),
    ('طلب خدمة أو وثيقة', 'assignment', '/services/request', true, 30, 'requests_forms', 'request_entry', 'service_request_entry'),
    ('متابعة طلب خدمة', 'manage_search', '/services/track', true, 40, 'inquiries_tracking', 'tracking', 'service_request_tracking'),
    ('الشكاوى والملاحظات', 'feedback', '/complaints', true, 50, 'complaints_feedback', 'existing_channel', 'complaints_feedback'),
    ('الأنظمة والقوانين والتعليمات', 'gavel', '/legal-references', true, 60, 'official_references', 'public_page', 'official_references'),
    ('الزكاة والتبرعات', 'volunteer_activism', '/zakat', true, 70, 'financial_services', 'feature_service', 'zakat_donations'),
    ('مواقيت الصلاة', 'schedule', '/prayer-times', true, 80, 'public_services', 'feature_service', 'prayer_times'),
    ('القرآن الكريم', 'menu_book', '/quran', true, 90, 'public_services', 'feature_service', 'quran_service')
)
select 'final_seed_insert_ready' as section, *
from final_seed
order by order_index;

-- 3) Deferred row: safe read-only. Not included in insert.
with deferred_seed(title, icon, link, is_active, order_index, family_key, endpoint_type, service_key, reason) as (
  values
    ('خدمات المديريات والوحدات', 'account_tree', '/:unitSlug/services', false, 100, 'unit_services', 'unit_route_pattern', 'unit_services_directory', 'Deferred: route pattern is not a confirmed direct public GoRoute.')
)
select 'deferred_seed_not_inserted' as section, *
from deferred_seed
order by order_index;

-- 4) Duplicate review: safe read-only.
with final_seed(title, icon, link, is_active, order_index) as (
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
select 'duplicate_review' as section,
       s.title,
       s.link,
       case when exists (
         select 1 from public.services ps
         where ps.title = s.title or ps.link = s.link
       ) then 'would_skip_existing_title_or_link'
       else 'would_insert_after_explicit_approval'
       end as review_result
from final_seed s
order by s.order_index;

-- 5) Insert count preview: safe read-only.
with final_seed(title, icon, link, is_active, order_index) as (
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
select 'insert_count_preview' as section,
       count(*) filter (where not exists (
         select 1 from public.services ps
         where ps.title = final_seed.title or ps.link = final_seed.link
       )) as rows_that_would_insert,
       count(*) filter (where exists (
         select 1 from public.services ps
         where ps.title = final_seed.title or ps.link = final_seed.link
       )) as rows_that_would_skip,
       count(*) as reviewed_rows
from final_seed;

/*
-- APPROVED EXECUTION BLOCK — DO NOT UNCOMMENT WITHOUT EXPLICIT USER/PLATFORM APPROVAL.
-- This block supports either:
-- 1) public.services.id has a UUID default; or
-- 2) gen_random_uuid() is available.
-- It skips existing rows by matching either title or link.

do $$
declare
  has_id_default boolean;
  has_gen_random_uuid boolean;
begin
  select column_default is not null
  into has_id_default
  from information_schema.columns
  where table_schema = 'public'
    and table_name = 'services'
    and column_name = 'id';

  select exists (
    select 1
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where p.proname = 'gen_random_uuid'
      and n.nspname in ('pg_catalog', 'public', 'extensions')
  ) into has_gen_random_uuid;

  if has_id_default then
    insert into public.services (title, icon, link, is_active, order_index)
    select s.title, s.icon, s.link, s.is_active, s.order_index
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
        ('القرآن الكريم', 'menu_book', '/quran', true, 90)
    ) as s(title, icon, link, is_active, order_index)
    where not exists (
      select 1 from public.services ps
      where ps.title = s.title or ps.link = s.link
    );
  elsif has_gen_random_uuid then
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
        ('القرآن الكريم', 'menu_book', '/quran', true, 90)
    ) as s(title, icon, link, is_active, order_index)
    where not exists (
      select 1 from public.services ps
      where ps.title = s.title or ps.link = s.link
    );
  else
    raise exception 'public.services.id has no default and gen_random_uuid() is not available. Add a UUID default or enable pgcrypto before inserting.';
  end if;
end $$;

-- Post-insert verification:
select id, title, icon, link, is_active, order_index
from public.services
where link in (
  '/services', '/eservices', '/services/request', '/services/track', '/complaints',
  '/legal-references', '/zakat', '/prayer-times', '/quran'
)
order by order_index;

-- Optional rollback for this seed only, if executed by mistake and no user data depends on the rows:
-- delete from public.services
-- where link in (
--   '/services', '/eservices', '/services/request', '/services/track', '/complaints',
--   '/legal-references', '/zakat', '/prayer-times', '/quran'
-- )
-- and title in (
--   'دليل الخدمات', 'بوابة الخدمات الإلكترونية', 'طلب خدمة أو وثيقة', 'متابعة طلب خدمة',
--   'الشكاوى والملاحظات', 'الأنظمة والقوانين والتعليمات', 'الزكاة والتبرعات',
--   'مواقيت الصلاة', 'القرآن الكريم'
-- );
*/
