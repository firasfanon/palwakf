-- PalWakf Platform Development 4D
-- Dynamic Homepage Section Seed Review + public.services Optional Insert
-- Date: 2026-05-09
-- Status: SAFE REVIEW MODE BY DEFAULT
-- Purpose:
--   1) Review the dynamic homepage section key `pwf_public_services_catalog`.
--   2) Review the final public.services seed after separating public audience services from waqf property services.
--   3) Provide commented optional execution blocks only after explicit approval.
--
-- IMPORTANT:
-- Active statements below perform no INSERT/UPDATE/DELETE.
-- Required authorization phrase before executing the commented block:
-- أوافق صراحة على تنفيذ إدخال كتالوج خدمات الجمهور وقسم الصفحة الديناميكية وفق ملف 23_services_center_dynamic_home_section_seed_review_and_optional_insert.sql

select 'platform_4d_execution_mode' as section,
       'review-only' as execution_mode,
       'No active statement in this script writes to production tables.' as note;

-- 01) Confirm public.services shape used by the Flutter source-of-truth provider.
select
  'public_services_columns' as section,
  column_name,
  data_type,
  is_nullable,
  column_default
from information_schema.columns
where table_schema = 'public'
  and table_name = 'services'
  and column_name in ('id', 'title', 'icon', 'link', 'is_active', 'order_index')
order by ordinal_position;

-- 02) Confirm homepage_sections shape used by the dynamic homepage renderer.
select
  'homepage_sections_columns' as section,
  column_name,
  data_type,
  is_nullable,
  column_default
from information_schema.columns
where table_schema = 'public'
  and table_name = 'homepage_sections'
  and column_name in ('id', 'section_name', 'settings', 'is_active', 'display_order', 'unit_id', 'updated_at', 'updated_by')
order by ordinal_position;

-- 03) Final public audience seed. This intentionally excludes waqf property/asset services.
with final_public_services_seed(title, icon, link, is_active, order_index, family_key, service_scope, note) as (
  values
    ('دليل الخدمات', 'list_alt', '/services', true, 10, 'public_services', 'global_public', 'Public service directory route.'),
    ('بوابة الخدمات الإلكترونية', 'language', '/eservices', true, 20, 'e_services', 'global_public', 'Public e-services route.'),
    ('طلب خدمة أو وثيقة', 'assignment', '/services/request', true, 30, 'requests_forms', 'global_public', 'Generic public request entry. Not a waqf property request.'),
    ('متابعة طلب خدمة', 'manage_search', '/services/track', true, 40, 'inquiries_tracking', 'global_public', 'Generic public request tracking.'),
    ('الشكاوى والملاحظات', 'feedback', '/complaints', true, 50, 'complaints_feedback', 'existing_channel', 'Existing complaints channel remains separate from service requests.'),
    ('الأنظمة والقوانين والتعليمات', 'gavel', '/legal-references', true, 60, 'official_references', 'global_public', 'Official legal/regulatory references.'),
    ('الزكاة والتبرعات', 'volunteer_activism', '/zakat', true, 70, 'financial_public', 'global_public', 'Public donation/zakat entry; not waqf property revenue workflow.'),
    ('مواقيت الصلاة', 'schedule', '/prayer-times', true, 80, 'public_services', 'global_public', 'Public prayer-times page.'),
    ('القرآن الكريم', 'menu_book', '/quran', true, 90, 'public_services', 'global_public', 'Public Quran page.')
)
select 'final_public_services_seed_review' as section, *
from final_public_services_seed
order by order_index;

-- 04) Rows deliberately excluded from public.services.
with excluded_services(title, suggested_scope, reason) as (
  values
    ('خدمات العقارات الوقفية', 'properties / waqf_assets workflow', 'Excluded until waqf_assets is production-ready and waqf_asset_id becomes the sovereign link.'),
    ('خدمات المديريات والوحدات كصف واحد نمطي', 'dynamic unit-scoped homepage rendering', 'Excluded because unitSlug filters the same dynamic page structure; /:unitSlug/services is not a global catalog row.'),
    ('أي خدمة قضائية أو مالية مرتبطة بأصل وقفي محدد', 'cases/billing/tasks + waqf_asset_id', 'Excluded from public.services to prevent mixing public services with sovereign asset workflows.')
)
select 'excluded_from_public_services_seed' as section, *
from excluded_services;

