-- OPTIONAL SINGLE SAFE RETEST — NO billing_system.* relation references
-- Use this if old SQL Editor tabs still throw: ERROR 42P01 relation "billing_system" does not exist.
-- This script checks the readiness wrapper and pg_catalog only.

with catalog_state as (
  select
    exists(select 1 from pg_namespace where nspname='billing_system') as billing_schema_present,
    exists(select 1 from pg_namespace where nspname='zakat') as zakat_schema_present,
    exists (
      select 1 from pg_class c join pg_namespace n on n.oid=c.relnamespace
      where n.nspname='public' and c.relname='v_billing_zakat_payment_readiness_v1' and c.relkind in ('v','m')
    ) as readiness_view_present,
    exists (
      select 1 from pg_proc p join pg_namespace n on n.oid=p.pronamespace
      where n.nspname='public' and p.proname='rpc_billing_zakat_payment_readiness_v1'
    ) as readiness_rpc_present
), readiness_xml as (
  select
    *,
    case when readiness_view_present then query_to_xml(
      'select bridge_key, zakat_config_source, zakat_public_config_wrapper, billing_owner_schema, readiness_status, payment_workflow_enabled, payment_gateway_enabled, receipt_issuance_enabled, transaction_posting_enabled, payment_intent_contract_status, receipt_contract_status, compatibility_contract from public.v_billing_zakat_payment_readiness_v1 limit 1',
      false, false, ''
    ) else null::xml end as x
  from catalog_state
), payload as (
  select
    billing_schema_present,
    zakat_schema_present,
    readiness_view_present,
    readiness_rpc_present,
    nullif((xpath('/table/row/bridge_key/text()', x))[1]::text, '') as bridge_key,
    nullif((xpath('/table/row/zakat_config_source/text()', x))[1]::text, '') as zakat_config_source,
    nullif((xpath('/table/row/zakat_public_config_wrapper/text()', x))[1]::text, '') as zakat_public_config_wrapper,
    nullif((xpath('/table/row/billing_owner_schema/text()', x))[1]::text, '') as billing_owner_schema,
    nullif((xpath('/table/row/readiness_status/text()', x))[1]::text, '') as readiness_status,
    coalesce(nullif((xpath('/table/row/payment_workflow_enabled/text()', x))[1]::text, '')::boolean, true) as payment_workflow_enabled,
    coalesce(nullif((xpath('/table/row/payment_gateway_enabled/text()', x))[1]::text, '')::boolean, true) as payment_gateway_enabled,
    coalesce(nullif((xpath('/table/row/receipt_issuance_enabled/text()', x))[1]::text, '')::boolean, true) as receipt_issuance_enabled,
    coalesce(nullif((xpath('/table/row/transaction_posting_enabled/text()', x))[1]::text, '')::boolean, true) as transaction_posting_enabled,
    nullif((xpath('/table/row/payment_intent_contract_status/text()', x))[1]::text, '') as payment_intent_contract_status,
    nullif((xpath('/table/row/receipt_contract_status/text()', x))[1]::text, '') as receipt_contract_status,
    nullif((xpath('/table/row/compatibility_contract/text()', x))[1]::text, '') as compatibility_contract
  from readiness_xml
)
select
  'billing_safe_retest_payload' as section,
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
  compatibility_contract,
  billing_schema_present,
  zakat_schema_present,
  readiness_view_present,
  readiness_rpc_present
from payload;

with catalog_state as (
  select
    exists(select 1 from pg_namespace where nspname='billing_system') as billing_schema_present,
    exists(select 1 from pg_namespace where nspname='zakat') as zakat_schema_present,
    exists (
      select 1 from pg_class c join pg_namespace n on n.oid=c.relnamespace
      where n.nspname='public' and c.relname='v_billing_zakat_payment_readiness_v1' and c.relkind in ('v','m')
    ) as readiness_view_present,
    exists (
      select 1 from pg_proc p join pg_namespace n on n.oid=p.pronamespace
      where n.nspname='public' and p.proname='rpc_billing_zakat_payment_readiness_v1'
    ) as readiness_rpc_present
), readiness_xml as (
  select
    *,
    case when readiness_view_present then query_to_xml(
      'select billing_owner_schema, readiness_status, payment_workflow_enabled, payment_gateway_enabled, receipt_issuance_enabled, transaction_posting_enabled from public.v_billing_zakat_payment_readiness_v1 limit 1',
      false, false, ''
    ) else null::xml end as x
  from catalog_state
), gate as (
  select
    billing_schema_present,
    zakat_schema_present,
    readiness_view_present,
    readiness_rpc_present,
    nullif((xpath('/table/row/billing_owner_schema/text()', x))[1]::text, '') as billing_owner_schema,
    nullif((xpath('/table/row/readiness_status/text()', x))[1]::text, '') as readiness_status,
    coalesce(nullif((xpath('/table/row/payment_workflow_enabled/text()', x))[1]::text, '')::boolean, true) as payment_workflow_enabled,
    coalesce(nullif((xpath('/table/row/payment_gateway_enabled/text()', x))[1]::text, '')::boolean, true) as payment_gateway_enabled,
    coalesce(nullif((xpath('/table/row/receipt_issuance_enabled/text()', x))[1]::text, '')::boolean, true) as receipt_issuance_enabled,
    coalesce(nullif((xpath('/table/row/transaction_posting_enabled/text()', x))[1]::text, '')::boolean, true) as transaction_posting_enabled
  from readiness_xml
)
select
  'billing_safe_retest_gate' as section,
  case
    when readiness_view_present
     and readiness_rpc_present
     and billing_owner_schema = 'billing_system'
     and readiness_status = 'readiness_only'
     and not payment_workflow_enabled
     and not payment_gateway_enabled
     and not receipt_issuance_enabled
     and not transaction_posting_enabled
    then 'BILLING_READINESS_CONTRACT_PASSED_PAYMENT_WORKFLOW_DISABLED'
    else 'BILLING_READINESS_CONTRACT_REQUIRES_REVIEW'
  end as decision,
  'No direct billing_system relation references were used by this script.' as note
from gate;
