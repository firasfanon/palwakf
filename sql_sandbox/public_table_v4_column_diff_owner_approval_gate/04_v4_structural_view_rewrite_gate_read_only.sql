with v4_sensitive_map(public_table, target_schema, target_table, owner_approval_required, sensitivity, functional_reason) as (
  values
    ('admin_users', 'platform_access', 'admin_users', 'platform-access-owner + security-review', 'high', 'identity/RBAC/scope assignments must be isolated from public and not merged into auth'),
    ('user_accounts', 'platform_access', 'user_accounts', 'platform-access-owner + security-review', 'high', 'identity/RBAC/scope assignments must be isolated from public and not merged into auth'),
    ('user_permissions', 'platform_access', 'user_permissions', 'platform-access-owner + security-review', 'high', 'identity/RBAC/scope assignments must be isolated from public and not merged into auth'),
    ('user_scope_assignments', 'platform_access', 'user_scope_assignments', 'platform-access-owner + security-review', 'high', 'identity/RBAC/scope assignments must be isolated from public and not merged into auth'),
    ('user_scope_assignment_units', 'platform_access', 'user_scope_assignment_units', 'platform-access-owner + security-review', 'high', 'identity/RBAC/scope assignments must be isolated from public and not merged into auth'),
    ('user_system_permissions', 'platform_access', 'user_system_permissions', 'platform-access-owner + security-review', 'high', 'identity/RBAC/scope assignments must be isolated from public and not merged into auth'),
    ('user_system_roles', 'platform_access', 'user_system_roles', 'platform-access-owner + security-review', 'high', 'identity/RBAC/scope assignments must be isolated from public and not merged into auth'),
    ('platform_permissions', 'platform_access', 'platform_permissions', 'platform-access-owner + security-review', 'high', 'identity/RBAC/scope assignments must be isolated from public and not merged into auth'),
    ('platform_systems', 'platform_access', 'platform_systems', 'platform-access-owner + security-review', 'high', 'identity/RBAC/scope assignments must be isolated from public and not merged into auth'),
    ('app_settings', 'platform_experience', 'app_settings', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('breaking_news', 'platform_experience', 'breaking_news', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('footer_settings', 'platform_experience', 'footer_settings', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('header_settings', 'platform_experience', 'header_settings', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('hero_slides', 'platform_experience', 'hero_slides', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('home_config', 'platform_experience', 'home_config', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('home_hero_slides', 'platform_experience', 'home_hero_slides', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('home_news', 'platform_experience', 'home_news', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('home_stats', 'platform_experience', 'home_stats', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('homepage_sections', 'platform_experience', 'homepage_sections', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('site_settings', 'platform_experience', 'site_settings', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('awqaf_community_document_evidence_links', 'core', 'awqaf_community_document_evidence_links', 'core-owner + data-governance-owner', 'high', 'shared reference/core data must be owned by core wrappers and not public'),
    ('cities', 'core', 'cities', 'core-owner + data-governance-owner', 'high', 'shared reference/core data must be owned by core wrappers and not public'),
    ('governorates', 'core', 'governorates', 'core-owner + data-governance-owner', 'high', 'shared reference/core data must be owned by core wrappers and not public'),
    ('org_units_cache', 'core', 'org_units_cache', 'core-owner + data-governance-owner', 'high', 'shared reference/core data must be owned by core wrappers and not public'),
    ('pwf_org_units_cache', 'core', 'pwf_org_units_cache', 'core-owner + data-governance-owner', 'high', 'shared reference/core data must be owned by core wrappers and not public'),
    ('assettypes', 'waqf', 'assettypes', 'waqf-owner + legal/data-owner', 'high', 'waqf sovereign/asset reference data must be handled under waqf authority'),
    ('awqaf_reference_waqf_links', 'waqf', 'awqaf_reference_waqf_links', 'waqf-owner + legal/data-owner', 'high', 'waqf sovereign/asset reference data must be handled under waqf authority'),
    ('endowment_supervisors', 'waqf', 'endowment_supervisors', 'waqf-owner + legal/data-owner', 'high', 'waqf sovereign/asset reference data must be handled under waqf authority'),
    ('waqf_lands', 'waqf', 'waqf_lands', 'waqf-owner + legal/data-owner', 'high', 'waqf sovereign/asset reference data must be handled under waqf authority'),
    ('friday_sermons', 'religious_affairs', 'friday_sermons', 'religious-affairs-owner + gis-link-review', 'medium-high', 'religious affairs registry/content domain; mosques registry should link to GIS rather than be blindly merged'),
    ('islamic_terms', 'religious_affairs', 'islamic_terms', 'religious-affairs-owner + gis-link-review', 'medium-high', 'religious affairs registry/content domain; mosques registry should link to GIS rather than be blindly merged'),
    ('mosques', 'religious_affairs', 'mosques', 'religious-affairs-owner + gis-link-review', 'medium-high', 'religious affairs registry/content domain; mosques registry should link to GIS rather than be blindly merged'),
    ('pwf_complaints', 'complaints', 'pwf_complaints', 'complaints-owner + privacy-review', 'high', 'complaint workflow and personal/request data should be isolated from cases/legal system'),
    ('pwf_complaint_attachments', 'complaints', 'pwf_complaint_attachments', 'complaints-owner + privacy-review', 'high', 'complaint workflow and personal/request data should be isolated from cases/legal system'),
    ('pwf_complaint_updates', 'complaints', 'pwf_complaint_updates', 'complaints-owner + privacy-review', 'high', 'complaint workflow and personal/request data should be isolated from cases/legal system'),
    ('pwf_complaints_retention_policies', 'complaints', 'pwf_complaints_retention_policies', 'complaints-owner + privacy-review', 'high', 'complaint workflow and personal/request data should be isolated from cases/legal system'),
    ('awqaf_historical_topology_nodes', 'topology', 'awqaf_historical_topology_nodes', 'topology-owner + hist-owner', 'medium-high', 'historical topology and lineage seed matrices belong to topology, not generic history'),
    ('awqaf_historical_topology_relations', 'topology', 'awqaf_historical_topology_relations', 'topology-owner + hist-owner', 'medium-high', 'historical topology and lineage seed matrices belong to topology, not generic history'),
    ('historical_child_level_policy', 'topology', 'historical_child_level_policy', 'topology-owner + hist-owner', 'medium-high', 'historical topology and lineage seed matrices belong to topology, not generic history'),
    ('historical_cluster_anchor_registry', 'topology', 'historical_cluster_anchor_registry', 'topology-owner + hist-owner', 'medium-high', 'historical topology and lineage seed matrices belong to topology, not generic history'),
    ('historical_parent_seed_matrix', 'topology', 'historical_parent_seed_matrix', 'topology-owner + hist-owner', 'medium-high', 'historical topology and lineage seed matrices belong to topology, not generic history'),
    ('historical_seed_decision_registry', 'topology', 'historical_seed_decision_registry', 'topology-owner + hist-owner', 'medium-high', 'historical topology and lineage seed matrices belong to topology, not generic history'),
    ('waqf_community_lineage', 'topology', 'waqf_community_lineage', 'topology-owner + hist-owner', 'medium-high', 'historical topology and lineage seed matrices belong to topology, not generic history'),
    ('historical_admin_units', 'hist', 'historical_admin_units', 'hist-owner + topology-owner-for-dependent-views', 'medium-high', 'normalized historical administrative data belongs to hist, with topology dependent views rewritten'),
    ('historical_layers', 'hist', 'historical_layers', 'hist-owner + topology-owner-for-dependent-views', 'medium-high', 'normalized historical administrative data belongs to hist, with topology dependent views rewritten'),
    ('historical_periods', 'hist', 'historical_periods', 'hist-owner + topology-owner-for-dependent-views', 'medium-high', 'normalized historical administrative data belongs to hist, with topology dependent views rewritten'),
    ('land_admin_history', 'hist', 'land_admin_history', 'hist-owner + topology-owner-for-dependent-views', 'medium-high', 'normalized historical administrative data belongs to hist, with topology dependent views rewritten'),
    ('awqaf_assist_answer_contracts', 'awqaf_system', 'awqaf_assist_answer_contracts', 'awqaf-system-owner + platform-integration-owner', 'high', 'awqaf system and awqaf assist operational surfaces belong to awqaf_system stream'),
    ('awqaf_assist_workspace_items', 'awqaf_system', 'awqaf_assist_workspace_items', 'awqaf-system-owner + platform-integration-owner', 'high', 'awqaf system and awqaf assist operational surfaces belong to awqaf_system stream'),
    ('awqaf_system_content', 'awqaf_system', 'awqaf_system_content', 'awqaf-system-owner + platform-integration-owner', 'high', 'awqaf system and awqaf assist operational surfaces belong to awqaf_system stream'),
    ('awqaf_system_institution_profile', 'awqaf_system', 'awqaf_system_institution_profile', 'awqaf-system-owner + platform-integration-owner', 'high', 'awqaf system and awqaf assist operational surfaces belong to awqaf_system stream'),
    ('awqaf_system_settings', 'awqaf_system', 'awqaf_system_settings', 'awqaf-system-owner + platform-integration-owner', 'high', 'awqaf system and awqaf assist operational surfaces belong to awqaf_system stream'),
    ('awqaf_system_unit_pages', 'awqaf_system', 'awqaf_system_unit_pages', 'awqaf-system-owner + platform-integration-owner', 'high', 'awqaf system and awqaf assist operational surfaces belong to awqaf_system stream')
),
public_tables as (
  select c.oid as table_oid, n.nspname as table_schema, c.relname as table_name
  from pg_class c join pg_namespace n on n.oid = c.relnamespace
  join v4_sensitive_map m on m.public_table = c.relname
  where n.nspname = 'public' and c.relkind in ('r','p','f')
),
view_rewrites as (
  select
    d.refobjid as table_oid,
    v_ns.nspname as dependent_schema,
    v.relname as dependent_view,
    v.relkind as dependent_kind
  from pg_depend d
  join pg_rewrite r on r.oid = d.objid
  join pg_class v on v.oid = r.ev_class
  join pg_namespace v_ns on v_ns.oid = v.relnamespace
  where v.relkind in ('v','m')
)
select distinct
  'v4_structural_view_rewrite_gate_detail' as section,
  pt.table_schema,
  pt.table_name,
  m.target_schema,
  m.target_table,
  vr.dependent_schema,
  vr.dependent_view,
  vr.dependent_kind,
  'rewrite_dependent_view_to_owner_backed_source_before_archive' as required_resolution,
  false as view_rewrite_executed_by_this_script,
  false as archive_authorized,
  false as production_approved,
  true as read_only
from public_tables pt
join v4_sensitive_map m on m.public_table = pt.table_name
join view_rewrites vr on vr.table_oid = pt.table_oid
order by m.target_schema, pt.table_name, vr.dependent_schema, vr.dependent_view;

with v4_sensitive_map(public_table, target_schema, target_table, owner_approval_required, sensitivity, functional_reason) as (
  values
    ('admin_users', 'platform_access', 'admin_users', 'platform-access-owner + security-review', 'high', 'identity/RBAC/scope assignments must be isolated from public and not merged into auth'),
    ('user_accounts', 'platform_access', 'user_accounts', 'platform-access-owner + security-review', 'high', 'identity/RBAC/scope assignments must be isolated from public and not merged into auth'),
    ('user_permissions', 'platform_access', 'user_permissions', 'platform-access-owner + security-review', 'high', 'identity/RBAC/scope assignments must be isolated from public and not merged into auth'),
    ('user_scope_assignments', 'platform_access', 'user_scope_assignments', 'platform-access-owner + security-review', 'high', 'identity/RBAC/scope assignments must be isolated from public and not merged into auth'),
    ('user_scope_assignment_units', 'platform_access', 'user_scope_assignment_units', 'platform-access-owner + security-review', 'high', 'identity/RBAC/scope assignments must be isolated from public and not merged into auth'),
    ('user_system_permissions', 'platform_access', 'user_system_permissions', 'platform-access-owner + security-review', 'high', 'identity/RBAC/scope assignments must be isolated from public and not merged into auth'),
    ('user_system_roles', 'platform_access', 'user_system_roles', 'platform-access-owner + security-review', 'high', 'identity/RBAC/scope assignments must be isolated from public and not merged into auth'),
    ('platform_permissions', 'platform_access', 'platform_permissions', 'platform-access-owner + security-review', 'high', 'identity/RBAC/scope assignments must be isolated from public and not merged into auth'),
    ('platform_systems', 'platform_access', 'platform_systems', 'platform-access-owner + security-review', 'high', 'identity/RBAC/scope assignments must be isolated from public and not merged into auth'),
    ('app_settings', 'platform_experience', 'app_settings', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('breaking_news', 'platform_experience', 'breaking_news', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('footer_settings', 'platform_experience', 'footer_settings', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('header_settings', 'platform_experience', 'header_settings', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('hero_slides', 'platform_experience', 'hero_slides', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('home_config', 'platform_experience', 'home_config', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('home_hero_slides', 'platform_experience', 'home_hero_slides', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('home_news', 'platform_experience', 'home_news', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('home_stats', 'platform_experience', 'home_stats', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('homepage_sections', 'platform_experience', 'homepage_sections', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('site_settings', 'platform_experience', 'site_settings', 'platform-experience-owner + frontend-owner', 'medium', 'public homepage/layout/site experience tables belong to a coherent platform experience domain'),
    ('awqaf_community_document_evidence_links', 'core', 'awqaf_community_document_evidence_links', 'core-owner + data-governance-owner', 'high', 'shared reference/core data must be owned by core wrappers and not public'),
    ('cities', 'core', 'cities', 'core-owner + data-governance-owner', 'high', 'shared reference/core data must be owned by core wrappers and not public'),
    ('governorates', 'core', 'governorates', 'core-owner + data-governance-owner', 'high', 'shared reference/core data must be owned by core wrappers and not public'),
    ('org_units_cache', 'core', 'org_units_cache', 'core-owner + data-governance-owner', 'high', 'shared reference/core data must be owned by core wrappers and not public'),
    ('pwf_org_units_cache', 'core', 'pwf_org_units_cache', 'core-owner + data-governance-owner', 'high', 'shared reference/core data must be owned by core wrappers and not public'),
    ('assettypes', 'waqf', 'assettypes', 'waqf-owner + legal/data-owner', 'high', 'waqf sovereign/asset reference data must be handled under waqf authority'),
    ('awqaf_reference_waqf_links', 'waqf', 'awqaf_reference_waqf_links', 'waqf-owner + legal/data-owner', 'high', 'waqf sovereign/asset reference data must be handled under waqf authority'),
    ('endowment_supervisors', 'waqf', 'endowment_supervisors', 'waqf-owner + legal/data-owner', 'high', 'waqf sovereign/asset reference data must be handled under waqf authority'),
    ('waqf_lands', 'waqf', 'waqf_lands', 'waqf-owner + legal/data-owner', 'high', 'waqf sovereign/asset reference data must be handled under waqf authority'),
    ('friday_sermons', 'religious_affairs', 'friday_sermons', 'religious-affairs-owner + gis-link-review', 'medium-high', 'religious affairs registry/content domain; mosques registry should link to GIS rather than be blindly merged'),
    ('islamic_terms', 'religious_affairs', 'islamic_terms', 'religious-affairs-owner + gis-link-review', 'medium-high', 'religious affairs registry/content domain; mosques registry should link to GIS rather than be blindly merged'),
    ('mosques', 'religious_affairs', 'mosques', 'religious-affairs-owner + gis-link-review', 'medium-high', 'religious affairs registry/content domain; mosques registry should link to GIS rather than be blindly merged'),
    ('pwf_complaints', 'complaints', 'pwf_complaints', 'complaints-owner + privacy-review', 'high', 'complaint workflow and personal/request data should be isolated from cases/legal system'),
    ('pwf_complaint_attachments', 'complaints', 'pwf_complaint_attachments', 'complaints-owner + privacy-review', 'high', 'complaint workflow and personal/request data should be isolated from cases/legal system'),
    ('pwf_complaint_updates', 'complaints', 'pwf_complaint_updates', 'complaints-owner + privacy-review', 'high', 'complaint workflow and personal/request data should be isolated from cases/legal system'),
    ('pwf_complaints_retention_policies', 'complaints', 'pwf_complaints_retention_policies', 'complaints-owner + privacy-review', 'high', 'complaint workflow and personal/request data should be isolated from cases/legal system'),
    ('awqaf_historical_topology_nodes', 'topology', 'awqaf_historical_topology_nodes', 'topology-owner + hist-owner', 'medium-high', 'historical topology and lineage seed matrices belong to topology, not generic history'),
    ('awqaf_historical_topology_relations', 'topology', 'awqaf_historical_topology_relations', 'topology-owner + hist-owner', 'medium-high', 'historical topology and lineage seed matrices belong to topology, not generic history'),
    ('historical_child_level_policy', 'topology', 'historical_child_level_policy', 'topology-owner + hist-owner', 'medium-high', 'historical topology and lineage seed matrices belong to topology, not generic history'),
    ('historical_cluster_anchor_registry', 'topology', 'historical_cluster_anchor_registry', 'topology-owner + hist-owner', 'medium-high', 'historical topology and lineage seed matrices belong to topology, not generic history'),
    ('historical_parent_seed_matrix', 'topology', 'historical_parent_seed_matrix', 'topology-owner + hist-owner', 'medium-high', 'historical topology and lineage seed matrices belong to topology, not generic history'),
    ('historical_seed_decision_registry', 'topology', 'historical_seed_decision_registry', 'topology-owner + hist-owner', 'medium-high', 'historical topology and lineage seed matrices belong to topology, not generic history'),
    ('waqf_community_lineage', 'topology', 'waqf_community_lineage', 'topology-owner + hist-owner', 'medium-high', 'historical topology and lineage seed matrices belong to topology, not generic history'),
    ('historical_admin_units', 'hist', 'historical_admin_units', 'hist-owner + topology-owner-for-dependent-views', 'medium-high', 'normalized historical administrative data belongs to hist, with topology dependent views rewritten'),
    ('historical_layers', 'hist', 'historical_layers', 'hist-owner + topology-owner-for-dependent-views', 'medium-high', 'normalized historical administrative data belongs to hist, with topology dependent views rewritten'),
    ('historical_periods', 'hist', 'historical_periods', 'hist-owner + topology-owner-for-dependent-views', 'medium-high', 'normalized historical administrative data belongs to hist, with topology dependent views rewritten'),
    ('land_admin_history', 'hist', 'land_admin_history', 'hist-owner + topology-owner-for-dependent-views', 'medium-high', 'normalized historical administrative data belongs to hist, with topology dependent views rewritten'),
    ('awqaf_assist_answer_contracts', 'awqaf_system', 'awqaf_assist_answer_contracts', 'awqaf-system-owner + platform-integration-owner', 'high', 'awqaf system and awqaf assist operational surfaces belong to awqaf_system stream'),
    ('awqaf_assist_workspace_items', 'awqaf_system', 'awqaf_assist_workspace_items', 'awqaf-system-owner + platform-integration-owner', 'high', 'awqaf system and awqaf assist operational surfaces belong to awqaf_system stream'),
    ('awqaf_system_content', 'awqaf_system', 'awqaf_system_content', 'awqaf-system-owner + platform-integration-owner', 'high', 'awqaf system and awqaf assist operational surfaces belong to awqaf_system stream'),
    ('awqaf_system_institution_profile', 'awqaf_system', 'awqaf_system_institution_profile', 'awqaf-system-owner + platform-integration-owner', 'high', 'awqaf system and awqaf assist operational surfaces belong to awqaf_system stream'),
    ('awqaf_system_settings', 'awqaf_system', 'awqaf_system_settings', 'awqaf-system-owner + platform-integration-owner', 'high', 'awqaf system and awqaf assist operational surfaces belong to awqaf_system stream'),
    ('awqaf_system_unit_pages', 'awqaf_system', 'awqaf_system_unit_pages', 'awqaf-system-owner + platform-integration-owner', 'high', 'awqaf system and awqaf assist operational surfaces belong to awqaf_system stream')
),
public_tables as (
  select c.oid as table_oid, n.nspname as table_schema, c.relname as table_name
  from pg_class c join pg_namespace n on n.oid = c.relnamespace
  join v4_sensitive_map m on m.public_table = c.relname
  where n.nspname = 'public' and c.relkind in ('r','p','f')
),
view_rewrites as (
  select d.refobjid as table_oid, v_ns.nspname as dependent_schema, v.relname as dependent_view, v.relkind as dependent_kind
  from pg_depend d join pg_rewrite r on r.oid=d.objid join pg_class v on v.oid=r.ev_class join pg_namespace v_ns on v_ns.oid=v.relnamespace
  where v.relkind in ('v','m')
),
deps as (
  select distinct pt.table_name, m.target_schema, vr.dependent_schema, vr.dependent_view
  from public_tables pt join v4_sensitive_map m on m.public_table=pt.table_name join view_rewrites vr on vr.table_oid=pt.table_oid
)
select
  'v4_structural_view_rewrite_gate_summary' as section,
  count(*) as structural_view_dependency_rows,
  count(distinct table_name) as public_tables_with_view_dependencies,
  count(distinct dependent_schema || '.' || dependent_view) as dependent_views,
  false as db_dependency_zero_certified_by_this_script,
  false as archive_authorized,
  false as production_approved,
  true as read_only
from deps;