-- 05) Duplicate review for public.services.
with final_public_services_seed(title, icon, link, is_active, order_index) as (
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
select 'public_services_duplicate_review' as section,
       s.title,
       s.link,
       case when exists (
         select 1 from public.services ps
         where ps.title = s.title or ps.link = s.link
       ) then 'would_skip_existing_title_or_link'
       else 'would_insert_after_explicit_approval'
       end as review_result
from final_public_services_seed s
order by s.order_index;

-- 06) Insert count preview for public.services.
with final_public_services_seed(title, icon, link, is_active, order_index) as (
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
select 'public_services_insert_count_preview' as section,
       count(*) filter (where not exists (
         select 1 from public.services ps
         where ps.title = final_public_services_seed.title or ps.link = final_public_services_seed.link
       )) as rows_that_would_insert,
       count(*) filter (where exists (
         select 1 from public.services ps
         where ps.title = final_public_services_seed.title or ps.link = final_public_services_seed.link
       )) as rows_that_would_skip,
       count(*) as reviewed_rows
from final_public_services_seed;

-- 07) Review dynamic homepage section row.
select 'homepage_section_current_state' as section,
       id,
       section_name,
       settings,
       is_active,
       display_order,
       unit_id
from public.homepage_sections
where section_name = 'pwf_public_services_catalog'
order by unit_id nulls first, display_order;

-- 08) Homepage section seed preview.
with dynamic_section_seed(section_name, is_active, display_order, settings, scope_rule) as (
  values
    (
      'pwf_public_services_catalog',
      true,
      25,
      jsonb_build_object(
        'title', 'كتالوج خدمات الجمهور المعتمد',
        'subtitle', 'بطاقات خدمات الجمهور العامة المقروءة من public.services. لا تشمل خدمات العقارات الوقفية. ظهور القسم أو إخفاؤه يدار من homepage_sections حسب الوحدة/النطاق.'
      ),
      'DB-controlled dynamic homepage section; visibility/order/scope come from public.homepage_sections rows filtered by unitSlug/unit_id; the widget does not hardcode home-only hiding'
    )
)
select 'dynamic_homepage_section_seed_review' as section, *
from dynamic_section_seed;

-- 09) Route-pattern and waqf-property safety checks.
select
  'route_pattern_links_rejected_for_public_services' as section,
  id,
  title,
  link
from public.services
where coalesce(link, '') like '%/:%'
order by order_index asc, title asc;

select
  'waqf_property_rows_rejected_for_public_services' as section,
  id,
  title,
  link,
  'Must move to properties/waqf_assets workflow, not public.services.' as required_action
from public.services
where lower(coalesce(title, '')) similar to '%(عقار|عقارات|أصل|أصول|asset|property)%'
   or lower(coalesce(link, '')) similar to '%(property|properties|waqf-assets|waqf_asset)%'
order by order_index asc, title asc;

