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
public_cols as (
  select
    m.public_table,
    m.target_schema,
    m.target_table,
    c.ordinal_position,
    c.column_name,
    c.data_type,
    c.udt_name,
    c.is_nullable,
    c.column_default
  from v4_sensitive_map m
  join information_schema.columns c
    on c.table_schema = 'public'
   and c.table_name = m.public_table
),
target_cols as (
  select
    m.public_table,
    m.target_schema,
    m.target_table,
    c.ordinal_position as target_ordinal_position,
    c.column_name,
    c.data_type as target_data_type,
    c.udt_name as target_udt_name,
    c.is_nullable as target_is_nullable,
    c.column_default as target_column_default
  from v4_sensitive_map m
  join information_schema.columns c
    on c.table_schema = m.target_schema
   and c.table_name = m.target_table
),
public_to_target as (
  select
    pc.public_table,
    pc.target_schema,
    pc.target_table,
    pc.column_name,
    pc.ordinal_position as public_ordinal_position,
    tc.target_ordinal_position,
    pc.data_type as public_data_type,
    tc.target_data_type,
    pc.udt_name as public_udt_name,
    tc.target_udt_name,
    pc.is_nullable as public_is_nullable,
    tc.target_is_nullable,
    case
      when tc.column_name is null then 'missing_in_target'
      when pc.udt_name is distinct from tc.target_udt_name then 'type_mismatch'
      when pc.is_nullable is distinct from tc.target_is_nullable then 'nullability_mismatch'
      else 'compatible_by_name_type_nullability'
    end as diff_status
  from public_cols pc
  left join target_cols tc
    on tc.public_table = pc.public_table
   and tc.target_schema = pc.target_schema
   and tc.target_table = pc.target_table
   and tc.column_name = pc.column_name
),
target_extra as (
  select
    tc.public_table,
    tc.target_schema,
    tc.target_table,
    tc.column_name,
    null::integer as public_ordinal_position,
    tc.target_ordinal_position,
    null::text as public_data_type,
    tc.target_data_type,
    null::text as public_udt_name,
    tc.target_udt_name,
    null::text as public_is_nullable,
    tc.target_is_nullable,
    'extra_in_target' as diff_status
  from target_cols tc
  left join public_cols pc
    on pc.public_table = tc.public_table
   and pc.target_schema = tc.target_schema
   and pc.target_table = tc.target_table
   and pc.column_name = tc.column_name
  where pc.column_name is null
)
select
  'v4_public_to_owner_column_diff_detail' as section,
  public_table,
  target_schema,
  target_table,
  column_name,
  public_ordinal_position,
  target_ordinal_position,
  public_data_type,
  target_data_type,
  public_udt_name,
  target_udt_name,
  public_is_nullable,
  target_is_nullable,
  diff_status,
  false as migration_executed_by_this_script,
  false as archive_authorized,
  false as production_approved,
  true as read_only
from (
  select * from public_to_target
  union all
  select * from target_extra
) d
order by target_schema, public_table, public_ordinal_position nulls last, column_name;

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
public_cols as (
  select m.public_table, m.target_schema, m.target_table, c.column_name, c.udt_name, c.is_nullable
  from v4_sensitive_map m join information_schema.columns c on c.table_schema='public' and c.table_name=m.public_table
),
target_cols as (
  select m.public_table, m.target_schema, m.target_table, c.column_name, c.udt_name, c.is_nullable
  from v4_sensitive_map m join information_schema.columns c on c.table_schema=m.target_schema and c.table_name=m.target_table
),
diffs as (
  select pc.public_table, pc.target_schema, pc.target_table,
    case
      when tc.column_name is null then 'missing_in_target'
      when pc.udt_name is distinct from tc.udt_name then 'type_mismatch'
      when pc.is_nullable is distinct from tc.is_nullable then 'nullability_mismatch'
      else 'compatible_by_name_type_nullability'
    end as diff_status
  from public_cols pc left join target_cols tc
    on tc.public_table=pc.public_table and tc.target_schema=pc.target_schema and tc.target_table=pc.target_table and tc.column_name=pc.column_name
  union all
  select tc.public_table, tc.target_schema, tc.target_table, 'extra_in_target'
  from target_cols tc left join public_cols pc
    on pc.public_table=tc.public_table and pc.target_schema=tc.target_schema and pc.target_table=tc.target_table and pc.column_name=tc.column_name
  where pc.column_name is null
)
select
  'v4_public_to_owner_column_diff_summary' as section,
  target_schema,
  count(distinct public_table) as table_count,
  count(*) filter (where diff_status = 'missing_in_target') as missing_in_target_columns,
  count(*) filter (where diff_status = 'type_mismatch') as type_mismatch_columns,
  count(*) filter (where diff_status = 'nullability_mismatch') as nullability_mismatch_columns,
  count(*) filter (where diff_status = 'extra_in_target') as extra_in_target_columns,
  bool_and(diff_status = 'compatible_by_name_type_nullability') as schema_zero_diff_candidate,
  false as apply_authorized_by_this_script,
  false as production_approved,
  true as read_only
from diffs
group by target_schema
order by target_schema;
