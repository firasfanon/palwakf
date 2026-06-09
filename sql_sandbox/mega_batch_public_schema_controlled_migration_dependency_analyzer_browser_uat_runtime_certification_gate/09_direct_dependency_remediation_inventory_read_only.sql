-- Mega Batch — Public Schema Direct Dependency Remediation Plan + Route Console Evidence Pack
-- 09_direct_dependency_remediation_inventory_read_only.sql
-- SELECT-only evidence script. No DDL/DML.

with dependency_inventory(family, owner_schema, legacy_table, file_path, first_line, target_surface, reroute_phase, risk_level) as (
  values
  ('core_linkage', 'core', 'admin_users', 'lib/core/access/access_repository.dart', 28, 'public.v_core_admin_users_compat_v1 / future core-admin repository adapter', 'phase_3_core_admin_linkage', 'high'),
  ('core_linkage', 'core', 'admin_users', 'lib/data/repositories/admin_users_repository.dart', 169, 'public.v_core_admin_users_compat_v1 / future core-admin repository adapter', 'phase_3_core_admin_linkage', 'high'),
  ('core_linkage', 'core', 'admin_users', 'lib/data/repositories/auth_repository.dart', 23, 'public.v_core_admin_users_compat_v1 / future core-admin repository adapter', 'phase_3_core_admin_linkage', 'high'),
  ('core_linkage', 'core', 'admin_users', 'lib/features/tasks_system/data/repositories/admin_users_repository.dart', 12, 'public.v_core_admin_users_compat_v1 / future core-admin repository adapter', 'phase_3_core_admin_linkage', 'high'),
  ('core_linkage', 'core', 'admin_users', 'lib/features/tasks_system/data/repositories/auth_repository.dart', 210, 'public.v_core_admin_users_compat_v1 / future core-admin repository adapter', 'phase_3_core_admin_linkage', 'high'),
  ('platform_access_rbac', 'platform', 'user_system_permissions', 'lib/core/access/access_repository.dart', 60, 'public.v_platform_user_system_permissions_compat_v1 / platform RBAC repository adapter', 'phase_2_platform_rbac_access', 'high'),
  ('platform_access_rbac', 'platform', 'user_system_roles', 'lib/core/access/access_repository.dart', 43, 'public.v_platform_user_system_roles_compat_v1 / platform RBAC repository adapter', 'phase_2_platform_rbac_access', 'high'),
  ('platform_access_rbac', 'platform', 'platform_permissions', 'lib/data/repositories/rbac_admin_repository.dart', 33, 'platform.platform_permissions via platform RBAC RPC/wrapper', 'phase_2_platform_rbac_access', 'high'),
  ('platform_access_rbac', 'platform', 'platform_systems', 'lib/data/repositories/rbac_admin_repository.dart', 11, 'platform.platform_systems via platform RBAC RPC/wrapper', 'phase_2_platform_rbac_access', 'high'),
  ('platform_access_rbac', 'platform', 'user_system_permissions', 'lib/data/repositories/rbac_admin_repository.dart', 50, 'public.v_platform_user_system_permissions_compat_v1 / platform RBAC repository adapter', 'phase_2_platform_rbac_access', 'high'),
  ('platform_access_rbac', 'platform', 'user_system_roles', 'lib/data/repositories/rbac_admin_repository.dart', 41, 'public.v_platform_user_system_roles_compat_v1 / platform RBAC repository adapter', 'phase_2_platform_rbac_access', 'high'),
  ('platform_access_rbac', 'platform', 'platform_permissions', 'lib/features/tasks_system/data/repositories/rbac_admin_repository.dart', 17, 'platform.platform_permissions via platform RBAC RPC/wrapper', 'phase_2_platform_rbac_access', 'high'),
  ('platform_access_rbac', 'platform', 'platform_systems', 'lib/features/tasks_system/data/repositories/rbac_admin_repository.dart', 9, 'platform.platform_systems via platform RBAC RPC/wrapper', 'phase_2_platform_rbac_access', 'high'),
  ('platform_access_rbac', 'platform', 'user_system_permissions', 'lib/features/tasks_system/data/repositories/rbac_admin_repository.dart', 34, 'public.v_platform_user_system_permissions_compat_v1 / platform RBAC repository adapter', 'phase_2_platform_rbac_access', 'high'),
  ('platform_access_rbac', 'platform', 'user_system_roles', 'lib/features/tasks_system/data/repositories/rbac_admin_repository.dart', 25, 'public.v_platform_user_system_roles_compat_v1 / platform RBAC repository adapter', 'phase_2_platform_rbac_access', 'high'),
  ('platform_shell_site_content', 'platform', 'site_pages', 'lib/core/visual_identity/visual_identity_publish_repository.dart', 108, 'public.v_platform_site_pages_compat_v1 / platform site-pages adapter', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'footer_settings', 'lib/data/repositories/footer_repository.dart', 15, 'public.v_platform_footer_settings_compat_v1 / platform footer adapter', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'header_settings', 'lib/data/repositories/header_repository.dart', 14, 'public.v_platform_header_settings_compat_v1 / platform header adapter', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'breaking_news', 'lib/data/repositories/homepage_repository.dart', 660, 'platform.breaking_news via compatibility wrapper/RPC before direct owner-schema use', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'hero_slides', 'lib/data/repositories/homepage_repository.dart', 77, 'platform.hero_slides via compatibility wrapper/RPC before direct owner-schema use', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'site_settings', 'lib/data/repositories/homepage_repository.dart', 28, 'platform.site_settings via compatibility wrapper/RPC before direct owner-schema use', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'site_pages', 'lib/features/platform/home/data/repositories/pwf_site_pages_repository.dart', 31, 'public.v_platform_site_pages_compat_v1 / platform site-pages adapter', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'footer_settings', 'lib/features/tasks_system/data/repositories/footer_repository.dart', 11, 'public.v_platform_footer_settings_compat_v1 / platform footer adapter', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'header_settings', 'lib/features/tasks_system/data/repositories/header_repository.dart', 11, 'public.v_platform_header_settings_compat_v1 / platform header adapter', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'breaking_news', 'lib/features/tasks_system/data/repositories/homepage_repository.dart', 363, 'platform.breaking_news via compatibility wrapper/RPC before direct owner-schema use', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'hero_slides', 'lib/features/tasks_system/data/repositories/homepage_repository.dart', 66, 'platform.hero_slides via compatibility wrapper/RPC before direct owner-schema use', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'site_settings', 'lib/features/tasks_system/data/repositories/homepage_repository.dart', 17, 'platform.site_settings via compatibility wrapper/RPC before direct owner-schema use', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'homepage_sections', 'lib/presentation/screens/admin/main/management/home_management/pwf_unit_pages_repository.dart', 33, 'public.v_platform_homepage_sections_compat_v1 / platform homepage adapter', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'site_pages', 'lib/presentation/screens/admin/main/management/home_management/pwf_unit_pages_repository.dart', 27, 'public.v_platform_site_pages_compat_v1 / platform site-pages adapter', 'phase_1_platform_shell_site_content', 'medium')
)
select
  '09_direct_dependency_inventory' as section,
  family,
  owner_schema,
  legacy_table,
  file_path,
  first_line,
  target_surface,
  reroute_phase,
  risk_level
