with public_services as (
  select
    count(*)::int as public_services_rows,
    jsonb_agg(
      jsonb_build_object(
        'id', id,
        'title', title,
        'link', link,
        'icon', icon,
        'is_active', is_active,
        'order_index', order_index
      )
      order by order_index nulls last, title nulls last
    ) as public_services_sample
  from public.services
),
forms as (
  select
    count(*)::int as platform_forms_rows,
    jsonb_agg(
      jsonb_build_object(
        'form_key', form_key,
        'service_key', service_key,
        'title_ar', title_ar,
        'audience', audience,
        'review_status', review_status,
        'public_visibility', public_visibility
      )
      order by service_family, service_key, title_ar
    ) as platform_forms_sample
  from platform_services.service_forms_registry
),
route_classification as (
  select
    s.id,
    s.title,
    s.link,
    case
      when s.link in ('/services','/eservices','/services/request','/services/track')
        then 'service_center_entry_route'
      when s.link in ('/complaints','/legal-references','/zakat','/prayer-times','/quran')
        then 'cross_system_or_public_utility_route'
      else 'unclassified_public_service_entry'
    end as route_owner_class
  from public.services s
)
select
  'service_navigation_owner_separation' as section,
  ps.public_services_rows,
  f.platform_forms_rows,
  case
    when ps.public_services_rows = f.platform_forms_rows then 'COUNT_MATCH_REVIEW_STILL_REQUIRED'
    else 'COUNT_MISMATCH_PUBLIC_SERVICES_IS_NAVIGATION_OR_SERVICE_ENTRY_CATALOG'
  end as mapping_decision,
  (select jsonb_agg(to_jsonb(route_classification) order by link) from route_classification) as route_classification,
  false as rewrite_authorized_by_this_script,
  false as delete_authorized_by_this_script,
  true as read_only
from public_services ps
cross join forms f;
