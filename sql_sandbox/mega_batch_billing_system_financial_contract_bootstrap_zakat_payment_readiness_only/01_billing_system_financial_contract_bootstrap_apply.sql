-- Mega Batch: Billing System Financial Contract Bootstrap + Zakat Payment Readiness Only
-- Scope: contract foundation only. No payment gateway, no receipts, no transaction posting.

begin;

create schema if not exists billing_system;

create table if not exists billing_system.financial_contract_registry (
  contract_key text primary key,
  owner_schema text not null default 'billing_system',
  domain_key text not null,
  contract_name_ar text not null,
  contract_name_en text not null,
  readiness_status text not null default 'readiness_only'
    check (readiness_status in ('draft', 'readiness_only', 'uat_required', 'certified', 'deprecated')),
  is_runtime_enabled boolean not null default false,
  is_payment_enabled boolean not null default false,
  is_receipt_enabled boolean not null default false,
  is_transaction_posting_enabled boolean not null default false,
  notes_ar text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists billing_system.payment_intent_contracts (
  intent_contract_key text primary key,
  source_domain text not null,
  source_schema text not null,
  source_object text not null,
  public_wrapper text,
  readiness_status text not null default 'readiness_only'
    check (readiness_status in ('draft', 'readiness_only', 'uat_required', 'certified', 'deprecated')),
  payment_gateway_enabled boolean not null default false,
  can_create_payment_intent boolean not null default false,
  can_collect_money boolean not null default false,
  can_post_transaction boolean not null default false,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists billing_system.receipt_contracts (
  receipt_contract_key text primary key,
  source_domain text not null,
  receipt_series_key text not null,
  readiness_status text not null default 'readiness_only'
    check (readiness_status in ('draft', 'readiness_only', 'uat_required', 'certified', 'deprecated')),
  can_issue_official_receipt boolean not null default false,
  can_cancel_receipt boolean not null default false,
  can_refund boolean not null default false,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists billing_system.zakat_payment_readiness_bridge (
  bridge_key text primary key,
  zakat_config_source text not null default 'zakat.public_config',
  zakat_public_config_wrapper text not null default 'public.v_zakat_public_config_v1',
  billing_owner_schema text not null default 'billing_system',
  platform_services_role text not null default 'public request/service interface only',
  readiness_status text not null default 'readiness_only'
    check (readiness_status in ('draft', 'readiness_only', 'uat_required', 'certified', 'deprecated')),
  payment_workflow_enabled boolean not null default false,
  payment_gateway_enabled boolean not null default false,
  receipt_issuance_enabled boolean not null default false,
  transaction_posting_enabled boolean not null default false,
  notes_ar text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table billing_system.financial_contract_registry enable row level security;
alter table billing_system.payment_intent_contracts enable row level security;
alter table billing_system.receipt_contracts enable row level security;
alter table billing_system.zakat_payment_readiness_bridge enable row level security;

insert into billing_system.financial_contract_registry (
  contract_key,
  domain_key,
  contract_name_ar,
  contract_name_en,
  readiness_status,
  is_runtime_enabled,
  is_payment_enabled,
  is_receipt_enabled,
  is_transaction_posting_enabled,
  notes_ar,
  metadata
) values
  (
    'billing_system_foundation_v1',
    'billing_system',
    'عقد تأسيس النظام المالي',
    'Billing system foundation contract',
    'readiness_only',
    false,
    false,
    false,
    false,
    'تأسيس عقد مالي فقط دون دفع فعلي أو إيصالات أو قيود.',
    jsonb_build_object('scope', 'contract_bootstrap_only')
  ),
  (
    'zakat_payment_readiness_v1',
    'zakat',
    'عقد جاهزية ربط الزكاة بالدفع',
    'Zakat payment readiness contract',
    'readiness_only',
    false,
    false,
    false,
    false,
    'الزكاة جاهزة من ناحية المصدر التشغيلي، لكن الدفع مؤجل لدفعة مالية مستقلة.',
    jsonb_build_object('zakat_owner', 'zakat', 'financial_owner', 'billing_system')
  )
on conflict (contract_key) do update set
  owner_schema = excluded.owner_schema,
  domain_key = excluded.domain_key,
  contract_name_ar = excluded.contract_name_ar,
  contract_name_en = excluded.contract_name_en,
  readiness_status = excluded.readiness_status,
  is_runtime_enabled = excluded.is_runtime_enabled,
  is_payment_enabled = excluded.is_payment_enabled,
  is_receipt_enabled = excluded.is_receipt_enabled,
  is_transaction_posting_enabled = excluded.is_transaction_posting_enabled,
  notes_ar = excluded.notes_ar,
  metadata = excluded.metadata,
  updated_at = now();

insert into billing_system.payment_intent_contracts (
  intent_contract_key,
  source_domain,
  source_schema,
  source_object,
  public_wrapper,
  readiness_status,
  payment_gateway_enabled,
  can_create_payment_intent,
  can_collect_money,
  can_post_transaction,
  metadata
) values (
  'zakat_public_payment_intent_readiness_v1',
  'zakat',
  'zakat',
  'public_config',
  'public.v_zakat_public_config_v1',
  'readiness_only',
  false,
  false,
  false,
  false,
  jsonb_build_object(
    'note', 'readiness only; no payment intent creation is enabled',
    'future_owner', 'billing_system'
  )
)
on conflict (intent_contract_key) do update set
  source_domain = excluded.source_domain,
  source_schema = excluded.source_schema,
  source_object = excluded.source_object,
  public_wrapper = excluded.public_wrapper,
  readiness_status = excluded.readiness_status,
  payment_gateway_enabled = excluded.payment_gateway_enabled,
  can_create_payment_intent = excluded.can_create_payment_intent,
  can_collect_money = excluded.can_collect_money,
  can_post_transaction = excluded.can_post_transaction,
  metadata = excluded.metadata,
  updated_at = now();

insert into billing_system.receipt_contracts (
  receipt_contract_key,
  source_domain,
  receipt_series_key,
  readiness_status,
  can_issue_official_receipt,
  can_cancel_receipt,
  can_refund,
  metadata
) values (
  'zakat_receipt_readiness_v1',
  'zakat',
  'ZAKAT-RECEIPT-FUTURE',
  'readiness_only',
  false,
  false,
  false,
  jsonb_build_object('note', 'receipt issuance is deferred to a dedicated billing batch')
)
on conflict (receipt_contract_key) do update set
  source_domain = excluded.source_domain,
  receipt_series_key = excluded.receipt_series_key,
  readiness_status = excluded.readiness_status,
  can_issue_official_receipt = excluded.can_issue_official_receipt,
  can_cancel_receipt = excluded.can_cancel_receipt,
  can_refund = excluded.can_refund,
  metadata = excluded.metadata,
  updated_at = now();

insert into billing_system.zakat_payment_readiness_bridge (
  bridge_key,
  readiness_status,
  payment_workflow_enabled,
  payment_gateway_enabled,
  receipt_issuance_enabled,
  transaction_posting_enabled,
  notes_ar,
  metadata
) values (
  'zakat_payment_readiness_bridge_v1',
  'readiness_only',
  false,
  false,
  false,
  false,
  'جسر جاهزية فقط بين نطاق الزكاة والنظام المالي؛ لا ينشئ دفعًا ولا إيصالات.',
  jsonb_build_object(
    'zakat_owner', 'zakat',
    'financial_owner', 'billing_system',
    'platform_services_role', 'public service/request interface only',
    'public_surface', 'wrappers/rpc/views only'
  )
)
on conflict (bridge_key) do update set
  readiness_status = excluded.readiness_status,
  payment_workflow_enabled = excluded.payment_workflow_enabled,
  payment_gateway_enabled = excluded.payment_gateway_enabled,
  receipt_issuance_enabled = excluded.receipt_issuance_enabled,
  transaction_posting_enabled = excluded.transaction_posting_enabled,
  notes_ar = excluded.notes_ar,
  metadata = excluded.metadata,
  updated_at = now();

create or replace view public.v_billing_zakat_payment_readiness_v1 as
select
  b.bridge_key,
  b.zakat_config_source,
  b.zakat_public_config_wrapper,
  b.billing_owner_schema,
  b.platform_services_role,
  b.readiness_status,
  b.payment_workflow_enabled,
  b.payment_gateway_enabled,
  b.receipt_issuance_enabled,
  b.transaction_posting_enabled,
  c.readiness_status as payment_intent_contract_status,
  r.readiness_status as receipt_contract_status,
  'public.v_billing_zakat_payment_readiness_v1'::text as compatibility_contract,
  b.updated_at
from billing_system.zakat_payment_readiness_bridge b
left join billing_system.payment_intent_contracts c
  on c.intent_contract_key = 'zakat_public_payment_intent_readiness_v1'
left join billing_system.receipt_contracts r
  on r.receipt_contract_key = 'zakat_receipt_readiness_v1'
where b.bridge_key = 'zakat_payment_readiness_bridge_v1';

create or replace function public.rpc_billing_zakat_payment_readiness_v1()
returns table (
  bridge_key text,
  zakat_config_source text,
  zakat_public_config_wrapper text,
  billing_owner_schema text,
  platform_services_role text,
  readiness_status text,
  payment_workflow_enabled boolean,
  payment_gateway_enabled boolean,
  receipt_issuance_enabled boolean,
  transaction_posting_enabled boolean,
  payment_intent_contract_status text,
  receipt_contract_status text,
  compatibility_contract text,
  updated_at timestamptz
)
language sql
stable
security definer
set search_path = public, billing_system
as $$
  select
    bridge_key,
    zakat_config_source,
    zakat_public_config_wrapper,
    billing_owner_schema,
    platform_services_role,
    readiness_status,
    payment_workflow_enabled,
    payment_gateway_enabled,
    receipt_issuance_enabled,
    transaction_posting_enabled,
    payment_intent_contract_status,
    receipt_contract_status,
    compatibility_contract,
    updated_at
  from public.v_billing_zakat_payment_readiness_v1;
$$;

grant usage on schema billing_system to anon, authenticated;
grant select on public.v_billing_zakat_payment_readiness_v1 to anon, authenticated;
grant execute on function public.rpc_billing_zakat_payment_readiness_v1() to anon, authenticated;

comment on schema billing_system is
  'PalWakf financial owner schema. Current pack is contract/readiness only; no payment workflow is enabled.';
comment on table billing_system.financial_contract_registry is
  'Non-transactional financial contract registry. Not a ledger.';
comment on table billing_system.payment_intent_contracts is
  'Payment-intent readiness contracts only. Does not store or create payment intents.';
comment on table billing_system.receipt_contracts is
  'Receipt readiness contracts only. Does not issue official receipts.';
comment on table billing_system.zakat_payment_readiness_bridge is
  'Readiness bridge between zakat operational owner and billing_system financial owner.';

commit;
