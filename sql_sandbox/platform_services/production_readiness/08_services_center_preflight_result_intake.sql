-- PalWakf Platform Services Center
-- Production Integration Preflight Result Intake
-- 08 - Read-only/no-op result classification
-- Date: 2026-05-08
-- Status: READ-ONLY / NO DDL / SAFE AS A DECISION NOTE
-- Purpose:
--   Classify the uploaded production preflight result and keep files 01-05 blocked
--   until existing service, complaint, permission, storage, and unit contracts are reviewed.

select 'Services Center production preflight result intake recorded. No DDL is approved by this file.' as decision;

select * from (values
  ('parsed_rows', '127'),
  ('platform_services_schema_visible_in_uploaded_inventory', 'false'),
  ('public_services_rls', 'true'),
  ('public_pwf_complaints_rls', 'true'),
  ('public_platform_permissions_rls', 'true'),
  ('core_org_units_rls', 'true'),
  ('storage_objects_rls', 'true')
) as preflight_result_intake(metric, value);

select * from (values
  ('00_services_center_production_preflight.sql', 'allowed_read_only'),
  ('06_services_center_existing_schema_integration_review.sql', 'allowed_read_only'),
  ('07_services_center_production_integration_decision_notes.sql', 'allowed_read_only_noop'),
  ('08_services_center_preflight_result_intake.sql', 'allowed_read_only_noop'),
  ('01_services_center_production_schema_v1_draft.sql', 'blocked_until_existing_columns_policies_intake'),
  ('02_services_center_production_rpc_v1_draft.sql', 'blocked_until_rbac_helper_intake'),
  ('03_services_center_production_rls_v1_draft.sql', 'blocked_until_policy_contract_intake'),
  ('04_services_center_storage_policy_readiness_draft.sql', 'blocked_until_bucket_policy_decision'),
  ('05_services_center_post_deploy_verification.sql', 'blocked_until_migration_finalized'),
  ('99_services_center_production_rollback_draft.sql', 'blocked_until_migration_finalized')
) as file_execution_gate(file_name, status);

select * from (values
  ('public.services', 'true', 'existing service catalog / do not duplicate'),
  ('public.servicetypes', 'true', 'existing service type reference'),
  ('public.serviceproviders', 'true', 'existing service provider reference'),
  ('public.servicepoints', 'true', 'existing service point reference'),
  ('public.pwf_complaints', 'true', 'existing complaint channel / do not replace'),
  ('public.platform_permissions', 'true', 'existing permission source candidate'),
  ('public.user_system_permissions', 'true', 'existing user permission source candidate'),
  ('public.user_system_roles', 'true', 'existing role source candidate'),
  ('public.user_scope_assignments', 'true', 'existing scope source candidate'),
  ('core.org_units', 'true', 'unit authority'),
  ('storage.buckets', 'true', 'storage bucket authority'),
  ('storage.objects', 'true', 'storage object authority')
) as object_contract(object_name, rls_status, integration_decision);
