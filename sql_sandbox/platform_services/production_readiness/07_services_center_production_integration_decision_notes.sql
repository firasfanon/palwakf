-- PalWakf Platform Services Center
-- Production Integration Decision Notes
-- 07 - No-op decision register
-- Date: 2026-05-08
-- Status: READ-ONLY / NO DDL / SAFE AS A DECISION NOTE
-- Purpose:
--   Keep the production SQL pack honest after preflight showed existing services,
--   complaint, permission, unit, and storage structures.

select 'PalWakf Services Center production DDL remains blocked until existing schema integration review is approved.' as decision;

select * from (values
  ('service_catalog', 'Use existing public.services. Do not duplicate service catalog inside platform_services.'),
  ('forms_registry', 'platform_services.service_forms_registry may store form metadata and attachment requirements; map to public.services by service_key until final FK is approved.'),
  ('requests', 'platform_services.service_requests is a candidate new transactional intake table; no existing equivalent was confirmed by table inventory alone.'),
  ('complaints', 'public.pwf_complaints remains the complaint channel; service requests must not replace it.'),
  ('rbac', 'Use existing platform permission/user role tables or a confirmed helper before enabling admin queue actions.'),
  ('storage', 'Use storage.objects/buckets policies; request attachments table stores metadata only.'),
  ('waqf_assets', 'waqf_asset_id remains nullable and non-enforced until the sovereign table is production-complete.')
) as decisions(area, decision_note);
