-- Public Table Functional Reclassification v4 — Schema-to-Schema Move Safety Gate
-- Date: 2026-05-31
-- Purpose: replace the rejected Column Diff model with a correct move-only safety model.
-- Correct strategy: ALTER TABLE public.<table> SET SCHEMA <target_schema>.
-- This pack is READ ONLY. It does not execute DDL/DML/GRANT/DROP.
-- The future apply pack is not authorized by this gate.
--
-- Safety principle:
--   Target tables do NOT need to exist before a move. In fact, existing target tables with the same name are collisions.
--   Target schemas may be created later in an authorized apply pack if missing.
--
-- Run order:
--   01 target schema + name collision gate
--   02 sequence/default ownership gate
--   03 structural view dependency gate
--   04 function/RPC text dependency gate
--   05 Flutter dependency operator template
--   06 grants/RLS/policy inventory
--   07 compatibility public view plan
--   08 rollback command matrix
--   09 owner approval operator template
--   10 pre-apply hard gate
--
-- Forbidden in this pack:
--   ALTER TABLE / CREATE SCHEMA / CREATE VIEW / DROP / GRANT / REVOKE / INSERT / UPDATE / DELETE.

with v4_move_map(public_table, target_schema, target_table, sensitivity, functional_reason) as (
  values
    ('achievements', 'ministry_profile', 'achievements', 'medium', 'ministry achievements/profile domain'),
    ('activities', 'media_center', 'activities', 'medium', 'media center operational/editorial content'),
    ('admin_users', 'platform_access', 'admin_users', 'high', 'platform identity/RBAC/scope domain, not auth.users'),
    ('announcement_items', 'media_center', 'announcement_items', 'medium', 'media announcement content'),
    ('announcements', 'media_center', 'announcements', 'medium', 'media announcement content'),
    ('app_settings', 'platform_experience', 'app_settings', 'medium', 'platform public experience/settings'),
    ('appointments', 'platform_services', 'appointments', 'medium', 'service center/service appointment domain'),
    ('assettypes', 'waqf', 'assettypes', 'high', 'waqf sovereign asset reference'),
    ('assistant_conversations', 'assistant', 'assistant_conversations', 'medium', 'assistant conversation domain'),
    ('assistant_messages', 'assistant', 'assistant_messages', 'medium', 'assistant conversation domain'),
    ('awqaf_assist_answer_contracts', 'awqaf_system', 'awqaf_assist_answer_contracts', 'high', 'Awqaf Assist belongs to awqaf_system operational stream'),
    ('awqaf_assist_workspace_items', 'awqaf_system', 'awqaf_assist_workspace_items', 'high', 'Awqaf Assist workspace belongs to awqaf_system operational stream'),
    ('awqaf_community_document_evidence_links', 'core', 'awqaf_community_document_evidence_links', 'high', 'shared community waqf evidence/reference belongs to core governance'),
    ('awqaf_historical_topology_nodes', 'topology', 'awqaf_historical_topology_nodes', 'medium-high', 'historical topology graph/lineage domain'),
    ('awqaf_historical_topology_relations', 'topology', 'awqaf_historical_topology_relations', 'medium-high', 'historical topology graph/lineage domain'),
    ('awqaf_reference_waqf_links', 'waqf', 'awqaf_reference_waqf_links', 'high', 'waqf sovereign reference/linkage'),
    ('awqaf_system_content', 'awqaf_system', 'awqaf_system_content', 'high', 'awqaf_system public/system content'),
    ('awqaf_system_institution_profile', 'awqaf_system', 'awqaf_system_institution_profile', 'high', 'awqaf_system institution profile'),
    ('awqaf_system_settings', 'awqaf_system', 'awqaf_system_settings', 'high', 'awqaf_system settings'),
    ('awqaf_system_unit_pages', 'awqaf_system', 'awqaf_system_unit_pages', 'high', 'awqaf_system unit-scoped pages'),
    ('breaking_news', 'platform_experience', 'breaking_news', 'medium', 'homepage breaking news placement/experience'),
    ('categories', 'media_center', 'categories', 'medium', 'media content category catalog'),
    ('chatbot_conversations', 'assistant', 'chatbot_conversations', 'medium', 'chatbot conversation domain'),
    ('chatbot_intents', 'assistant', 'chatbot_intents', 'medium', 'chatbot intent catalog'),
    ('chatbot_messages', 'assistant', 'chatbot_messages', 'medium', 'chatbot messages'),
    ('chatbot_retention_policies', 'assistant', 'chatbot_retention_policies', 'medium-high', 'assistant retention/governance'),
    ('cities', 'core', 'cities', 'high', 'core geographic/reference dictionary'),
    ('daily_habits', 'legacy_quarantine', 'daily_habits', 'low', 'out-of-domain experimental table; quarantine pending owner decision'),
    ('documents', 'cms', 'documents', 'medium', 'content/document CMS domain'),
    ('endowment_supervisors', 'waqf', 'endowment_supervisors', 'high', 'waqf supervision/legal administration'),
    ('footer_settings', 'platform_experience', 'footer_settings', 'medium', 'platform layout/footer settings'),
    ('former_ministers', 'ministry_profile', 'former_ministers', 'medium', 'ministry profile/history'),
    ('friday_sermons', 'religious_affairs', 'friday_sermons', 'medium-high', 'religious affairs content/sermon registry'),
    ('governorates', 'core', 'governorates', 'high', 'core geographic/reference dictionary'),
    ('header_settings', 'platform_experience', 'header_settings', 'medium', 'platform layout/header settings'),
    ('hero_slides', 'platform_experience', 'hero_slides', 'medium', 'platform public hero/experience'),
    ('historical_admin_units', 'hist', 'historical_admin_units', 'medium-high', 'normalized historical administrative data'),
    ('historical_child_level_policy', 'topology', 'historical_child_level_policy', 'medium-high', 'historical topology rules/policy'),
    ('historical_cluster_anchor_registry', 'topology', 'historical_cluster_anchor_registry', 'medium-high', 'historical topology cluster anchors'),
    ('historical_layers', 'hist', 'historical_layers', 'medium-high', 'historical layer registry'),
    ('historical_parent_seed_matrix', 'topology', 'historical_parent_seed_matrix', 'medium-high', 'historical topology seed matrix'),
    ('historical_periods', 'hist', 'historical_periods', 'medium-high', 'historical period registry'),
    ('historical_seed_decision_registry', 'topology', 'historical_seed_decision_registry', 'medium-high', 'historical topology seed decisions'),
    ('home_config', 'platform_experience', 'home_config', 'medium', 'homepage configuration'),
    ('home_hero_slides', 'platform_experience', 'home_hero_slides', 'medium', 'homepage hero slides'),
    ('home_news', 'platform_experience', 'home_news', 'medium', 'homepage news projection/order'),
    ('home_services', 'platform_navigation', 'home_services', 'medium', 'homepage service/navigation entry catalog'),
    ('home_stats', 'platform_experience', 'home_stats', 'medium', 'homepage public statistics'),
    ('homepage_sections', 'platform_experience', 'homepage_sections', 'medium', 'homepage section configuration'),
    ('intelligentrecommendations', 'legacy_quarantine', 'intelligentrecommendations', 'low', 'out-of-domain experimental/legacy table'),
    ('islamic_terms', 'religious_affairs', 'islamic_terms', 'medium-high', 'religious affairs terminology/content'),
    ('land_admin_history', 'hist', 'land_admin_history', 'medium-high', 'historical land administration data'),
    ('locations', 'gis', 'locations', 'high', 'GIS location layer/reference'),
    ('media_center_audit_events', 'media_center', 'media_center_audit_events', 'medium-high', 'media center audit trail'),
    ('media_center_editorial_events', 'media_center', 'media_center_editorial_events', 'medium-high', 'media center editorial workflow'),
    ('media_center_editorial_roles', 'media_center', 'media_center_editorial_roles', 'medium-high', 'media center editorial RBAC extension'),
    ('media_center_permission_uat_events', 'media_center', 'media_center_permission_uat_events', 'medium-high', 'media center permission UAT'),
    ('media_center_publishing_governance_rules', 'media_center', 'media_center_publishing_governance_rules', 'medium-high', 'media publishing governance'),
    ('media_gallery_items', 'media_center', 'media_gallery_items', 'medium', 'media gallery content'),
    ('mosques', 'religious_affairs', 'mosques', 'medium-high', 'religious affairs mosque registry; GIS linked separately'),
    ('mustakshif_announcements', 'mustakshif_staging', 'mustakshif_announcements', 'medium', 'Mustakshif staging announcements'),
    ('mustakshif_news', 'mustakshif_staging', 'mustakshif_news', 'medium', 'Mustakshif staging news'),
    ('mustakshif_site_pages', 'mustakshif_staging', 'mustakshif_site_pages', 'medium', 'Mustakshif staging pages'),
    ('news', 'media_center', 'news', 'medium', 'media/news content'),
    ('news_articles', 'media_center', 'news_articles', 'medium', 'media/news content'),
    ('news_items', 'media_center', 'news_items', 'medium', 'media/news content'),
    ('notifications', 'platform_notifications', 'notifications', 'medium-high', 'platform notifications domain'),
    ('org_units_cache', 'core', 'org_units_cache', 'high', 'core organizational unit cache/reference'),
    ('platform_permissions', 'platform_access', 'platform_permissions', 'high', 'platform RBAC/access domain'),
    ('platform_systems', 'platform_access', 'platform_systems', 'high', 'platform system registry/access linkage'),
    ('pwf_complaint_attachments', 'complaints', 'pwf_complaint_attachments', 'high', 'complaint workflow attachment/private data'),
    ('pwf_complaint_updates', 'complaints', 'pwf_complaint_updates', 'high', 'complaint workflow updates/private data'),
    ('pwf_complaints', 'complaints', 'pwf_complaints', 'high', 'complaint workflow/private request data'),
    ('pwf_complaints_retention_policies', 'complaints', 'pwf_complaints_retention_policies', 'high', 'complaint retention/privacy governance'),
    ('pwf_former_ministers', 'ministry_profile', 'pwf_former_ministers', 'medium', 'ministry profile/history'),
    ('pwf_org_units_cache', 'core', 'pwf_org_units_cache', 'high', 'core organizational unit cache/reference'),
    ('reports', 'platform_reporting', 'reports', 'medium-high', 'platform reporting domain'),
    ('servicepoints', 'platform_services', 'servicepoints', 'medium', 'service center reference/service points'),
    ('serviceproviders', 'platform_services', 'serviceproviders', 'medium', 'service center reference/providers'),
    ('services', 'platform_navigation', 'services', 'medium', 'service catalog/navigation entry'),
    ('servicetypes', 'platform_services', 'servicetypes', 'medium', 'service center reference/types'),
    ('site_pages', 'platform_content', 'site_pages', 'medium', 'general public site pages/content'),
    ('site_settings', 'platform_experience', 'site_settings', 'medium', 'site experience/settings'),
    ('social_notices', 'media_center', 'social_notices', 'medium', 'public media/social notices'),
    ('task_statistics', 'tasks', 'task_statistics', 'medium', 'task management statistics'),
    ('task_status_history', 'tasks', 'task_status_history', 'medium', 'task lifecycle history'),
    ('task_statuses', 'tasks', 'task_statuses', 'medium', 'task status catalog'),
    ('task_types', 'tasks', 'task_types', 'medium', 'task type catalog'),
    ('user_accounts', 'platform_access', 'user_accounts', 'high', 'platform access/account profile'),
    ('user_permissions', 'platform_access', 'user_permissions', 'high', 'platform access permissions'),
    ('user_scope_assignment_units', 'platform_access', 'user_scope_assignment_units', 'high', 'platform scoped access units'),
    ('user_scope_assignments', 'platform_access', 'user_scope_assignments', 'high', 'platform scoped access assignments'),
    ('user_system_permissions', 'platform_access', 'user_system_permissions', 'high', 'platform system permissions'),
    ('user_system_roles', 'platform_access', 'user_system_roles', 'high', 'platform system roles'),
    ('waqf_community_lineage', 'topology', 'waqf_community_lineage', 'medium-high', 'waqf community historical lineage/topology'),
    ('waqf_lands', 'waqf', 'waqf_lands', 'high', 'waqf lands/sovereign data'),
    ('zakat_donation_requests', 'zakat', 'zakat_donation_requests', 'high', 'zakat donations/request workflow')
), schema_collision as (
  select
    m.*,
    (to_regnamespace(m.target_schema) is not null) as target_schema_exists,
    (to_regclass(format('%I.%I', m.target_schema, m.target_table)) is not null) as target_table_name_collision
  from v4_move_map m
), table_oids as (
  select m.*, c.oid as table_oid
  from v4_move_map m
  left join pg_class c on c.oid = to_regclass(format('public.%I', m.public_table))
), view_deps as (
  select distinct t.public_table, v_ns.nspname as dependent_schema, v.relname as dependent_view
  from table_oids t
  join pg_depend d on d.refobjid = t.table_oid
  join pg_rewrite r on r.oid = d.objid
  join pg_class v on v.oid = r.ev_class and v.relkind in ('v','m')
  join pg_namespace v_ns on v_ns.oid = v.relnamespace
), fn as (
  select n.nspname as function_schema, p.proname as function_name, pg_get_functiondef(p.oid) as function_definition
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
  where p.prokind in ('f','p') and n.nspname not in ('pg_catalog','information_schema')
), fn_hits as (
  select distinct m.public_table, f.function_schema, f.function_name
  from v4_move_map m join fn f on position(m.public_table in f.function_definition) > 0
)
select
  'v4_schema_to_schema_move_pre_apply_hard_gate_summary' as section,
  count(*) as mapped_public_table_count,
  count(*) filter (where target_schema_exists) as target_schema_present_rows,
  count(distinct target_schema) as target_schema_count,
  count(distinct target_schema) filter (where target_schema_exists) as target_schemas_present_count,
  count(*) filter (where target_table_name_collision) as target_table_collision_count,
  (select count(*) from view_deps) as structural_view_dependency_rows,
  (select count(*) from fn_hits) as function_text_dependency_rows,
  false as owner_approvals_confirmed_by_this_script,
  false as flutter_dependency_zero_certified_by_this_script,
  false as backup_and_reversal_confirmed_by_this_script,
  false as role_rls_uat_confirmed_by_this_script,
  false as apply_pack_authorized_by_this_script,
  false as destructive_sql_authorized,
  false as archive_authorized,
  false as production_approved,
  case
    when bool_or(target_table_name_collision) then 'APPLY_BLOCKED_TARGET_TABLE_NAME_COLLISION_RESOLUTION_REQUIRED'
    else 'APPLY_BLOCKED_PENDING_OPERATOR_APPROVAL_FLUTTER_SCAN_BACKUP_RLS_UAT_AND_AUTHORIZED_MOVE_PACK'
  end as decision,
  true as read_only
from schema_collision;
