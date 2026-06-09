-- Public Legacy Dependency Reduction Pack
-- 04_DEPENDENCY_REDUCTION_TARGET_MATRIX_READ_ONLY.sql
-- Read-only target matrix for the next exact-body rewrite pack.

select *
from (
  values
    ('media_center', 'cms.rpc_public_home_feed', 'public.activities/media/news references', 'Use media_center owner-backed content surface or public.v_media_*_compat_v1; exact body required.', 'candidate_after_exact_body_export'),
    ('media_center', 'cms.rpc_public_home_page', 'public.activities/media/news references', 'Use owner-backed media feed; keep homepage_sections unchanged.', 'candidate_after_exact_body_export'),
    ('media_center', 'cms.rpc_public_unit_feed', 'public.activities/media/news references', 'Use owner-backed unit-scoped media feed; preserve unitSlug behavior.', 'candidate_after_exact_body_export'),
    ('media_center', 'cms.rpc_public_unit_page', 'public.activities/media/news references', 'Use owner-backed unit-scoped media feed; preserve unitSlug behavior.', 'candidate_after_exact_body_export'),
    ('media_center', 'public.rpc_media_center_readiness_v1', 'legacy public table existence checks', 'Replace readiness evidence with media_center.content_items/content_assets and compatibility surfaces.', 'safe_candidate_after_exact_body_export'),
    ('media_center', 'public.rpc_media_center_family_registry_v1', 'legacy public storage labels', 'Change labels to media_center owner + public compatibility surfaces; no runtime DML.', 'safe_candidate_after_exact_body_export'),
    ('media_center', 'public.rpc_media_center_runtime_ux_checks_v1', 'legacy public table checks', 'Use owner-backed readiness and UAT evidence.', 'candidate_after_exact_body_export'),
    ('media_center', 'public.rpc_media_center_record_audit_event_v1', 'legacy family/source references', 'Do not alter write/audit body until rollback body is exported.', 'manual_review_required'),
    ('media_center', 'public.rpc_media_center_record_editorial_event_v1', 'legacy family/source references', 'Do not alter write/editorial body until rollback body is exported.', 'manual_review_required'),
    ('service_center', 'public.rpc_services_catalog_compat_v1', 'public.services dependency', 'Do not rewrite until 9-vs-6 mapping gap is closed.', 'blocked_by_mapping_gap'),
    ('service_center', 'public.rpc_home_services_compat_v1', 'public.services/home services dependency', 'Do not rewrite until catalog/home-service mapping is closed.', 'blocked_by_mapping_gap'),
    ('service_center', 'public.rpc_services_forms_public_v1', 'service catalog/form dependency', 'Keep as platform_services wrapper if body already owner-backed; export exact body first.', 'candidate_after_exact_body_export'),
    ('service_center', 'platform_services.* helper functions', 'public.services text references may be false positives', 'Review exact body and avoid changing helpers unless they directly read legacy tables.', 'manual_review_required')
) as t(domain_key, routine_or_surface, current_dependency, reduction_target, rewrite_status)
order by domain_key, routine_or_surface;
