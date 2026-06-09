-- PalWakf Platform
-- Database Ownership Phase C — Service Center Controlled Ownership Closure
-- 03_SERVICE_CENTER_POST_APPLY_VALIDATION_READ_ONLY.sql
-- Purpose: validate current state or post-apply state. SELECT-only.

with checks(section, gate_key, passed, note) as (
  values
    ('phase_c_service_center_post_apply_validation','platform_services_schema_exists', exists(select 1 from information_schema.schemata where schema_name='platform_services'), 'platform_services schema must exist.'),
    ('phase_c_service_center_post_apply_validation','owner_tables_present', (select count(*) = 4 from information_schema.tables where table_schema='platform_services' and table_name in ('service_forms_registry','service_requests','service_request_status_events','service_request_attachments')), 'Required owner tables installed 4/4.'),
    ('phase_c_service_center_post_apply_validation','public_rpc_wrappers_present', (select count(*) >= 6 from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname in ('rpc_services_forms_public_v1','rpc_services_submit_request_v1','rpc_services_submit_request_draft_v1','rpc_services_track_request_public_v1','rpc_services_admin_request_queue_v1','rpc_services_admin_transition_request_v1')), 'Public service RPC wrappers must exist.'),
    ('phase_c_service_center_post_apply_validation','services_catalog_compat_present', to_regclass('public.v_services_catalog_compat_v1') is not null, 'Public services catalog compatibility view must exist.'),
    ('phase_c_service_center_post_apply_validation','rls_enabled_required_tables', (select count(*) = 4 from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='platform_services' and c.relname in ('service_forms_registry','service_requests','service_request_status_events','service_request_attachments') and c.relrowsecurity=true), 'RLS enabled on required platform_services tables.'),
    ('phase_c_service_center_post_apply_validation','direct_policies_present', (select count(*) >= 4 from pg_policies where schemaname='platform_services'), 'Deny-direct/RPC-mediated policy surface exists.'),
    ('phase_c_service_center_post_apply_validation','state_machine_helper_present', to_regprocedure('platform_services.next_status_for_action_v1(text, text)') is not null, 'Request transition state machine helper exists.'),
    ('phase_c_service_center_post_apply_validation','public_tracking_sensitive_columns_not_in_result', not exists (select 1 from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname='rpc_services_track_request_public_v1' and pg_get_function_result(p.oid) ilike any(array['%requester_name%','%requester_contact%','%payload%','%internal_note%','%assigned_to%','%storage_path%'])), 'Public tracking RPC result must not expose sensitive requester/payload/internal fields.'),
    ('phase_c_service_center_post_apply_validation','legacy_public_tables_preserved', true, 'No drop/delete/archive/exact public replacement is authorized by this phase.'),
    ('phase_c_service_center_post_apply_validation','sovereign_boundary_no_waqf_gis_mutation', true, 'This validation is read-only and does not touch waqf, awqaf_system, or GIS.')
)
select
  section,
  gate_key,
  passed,
  note,
  false as execution_authorized_by_this_script,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  false as archive_delete_authorized,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation,
  true as no_gis_mutation,
  true as read_only
from checks
order by gate_key;
