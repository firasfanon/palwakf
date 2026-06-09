-- Read-only follow-up. Inspect view definitions only. Do not rewrite.
select
  'view_definition_followup'::text as section,
  n.nspname || '.' || c.relname as view_name,
  pg_get_viewdef(c.oid, true) as view_definition,
  false as rewrite_authorized_by_this_script,
  false as destructive_sql_authorized,
  false as production_approved,
  true as read_only
from pg_class c
join pg_namespace n on n.oid = c.relnamespace
where c.relkind in ('v', 'm')
  and (
    n.nspname || '.' || c.relname in (
      'cms.v_public_unit_activities',
      'cms.v_public_unit_services',
      'cms.v_public_unit_news',
      'public.v_media_news_compat_v1',
      'public.v_media_announcements_compat_v1',
      'public.v_media_activities_compat_v1',
      'public.v_media_gallery_compat_v1',
      'public.v_services_catalog_compat_v1',
      'public.v_home_services_compat_v1'
    )
  )
order by view_name;
