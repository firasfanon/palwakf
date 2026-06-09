-- PalWakf V4 Wave1 Dependency Remediation Apply Design + Role/RLS UAT Execution Pack
-- Date: 2026-06-01
-- Hotfix: 2026-06-01 prosrc root fix; avoids pg_get_functiondef deparse failures such as relation public does not exist.
-- Safety: READ ONLY unless file name explicitly says FUTURE/SKELETON; no DDL/DML/GRANT/REVOKE/DROP/DELETE/ARCHIVE/RENAME.
-- Context: SQL02 move already applied. Do not rerun Wave1 SQL02 move.
-- Production: NOT APPROVED.

with
wave1(public_table, target_schema, sensitivity) as (
  values
    ('awqaf_assist_answer_contracts'::text, 'awqaf_system'::text, 'high'::text),
    ('awqaf_assist_workspace_items'::text, 'awqaf_system'::text, 'high'::text),
    ('awqaf_system_content'::text, 'awqaf_system'::text, 'high'::text),
    ('awqaf_system_institution_profile'::text, 'awqaf_system'::text, 'high'::text),
    ('awqaf_system_settings'::text, 'awqaf_system'::text, 'high'::text),
    ('awqaf_system_unit_pages'::text, 'awqaf_system'::text, 'high'::text),
    ('documents'::text, 'cms'::text, 'medium'::text),
    ('pwf_complaint_attachments'::text, 'complaints'::text, 'high'::text),
    ('pwf_complaint_updates'::text, 'complaints'::text, 'high'::text),
    ('pwf_complaints'::text, 'complaints'::text, 'high'::text),
    ('pwf_complaints_retention_policies'::text, 'complaints'::text, 'high'::text),
    ('awqaf_community_document_evidence_links'::text, 'core'::text, 'high'::text),
    ('cities'::text, 'core'::text, 'high'::text),
    ('governorates'::text, 'core'::text, 'high'::text),
    ('historical_admin_units'::text, 'hist'::text, 'medium-high'::text),
    ('historical_layers'::text, 'hist'::text, 'medium-high'::text),
    ('historical_periods'::text, 'hist'::text, 'medium-high'::text),
    ('land_admin_history'::text, 'hist'::text, 'medium-high'::text),
    ('daily_habits'::text, 'legacy_quarantine'::text, 'low'::text),
    ('intelligentrecommendations'::text, 'legacy_quarantine'::text, 'low'::text),
    ('activities'::text, 'media_center'::text, 'medium'::text),
    ('announcement_items'::text, 'media_center'::text, 'medium'::text),
    ('announcements'::text, 'media_center'::text, 'medium'::text),
    ('categories'::text, 'media_center'::text, 'medium'::text),
    ('media_center_audit_events'::text, 'media_center'::text, 'medium-high'::text),
    ('media_center_editorial_events'::text, 'media_center'::text, 'medium-high'::text),
    ('media_center_editorial_roles'::text, 'media_center'::text, 'medium-high'::text),
    ('media_center_permission_uat_events'::text, 'media_center'::text, 'medium-high'::text),
    ('media_center_publishing_governance_rules'::text, 'media_center'::text, 'medium-high'::text),
    ('media_gallery_items'::text, 'media_center'::text, 'medium'::text),
    ('news'::text, 'media_center'::text, 'medium'::text),
    ('news_articles'::text, 'media_center'::text, 'medium'::text),
    ('news_items'::text, 'media_center'::text, 'medium'::text),
    ('social_notices'::text, 'media_center'::text, 'medium'::text),
    ('achievements'::text, 'ministry_profile'::text, 'medium'::text),
    ('former_ministers'::text, 'ministry_profile'::text, 'medium'::text),
    ('pwf_former_ministers'::text, 'ministry_profile'::text, 'medium'::text),
    ('mustakshif_announcements'::text, 'mustakshif_staging'::text, 'medium'::text),
    ('mustakshif_news'::text, 'mustakshif_staging'::text, 'medium'::text),
    ('mustakshif_site_pages'::text, 'mustakshif_staging'::text, 'medium'::text),
    ('admin_users'::text, 'platform_access'::text, 'high'::text),
    ('platform_permissions'::text, 'platform_access'::text, 'high'::text),
    ('platform_systems'::text, 'platform_access'::text, 'high'::text),
    ('user_accounts'::text, 'platform_access'::text, 'high'::text),
    ('user_permissions'::text, 'platform_access'::text, 'high'::text),
    ('user_scope_assignment_units'::text, 'platform_access'::text, 'high'::text),
    ('user_scope_assignments'::text, 'platform_access'::text, 'high'::text),
    ('user_system_permissions'::text, 'platform_access'::text, 'high'::text),
    ('user_system_roles'::text, 'platform_access'::text, 'high'::text),
    ('site_pages'::text, 'platform_content'::text, 'medium'::text),
    ('app_settings'::text, 'platform_experience'::text, 'medium'::text),
    ('breaking_news'::text, 'platform_experience'::text, 'medium'::text),
    ('footer_settings'::text, 'platform_experience'::text, 'medium'::text),
    ('header_settings'::text, 'platform_experience'::text, 'medium'::text),
    ('hero_slides'::text, 'platform_experience'::text, 'medium'::text),
    ('home_config'::text, 'platform_experience'::text, 'medium'::text),
    ('home_hero_slides'::text, 'platform_experience'::text, 'medium'::text),
    ('home_news'::text, 'platform_experience'::text, 'medium'::text),
    ('home_stats'::text, 'platform_experience'::text, 'medium'::text),
    ('homepage_sections'::text, 'platform_experience'::text, 'medium'::text),
    ('site_settings'::text, 'platform_experience'::text, 'medium'::text),
    ('home_services'::text, 'platform_navigation'::text, 'medium'::text),
    ('services'::text, 'platform_navigation'::text, 'medium'::text),
    ('notifications'::text, 'platform_notifications'::text, 'medium-high'::text),
    ('reports'::text, 'platform_reporting'::text, 'medium-high'::text),
    ('appointments'::text, 'platform_services'::text, 'medium'::text),
    ('servicepoints'::text, 'platform_services'::text, 'medium'::text),
    ('serviceproviders'::text, 'platform_services'::text, 'medium'::text),
    ('servicetypes'::text, 'platform_services'::text, 'medium'::text),
    ('friday_sermons'::text, 'religious_affairs'::text, 'medium-high'::text),
    ('islamic_terms'::text, 'religious_affairs'::text, 'medium-high'::text),
    ('mosques'::text, 'religious_affairs'::text, 'medium-high'::text),
    ('task_statistics'::text, 'tasks'::text, 'medium'::text),
    ('task_status_history'::text, 'tasks'::text, 'medium'::text),
    ('task_statuses'::text, 'tasks'::text, 'medium'::text),
    ('task_types'::text, 'tasks'::text, 'medium'::text),
    ('awqaf_historical_topology_nodes'::text, 'topology'::text, 'medium-high'::text),
    ('awqaf_historical_topology_relations'::text, 'topology'::text, 'medium-high'::text),
    ('historical_child_level_policy'::text, 'topology'::text, 'medium-high'::text),
    ('historical_cluster_anchor_registry'::text, 'topology'::text, 'medium-high'::text),
    ('historical_parent_seed_matrix'::text, 'topology'::text, 'medium-high'::text),
    ('historical_seed_decision_registry'::text, 'topology'::text, 'medium-high'::text),
    ('waqf_community_lineage'::text, 'topology'::text, 'medium-high'::text),
    ('assettypes'::text, 'waqf'::text, 'high'::text),
    ('awqaf_reference_waqf_links'::text, 'waqf'::text, 'high'::text),
    ('endowment_supervisors'::text, 'waqf'::text, 'high'::text),
    ('waqf_lands'::text, 'waqf'::text, 'high'::text),
    ('zakat_donation_requests'::text, 'zakat'::text, 'high'::text)
),
function_source as materialized (
  select
    n.nspname as function_schema,
    p.proname as function_name,
    p.oid,
    pg_get_function_identity_arguments(p.oid) as function_arguments,
    n.nspname || '.' || p.proname || '(' || pg_get_function_identity_arguments(p.oid) || ')' as function_signature,
    coalesce(p.prosrc::text, '') as function_body
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where p.prokind in ('f','p')
),
deps as (
  select
    w.public_table,
    w.target_schema,
    w.public_table as target_table,
    w.sensitivity,
    fs.function_schema,
    fs.function_name,
    fs.function_signature,
    case
      when (lower(fs.function_body) like '%insert into public.' || lower(w.public_table) || '%' or lower(fs.function_body) like '%insert into ' || lower(w.public_table) || '%' or lower(fs.function_body) like '%update public.' || lower(w.public_table) || '%' or lower(fs.function_body) like '%update ' || lower(w.public_table) || '%' or lower(fs.function_body) like '%delete from public.' || lower(w.public_table) || '%' or lower(fs.function_body) like '%delete from ' || lower(w.public_table) || '%' or lower(fs.function_body) like '%truncate public.' || lower(w.public_table) || '%' or lower(fs.function_body) like '%merge into public.' || lower(w.public_table) || '%')
        then 'REWRITE_TO_OWNER_SCHEMA_BEFORE_PUBLIC_VIEW_REMOVAL'
      when lower(fs.function_body) like '%public.' || lower(w.public_table) || '%'
           and not (lower(fs.function_body) like '%insert into%' or lower(fs.function_body) like '%update %' or lower(fs.function_body) like '%delete from%' or lower(fs.function_body) like '%truncate%' or lower(fs.function_body) like '%merge into%')
        then 'KEEP_COMPAT_VIEW_TEMPORARILY_AND_REVIEW_BODY'
      else 'BODY_TEXT_REVIEW_REQUIRED'
    end as recommended_action,
    ('/* DESIGN ONLY: inspect exact body of ' || fs.function_signature ||
      '; replace public.' || w.public_table || ' with ' || w.target_schema || '.' || w.public_table ||
      ' only after owner review, RLS/UAT evidence, and rollback plan. */') as remediation_design_note,
    false as apply_authorized_by_this_script,
    false as ddl_authorized_by_this_script,
    false as production_approved,
    true as read_only
  from wave1 w
  join function_source fs
    on position(lower(w.public_table) in lower(fs.function_body)) > 0
)
select
  'v4_wave1_rpc_function_body_rewrite_apply_design_detail' as section,
  public_table,
  target_schema,
  target_table,
  sensitivity,
  function_schema,
  function_name,
  function_signature,
  recommended_action,
  remediation_design_note,
  apply_authorized_by_this_script,
  ddl_authorized_by_this_script,
  production_approved,
  read_only
from deps
order by
  case recommended_action
    when 'REWRITE_TO_OWNER_SCHEMA_BEFORE_PUBLIC_VIEW_REMOVAL' then 1
    when 'BODY_TEXT_REVIEW_REQUIRED' then 2
    else 3
  end,
  target_schema,
  public_table,
  function_schema,
  function_name;
