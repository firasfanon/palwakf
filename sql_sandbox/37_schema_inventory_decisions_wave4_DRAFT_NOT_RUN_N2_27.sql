-- PalWakf N2.27
-- Draft only. Updates platform.schema_inventory_decisions if approved.

-- Expected table: platform.schema_inventory_decisions from N2.23.
-- This draft records decisions only. It does not move data.

insert into platform.schema_inventory_decisions
  (schema_name, table_name, object_type, current_owner_system, recommended_owner_system, classification, decision, risk_level, action_required, notes)
values
  ('public', 'site_pages', 'table', 'public', 'site_content', 'site_content_candidate', 'migration_plan_required', 'medium', 'prepare_rls_rpc_flutter_migration', 'N2.27 site content ownership'),
  ('public', 'homepage_sections', 'table', 'public', 'site_content', 'site_content_candidate', 'migration_plan_required', 'high', 'prepare_rls_rpc_flutter_migration', 'Controls dynamic homepage visibility/order'),
  ('public', 'home_config', 'table', 'public', 'site_content', 'site_content_candidate', 'migration_plan_required', 'high', 'prepare_rls_rpc_flutter_migration', 'Home configuration'),
  ('public', 'header_settings', 'table', 'public', 'site_content', 'site_content_candidate', 'migration_plan_required', 'high', 'prepare_rls_rpc_flutter_migration', 'Header settings'),
  ('public', 'footer_settings', 'table', 'public', 'site_content', 'site_content_candidate', 'migration_plan_required', 'high', 'prepare_rls_rpc_flutter_migration', 'Footer settings'),
  ('public', 'activities', 'table', 'public', 'media_center', 'media_candidate', 'migration_plan_required', 'high', 'prepare_rls_rpc_flutter_migration', 'Media center activity content'),
  ('public', 'announcements', 'table', 'public', 'media_center', 'media_candidate', 'migration_plan_required', 'high', 'prepare_rls_rpc_flutter_migration', 'Media announcements'),
  ('public', 'news_articles', 'table', 'public', 'media_center', 'media_candidate', 'migration_plan_required', 'high', 'prepare_rls_rpc_flutter_migration', 'Media news articles'),
  ('public', 'services', 'table', 'public', 'platform_services', 'services_candidate', 'mapping_plan_required', 'medium', 'map_to_platform_services', 'Public services catalog legacy/transitional')
on conflict do nothing;
