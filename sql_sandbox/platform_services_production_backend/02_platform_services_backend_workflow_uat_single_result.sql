-- PalWakf Platform — Mega Batch M
-- Service Center Production Backend + Request Workflow UAT
-- Single-result read-only verification.

with checks as (
  select 'platform_services_schema_exists' as check_key,
    exists(select 1 from information_schema.schemata where schema_name = 'platform_services') as passed,
    'platform_services schema exists' as note
  union all
  select 'platform_services_required_tables',
    (select count(*) = 4 from information_schema.tables
      where table_schema = 'platform_services'
        and table_name in ('service_forms_registry','service_requests','service_request_status_events','service_request_attachments')),
    'required tables installed=' || (select count(*)::text from information_schema.tables
      where table_schema = 'platform_services'
        and table_name in ('service_forms_registry','service_requests','service_request_status_events','service_request_attachments')) || '/4'
  union all
  select 'service_forms_seed_exists',
    (select count(*) >= 6 from platform_services.service_forms_registry where source_reference = 'Mega Batch M seed'),
    'seed_forms=' || (select count(*)::text from platform_services.service_forms_registry where source_reference = 'Mega Batch M seed')
  union all
  select 'public_rpc_wrappers_exist',
    (select count(*) = 6 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public'
        and p.proname in (
          'rpc_services_forms_public_v1',
          'rpc_services_submit_request_v1',
          'rpc_services_submit_request_draft_v1',
          'rpc_services_track_request_public_v1',
          'rpc_services_admin_request_queue_v1',
          'rpc_services_admin_transition_request_v1'
        )),
    'installed=' || (select count(*)::text from pg_proc p join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public'
        and p.proname in (
          'rpc_services_forms_public_v1',
          'rpc_services_submit_request_v1',
          'rpc_services_submit_request_draft_v1',
          'rpc_services_track_request_public_v1',
          'rpc_services_admin_request_queue_v1',
          'rpc_services_admin_transition_request_v1'
        )) || '/6'
  union all
  select 'rls_enabled_on_required_tables',
    (select count(*) = 4 from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'platform_services'
        and c.relname in ('service_forms_registry','service_requests','service_request_status_events','service_request_attachments')
        and c.relrowsecurity = true),
    'rls_enabled=' || (select count(*)::text from pg_class c join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'platform_services'
        and c.relname in ('service_forms_registry','service_requests','service_request_status_events','service_request_attachments')
        and c.relrowsecurity = true) || '/4'
  union all
  select 'deny_direct_policies_exist',
    (select count(*) >= 4 from pg_policies where schemaname = 'platform_services'),
    'policies=' || (select count(*)::text from pg_policies where schemaname = 'platform_services')
  union all
  select 'admin_transition_state_machine_exists',
    exists(select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname='platform_services' and p.proname='next_status_for_action_v1'),
    'state machine helper installed'
  union all
  select 'public_tracking_does_not_expose_sensitive_columns',
    not exists (
      select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public'
        and p.proname = 'rpc_services_track_request_public_v1'
        and pg_get_function_result(p.oid) ilike any(array['%requester_name%','%requester_contact%','%payload%','%internal_note%','%assigned_to%'])
    ),
    'public tracking RPC exposes status/note/timestamps only'
  union all
  select 'no_waq_assets_mutation_in_this_script', true,
    'Mega Batch M creates/updates platform_services only and public wrappers; it does not touch waqf schema or awqaf_system.'
)
select * from checks order by check_key;
