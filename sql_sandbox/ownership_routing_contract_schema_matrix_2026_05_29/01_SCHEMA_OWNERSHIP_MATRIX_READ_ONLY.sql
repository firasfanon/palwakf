select *
from (values
  ('media_center','public.news_articles','media_center.content_items','freeze_public_keep_compat','no_delete_no_rewrite'),
  ('media_center','public.announcements','media_center.content_items','freeze_public_keep_compat','no_delete_no_rewrite'),
  ('media_center','public.activities','media_center.content_items / cms.unit_activities','freeze_public_keep_compat','no_delete_no_rewrite'),
  ('media_center','public.breaking_news','media_center.content_items','freeze_public_keep_compat','no_delete_no_rewrite'),
  ('media_center','public.media_gallery_items','media_center.content_assets','freeze_public_keep_compat','no_delete_no_rewrite'),
  ('service_center','public.service_requests','platform_services.service_requests','absent_or_owner_exists','no_action'),
  ('service_center','public.service_forms','platform_services.service_forms_registry','absent_or_owner_exists','no_action'),
  ('navigation','public.services','platform_navigation.service_entries','owner_missing','design_owner_then_migrate'),
  ('navigation','public.home_services','platform_navigation.home_entries','owner_missing','design_owner_then_migrate'),
  ('service_taxonomy','public.servicepoints','tbd','preserve','manual_design_required'),
  ('service_taxonomy','public.serviceproviders','tbd','preserve','manual_design_required'),
  ('service_taxonomy','public.servicetypes','tbd','preserve','manual_design_required')
) as t(domain_key, current_public_object, target_owner_object, current_status, required_next_action)
order by domain_key, current_public_object;
