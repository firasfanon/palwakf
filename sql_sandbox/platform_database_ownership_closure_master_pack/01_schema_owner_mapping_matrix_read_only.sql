-- Platform Database Ownership Closure Master Pack — 01
-- OWNER MAPPING MATRIX READ-ONLY. No DDL/DML.
with mapping(legacy_object,target_object,owner_schema,risk,decision,note) as (
  values
  ('public.news_articles','media_center.content_items','media_center','high','preserve_public_compat_view','legacy media source; writes must move to owner RPC'),
  ('public.announcements','media_center.content_items','media_center','high','preserve_public_compat_view','legacy media source; type=announcement'),
  ('public.activities','media_center.content_items','media_center','high','preserve_public_compat_view','legacy media source; activities/events'),
  ('public.media_gallery_items','media_center.media_gallery_items','media_center','high','preserve_public_compat_view','gallery/media library owner schema'),
  ('public.friday_sermons','media_center.friday_sermons','media_center','medium','preserve_public_compat_view','sermon content remains media/editorial'),
  ('public.breaking_news','platform_content.breaking_news','platform_content','medium','preserve_public_compat_view','platform homepage/public alert content'),
  ('public.hero_slides','platform_content.hero_slides','platform_content','medium','preserve_public_compat_view','visual content / homepage hero'),
  ('public.homepage_sections','platform_content.homepage_sections','platform_content','high','preserve_public_compat_view','home sections visibility/order/scope'),
  ('public.site_pages','platform_content.site_pages','platform_content','high','preserve_public_compat_view','public site/page-builder surface'),
  ('public.header_settings','platform_content.header_settings','platform_content','medium','preserve_public_compat_view','public header configuration'),
  ('public.footer_settings','platform_content.footer_settings','platform_content','medium','preserve_public_compat_view','public footer configuration'),
  ('public.site_settings','platform_content.site_settings','platform_content','medium','preserve_public_compat_view','site-wide settings'),
  ('public.services','platform_services.public_services_catalog','platform_services','high','preserve_public_compat_view','public services catalog'),
  ('public.service_forms_registry','platform_services.service_forms_registry','platform_services','high','owner_already_expected','forms registry owner schema'),
  ('public.service_requests','platform_services.service_requests','platform_services','high','owner_already_expected','service request owner schema'),
  ('public.platform_systems','platform_access.platform_systems','platform_access','critical','compat_view_rpc_only','dynamic system registry'),
  ('public.platform_permissions','platform_access.platform_permissions','platform_access','critical','compat_view_rpc_only','platform permissions'),
  ('public.user_system_roles','platform_access.user_system_roles','platform_access','critical','compat_view_rpc_only','role assignments; no auth.users migration'),
  ('public.user_system_permissions','platform_access.user_system_permissions','platform_access','critical','compat_view_rpc_only','direct permission grants; no auth.users migration'),
  ('public.admin_users','core.admin_users','core','critical','compat_view_rpc_only','admin profile/linkage; auth.users untouched'),
  ('public.users','core.user_accounts','core','critical','compat_view_rpc_only','profile cache only; no auth.users migration'),
  ('public.org_units','core.org_units','core','critical','read_wrapper_only','org units sovereign reference'),
  ('public.org_unit_profiles','core.org_unit_profiles','core','high','read_wrapper_only','unit profile/reference'),
  ('public.assistant_conversations','assistant.assistant_conversations','assistant','high','compat_view_rpc_only','assistant is existing system; maturity closure applies'),
  ('public.assistant_messages','assistant.assistant_messages','assistant','high','compat_view_rpc_only','assistant messages; citations/RAG pending'),
  ('public.chatbot_conversations','assistant.chatbot_conversations','assistant','medium','compat_view_rpc_only','legacy chatbot compatibility'),
  ('public.chatbot_messages','assistant.chatbot_messages','assistant','medium','compat_view_rpc_only','legacy chatbot compatibility'),
  ('public.cases','cases.case_records','cases','high','owner_schema_required','case system ownership'),
  ('public.pwf_complaints','platform_services.complaints','platform_services','medium','owner_schema_required','legacy complaint surface'),
  ('public.pwf_complaint_updates','platform_services.complaint_updates','platform_services','medium','owner_schema_required','legacy complaint updates'),
  ('public.tasks','tasks.tasks','tasks','medium','owner_schema_required','tasks system owns data'),
  ('public.waqf_lands','waqf.waqf_lands','waqf','critical','do_not_migrate_in_platform_batch','sovereign waqf/awqaf line; excluded'),
  ('public.mosques','awqaf_system.mosques','awqaf_system','critical','do_not_migrate_in_platform_batch','sovereign awqaf_system; excluded'),
  ('gis.*','gis.*','gis','critical','read_only_wrappers_only','GIS owner schema; no writes'),
  ('auth.users','auth.users','auth','critical','never_migrate','auth provider table; never migrated by platform')
)
select 'schema_owner_mapping_matrix' as section, *
from mapping
order by risk desc, owner_schema, legacy_object;
