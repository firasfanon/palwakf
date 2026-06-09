
-- Script 03: Public ownership assignment matrix read-only
-- Purpose: assign intended owner schema/action for every public relation/function by naming and known PalWakf contracts.

with objects as (
  select
    c.relname as object_name,
    case c.relkind
      when 'r' then 'table'
      when 'p' then 'partitioned_table'
      when 'v' then 'view'
      when 'm' then 'materialized_view'
      when 'S' then 'sequence'
      else c.relkind::text
    end as object_type
  from pg_catalog.pg_class c
  join pg_catalog.pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public'
    and c.relkind in ('r','p','v','m','S')
  union all
  select
    p.proname || '(' || pg_catalog.pg_get_function_identity_arguments(p.oid) || ')' as object_name,
    'function' as object_type
  from pg_catalog.pg_proc p
  join pg_catalog.pg_namespace n on n.oid = p.pronamespace
  where n.nspname = 'public'
), classified as (
  select
    object_type,
    object_name,
    case
      when object_type in ('view','function') and (object_name like 'v_%' or object_name like 'rpc_%' or object_name like 'pwf_%') then 'public'
      when object_name in ('homepage_sections','header_settings','footer_settings','site_pages','navigation_items','theme_settings','visual_identity_overrides','platform_routes','public_pages','app_settings') then 'platform'
      when object_name in ('admin_users','user_profiles','profiles','employees','staff_profiles','org_unit_users','org_units_cache','pwf_org_units_cache') then 'core'
      when object_name in ('roles','permissions','user_roles','user_permissions','user_system_roles','user_system_permissions','admin_permissions','access_profiles','system_roles') then 'platform'
      when object_name in ('news_articles','announcements','activities','media_gallery_items','news') then 'media_center'
      when object_name in ('services','servicetypes','servicepoints','serviceproviders','service_requests','service_forms','service_catalog') then 'platform_services'
      when object_name like 'zakat%' or object_name like '%zakat%' then 'zakat_or_public_wrapper'
      when object_name like 'billing%' or object_name like '%payment%' or object_name like '%receipt%' then 'billing_system_or_public_wrapper'
      when object_name like 'case%' or object_name like '%legal%' then 'cases'
      when object_name like 'assistant%' or object_name like 'chat%' or object_name like '%chatbot%' then 'assistant'
      when object_name like '%location%' or object_name in ('locations') then 'gis_or_public_wrapper'
      else 'needs_manual_owner_review'
    end as proposed_owner_schema,
    case
      when object_type in ('view','function') and (object_name like 'v_%' or object_name like 'rpc_%' or object_name like 'pwf_%') then 'KEEP_AS_PUBLIC_WRAPPER'
      when object_name in ('homepage_sections','header_settings','footer_settings','site_pages','navigation_items','theme_settings','visual_identity_overrides','platform_routes','public_pages','app_settings') then 'MIGRATE_TO_PLATFORM_KEEP_PUBLIC_COMPAT_VIEW'
      when object_name in ('admin_users','user_profiles','profiles','employees','staff_profiles','org_unit_users','org_units_cache','pwf_org_units_cache') then 'MIGRATE_TO_CORE_OR_KEEP_AUTH_LINKED_COMPAT_VIEW'
      when object_name in ('roles','permissions','user_roles','user_permissions','user_system_roles','user_system_permissions','admin_permissions','access_profiles','system_roles') then 'MIGRATE_TO_PLATFORM_ACCESS_KEEP_PUBLIC_RPC'
      when object_name in ('news_articles','announcements','activities','media_gallery_items','news') then 'QUARANTINE_LEGACY_AFTER_MEDIA_CENTER_VERIFICATION'
      when object_name in ('services','servicetypes','servicepoints','serviceproviders','service_requests','service_forms','service_catalog') then 'QUARANTINE_LEGACY_AFTER_PLATFORM_SERVICES_VERIFICATION'
      when object_name like 'zakat%' or object_name like '%zakat%' then 'MOVE_OWNER_TO_ZAKAT_KEEP_PUBLIC_WRAPPER'
      when object_name like 'billing%' or object_name like '%payment%' or object_name like '%receipt%' then 'MOVE_OWNER_TO_BILLING_SYSTEM_KEEP_PUBLIC_WRAPPER'
      when object_name like 'case%' or object_name like '%legal%' then 'MOVE_OWNER_TO_CASES_KEEP_PUBLIC_WRAPPER'
      when object_name like 'assistant%' or object_name like 'chat%' or object_name like '%chatbot%' then 'MOVE_OWNER_TO_ASSISTANT_KEEP_PUBLIC_WRAPPER'
      when object_name like '%location%' or object_name in ('locations') then 'GIS_CORE_AUTHORITY_REVIEW_KEEP_PUBLIC_WRAPPER'
      else 'MANUAL_REVIEW_REQUIRED_BEFORE_MIGRATION'
    end as assignment_decision
  from objects
)
select
  'public_ownership_assignment_matrix' as section,
  object_type,
  object_name,
  proposed_owner_schema,
  assignment_decision,
  'decision-only; no migration or deletion is performed by this inventory pack' as note
from classified
order by proposed_owner_schema, object_type, object_name;
