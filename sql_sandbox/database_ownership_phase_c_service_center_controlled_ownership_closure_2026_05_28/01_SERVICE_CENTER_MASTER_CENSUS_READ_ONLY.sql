-- PalWakf Platform
-- Database Ownership Phase C — Service Center Controlled Ownership Closure
-- 01_SERVICE_CENTER_MASTER_CENSUS_READ_ONLY.sql
-- Purpose: one read-only census for platform_services ownership, public service compatibility surfaces, legacy public service surfaces, RPCs, RLS, and public tracking safety.
-- This script is SELECT-only and authorizes no execution.

with relation_targets(section, object_ref, expected_kind, owner_decision, required_for_closure, object_comment) as (
  values
    ('owner_schema', 'platform_services', 'schema', 'OWNER_SCHEMA_TARGET', true, 'Service Center sovereign owner schema.'),
    ('owner_table', 'platform_services.service_forms_registry', 'table', 'CANONICAL_FORMS_REGISTRY', true, 'Registry of public/internal service forms.'),
    ('owner_table', 'platform_services.service_requests', 'table', 'CANONICAL_REQUEST_INTAKE', true, 'Request intake and lifecycle table.'),
    ('owner_table', 'platform_services.service_request_status_events', 'table', 'CANONICAL_WORKFLOW_EVENTS', true, 'Request workflow event audit trail.'),
    ('owner_table', 'platform_services.service_request_attachments', 'table', 'CANONICAL_ATTACHMENT_METADATA', true, 'Attachment metadata only; storage remains external.'),
    ('owner_table_optional', 'platform_services.complaints', 'table', 'OPTIONAL_PLATFORM_SERVICES_COMPLAINTS_OWNER', false, 'Complaint ownership candidate if this table exists.'),
    ('owner_table_optional', 'platform_services.complaint_updates', 'table', 'OPTIONAL_PLATFORM_SERVICES_COMPLAINT_UPDATES_OWNER', false, 'Complaint update ownership candidate if this table exists.'),
    ('public_compat_surface', 'public.v_services_catalog_compat_v1', 'view', 'PUBLIC_COMPATIBILITY_SURFACE', true, 'Public catalog wrapper; public remains API/compatibility surface.'),
    ('legacy_public_source', 'public.services', 'table', 'LEGACY_SERVICE_CATALOG_PRESERVE_OR_WRAPPER_SOURCE', false, 'Legacy public services source candidate; do not delete here.'),
    ('legacy_public_source', 'public.service_catalog', 'table', 'LEGACY_SERVICE_CATALOG_PRESERVE_OR_WRAPPER_SOURCE', false, 'Legacy public service_catalog source candidate; do not delete here.'),
    ('legacy_public_source', 'public.service_forms', 'table', 'LEGACY_SERVICE_FORMS_PRESERVE_OR_WRAPPER_SOURCE', false, 'Legacy public service_forms source candidate; do not delete here.'),
    ('legacy_public_source', 'public.service_requests', 'table', 'LEGACY_SERVICE_REQUESTS_PRESERVE_OR_RECONCILE', false, 'Legacy public service_requests source candidate; do not delete here.'),
    ('legacy_public_source', 'public.servicetypes', 'table', 'LEGACY_SERVICE_TAXONOMY_PRESERVE', false, 'Legacy taxonomy source candidate.'),
    ('legacy_public_source', 'public.servicepoints', 'table', 'LEGACY_SERVICE_POINTS_PRESERVE', false, 'Legacy service points source candidate.'),
    ('legacy_public_source', 'public.serviceproviders', 'table', 'LEGACY_SERVICE_PROVIDERS_PRESERVE', false, 'Legacy service providers source candidate.')
), relation_census as (
  select
    'phase_c_service_center_master_census'::text as report_key,
    rt.section,
    rt.object_ref,
    rt.expected_kind,
    rt.owner_decision,
    rt.required_for_closure,
    case
      when rt.expected_kind = 'schema' then exists(select 1 from information_schema.schemata where schema_name = rt.object_ref)
      else to_regclass(rt.object_ref) is not null
    end as object_present,
    case
      when rt.expected_kind in ('table','view') and to_regclass(rt.object_ref) is not null then
        (xpath('/row/c/text()', query_to_xml(format('select count(*)::bigint as c from %s', rt.object_ref), false, true, '')))[1]::text::bigint
      else null::bigint
    end as estimated_rows,
    rt.object_comment,
    false as execution_authorized,
    false as production_approved,
    false as destructive_sql_authorized,
    false as exact_public_table_replacement_authorized,
    false as archive_delete_authorized,
    true as no_auth_users_migration,
    true as no_flutter_elevated_secret,
    true as no_waqf_assets_mutation,
    true as no_gis_mutation,
    true as read_only
  from relation_targets rt
), function_targets(object_ref, owner_decision, required_for_closure, object_comment) as (
  values
    ('public.rpc_services_forms_public_v1()', 'PUBLIC_SERVICE_FORMS_RPC', true, 'Public forms read RPC.'),
    ('public.rpc_services_submit_request_v1(jsonb)', 'PUBLIC_REQUEST_SUBMIT_RPC', true, 'Public request submission RPC.'),
    ('public.rpc_services_submit_request_draft_v1(jsonb)', 'PUBLIC_REQUEST_SUBMIT_DRAFT_COMPAT_RPC', false, 'Draft/compat submit wrapper.'),
    ('public.rpc_services_track_request_public_v1(text)', 'PUBLIC_TRACKING_RPC_SAFE_FIELDS_ONLY', true, 'Public tracking must not expose payload/internal fields.'),
    ('public.rpc_services_admin_request_queue_v1(text, integer)', 'ADMIN_REQUEST_QUEUE_RPC', true, 'Authenticated admin queue RPC.'),
    ('public.rpc_services_admin_request_queue_draft_v1()', 'ADMIN_REQUEST_QUEUE_DRAFT_COMPAT_RPC', false, 'Draft/compat queue wrapper.'),
    ('public.rpc_services_admin_transition_request_v1(text, text, text, text)', 'ADMIN_WORKFLOW_TRANSITION_RPC', true, 'Admin state-machine transition RPC.'),
    ('platform_services.next_status_for_action_v1(text, text)', 'OWNER_STATE_MACHINE_HELPER', true, 'Request lifecycle state-machine helper.'),
    ('platform_services.can_admin_read_requests_v1()', 'OWNER_AUTHORIZATION_HELPER_EXISTING_NO_REWRITE', true, 'Existing helper; no Auth/RBAC rewrite in this phase.'),
    ('platform_services.can_admin_write_requests_v1()', 'OWNER_AUTHORIZATION_HELPER_EXISTING_NO_REWRITE', true, 'Existing helper; no Auth/RBAC rewrite in this phase.')
), function_census as (
  select
    'phase_c_service_center_master_census'::text as report_key,
    'public_or_owner_rpc'::text as section,
    ft.object_ref,
    'function'::text as expected_kind,
    ft.owner_decision,
    ft.required_for_closure,
    to_regprocedure(ft.object_ref) is not null as object_present,
    null::bigint as estimated_rows,
    ft.object_comment,
    false as execution_authorized,
    false as production_approved,
    false as destructive_sql_authorized,
    false as exact_public_table_replacement_authorized,
    false as archive_delete_authorized,
    true as no_auth_users_migration,
    true as no_flutter_elevated_secret,
    true as no_waqf_assets_mutation,
    true as no_gis_mutation,
    true as read_only
  from function_targets ft
), column_targets(object_ref, owner_decision, required_for_closure, object_comment) as (
  values
    ('platform_services.service_forms_registry.form_key', 'required_column', true, 'Stable form key.'),
    ('platform_services.service_forms_registry.title_ar', 'required_column', true, 'Arabic form title.'),
    ('platform_services.service_forms_registry.service_key', 'required_column', true, 'Service key.'),
    ('platform_services.service_forms_registry.public_visibility', 'required_column', true, 'Public exposure guard.'),
    ('platform_services.service_forms_registry.review_status', 'required_column', true, 'Draft/review/approved/archive state.'),
    ('platform_services.service_requests.tracking_code', 'required_column', true, 'Public tracking code.'),
    ('platform_services.service_requests.requester_name', 'sensitive_column_not_public_tracking', true, 'Must not be exposed by public tracking RPC.'),
    ('platform_services.service_requests.requester_contact', 'sensitive_column_not_public_tracking', true, 'Must not be exposed by public tracking RPC.'),
    ('platform_services.service_requests.payload', 'sensitive_column_not_public_tracking', true, 'Must not be exposed by public tracking RPC.'),
    ('platform_services.service_requests.internal_note', 'sensitive_column_not_public_tracking', true, 'Must not be exposed by public tracking RPC.'),
    ('platform_services.service_requests.status', 'required_column', true, 'Lifecycle state.'),
    ('platform_services.service_requests.public_note', 'public_tracking_allowed_column', true, 'Safe public note.'),
    ('platform_services.service_request_status_events.to_status', 'required_column', true, 'Workflow target status.'),
    ('platform_services.service_request_status_events.action_key', 'required_column', true, 'Workflow action key.'),
    ('platform_services.service_request_attachments.storage_path', 'sensitive_metadata_admin_only', true, 'Must not be publicly exposed directly.')
), column_census as (
  select
    'phase_c_service_center_master_census'::text as report_key,
    'owner_required_column'::text as section,
    ct.object_ref,
    'column'::text as expected_kind,
    ct.owner_decision,
    ct.required_for_closure,
    exists (
      select 1
      from information_schema.columns c
      where c.table_schema = split_part(ct.object_ref, '.', 1)
        and c.table_name = split_part(ct.object_ref, '.', 2)
        and c.column_name = split_part(ct.object_ref, '.', 3)
    ) as object_present,
    null::bigint as estimated_rows,
    ct.object_comment,
    false as execution_authorized,
    false as production_approved,
    false as destructive_sql_authorized,
    false as exact_public_table_replacement_authorized,
    false as archive_delete_authorized,
    true as no_auth_users_migration,
    true as no_flutter_elevated_secret,
    true as no_waqf_assets_mutation,
    true as no_gis_mutation,
    true as read_only
  from column_targets ct
)
select * from relation_census
union all select * from function_census
union all select * from column_census
order by section, object_ref;
