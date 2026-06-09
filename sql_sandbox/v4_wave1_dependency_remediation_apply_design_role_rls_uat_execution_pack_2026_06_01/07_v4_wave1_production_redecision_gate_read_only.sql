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
public_objects as (
  select n.nspname as schema_name, c.relname, c.relkind
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'public' and c.relkind in ('v','r','p')
),
target_objects as (
  select n.nspname as schema_name, c.relname, c.relkind, c.relrowsecurity
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where c.relkind in ('r','p')
),
shape as (
  select
    count(*) as wave1_count,
    count(*) filter (where po.relkind = 'v') as public_view_count,
    count(*) filter (where tor.relkind in ('r','p')) as target_table_count,
    count(*) filter (where po.relkind = 'v' and tor.relkind in ('r','p')) as shape_ok_count,
    count(*) filter (where not (po.relkind = 'v' and tor.relkind in ('r','p'))) as shape_blocker_count
  from wave1 w
  left join public_objects po on po.relname = w.public_table
  left join target_objects tor on tor.schema_name = w.target_schema and tor.relname = w.public_table
),
function_source as materialized (
  select coalesce(p.prosrc::text, '') as function_body
  from pg_proc p
  join pg_namespace n on n.oid = p.pronamespace
  where p.prokind in ('f','p')
),
deps as (
  select w.public_table
  from wave1 w
  join function_source fs
    on position(lower(w.public_table) in lower(fs.function_body)) > 0
),
rls as (
  select
    w.public_table,
    w.target_schema,
    w.sensitivity,
    coalesce(c.relrowsecurity,false) as rls_enabled,
    coalesce((select count(*) from pg_policies p where p.schemaname = w.target_schema and p.tablename = w.public_table),0) as policy_count
  from wave1 w
  left join pg_namespace n on n.nspname = w.target_schema
  left join pg_class c on c.relnamespace = n.oid and c.relname = w.public_table and c.relkind in ('r','p')
),
summary as (
  select
    (select wave1_count from shape) as wave1_count,
    (select public_view_count from shape) as public_compatibility_views,
    (select target_table_count from shape) as owner_schema_tables,
    (select shape_ok_count from shape) as shape_ok_count,
    (select shape_blocker_count from shape) as shape_blocker_count,
    (select count(*) from deps) as text_dependency_rows,
    (select count(*) from rls where rls_enabled = true and policy_count = 0) as rls_enabled_zero_policy_count,
    (select count(*) from rls where sensitivity in ('high','medium-high') and rls_enabled = false) as sensitive_rls_disabled_count
)
select
  'v4_wave1_production_redecision_gate_summary' as section,
  *,
  false as compatibility_views_removal_authorized,
  false as grant_revoke_authorized,
  false as wave3_move_authorized,
  false as browser_uat_confirmed,
  false as production_approved,
  case
    when shape_blocker_count > 0 then 'PRODUCTION_BLOCKED_SHAPE_BLOCKERS'
    when text_dependency_rows > 0 then 'PRODUCTION_BLOCKED_PENDING_DEPENDENCY_REMEDIATION_BODY_REVIEW'
    when rls_enabled_zero_policy_count > 0 or sensitive_rls_disabled_count > 0 then 'PRODUCTION_BLOCKED_PENDING_ROLE_RLS_UAT_OWNER_APPROVAL'
    else 'PRODUCTION_STILL_REQUIRES_BROWSER_UAT_AND_OPERATOR_APPROVAL'
  end as decision,
  true as read_only
from summary;
