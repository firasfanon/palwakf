-- GUARD: Draft seed only. Run only after 02 schema bootstrap is explicitly approved and executed.
-- This copies legacy rows to platform_navigation. It does not delete, archive, update, or rename public legacy rows.

insert into platform_navigation.service_entries (
  service_entry_key,
  title_ar,
  title_en,
  description_ar,
  description_en,
  route_path,
  icon_key,
  category_key,
  route_owner_class,
  is_active,
  display_order,
  legacy_source,
  legacy_id,
  migration_batch,
  raw_payload,
  metadata
)
select
  coalesce(s.id::text, md5(to_jsonb(s)::text)) as service_entry_key,
  coalesce(s.title, s.title_ar, s.name_ar, 'مدخل خدمة') as title_ar,
  coalesce(s.title_en, s.name_en) as title_en,
  coalesce(s.description, s.description_ar, s.summary_ar) as description_ar,
  coalesce(s.description_en, s.summary_en) as description_en,
  coalesce(s.link, s.route_path, s.path, s.url) as route_path,
  coalesce(s.icon, s.icon_key) as icon_key,
  coalesce(s.category_key, s.category, s.service_type) as category_key,
  case
    when coalesce(s.link, s.route_path, s.path, s.url) in ('/services','/eservices','/services/request','/services/track') then 'service_center_entry_route'
    else 'cross_system_or_public_utility_route'
  end as route_owner_class,
  coalesce(s.is_active, true) as is_active,
  coalesce(s.order_index, s.display_order, s.sort_order) as display_order,
  'public.services'::text as legacy_source,
  s.id::text as legacy_id,
  'platform_navigation_owner_bootstrap_2026_05_29'::text as migration_batch,
  to_jsonb(s) as raw_payload,
  jsonb_build_object('migrated_from', 'public.services') as metadata
from public.services s
where to_regclass('public.services') is not null
on conflict (service_entry_key) do nothing;

insert into platform_navigation.home_entries (
  home_entry_key,
  title_ar,
  title_en,
  description_ar,
  route_path,
  icon_key,
  section_key,
  is_active,
  display_order,
  legacy_source,
  legacy_id,
  migration_batch,
  raw_payload,
  metadata
)
select
  coalesce(h.id::text, md5(to_jsonb(h)::text)) as home_entry_key,
  coalesce(h.title, h.title_ar, h.name_ar, 'مدخل الصفحة الرئيسية') as title_ar,
  coalesce(h.title_en, h.name_en) as title_en,
  coalesce(h.description, h.description_ar, h.summary_ar) as description_ar,
  coalesce(h.link, h.route_path, h.path, h.url) as route_path,
  coalesce(h.icon, h.icon_key) as icon_key,
  coalesce(h.section_key, h.home_section_key, 'home_services') as section_key,
  coalesce(h.is_active, true) as is_active,
  coalesce(h.order_index, h.display_order, h.sort_order) as display_order,
  'public.home_services'::text as legacy_source,
  h.id::text as legacy_id,
  'platform_navigation_owner_bootstrap_2026_05_29'::text as migration_batch,
  to_jsonb(h) as raw_payload,
  jsonb_build_object('migrated_from', 'public.home_services') as metadata
from public.home_services h
where to_regclass('public.home_services') is not null
on conflict (home_entry_key) do nothing;

select
  'controlled_seed_from_public_navigation_guarded_not_run'::text as section,
  'DRAFT_ONLY_EXECUTE_ONLY_AFTER_EXPLICIT_OPERATOR_APPROVAL'::text as decision,
  false as delete_authorized_by_this_script,
  false as destructive_sql_authorized,
  false as public_legacy_mutation_authorized,
  false as production_approved;
