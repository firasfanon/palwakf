-- Platform Technical Services — Dashboard RPC created_at order hotfix
--
-- Error:
--   ERROR 42703: column x.created_at does not exist
--
-- Cause:
--   public.rpc_platform_technical_services_dashboard_v1 aggregates the 'backups'
--   collection using:
--     jsonb_agg(to_jsonb(x) order by x.created_at desc)
--   but the backup subquery did not include x.created_at in the selected columns.
--
-- Fix:
--   Replace public.rpc_platform_technical_services_dashboard_v1 only.
--   Include created_at in backup rows and use explicit row_created_at aliases where useful.
--
-- This hotfix DOES NOT:
--   - alter tables
--   - change RLS
--   - weaken auth
--   - execute backup/restore
--   - activate maintenance mode
--   - mutate sovereign business data
--   - approve production

select
  'platform_technical_dashboard_rpc_created_at_order_hotfix_read_me_first' as section,
  'SINGLE_RPC_BODY_FIX_ONLY' as execution_mode,
  true as dashboard_rpc_body_fix_prepared,
  false as table_ddl,
  false as rls_change,
  false as runtime_auth_weakened,
  false as backup_restore_execution,
  false as maintenance_mode_global_activation,
  false as sovereign_business_data_mutation,
  false as production_approved,
  'Run 03A then 06A and 07.' as instruction;



begin;

create or replace function public.rpc_platform_technical_services_dashboard_v1()
returns jsonb
language plpgsql
stable
security definer
set search_path = public, platform_technical, auth
as $$
declare
  v_result jsonb;
begin
  perform platform_technical.assert_platform_technical_admin_v1();

  select jsonb_build_object(
    'backend_applied', true,
    'backend_status', 'platform-technical-backend-contract-active',
    'metrics', jsonb_build_array(
      jsonb_build_object(
        'key','requests',
        'label','الطلبات التقنية',
        'value',(select count(*)::text from platform_technical.technical_service_requests),
        'status','ready'
      ),
      jsonb_build_object(
        'key','maintenance',
        'label','نوافذ الصيانة',
        'value',(select count(*)::text from platform_technical.maintenance_windows),
        'status','ready'
      ),
      jsonb_build_object(
        'key','health',
        'label','Health Checks',
        'value',(select count(*)::text from platform_technical.health_checks),
        'status','ready'
      ),
      jsonb_build_object(
        'key','audit',
        'label','Audit Events',
        'value',(select count(*)::text from platform_technical.audit_events),
        'status','ready'
      )
    ),
    'requests', coalesce((
      select jsonb_agg(to_jsonb(x) order by x.created_at desc)
      from (
        select
          id,
          service_type,
          action_type,
          title,
          description,
          status,
          approval_status,
          risk_level,
          requested_at as created_at,
          scheduled_for
        from platform_technical.technical_service_requests
        order by requested_at desc
        limit 20
      ) x
    ), '[]'::jsonb),
    'maintenance_windows', coalesce((
      select jsonb_agg(to_jsonb(x) order by x.starts_at desc)
      from (
        select
          id,
          title,
          message_ar,
          starts_at,
          ends_at,
          affected_surfaces,
          status,
          created_at
        from platform_technical.maintenance_windows
        order by starts_at desc
        limit 20
      ) x
    ), '[]'::jsonb),
    'backups', coalesce((
      select jsonb_agg(to_jsonb(x) order by x.created_at desc)
      from (
        select
          id,
          backup_kind,
          provider,
          backup_label,
          status,
          completed_at,
          checksum,
          created_at
        from platform_technical.backup_registry
        order by created_at desc
        limit 20
      ) x
    ), '[]'::jsonb),
    'health_checks', coalesce((
      select jsonb_agg(to_jsonb(x) order by x.check_group, x.check_key)
      from (
        select
          check_key,
          check_group,
          label,
          status,
          details,
          last_checked_at,
          created_at
        from platform_technical.health_checks
        order by check_group, check_key
      ) x
    ), '[]'::jsonb),
    'releases', coalesce((
      select jsonb_agg(to_jsonb(x) order by x.created_at desc)
      from (
        select
          id,
          release_tag,
          git_commit_hash,
          deploy_url,
          status,
          created_at
        from platform_technical.release_records
        order by created_at desc
        limit 20
      ) x
    ), '[]'::jsonb),
    'audit_events', coalesce((
      select jsonb_agg(to_jsonb(x) order by x.created_at desc)
      from (
        select
          id,
          event_type,
          severity,
          message,
          created_at
        from platform_technical.audit_events
        order by created_at desc
        limit 40
      ) x
    ), '[]'::jsonb)
  ) into v_result;

  return v_result;
end;
$$;

grant execute on function public.rpc_platform_technical_services_dashboard_v1() to authenticated;

commit;

select
  'platform_technical_dashboard_rpc_created_at_order_hotfix_applied' as section,
  true as dashboard_rpc_replaced,
  false as table_ddl,
  false as rls_change,
  false as runtime_auth_weakened,
  false as backup_restore_execution,
  false as maintenance_mode_global_activation,
  false as production_approved;
