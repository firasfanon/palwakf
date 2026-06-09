-- Database Wave B-0A
-- Cross-schema readiness inventory for system-of-systems ownership.
-- READ ONLY. No DDL. No DML. No waqf_assets mutation.

with expected_schemas(schema_name, owner_system, sensitivity_level, expected_role) as (
  values
    ('platform','platform_core','high','registry_rbac_access_audit_shell'),
    ('platform_services','service_center','medium','service_forms_requests_workflow'),
    ('platform_content','platform_content','medium','generic_cross-platform_content'),
    ('media_center','media_center','medium','target_media_editorial_owner'),
    ('gis','mustakshif_gis','high','spatial_authority'),
    ('waqf','waqf_assets','critical','sovereign_waqf_assets_core'),
    ('awqaf_system','awqaf_system','critical','awqaf_administrative_system'),
    ('cases','cases','critical','legal_cases'),
    ('billing_system','billing_system','critical','payments_billing'),
    ('assistant','assistant','high','knowledge_assistant_scope'),
    ('tasks','tasks','medium','operational_tasks')
),
schema_objects as (
  select
    n.nspname as schema_name,
    count(*) filter (where c.relkind in ('r','p'))::int as table_count,
    count(*) filter (where c.relkind = 'v')::int as view_count,
    count(*) filter (where c.relkind = 'm')::int as materialized_view_count,
    count(*) filter (where c.relkind = 'f')::int as foreign_table_count
  from pg_namespace n
  left join pg_class c on c.relnamespace = n.oid and c.relkind in ('r','p','v','m','f')
  where n.nspname in (select schema_name from expected_schemas)
  group by n.nspname
),
routines as (
  select
    routine_schema as schema_name,
    count(*)::int as routine_count
  from information_schema.routines
  where routine_schema in (select schema_name from expected_schemas)
  group by routine_schema
),
public_wrappers as (
  select
    case
      when routine_name ilike '%service%' then 'platform_services'
      when routine_name ilike '%media%' or routine_name ilike '%news%' or routine_name ilike '%announcement%' then 'media_center'
      when routine_name ilike '%gis%' or routine_name ilike '%location%' then 'gis'
      when routine_name ilike '%waqf%' or routine_name ilike '%asset%' then 'waqf'
      when routine_name ilike '%case%' then 'cases'
      when routine_name ilike '%billing%' or routine_name ilike '%payment%' then 'billing_system'
      else 'unresolved'
    end as inferred_owner_system,
    count(*)::int as public_rpc_count
  from information_schema.routines
  where routine_schema = 'public'
  group by 1
)
select
  'cross_schema_readiness' as section,
  e.schema_name,
  e.owner_system,
  e.sensitivity_level,
  e.expected_role,
  (to_regnamespace(e.schema_name) is not null) as schema_exists,
  coalesce(o.table_count, 0) as table_count,
  coalesce(o.view_count, 0) as view_count,
  coalesce(o.materialized_view_count, 0) as materialized_view_count,
  coalesce(o.foreign_table_count, 0) as foreign_table_count,
  coalesce(r.routine_count, 0) as schema_routine_count,
  coalesce(pw.public_rpc_count, 0) as inferred_public_rpc_count,
  case
    when to_regnamespace(e.schema_name) is null and e.schema_name in ('media_center','cases','billing_system','assistant','tasks') then 'schema_missing_or_not_bootstrapped_review'
    when e.sensitivity_level = 'critical' then 'read_only_boundary_required'
    when e.schema_name = 'media_center' then 'target_owner_for_media_public_legacy'
    else 'ownership_boundary_present_or_review'
  end as readiness_note
from expected_schemas e
left join schema_objects o on o.schema_name = e.schema_name
left join routines r on r.schema_name = e.schema_name
left join public_wrappers pw on pw.inferred_owner_system = e.owner_system or (e.schema_name = pw.inferred_owner_system)
order by e.sensitivity_level desc, e.schema_name;
