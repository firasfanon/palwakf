-- Billing System Financial Contract Bootstrap + Zakat Payment Readiness Only
-- 02 UAT READ-ONLY — ROOT FIX 2026-05-22
-- Purpose: avoid ERROR 42P01 relation "billing_system" does not exist.
-- Rule: this script does NOT reference billing_system.* relations directly, does NOT use to_regclass('billing_system.*'),
-- and checks schema/table presence through pg_catalog only.

with expected_objects as (
  select * from (values
    ('schema'::text, 'billing_system'::text, null::text, null::text, 'billing_system financial owner schema'),
    ('table', 'billing_system.financial_contract_registry', 'billing_system', 'financial_contract_registry', 'contract registry table'),
    ('table', 'billing_system.payment_intent_contracts', 'billing_system', 'payment_intent_contracts', 'payment-intent contract table'),
    ('table', 'billing_system.receipt_contracts', 'billing_system', 'receipt_contracts', 'receipt contract table'),
    ('table', 'billing_system.zakat_payment_readiness_bridge', 'billing_system', 'zakat_payment_readiness_bridge', 'zakat readiness bridge'),
    ('view', 'public.v_billing_zakat_payment_readiness_v1', 'public', 'v_billing_zakat_payment_readiness_v1', 'public readiness wrapper')
  ) as v(object_type, contract_name, schema_name, object_name, note)
), catalog_presence as (
  select
    e.object_type,
    e.contract_name,
    case
      when e.object_type = 'schema' then exists (
        select 1 from pg_namespace n where n.nspname = e.contract_name
      )
      when e.object_type in ('table', 'view') then exists (
        select 1
        from pg_class c
        join pg_namespace n on n.oid = c.relnamespace
        where n.nspname = e.schema_name
          and c.relname = e.object_name
          and (
            (e.object_type = 'table' and c.relkind in ('r','p'))
            or (e.object_type = 'view' and c.relkind in ('v','m'))
          )
      )
      else false
    end as passed,
    e.note
  from expected_objects e
), rpc_presence as (
  select
    'rpc'::text as object_type,
    'public.rpc_billing_zakat_payment_readiness_v1()'::text as contract_name,
    exists (
      select 1
      from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public'
        and p.proname = 'rpc_billing_zakat_payment_readiness_v1'
    ) as passed,
    'public readiness RPC wrapper'::text as note
)
select 'billing_contract_presence' as section, object_type, contract_name, passed, note
from catalog_presence
union all
select 'billing_contract_presence', object_type, contract_name, passed, note
from rpc_presence
order by object_type, contract_name;

with catalog_counts as (
  select
    n.nspname || '.' || c.relname as check_key,
    case
      when c.reltuples < 0 then null::bigint
      else greatest(c.reltuples::bigint, 0)
    end as estimated_row_count,
    'catalog_estimate_only_no_relation_scan'::text as note
  from pg_class c
  join pg_namespace n on n.oid = c.relnamespace
  where n.nspname = 'billing_system'
    and c.relname in (
      'financial_contract_registry',
      'payment_intent_contracts',
      'receipt_contracts',
      'zakat_payment_readiness_bridge'
    )
    and c.relkind in ('r','p')
)
select 'billing_contract_catalog_counts' as section, check_key, estimated_row_count, note
from catalog_counts
union all
select
  'billing_contract_catalog_counts' as section,
  'billing_system.*' as check_key,
  null::bigint as estimated_row_count,
  'no billing_system table found through pg_catalog; if readiness payload exists, run 04 consolidated diagnostic before rerunning apply' as note
where not exists (select 1 from catalog_counts);

