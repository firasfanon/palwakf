-- Mega Batch N — Platform Operational Readiness Review — Read-only UAT
-- Safe: read-only. Does not touch waqf schema or awqaf_system.

with checks as (
  select
    'platform_content_schema_exists'::text as check_key,
    exists(select 1 from information_schema.schemata where schema_name='platform_content') as passed,
    'platform_content schema presence for platform center content.'::text as note
  union all
  select
    'platform_content_required_tables',
    (select count(*) = 5 from information_schema.tables
      where table_schema='platform_content'
        and table_name in ('center_content_categories','center_content_items','center_content_workflow_events','center_content_attachments','center_content_relations')),
    'Required platform_content tables expected=5.'
  union all
  select
    'platform_content_public_view_exists',
    exists(select 1 from information_schema.views where table_schema='public' and table_name='v_platform_center_content'),
    'public.v_platform_center_content must exist and remain public read wrapper.'
  union all
  select
    'platform_content_detail_rpc_exists',
    exists(select 1 from pg_proc p join pg_namespace n on n.oid=p.pronamespace where n.nspname='public' and p.proname='pwf_platform_center_content_get'),
    'Detail RPC required for /family/:id pages.'
  union all
  select
    'platform_services_required_tables',
    (select count(*) = 4 from information_schema.tables
      where table_schema='platform_services'
        and table_name in ('service_forms_registry','service_requests','service_request_status_events','service_request_attachments')),
    'Required platform_services tables expected=4.'
  union all
  select
    'platform_services_runtime_rpcs_exist',
    (select count(distinct p.proname)=5 from pg_proc p join pg_namespace n on n.oid=p.pronamespace
      where n.nspname='public'
        and p.proname in ('rpc_services_forms_public_v1','rpc_services_submit_request_v1','rpc_services_track_request_public_v1','rpc_services_admin_request_queue_v1','rpc_services_admin_transition_request_v1')),
    'Runtime service center RPCs expected=5.'
  union all
  select
    'service_center_browser_uat_evidence_present',
    exists(select 1 from platform_services.service_requests limit 1)
      and exists(select 1 from platform_services.service_request_status_events limit 1),
    'Requires at least one browser-created request and one workflow event.'
  union all
  select
    'homepage_sections_key_catalog_present',
    exists(select 1 from public.homepage_sections where section_key in ('pwf_public_services_catalog','pwf_events_section','pwf_legal_references_section') limit 1),
    'Representative dynamic homepage section keys should exist. If false, seed/admin configuration is still required.'
  union all
  select
    'media_center_governance_tables_exist',
    (select count(*) >= 3 from information_schema.tables
      where table_schema='public'
        and table_name in ('media_center_audit_events','media_center_editorial_events','media_center_publishing_governance_rules','media_center_editorial_roles')),
    'Media center governance/audit tables should exist.'
  union all
  select
    'no_waq_assets_mutation_in_this_script',
    true,
    'Read-only UAT. This script does not mutate waqf schema or awqaf_system.'
)
select check_key, passed, note
from checks
order by check_key;