from dependency_inventory
order by reroute_phase, family, file_path, legacy_table;

with dependency_inventory(family, owner_schema, legacy_table, file_path, first_line, target_surface, reroute_phase, risk_level) as (
  values
  ('core_linkage', 'core', 'admin_users', 'lib/core/access/access_repository.dart', 28, 'public.v_core_admin_users_compat_v1 / future core-admin repository adapter', 'phase_3_core_admin_linkage', 'high'),
  ('core_linkage', 'core', 'admin_users', 'lib/data/repositories/admin_users_repository.dart', 169, 'public.v_core_admin_users_compat_v1 / future core-admin repository adapter', 'phase_3_core_admin_linkage', 'high'),
  ('core_linkage', 'core', 'admin_users', 'lib/data/repositories/auth_repository.dart', 23, 'public.v_core_admin_users_compat_v1 / future core-admin repository adapter', 'phase_3_core_admin_linkage', 'high'),
  ('core_linkage', 'core', 'admin_users', 'lib/features/tasks_system/data/repositories/admin_users_repository.dart', 12, 'public.v_core_admin_users_compat_v1 / future core-admin repository adapter', 'phase_3_core_admin_linkage', 'high'),
  ('core_linkage', 'core', 'admin_users', 'lib/features/tasks_system/data/repositories/auth_repository.dart', 210, 'public.v_core_admin_users_compat_v1 / future core-admin repository adapter', 'phase_3_core_admin_linkage', 'high'),
  ('platform_access_rbac', 'platform', 'user_system_permissions', 'lib/core/access/access_repository.dart', 60, 'public.v_platform_user_system_permissions_compat_v1 / platform RBAC repository adapter', 'phase_2_platform_rbac_access', 'high'),
  ('platform_access_rbac', 'platform', 'user_system_roles', 'lib/core/access/access_repository.dart', 43, 'public.v_platform_user_system_roles_compat_v1 / platform RBAC repository adapter', 'phase_2_platform_rbac_access', 'high'),
  ('platform_access_rbac', 'platform', 'platform_permissions', 'lib/data/repositories/rbac_admin_repository.dart', 33, 'platform.platform_permissions via platform RBAC RPC/wrapper', 'phase_2_platform_rbac_access', 'high'),
  ('platform_access_rbac', 'platform', 'platform_systems', 'lib/data/repositories/rbac_admin_repository.dart', 11, 'platform.platform_systems via platform RBAC RPC/wrapper', 'phase_2_platform_rbac_access', 'high'),
  ('platform_access_rbac', 'platform', 'user_system_permissions', 'lib/data/repositories/rbac_admin_repository.dart', 50, 'public.v_platform_user_system_permissions_compat_v1 / platform RBAC repository adapter', 'phase_2_platform_rbac_access', 'high'),
  ('platform_access_rbac', 'platform', 'user_system_roles', 'lib/data/repositories/rbac_admin_repository.dart', 41, 'public.v_platform_user_system_roles_compat_v1 / platform RBAC repository adapter', 'phase_2_platform_rbac_access', 'high'),
  ('platform_access_rbac', 'platform', 'platform_permissions', 'lib/features/tasks_system/data/repositories/rbac_admin_repository.dart', 17, 'platform.platform_permissions via platform RBAC RPC/wrapper', 'phase_2_platform_rbac_access', 'high'),
  ('platform_access_rbac', 'platform', 'platform_systems', 'lib/features/tasks_system/data/repositories/rbac_admin_repository.dart', 9, 'platform.platform_systems via platform RBAC RPC/wrapper', 'phase_2_platform_rbac_access', 'high'),
  ('platform_access_rbac', 'platform', 'user_system_permissions', 'lib/features/tasks_system/data/repositories/rbac_admin_repository.dart', 34, 'public.v_platform_user_system_permissions_compat_v1 / platform RBAC repository adapter', 'phase_2_platform_rbac_access', 'high'),
  ('platform_access_rbac', 'platform', 'user_system_roles', 'lib/features/tasks_system/data/repositories/rbac_admin_repository.dart', 25, 'public.v_platform_user_system_roles_compat_v1 / platform RBAC repository adapter', 'phase_2_platform_rbac_access', 'high'),
  ('platform_shell_site_content', 'platform', 'site_pages', 'lib/core/visual_identity/visual_identity_publish_repository.dart', 108, 'public.v_platform_site_pages_compat_v1 / platform site-pages adapter', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'footer_settings', 'lib/data/repositories/footer_repository.dart', 15, 'public.v_platform_footer_settings_compat_v1 / platform footer adapter', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'header_settings', 'lib/data/repositories/header_repository.dart', 14, 'public.v_platform_header_settings_compat_v1 / platform header adapter', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'breaking_news', 'lib/data/repositories/homepage_repository.dart', 660, 'platform.breaking_news via compatibility wrapper/RPC before direct owner-schema use', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'hero_slides', 'lib/data/repositories/homepage_repository.dart', 77, 'platform.hero_slides via compatibility wrapper/RPC before direct owner-schema use', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'site_settings', 'lib/data/repositories/homepage_repository.dart', 28, 'platform.site_settings via compatibility wrapper/RPC before direct owner-schema use', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'site_pages', 'lib/features/platform/home/data/repositories/pwf_site_pages_repository.dart', 31, 'public.v_platform_site_pages_compat_v1 / platform site-pages adapter', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'footer_settings', 'lib/features/tasks_system/data/repositories/footer_repository.dart', 11, 'public.v_platform_footer_settings_compat_v1 / platform footer adapter', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'header_settings', 'lib/features/tasks_system/data/repositories/header_repository.dart', 11, 'public.v_platform_header_settings_compat_v1 / platform header adapter', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'breaking_news', 'lib/features/tasks_system/data/repositories/homepage_repository.dart', 363, 'platform.breaking_news via compatibility wrapper/RPC before direct owner-schema use', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'hero_slides', 'lib/features/tasks_system/data/repositories/homepage_repository.dart', 66, 'platform.hero_slides via compatibility wrapper/RPC before direct owner-schema use', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'site_settings', 'lib/features/tasks_system/data/repositories/homepage_repository.dart', 17, 'platform.site_settings via compatibility wrapper/RPC before direct owner-schema use', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'homepage_sections', 'lib/presentation/screens/admin/main/management/home_management/pwf_unit_pages_repository.dart', 33, 'public.v_platform_homepage_sections_compat_v1 / platform homepage adapter', 'phase_1_platform_shell_site_content', 'medium'),
  ('platform_shell_site_content', 'platform', 'site_pages', 'lib/presentation/screens/admin/main/management/home_management/pwf_unit_pages_repository.dart', 27, 'public.v_platform_site_pages_compat_v1 / platform site-pages adapter', 'phase_1_platform_shell_site_content', 'medium')
)
select
  '09_dependency_summary' as section,
  count(*) as direct_postgrest_unique_file_table_pair_count,
  count(distinct file_path) as unique_direct_file_count,
  count(*) filter (where family = 'platform_shell_site_content') as platform_shell_site_content_pairs,
  count(*) filter (where family = 'platform_access_rbac') as platform_access_rbac_pairs,
  count(*) filter (where family = 'core_linkage') as core_linkage_pairs,
  count(*) filter (where family = 'assistant') as assistant_pairs,
  'DEPENDENCY_ZERO_NOT_CERTIFIED_RUNTIME_REROUTE_BLOCKED' as decision
from dependency_inventory;
