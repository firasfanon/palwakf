-- PalWakf V4 Wave1 Runtime Gate SQL01/SQL02 ST_Union Root Fix
-- Date: 2026-06-01
-- Scope: READ-ONLY. This pack does not authorize DDL/DML/GRANT/REVOKE/DROP/DELETE/ARCHIVE/RENAME.
-- Production approval: false
-- Root fixes:
--   1) SQL01 schema-bound pg_class joins to prevent cross-schema object-kind Cartesian output.
--   2) SQL02/SQL06 exclude aggregate/window functions before pg_get_functiondef to avoid ERROR 42809 on ST_Union.

with candidates(public_table, target_schema, target_table, sensitivity) as (
  values
    ('awqaf_assist_answer_contracts', 'awqaf_system', 'awqaf_assist_answer_contracts', 'high'),
    ('awqaf_assist_workspace_items', 'awqaf_system', 'awqaf_assist_workspace_items', 'high'),
    ('awqaf_system_content', 'awqaf_system', 'awqaf_system_content', 'high'),
    ('awqaf_system_institution_profile', 'awqaf_system', 'awqaf_system_institution_profile', 'high'),
    ('awqaf_system_settings', 'awqaf_system', 'awqaf_system_settings', 'high'),
    ('awqaf_system_unit_pages', 'awqaf_system', 'awqaf_system_unit_pages', 'high'),
    ('documents', 'cms', 'documents', 'medium'),
    ('pwf_complaint_attachments', 'complaints', 'pwf_complaint_attachments', 'high'),
    ('pwf_complaint_updates', 'complaints', 'pwf_complaint_updates', 'high'),
    ('pwf_complaints', 'complaints', 'pwf_complaints', 'high'),
    ('pwf_complaints_retention_policies', 'complaints', 'pwf_complaints_retention_policies', 'high'),
    ('awqaf_community_document_evidence_links', 'core', 'awqaf_community_document_evidence_links', 'high'),
    ('cities', 'core', 'cities', 'high'),
    ('governorates', 'core', 'governorates', 'high'),
    ('historical_admin_units', 'hist', 'historical_admin_units', 'medium-high'),
    ('historical_layers', 'hist', 'historical_layers', 'medium-high'),
    ('historical_periods', 'hist', 'historical_periods', 'medium-high'),
    ('land_admin_history', 'hist', 'land_admin_history', 'medium-high'),
    ('daily_habits', 'legacy_quarantine', 'daily_habits', 'low'),
    ('intelligentrecommendations', 'legacy_quarantine', 'intelligentrecommendations', 'low'),
    ('activities', 'media_center', 'activities', 'medium'),
    ('announcement_items', 'media_center', 'announcement_items', 'medium'),
    ('announcements', 'media_center', 'announcements', 'medium'),
    ('categories', 'media_center', 'categories', 'medium'),
    ('media_center_audit_events', 'media_center', 'media_center_audit_events', 'medium-high'),
    ('media_center_editorial_events', 'media_center', 'media_center_editorial_events', 'medium-high'),
    ('media_center_editorial_roles', 'media_center', 'media_center_editorial_roles', 'medium-high'),
    ('media_center_permission_uat_events', 'media_center', 'media_center_permission_uat_events', 'medium-high'),
    ('media_center_publishing_governance_rules', 'media_center', 'media_center_publishing_governance_rules', 'medium-high'),
    ('media_gallery_items', 'media_center', 'media_gallery_items', 'medium'),
    ('news', 'media_center', 'news', 'medium'),
    ('news_articles', 'media_center', 'news_articles', 'medium'),
    ('news_items', 'media_center', 'news_items', 'medium'),
    ('social_notices', 'media_center', 'social_notices', 'medium'),
    ('achievements', 'ministry_profile', 'achievements', 'medium'),
    ('former_ministers', 'ministry_profile', 'former_ministers', 'medium'),
    ('pwf_former_ministers', 'ministry_profile', 'pwf_former_ministers', 'medium'),
    ('mustakshif_announcements', 'mustakshif_staging', 'mustakshif_announcements', 'medium'),
    ('mustakshif_news', 'mustakshif_staging', 'mustakshif_news', 'medium'),
    ('mustakshif_site_pages', 'mustakshif_staging', 'mustakshif_site_pages', 'medium'),
    ('admin_users', 'platform_access', 'admin_users', 'high'),
    ('platform_permissions', 'platform_access', 'platform_permissions', 'high'),
    ('platform_systems', 'platform_access', 'platform_systems', 'high'),
    ('user_accounts', 'platform_access', 'user_accounts', 'high'),
    ('user_permissions', 'platform_access', 'user_permissions', 'high'),
    ('user_scope_assignment_units', 'platform_access', 'user_scope_assignment_units', 'high'),
    ('user_scope_assignments', 'platform_access', 'user_scope_assignments', 'high'),
    ('user_system_permissions', 'platform_access', 'user_system_permissions', 'high'),
    ('user_system_roles', 'platform_access', 'user_system_roles', 'high'),
    ('site_pages', 'platform_content', 'site_pages', 'medium'),
    ('app_settings', 'platform_experience', 'app_settings', 'medium'),
    ('breaking_news', 'platform_experience', 'breaking_news', 'medium'),
    ('footer_settings', 'platform_experience', 'footer_settings', 'medium'),
    ('header_settings', 'platform_experience', 'header_settings', 'medium'),
    ('hero_slides', 'platform_experience', 'hero_slides', 'medium'),
    ('home_config', 'platform_experience', 'home_config', 'medium'),
    ('home_hero_slides', 'platform_experience', 'home_hero_slides', 'medium'),
    ('home_news', 'platform_experience', 'home_news', 'medium'),
    ('home_stats', 'platform_experience', 'home_stats', 'medium'),
    ('homepage_sections', 'platform_experience', 'homepage_sections', 'medium'),
    ('site_settings', 'platform_experience', 'site_settings', 'medium'),
    ('home_services', 'platform_navigation', 'home_services', 'medium'),
    ('services', 'platform_navigation', 'services', 'medium'),
    ('notifications', 'platform_notifications', 'notifications', 'medium-high'),
    ('reports', 'platform_reporting', 'reports', 'medium-high'),
    ('appointments', 'platform_services', 'appointments', 'medium'),
    ('servicepoints', 'platform_services', 'servicepoints', 'medium'),
    ('serviceproviders', 'platform_services', 'serviceproviders', 'medium'),
    ('servicetypes', 'platform_services', 'servicetypes', 'medium'),
    ('friday_sermons', 'religious_affairs', 'friday_sermons', 'medium-high'),
    ('islamic_terms', 'religious_affairs', 'islamic_terms', 'medium-high'),
    ('mosques', 'religious_affairs', 'mosques', 'medium-high'),
    ('task_statistics', 'tasks', 'task_statistics', 'medium'),
    ('task_status_history', 'tasks', 'task_status_history', 'medium'),
    ('task_statuses', 'tasks', 'task_statuses', 'medium'),
    ('task_types', 'tasks', 'task_types', 'medium'),
    ('awqaf_historical_topology_nodes', 'topology', 'awqaf_historical_topology_nodes', 'medium-high'),
    ('awqaf_historical_topology_relations', 'topology', 'awqaf_historical_topology_relations', 'medium-high'),
    ('historical_child_level_policy', 'topology', 'historical_child_level_policy', 'medium-high'),
    ('historical_cluster_anchor_registry', 'topology', 'historical_cluster_anchor_registry', 'medium-high'),
    ('historical_parent_seed_matrix', 'topology', 'historical_parent_seed_matrix', 'medium-high'),
    ('historical_seed_decision_registry', 'topology', 'historical_seed_decision_registry', 'medium-high'),
    ('waqf_community_lineage', 'topology', 'waqf_community_lineage', 'medium-high'),
    ('assettypes', 'waqf', 'assettypes', 'high'),
    ('awqaf_reference_waqf_links', 'waqf', 'awqaf_reference_waqf_links', 'high'),
    ('endowment_supervisors', 'waqf', 'endowment_supervisors', 'high'),
    ('waqf_lands', 'waqf', 'waqf_lands', 'high'),
    ('zakat_donation_requests', 'zakat', 'zakat_donation_requests', 'high')
), public_objects as (
  select
    cls.relname,
    cls.relkind
  from pg_namespace ns
  join pg_class cls on cls.relnamespace = ns.oid
  where ns.nspname = 'public'
    and cls.relkind in ('r','v','m','f','p')
), target_objects as (
  select
    ns.nspname as target_schema,
    cls.relname,
    cls.relkind
  from pg_namespace ns
  join pg_class cls on cls.relnamespace = ns.oid
  where cls.relkind in ('r','v','m','f','p')
)
select
  'v4_wave1_post_apply_shape_reconfirm_detail' as section,
  c.public_table,
  c.target_schema,
  c.target_table,
  c.sensitivity,
  po.relkind as public_object_kind,
  tgo.relkind as target_object_kind,
  case
    when po.relkind = 'v' and tgo.relkind = 'r' then 'POST_APPLY_SHAPE_OK_PUBLIC_VIEW_TARGET_TABLE'
    when po.relkind is null then 'PUBLIC_COMPATIBILITY_VIEW_MISSING'
    when tgo.relkind is null then 'TARGET_OWNER_TABLE_MISSING'
    else 'POST_APPLY_SHAPE_REVIEW_REQUIRED'
  end as shape_decision,
  true as read_only
