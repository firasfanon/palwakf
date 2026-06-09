-- PalWakf Platform Development 4E
-- Services Center Approved Seed Execution + Dynamic Homepage Section Activation
-- Date: 2026-05-09
-- Status: APPROVED EXECUTION SCRIPT — NOT REVIEW-ONLY
-- Authorization received from platform owner:
--   أوافق صراحة على تنفيذ إدخال كتالوج خدمات الجمهور وقسم الصفحة الديناميكية وفق ملف 23_services_center_dynamic_home_section_seed_review_and_optional_insert.sql
--
-- Purpose:
--   1) Insert final public audience service catalog rows into public.services.
--   2) Insert/update the dynamic homepage section row pwf_public_services_catalog in public.homepage_sections.
--   3) Keep waqf property/asset services outside public.services.
--   4) Keep unit-scoped display controlled by public.homepage_sections and unitSlug/unit_id filtering.
--
-- Execution note:
--   This file contains active INSERT/UPDATE statements.
--   Execute only in Supabase SQL Editor or trusted migration runner by an authorized admin.
--   The ChatGPT environment that prepared this file does not have direct database access.

begin;

do $$
declare
  services_has_id_default boolean := false;
  homepage_has_id_default boolean := false;
  homepage_has_updated_at boolean := false;
  homepage_settings_data_type text := 'jsonb';
  homepage_settings_expr text;
  has_gen_random_uuid boolean := false;
  required_missing text;
  homepage_insert_columns text;
  homepage_insert_values text;
  homepage_update_sql text;
begin
  -- 00) Required table/column guardrails.
  select string_agg(req.table_schema || '.' || req.table_name || '.' || req.column_name, ', ' order by req.table_schema, req.table_name, req.column_name)
  into required_missing
  from (
    values
      ('public', 'services', 'id'),
      ('public', 'services', 'title'),
      ('public', 'services', 'icon'),
      ('public', 'services', 'link'),
      ('public', 'services', 'is_active'),
      ('public', 'services', 'order_index'),
      ('public', 'homepage_sections', 'id'),
      ('public', 'homepage_sections', 'section_name'),
      ('public', 'homepage_sections', 'settings'),
      ('public', 'homepage_sections', 'is_active'),
      ('public', 'homepage_sections', 'display_order'),
      ('public', 'homepage_sections', 'unit_id')
  ) as req(table_schema, table_name, column_name)
  where not exists (
    select 1
    from information_schema.columns c
    where c.table_schema = req.table_schema
      and c.table_name = req.table_name
      and c.column_name = req.column_name
  );

  if required_missing is not null then
    raise exception 'Missing required columns for Services Center approved seed execution: %', required_missing;
  end if;

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
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'homepage_sections'
      and column_name = 'updated_at'
  ) into homepage_has_updated_at;

  select data_type
  into homepage_settings_data_type
  from information_schema.columns
  where table_schema = 'public'
    and table_name = 'homepage_sections'
    and column_name = 'settings';

  homepage_settings_expr :=
    case when homepage_settings_data_type = 'json' then 'json_build_object' else 'jsonb_build_object' end || '(' ||
      quote_literal('title') || ', ' || quote_literal('كتالوج خدمات الجمهور المعتمد') || ', ' ||
      quote_literal('subtitle') || ', ' || quote_literal('بطاقات خدمات الجمهور العامة المقروءة من public.services. لا تشمل خدمات العقارات الوقفية. ظهور القسم أو إخفاؤه يدار من homepage_sections حسب الوحدة/النطاق.') ||
    ')';

  select exists (
    select 1
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where p.proname = 'gen_random_uuid'
      and n.nspname in ('pg_catalog', 'public', 'extensions')
  ) into has_gen_random_uuid;

  if not services_has_id_default and not has_gen_random_uuid then
    raise exception 'public.services.id has no default and gen_random_uuid() is not available.';
  end if;

  if not homepage_has_id_default and not has_gen_random_uuid then
    raise exception 'public.homepage_sections.id has no default and gen_random_uuid() is not available.';
  end if;

  -- 01) Insert public.services rows, skipping any existing row with same title or link.
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
      select 1
      from public.services ps
      where ps.title = s.title
         or ps.link = s.link
    );
  else
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
      select 1
      from public.services ps
      where ps.title = s.title
         or ps.link = s.link
    );
  end if;

  -- 02) Upsert central dynamic homepage section row.
  -- Visibility/scope/order are DB-controlled through public.homepage_sections.
  -- unit_id IS NULL represents the central/ministry/home scope in this seed.
  if exists (
    select 1
    from public.homepage_sections hs
    where hs.section_name = 'pwf_public_services_catalog'
      and hs.unit_id is null
  ) then
    homepage_update_sql :=
      'update public.homepage_sections set ' ||
      'is_active = true, ' ||
      'display_order = 25, ' ||
      'settings = ' || homepage_settings_expr ||
      case when homepage_has_updated_at then ', updated_at = now()' else '' end ||
      ' where section_name = ' || quote_literal('pwf_public_services_catalog') ||
      ' and unit_id is null';

    execute homepage_update_sql;
  else
    if homepage_has_id_default then
      homepage_insert_columns := 'section_name, settings, is_active, display_order, unit_id' || case when homepage_has_updated_at then ', updated_at' else '' end;
      homepage_insert_values :=
        quote_literal('pwf_public_services_catalog') || ', ' ||
        homepage_settings_expr || ', true, 25, null' ||
        case when homepage_has_updated_at then ', now()' else '' end;
    else
      homepage_insert_columns := 'id, section_name, settings, is_active, display_order, unit_id' || case when homepage_has_updated_at then ', updated_at' else '' end;
      homepage_insert_values :=
        'gen_random_uuid(), ' ||
        quote_literal('pwf_public_services_catalog') || ', ' ||
        homepage_settings_expr || ', true, 25, null' ||
        case when homepage_has_updated_at then ', now()' else '' end;
    end if;

    execute 'insert into public.homepage_sections (' || homepage_insert_columns || ') values (' || homepage_insert_values || ')';
  end if;
end $$;

commit;

-- 03) Post-execution verification.
select 'post_insert_public_services' as section,
       id,
       title,
       icon,
       link,
       is_active,
       order_index
from public.services
where link in ('/services', '/eservices', '/services/request', '/services/track', '/complaints', '/legal-references', '/zakat', '/prayer-times', '/quran')
order by order_index asc, title asc;

select 'post_insert_public_services_count' as section,
       count(*) as expected_or_existing_rows
from public.services
where link in ('/services', '/eservices', '/services/request', '/services/track', '/complaints', '/legal-references', '/zakat', '/prayer-times', '/quran');

select 'post_insert_homepage_section' as section,
       id,
       section_name,
       settings,
       is_active,
       display_order,
       unit_id
from public.homepage_sections
where section_name = 'pwf_public_services_catalog'
order by unit_id nulls first, display_order asc;

select 'route_pattern_links_rejected_for_public_services_after_execution' as section,
       id,
       title,
       link
from public.services
where coalesce(link, '') like '%/:%'
order by order_index asc, title asc;

select 'waqf_property_rows_rejected_for_public_services_after_execution' as section,
       id,
       title,
       link,
       'Move to properties/waqf_assets workflow; not public.services.' as required_action
from public.services
where lower(coalesce(title, '')) similar to '%(عقار|عقارات|أصل|أصول|asset|property)%'
   or lower(coalesce(link, '')) similar to '%(property|properties|waqf-assets|waqf_asset)%'
order by order_index asc, title asc;
