select
  'public_legacy_freeze_classification' as section,
  x.legacy_object,
  to_regclass(x.legacy_object) is not null as present,
  x.freeze_status,
  x.reason,
  false as migration_authorized_by_this_script,
  false as delete_authorized_by_this_script,
  false as destructive_sql_authorized,
  false as production_approved,
  true as read_only
from (values
  ('public.news_articles','frozen_keep_compat','media legacy table; owner exists but deletion not authorized'),
  ('public.announcements','frozen_keep_compat','media legacy table; owner exists but deletion not authorized'),
  ('public.activities','frozen_keep_compat','media legacy table; owner exists but deletion not authorized'),
  ('public.breaking_news','frozen_keep_compat','media legacy ticker; preserve until owner closure'),
  ('public.media_gallery_items','frozen_keep_compat','media gallery legacy; preserve until owner closure'),
  ('public.services','frozen_navigation_surface','navigation/service-entry catalog; owner missing'),
  ('public.home_services','frozen_home_navigation_surface','homepage/navigation surface; owner missing'),
  ('public.servicepoints','preserve_pending_design','taxonomy/location/service point semantics unresolved'),
  ('public.serviceproviders','preserve_pending_design','provider semantics unresolved'),
  ('public.servicetypes','preserve_pending_design','service taxonomy semantics unresolved')
) as x(legacy_object, freeze_status, reason)
order by x.legacy_object;
