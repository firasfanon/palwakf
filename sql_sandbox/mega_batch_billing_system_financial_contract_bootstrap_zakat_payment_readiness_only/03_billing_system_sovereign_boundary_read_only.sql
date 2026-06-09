-- Billing System Financial Contract Bootstrap + Zakat Payment Readiness Only
-- 03 SOVEREIGN BOUNDARY READ-ONLY — ROOT FIX 2026-05-22
-- This script intentionally avoids every direct billing_system.* relation reference.
-- It only reads pg_catalog and the public readiness wrapper through guarded dynamic XML.

with catalog_state as (
  select
    exists(select 1 from pg_namespace where nspname = 'billing_system') as billing_schema_present,
    exists(select 1 from pg_namespace where nspname = 'zakat') as zakat_schema_present,
    exists (
      select 1
      from pg_class c
      join pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public'
        and c.relname = 'v_billing_zakat_payment_readiness_v1'
        and c.relkind in ('v','m')
    ) as readiness_view_present,
    exists (
      select 1
      from pg_proc p
      join pg_namespace n on n.oid = p.pronamespace
      where n.nspname = 'public'
        and p.proname = 'rpc_billing_zakat_payment_readiness_v1'
    ) as readiness_rpc_present
), readiness_xml as (
  select
    case
      when readiness_view_present then query_to_xml(
        'select payment_workflow_enabled, payment_gateway_enabled, receipt_issuance_enabled, transaction_posting_enabled, readiness_status, billing_owner_schema from public.v_billing_zakat_payment_readiness_v1 limit 1',
        false, false, ''
      )
      else null::xml
    end as x,
    *
  from catalog_state
), readiness_flags as (
  select
    billing_schema_present,
    zakat_schema_present,
    readiness_view_present,
    readiness_rpc_present,
    coalesce(nullif((xpath('/table/row/payment_workflow_enabled/text()', x))[1]::text, '')::boolean, true) as payment_workflow_enabled,
    coalesce(nullif((xpath('/table/row/payment_gateway_enabled/text()', x))[1]::text, '')::boolean, true) as payment_gateway_enabled,
    coalesce(nullif((xpath('/table/row/receipt_issuance_enabled/text()', x))[1]::text, '')::boolean, true) as receipt_issuance_enabled,
    coalesce(nullif((xpath('/table/row/transaction_posting_enabled/text()', x))[1]::text, '')::boolean, true) as transaction_posting_enabled,
    nullif((xpath('/table/row/readiness_status/text()', x))[1]::text, '') as readiness_status,
    nullif((xpath('/table/row/billing_owner_schema/text()', x))[1]::text, '') as billing_owner_schema
  from readiness_xml
), boundary as (
  select
    'no_waq_assets_mutation_in_this_script'::text as check_key,
    true as passed,
    'Read-only catalog/wrapper checks only; no waqf/waqf_assets/awqaf_system DML.'::text as note
  union all
  select
    'public_is_wrappers_only',
    readiness_view_present and readiness_rpc_present,
    'public exposes readiness view/RPC only; it is not financial sovereign storage.'
  from readiness_flags
  union all
  select
    'billing_owner_declared',
    billing_owner_schema = 'billing_system',
    'Readiness wrapper declares billing_system as the financial owner.'
  from readiness_flags
  union all
  select
    'billing_schema_catalog_presence',
    billing_schema_present,
    'billing_system schema presence through pg_catalog only. If false while payload exists, rerun apply script 01 in the same database project.'
  from readiness_flags
  union all
  select
    'zakat_remains_operational_owner',
    zakat_schema_present,
    'zakat remains operational owner for Zakat rules/config.'
  from readiness_flags
  union all
  select
    'payment_workflow_not_enabled',
    not payment_workflow_enabled
    and not payment_gateway_enabled
    and not receipt_issuance_enabled
    and not transaction_posting_enabled,
    'Payment, gateway, receipt issuance, and transaction posting must remain disabled in readiness-only mode.'
  from readiness_flags
  union all
  select
    'readiness_only_status',
    readiness_status = 'readiness_only',
    'The wrapper must remain readiness_only until a dedicated billing production batch is approved.'
  from readiness_flags
  union all
  select
    'production_financial_approval_not_granted',
    true,
    'This bootstrap/retest does not approve production financial operations.'
)
select 'sovereign_boundary' as section, check_key, passed, note
from boundary;
