-- PalWakf V4 Wave1 Runtime Dependency Remediation + Compatibility View Grant Review + Role/RLS UAT Gate
-- Date: 2026-05-31
-- Scope: READ-ONLY unless explicitly stated. This pack does not authorize DDL/DML/GRANT/REVOKE/DROP.
-- Production approval: false


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
), public_view_privs as (
  select table_schema, table_name, grantee, privilege_type
  from information_schema.table_privileges
  where table_schema = 'public'
), target_table_privs as (
  select table_schema, table_name, grantee, privilege_type
  from information_schema.table_privileges
)
select
  'v4_wave1_compatibility_view_grant_review_summary' as section,
  count(*) as candidate_count,
  count(*) filter (where pv.table_name is not null) as public_view_grant_rows,
  count(*) filter (where tt.table_name is not null) as target_table_grant_rows,
  'REVIEW_GRANTS_ONLY_NO_GRANT_REVOKE_AUTHORIZED_BY_THIS_SCRIPT' as decision,
  false as grant_authorized_by_this_script,
  false as revoke_authorized_by_this_script,
  false as production_approved,
  true as read_only
from candidates c
left join public_view_privs pv on pv.table_name = c.public_table
left join target_table_privs tt on tt.table_schema = c.target_schema and tt.table_name = c.target_table;

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
), public_view_privs as (
  select table_schema, table_name, grantee, string_agg(privilege_type, ',' order by privilege_type) as privileges
  from information_schema.table_privileges
  where table_schema = 'public'
  group by table_schema, table_name, grantee
), target_table_privs as (
  select table_schema, table_name, grantee, string_agg(privilege_type, ',' order by privilege_type) as privileges
  from information_schema.table_privileges
  group by table_schema, table_name, grantee
)
select
  'v4_wave1_compatibility_view_grant_review_detail' as section,
  c.public_table,
  c.target_schema,
  c.target_table,
  c.sensitivity,
  coalesce(pv.grantee, tt.grantee, 'NO_EXPLICIT_GRANTEE_FOUND') as grantee,
  pv.privileges as public_view_privileges,
  tt.privileges as target_table_privileges,
  case
    when pv.privileges is null and tt.privileges is not null then 'PUBLIC_VIEW_GRANT_MISSING_REVIEW_REQUIRED'
    when pv.privileges is not null and tt.privileges is null then 'TARGET_TABLE_GRANT_MISSING_OR_RLS_ONLY_REVIEW_REQUIRED'
    when pv.privileges is distinct from tt.privileges then 'PRIVILEGE_DIFFERENCE_REVIEW_REQUIRED'
    else 'PRIVILEGE_MATCH_OR_NO_EXPLICIT_GRANT'
  end as grant_review_status,
  false as grant_authorized_by_this_script,
  true as read_only
from candidates c
left join public_view_privs pv on pv.table_name = c.public_table
left join target_table_privs tt on tt.table_schema = c.target_schema and tt.table_name = c.target_table and (tt.grantee = pv.grantee or pv.grantee is null)
order by c.target_schema, c.public_table, grantee;