/*
-- APPROVED EXECUTION BLOCK — DO NOT UNCOMMENT WITHOUT EXPLICIT PLATFORM APPROVAL.
-- Authorization phrase:
-- أوافق صراحة على تنفيذ إدخال كتالوج خدمات الجمهور وقسم الصفحة الديناميكية وفق ملف 23_services_center_dynamic_home_section_seed_review_and_optional_insert.sql

begin;

-- A) Insert public.services rows, skipping any existing title or link.
do $$
declare
  services_has_id_default boolean;
  homepage_has_id_default boolean;
  has_gen_random_uuid boolean;
begin
  select column_default is not null
  into services_has_id_default
  from information_schema.columns
  where table_schema = 'public'
    and table_name = 'services'
    and column_name = 'id';

  select column_default is not null
  into homepage_has_id_default
  from information_schema.columns
  where table_schema = 'public'
    and table_name = 'homepage_sections'
    and column_name = 'id';

  select exists (
    select 1
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where p.proname = 'gen_random_uuid'
      and n.nspname in ('pg_catalog', 'public', 'extensions')
  ) into has_gen_random_uuid;

  if services_has_id_default then
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
    raise exception 'public.services.id has no default and gen_random_uuid() is not available.';
  end if;

  -- B) Upsert dynamic homepage section for the ministry homepage only.
  -- Scope is controlled by homepage_sections/unit_id and the unitSlug-aware provider.
  -- The widget must not enforce home-only rendering; if a unit-scoped row exists, it is intentionally renderable.
  if exists (
    select 1 from public.homepage_sections hs
    where hs.section_name = 'pwf_public_services_catalog'
      and hs.unit_id is null
  ) then
    update public.homepage_sections
    set is_active = true,
        display_order = 25,
        settings = jsonb_build_object(
          'title', 'كتالوج خدمات الجمهور المعتمد',
          'subtitle', 'بطاقات خدمات الجمهور العامة المقروءة من public.services. لا تشمل خدمات العقارات الوقفية. ظهور القسم أو إخفاؤه يدار من homepage_sections حسب الوحدة/النطاق.'
        ),
        updated_at = now()
    where section_name = 'pwf_public_services_catalog'
      and unit_id is null;
  elsif homepage_has_id_default then
    insert into public.homepage_sections (section_name, settings, is_active, display_order, unit_id, updated_at)
    values (
      'pwf_public_services_catalog',
      jsonb_build_object(
        'title', 'كتالوج خدمات الجمهور المعتمد',
        'subtitle', 'بطاقات خدمات الجمهور العامة المقروءة من public.services. لا تشمل خدمات العقارات الوقفية. ظهور القسم أو إخفاؤه يدار من homepage_sections حسب الوحدة/النطاق.'
      ),
      true,
      25,
      null,
      now()
    );
  elsif has_gen_random_uuid then
    insert into public.homepage_sections (id, section_name, settings, is_active, display_order, unit_id, updated_at)
    values (
      gen_random_uuid(),
      'pwf_public_services_catalog',
      jsonb_build_object(
        'title', 'كتالوج خدمات الجمهور المعتمد',
        'subtitle', 'بطاقات خدمات الجمهور العامة المقروءة من public.services. لا تشمل خدمات العقارات الوقفية. ظهور القسم أو إخفاؤه يدار من homepage_sections حسب الوحدة/النطاق.'
      ),
      true,
      25,
      null,
      now()
    );
  else
    raise exception 'public.homepage_sections.id has no default and gen_random_uuid() is not available.';
  end if;
end $$;

commit;

-- Post-execution verification:
select 'post_insert_public_services' as section, id, title, icon, link, is_active, order_index
from public.services
where link in ('/services', '/eservices', '/services/request', '/services/track', '/complaints', '/legal-references', '/zakat', '/prayer-times', '/quran')
order by order_index, title;

select 'post_insert_homepage_section' as section, id, section_name, settings, is_active, display_order, unit_id
from public.homepage_sections
where section_name = 'pwf_public_services_catalog'
order by unit_id nulls first, display_order;

-- Optional rollback for this 4D seed only, if executed by mistake and no downstream data depends on it:
-- begin;
-- delete from public.services
-- where link in ('/services', '/eservices', '/services/request', '/services/track', '/complaints', '/legal-references', '/zakat', '/prayer-times', '/quran')
--   and title in ('دليل الخدمات', 'بوابة الخدمات الإلكترونية', 'طلب خدمة أو وثيقة', 'متابعة طلب خدمة', 'الشكاوى والملاحظات', 'الأنظمة والقوانين والتعليمات', 'الزكاة والتبرعات', 'مواقيت الصلاة', 'القرآن الكريم');
-- delete from public.homepage_sections
-- where section_name = 'pwf_public_services_catalog'
--   and unit_id is null;
-- NOTE: unit-scoped rows for this section, if later created by admins, should be handled through the unit homepage management workflow, not this central rollback.
-- commit;
*/