with readiness_view as (
  select exists (
    select 1
    from pg_class c
    join pg_namespace n on n.oid = c.relnamespace
    where n.nspname = 'public'
      and c.relname = 'v_billing_zakat_payment_readiness_v1'
      and c.relkind in ('v','m')
  ) as view_present
), readiness_xml as (
  select
    case
      when view_present then query_to_xml(
        'select bridge_key, zakat_config_source, zakat_public_config_wrapper, billing_owner_schema, readiness_status, payment_workflow_enabled, payment_gateway_enabled, receipt_issuance_enabled, transaction_posting_enabled, payment_intent_contract_status, receipt_contract_status, compatibility_contract from public.v_billing_zakat_payment_readiness_v1 limit 1',
        false, false, ''
      )
      else null::xml
    end as x,
    view_present
  from readiness_view
), payload as (
  select
    view_present,
    nullif((xpath('/table/row/bridge_key/text()', x))[1]::text, '') as bridge_key,
    nullif((xpath('/table/row/zakat_config_source/text()', x))[1]::text, '') as zakat_config_source,
    nullif((xpath('/table/row/zakat_public_config_wrapper/text()', x))[1]::text, '') as zakat_public_config_wrapper,
    nullif((xpath('/table/row/billing_owner_schema/text()', x))[1]::text, '') as billing_owner_schema,
    nullif((xpath('/table/row/readiness_status/text()', x))[1]::text, '') as readiness_status,
    coalesce(nullif((xpath('/table/row/payment_workflow_enabled/text()', x))[1]::text, '')::boolean, false) as payment_workflow_enabled,
    coalesce(nullif((xpath('/table/row/payment_gateway_enabled/text()', x))[1]::text, '')::boolean, false) as payment_gateway_enabled,
    coalesce(nullif((xpath('/table/row/receipt_issuance_enabled/text()', x))[1]::text, '')::boolean, false) as receipt_issuance_enabled,
    coalesce(nullif((xpath('/table/row/transaction_posting_enabled/text()', x))[1]::text, '')::boolean, false) as transaction_posting_enabled,
    nullif((xpath('/table/row/payment_intent_contract_status/text()', x))[1]::text, '') as payment_intent_contract_status,
    nullif((xpath('/table/row/receipt_contract_status/text()', x))[1]::text, '') as receipt_contract_status,
    nullif((xpath('/table/row/compatibility_contract/text()', x))[1]::text, '') as compatibility_contract
  from readiness_xml
)
select
  'zakat_payment_readiness_payload' as section,
  bridge_key,
  zakat_config_source,
  zakat_public_config_wrapper,
  billing_owner_schema,
  readiness_status,
  payment_workflow_enabled,
  payment_gateway_enabled,
  receipt_issuance_enabled,
  transaction_posting_enabled,
  payment_intent_contract_status,
  receipt_contract_status,
  compatibility_contract
from payload;

with readiness_xml as (
  select
    case
      when exists (
        select 1
        from pg_class c
        join pg_namespace n on n.oid = c.relnamespace
        where n.nspname = 'public'
          and c.relname = 'v_billing_zakat_payment_readiness_v1'
          and c.relkind in ('v','m')
      ) then query_to_xml(
        'select payment_workflow_enabled, payment_gateway_enabled, receipt_issuance_enabled, transaction_posting_enabled from public.v_billing_zakat_payment_readiness_v1 limit 1',
        false, false, ''
      )
      else null::xml
    end as x
), gate as (
  select
    coalesce(nullif((xpath('/table/row/payment_workflow_enabled/text()', x))[1]::text, '')::boolean, true) as payment_workflow_enabled,
    coalesce(nullif((xpath('/table/row/payment_gateway_enabled/text()', x))[1]::text, '')::boolean, true) as payment_gateway_enabled,
    coalesce(nullif((xpath('/table/row/receipt_issuance_enabled/text()', x))[1]::text, '')::boolean, true) as receipt_issuance_enabled,
    coalesce(nullif((xpath('/table/row/transaction_posting_enabled/text()', x))[1]::text, '')::boolean, true) as transaction_posting_enabled
  from readiness_xml
)
select
  'zakat_payment_readiness_gate' as section,
  case
    when not payment_workflow_enabled
     and not payment_gateway_enabled
     and not receipt_issuance_enabled
     and not transaction_posting_enabled
    then 'BILLING_CONTRACT_BOOTSTRAP_READY_PAYMENT_WORKFLOW_DISABLED'
    else 'BILLING_CONTRACT_BOOTSTRAP_REQUIRES_REVIEW'
  end as decision
from gate;