from candidates c
left join public_objects po on po.relname = c.public_table
left join target_objects tgo on tgo.target_schema = c.target_schema and tgo.relname = c.target_table
order by c.target_schema, c.public_table;

with candidates(public_table, target_schema, target_table, sensitivity) as (
  values
    ('awqaf_assist_answer_contracts', 'awqaf_system', 'awqaf_assist_answer_contracts', 'high'),
    ('awqaf_assist_workspace_items', 'awqaf_system', 'awqaf_assist_workspace_items', 'high'),
    ('awqaf_system_content', 'awqaf_system', 'awqaf_system_content', 'high'),
    ('awqaf_system_institution_profile', 'awqaf_system', 'awqaf_system_institution_profile', 'high'),
    ('awqaf_system_settings', 'awqaf_system', 'awqaf_system_settings', 'high'),
    ('awqaf_system_unit_pages', 'awqaf_system', 'awqaf_system_unit_pages', 'high'),
    ('documents', 'cms', 'documents', 'medium'),
    ('pwf_complaint_attachments', 'complaints', 'pwf_complaint_attachments', 'high'),
    ('pwf_complaint_updates', 'complaints', 'pwf_complaint_updates', 'high'),
    ('pwf_complaints', 'complaints', 'pwf_complaints', 'high'),
    ('pwf_complaints_retention_policies', 'complaints', 'pwf_complaints_retention_policies', 'high'),
    ('awqaf_community_document_evidence_links', 'core', 'awqaf_community_document_evidence_links', 'high'),
    ('cities', 'core', 'cities', 'high'),
    ('governorates', 'core', 'governorates', 'high'),
    ('historical_admin_units', 'hist', 'historical_admin_units', 'medium-high'),
    ('historical_layers', 'hist', 'historical_layers', 'medium-high'),
    ('historical_periods', 'hist', 'historical_periods', 'medium-high'),
    ('land_admin_history', 'hist', 'land_admin_history', 'medium-high'),
    ('daily_habits', 'legacy_quarantine', 'daily_habits', 'low'),
    ('intelligentrecommendations', 'legacy_quarantine', 'intelligentrecommendations', 'low'),
    ('activities', 'media_center', 'activities', 'medium'),
    ('announcement_items', 'media_center', 'announcement_items', 'medium'),
    ('announcements', 'media_center', 'announcements', 'medium'),
    ('categories', 'media_center', 'categories', 'medium'),
    ('media_center_audit_events', 'media_center', 'media_center_audit_events', 'medium-high'),
    ('media_center_editorial_events', 'media_center', 'media_center_editorial_events', 'medium-high'),
    ('media_center_editorial_roles', 'media_center', 'media_center_editorial_roles', 'medium-high'),
    ('media_center_permission_uat_events', 'media_center', 'media_center_permission_uat_events', 'medium-high'),
    ('media_center_publishing_governance_rules', 'media_center', 'media_center_publishing_governance_rules', 'medium-high'),
    ('media_gallery_items', 'media_center', 'media_gallery_items', 'medium'),
    ('news', 'media_center', 'news', 'medium'),
    ('news_articles', 'media_center', 'news_articles', 'medium'),
    ('news_items', 'media_center', 'news_items', 'medium'),
    ('social_notices', 'media_center', 'social_notices', 'medium'),
    ('achievements', 'ministry_profile', 'achievements', 'medium'),
    ('former_ministers', 'ministry_profile', 'former_ministers', 'medium'),
    ('pwf_former_ministers', 'ministry_profile', 'pwf_former_ministers', 'medium'),
    ('mustakshif_announcements', 'mustakshif_staging', 'mustakshif_announcements', 'medium'),
    ('mustakshif_news', 'mustakshif_staging', 'mustakshif_news', 'medium'),
    ('mustakshif_site_pages', 'mustakshif_staging', 'mustakshif_site_pages', 'medium'),
    ('admin_users', 'platform_access', 'admin_users', 'high'),
    ('platform_permissions', 'platform_access', 'platform_permissions', 'high'),
    ('platform_systems', 'platform_access', 'platform_systems', 'high'),
    ('user_accounts', 'platform_access', 'user_accounts', 'high'),
    ('user_permissions', 'platform_access', 'user_permissions', 'high'),
    ('user_scope_assignment_units', 'platform_access', 'user_scope_assignment_units', 'high'),
    ('user_scope_assignments', 'platform_access', 'user_scope_assignments', 'high'),
    ('user_system_permissions', 'platform_access', 'user_system_permissions', 'high'),
    ('user_system_roles', 'platform_access', 'user_system_roles', 'high'),
    ('site_pages', 'platform_content', 'site_pages', 'medium'),
    ('app_settings', 'platform_experience', 'app_settings', 'medium'),
    ('breaking_news', 'platform_experience', 'breaking_news', 'medium'),
    ('footer_settings', 'platform_experience', 'footer_settings', 'medium'),
    ('header_settings', 'platform_experience', 'header_settings', 'medium'),
    ('hero_slides', 'platform_experience', 'hero_slides', 'medium'),
    ('home_config', 'platform_experience', 'home_config', 'medium'),
    ('home_hero_slides', 'platform_experience', 'home_hero_slides', 'medium'),
    ('home_news', 'platform_experience', 'home_news', 'medium'),
    ('home_stats', 'platform_experience', 'home_stats', 'medium'),
    ('homepage_sections', 'platform_experience', 'homepage_sections', 'medium'),
    ('site_settings', 'platform_experience', 'site_settings', 'medium'),
    ('home_services', 'platform_navigation', 'home_services', 'medium'),
    ('services', 'platform_navigation', 'services', 'medium'),
    ('notifications', 'platform_notifications', 'notifications', 'medium-high'),
    ('reports', 'platform_reporting', 'reports', 'medium-high'),
    ('appointments', 'platform_services', 'appointments', 'medium'),
    ('servicepoints', 'platform_services', 'servicepoints', 'medium'),
    ('serviceproviders', 'platform_services', 'serviceproviders', 'medium'),
    ('servicetypes', 'platform_services', 'servicetypes', 'medium'),
    ('friday_sermons', 'religious_affairs', 'friday_sermons', 'medium-high'),
    ('islamic_terms', 'religious_affairs', 'islamic_terms', 'medium-high'),
    ('mosques', 'religious_affairs', 'mosques', 'medium-high'),
    ('task_statistics', 'tasks', 'task_statistics', 'medium'),
    ('task_status_history', 'tasks', 'task_status_history', 'medium'),
    ('task_statuses', 'tasks', 'task_statuses', 'medium'),
    ('task_types', 'tasks', 'task_types', 'medium'),
    ('awqaf_historical_topology_nodes', 'topology', 'awqaf_historical_topology_nodes', 'medium-high'),
    ('awqaf_historical_topology_relations', 'topology', 'awqaf_historical_topology_relations', 'medium-high'),
    ('historical_child_level_policy', 'topology', 'historical_child_level_policy', 'medium-high'),
    ('historical_cluster_anchor_registry', 'topology', 'historical_cluster_anchor_registry', 'medium-high'),
    ('historical_parent_seed_matrix', 'topology', 'historical_parent_seed_matrix', 'medium-high'),
    ('historical_seed_decision_registry', 'topology', 'historical_seed_decision_registry', 'medium-high'),
    ('waqf_community_lineage', 'topology', 'waqf_community_lineage', 'medium-high'),
    ('assettypes', 'waqf', 'assettypes', 'high'),
    ('awqaf_reference_waqf_links', 'waqf', 'awqaf_reference_waqf_links', 'high'),
    ('endowment_supervisors', 'waqf', 'endowment_supervisors', 'high'),
    ('waqf_lands', 'waqf', 'waqf_lands', 'high'),
    ('zakat_donation_requests', 'zakat', 'zakat_donation_requests', 'high')
), public_objects as (
  select cls.relname, cls.relkind
  from pg_namespace ns
  join pg_class cls on cls.relnamespace = ns.oid
  where ns.nspname = 'public' and cls.relkind in ('r','v','m','f','p')
), target_objects as (
  select ns.nspname as target_schema, cls.relname, cls.relkind
  from pg_namespace ns
  join pg_class cls on cls.relnamespace = ns.oid
  where cls.relkind in ('r','v','m','f','p')
), shape as (
  select
    count(*) as wave1_count,
    count(*) filter (where po.relkind = 'v') as public_view_count,
    count(*) filter (where tgo.relkind = 'r') as target_table_count,
    count(*) filter (where po.relkind = 'v' and tgo.relkind = 'r') as shape_ok_count,
    count(*) filter (where not (po.relkind = 'v' and tgo.relkind = 'r')) as shape_blocker_count
  from candidates c
  left join public_objects po on po.relname = c.public_table
  left join target_objects tgo on tgo.target_schema = c.target_schema and tgo.relname = c.target_table
)
select
  'v4_wave1_post_apply_shape_reconfirm_summary' as section,
  wave1_count,
  public_view_count,
  target_table_count,
  shape_ok_count,
  shape_blocker_count,
  case when wave1_count = 88 and public_view_count = 88 and target_table_count = 88 and shape_blocker_count = 0
    then 'POST_APPLY_SHAPE_RECONFIRMED_88_PUBLIC_VIEWS_88_TARGET_TABLES'
    else 'POST_APPLY_SHAPE_BLOCKED_REVIEW_REQUIRED'
  end as decision,
  false as ddl_authorized_by_this_script,
  false as production_approved,
  true as read_only
from shape;
