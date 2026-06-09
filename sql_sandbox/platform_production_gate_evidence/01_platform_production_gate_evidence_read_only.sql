-- Mega Batch N1 — Platform Production Gate Evidence Read-only SQL
-- Purpose: Collect one-result readiness evidence after Mega N/M4.
-- This script is read-only. It must not mutate waqf, awqaf_system, platform_content, or platform_services.

with checks as (
  select 'platform_content_schema_exists'::text as check_key,
         exists(select 1 from information_schema.schemata where schema_name='platform_content') as passed,
         'platform_content schema should exist after Mega I.'::text as note
  union all
  select 'platform_services_schema_exists',
         exists(select 1 from information_schema.schemata where schema_name='platform_services'),
         'platform_services schema should exist after Mega M.'
  union all
  select 'platform_content_required_tables',
         (select count(*) = 5 from information_schema.tables where table_schema='platform_content' and table_name in ('center_content_categories','center_content_items','center_content_workflow_events','center_content_attachments','center_content_relations')),
         'Requires 5/5 platform_content tables.'
  union all
  select 'platform_services_required_tables',
         (select count(*) = 4 from information_schema.tables where table_schema='platform_services' and table_name in ('service_forms_registry','service_requests','service_request_status_events','service_request_attachments')),
         'Requires 4/4 platform_services tables.'
  union all
  select 'platform_center_public_view_exists',
         exists(select 1 from information_schema.views where table_schema='public' and table_name='v_platform_center_content'),
         'Public view for platform centers should exist.'
  union all
  select 'platform_center_detail_rpc_exists',
         exists(select 1 from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname='pwf_platform_center_content_get'),
         'Detail RPC should exist for /family/:id pages.'
  union all
  select 'service_center_runtime_rpcs_exist',
         (select count(*) >= 5 from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname in ('rpc_services_forms_public_v1','rpc_services_submit_request_v1','rpc_services_track_request_public_v1','rpc_services_admin_request_queue_v1','rpc_services_admin_transition_request_v1')),
         'Service center runtime RPCs should exist.'
  union all
  select 'service_center_browser_submit_evidence_present',
         exists(select 1 from platform_services.service_requests limit 1),
         'At least one browser/submitted request should exist after M3/M4 UAT.'
  union all
  select 'service_center_workflow_events_present',
         exists(select 1 from platform_services.service_request_status_events limit 1),
         'Workflow events should exist after admin browser transition UAT.'
  union all
  select 'homepage_sections_table_exists',
         exists(select 1 from information_schema.tables where table_schema='public' and table_name='homepage_sections'),
         'homepage_sections controls public homepage visibility/order/scope.'
  union all
  select 'no_waq_assets_mutation_in_this_script',
         true,
         'Read-only production gate evidence; this script does not touch waqf schema or awqaf_system.'
)
select * from checks order by check_key;
