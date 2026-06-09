-- 07_v4_wave1_rollback_GUARDED_ONLY_IF_NEEDED.sql
-- WARNING: rollback script only. It drops public compatibility views and moves Wave1 tables back to public.
-- Do not run unless post-apply validation or runtime UAT fails and operator confirms rollback.
-- No DELETE/ARCHIVE/RENAME is included; DROP VIEW is unavoidable for rollback of compatibility views.

do $$
declare
  v_rollback_token text := 'REPLACE_WITH_EXPLICIT_ROLLBACK_TOKEN_V4_WAVE1_2026_05_31';
  v_expected_rollback_token text := 'I_AUTHORIZE_V4_WAVE1_ROLLBACK_ONLY_DEVELOPMENT_STAGING';
  v_backup_or_restore_point_reference text := 'REPLACE_WITH_SAME_REAL_EXTERNAL_BACKUP_OR_RESTORE_POINT_REFERENCE';
  r record;
  v_count int;
begin
  if v_rollback_token <> v_expected_rollback_token then
    raise exception 'V4 Wave1 rollback blocked: replace v_rollback_token with exact rollback token.';
  end if;
  if v_backup_or_restore_point_reference like 'REPLACE_WITH_%' or length(trim(v_backup_or_restore_point_reference)) < 12 then
    raise exception 'V4 Wave1 rollback blocked: provide real external backup/restore-point reference.';
  end if;

  create temp table _v4_wave1_move_map(
    public_table text primary key,
    target_schema text not null,
    target_table text not null,
    sensitivity text not null
  ) on commit drop;

  insert into _v4_wave1_move_map(public_table, target_schema, target_table, sensitivity)
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
    ('zakat_donation_requests', 'zakat', 'zakat_donation_requests', 'high');

  -- Validate target tables exist before rollback.
  select count(*) into v_count
  from _v4_wave1_move_map m
  where to_regclass(format('%I.%I', m.target_schema, m.target_table)) is null;
  if v_count <> 0 then
    raise exception 'V4 Wave1 rollback blocked: % target tables are missing.', v_count;
  end if;

  for r in select * from _v4_wave1_move_map order by target_schema desc, public_table desc loop
    execute format('drop view if exists public.%I', r.public_table);
    execute format('alter table %I.%I set schema public', r.target_schema, r.target_table);
    raise notice 'V4 Wave1 rollback moved %.% back to public.%', r.target_schema, r.target_table, r.public_table;
  end loop;

  raise notice 'V4 Wave1 rollback completed in development/staging scope. Production is NOT approved.';
end $$;
