-- 12_phase1_platform_shell_site_content_remediation_result_read_only.sql
-- Read-only. Documents Phase 1 runtime read remediation; does not authorize reroute.

with phase1(family, legacy_table, read_surface, status) as (
  values
    ('platform_shell_site_content','site_pages','public.v_platform_site_pages_compat_v1','runtime_read_wrapper_applied'),
    ('platform_shell_site_content','homepage_sections','public.v_platform_homepage_sections_compat_v1','runtime_read_wrapper_applied'),
    ('platform_shell_site_content','header_settings','public.v_platform_header_settings_compat_v1','runtime_read_wrapper_applied'),
    ('platform_shell_site_content','footer_settings','public.v_platform_footer_settings_compat_v1','runtime_read_wrapper_applied'),
    ('platform_shell_site_content','site_settings','public.v_platform_site_settings_compat_v1','runtime_read_wrapper_applied'),
    ('platform_shell_site_content','hero_slides','public.v_platform_hero_slides_compat_v1','runtime_read_wrapper_applied'),
    ('platform_shell_site_content','breaking_news','public.v_platform_breaking_news_compat_v1','runtime_read_wrapper_applied')
), pending(family, direct_pairs, note) as (
  values
    ('platform_access_rbac',10,'deferred to Phase 2 security/RBAC remediation'),
    ('core_linkage',5,'deferred to Phase 3 identity/core linkage remediation')
)
select
  '12_phase1_remediation_summary' as section,
  14 as platform_shell_site_content_pairs_remediated,
  (select coalesce(sum(direct_pairs),0) from pending) as remaining_non_phase1_direct_pairs,
  false as dependency_zero_certified,
  false as runtime_reroute_authorized,
  false as exact_public_table_name_replacement_authorized,
  'PHASE1_SITE_CONTENT_READ_REMEDIATED_RBAC_CORE_PENDING' as decision;

select
  '12_phase1_runtime_read_surfaces' as section,
  family,
  legacy_table,
  read_surface,
  to_regclass(read_surface) is not null as read_surface_present,
  status
from phase1
order by legacy_table;

select
  '12_phase1_pending_families' as section,
  family,
  direct_pairs,
  note
from pending
order by family;
