
-- Mega Batch — Zakat Domain Ownership Realignment + Billing Integration Contract
-- APPLY SCRIPT
-- Final ownership:
--   zakat          = operational Zakat rules/config/guidance owner
--   billing_system = financial/payment/receipt/transaction owner
--   platform_services = public service/request interface only
--   public         = wrappers/RPC/views only

begin;

create schema if not exists zakat;

create table if not exists zakat.public_config (
  id bigserial primary key,
  config_key text not null default 'default',
  status text not null default 'active' check (status in ('draft','active','archived')),
  gold_nisab_grams numeric not null default 85,
  gold_gram_price_ils numeric not null default 180,
  agriculture_nisab_kg numeric not null default 653,
  cash_and_trade_rate numeric not null default 0.025,
  irrigated_agriculture_rate numeric not null default 0.05,
  rain_agriculture_rate numeric not null default 0.10,
  currency_code text not null default 'ILS',
  source_label_ar text not null default 'إعدادات الزكاة الرسمية - مصدر تشغيلي ضمن schema zakat',
  official_source_ar text,
  source_reference_url text,
  billing_integration_mode text not null default 'billing_system_contract_only',
  effective_from timestamptz not null default now(),
  effective_to timestamptz,
  notes_ar text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists ux_zakat_public_config_one_active_default
  on zakat.public_config(config_key)
  where status = 'active' and effective_to is null;

insert into zakat.public_config (
  config_key,
  status,
  gold_nisab_grams,
  gold_gram_price_ils,
  agriculture_nisab_kg,
  cash_and_trade_rate,
  irrigated_agriculture_rate,
  rain_agriculture_rate,
  currency_code,
  source_label_ar,
  official_source_ar,
  billing_integration_mode,
  notes_ar,
  metadata
)
select
  'default',
  'active',
  85,
  180,
  653,
  0.025,
  0.05,
  0.10,
  'ILS',
  'إعدادات الزكاة الرسمية - مصدر تشغيلي ضمن schema zakat',
  'قابل للاستبدال بمرجع شرعي/إداري معتمد عبر إدارة الزكاة',
  'billing_system_contract_only',
  'Seed تشغيلي أولي لضمان أن public wrapper يقرأ من schema zakat لا من platform_services. لا يفعّل الدفع ولا يصدر إيصالات.',
  jsonb_build_object(
    'batch', 'mega_batch_zakat_domain_ownership_realignment_billing_integration_contract_2026_05_22',
    'owner', 'zakat',
    'billing_owner', 'billing_system',
    'platform_services_role', 'public_service_requests_only',
    'public_role', 'wrappers_rpc_views_only'
  )
where not exists (
  select 1
  from zakat.public_config
  where config_key = 'default'
    and status = 'active'
    and effective_to is null
);

-- If the superseded platform_services table exists and contains a config,
-- copy the first active row into zakat only when zakat has no active default.
do $$
begin
  if exists (
    select 1
    from information_schema.tables
    where table_schema = 'platform_services'
      and table_name = 'zakat_public_config'
  ) and not exists (
    select 1 from zakat.public_config
    where config_key = 'default' and status = 'active' and effective_to is null
  ) then
    execute $copy$
      insert into zakat.public_config (
        config_key,
        status,
        gold_nisab_grams,
        gold_gram_price_ils,
        agriculture_nisab_kg,
        cash_and_trade_rate,
        irrigated_agriculture_rate,
        rain_agriculture_rate,
        currency_code,
        source_label_ar,
        billing_integration_mode,
        notes_ar,
        metadata
      )
      select
        'default',
        coalesce(status, 'active'),
        coalesce(gold_nisab_grams, 85),
        coalesce(gold_gram_price_ils, 180),
        coalesce(agriculture_nisab_kg, 653),
        coalesce(cash_and_trade_rate, 0.025),
        coalesce(irrigated_agriculture_rate, 0.05),
        coalesce(rain_agriculture_rate, 0.10),
        coalesce(currency_code, 'ILS'),
        'إعدادات الزكاة الرسمية - منقولة إلى schema zakat بعد realignment',
        'billing_system_contract_only',
        'Migrated from superseded platform_services.zakat_public_config if present.',
        jsonb_build_object('migrated_from', 'platform_services.zakat_public_config', 'owner', 'zakat')
      from platform_services.zakat_public_config
      order by coalesce(effective_from, now()) desc
      limit 1
    $copy$;
  end if;
end $$;

create or replace view public.v_zakat_public_config_v1 as
select
  id,
  config_key,
  status,
  gold_nisab_grams,
  gold_gram_price_ils,
  agriculture_nisab_kg,
  cash_and_trade_rate,
  irrigated_agriculture_rate,
  rain_agriculture_rate,
  currency_code,
  'zakat.public_config'::text as source,
  source_label_ar,
  true::boolean as is_runtime_official,
  effective_from,
  notes_ar,
  'zakat'::text as source_schema_name,
  'zakat'::text as source_owner,
  'billing_system'::text as billing_owner,
  billing_integration_mode,
  'public.v_zakat_public_config_v1'::text as public_contract
from zakat.public_config
where status = 'active'
  and effective_to is null
order by effective_from desc
limit 1;

create or replace function public.rpc_zakat_public_config_v1()
returns table (
  id bigint,
  config_key text,
  status text,
  gold_nisab_grams numeric,
  gold_gram_price_ils numeric,
  agriculture_nisab_kg numeric,
  cash_and_trade_rate numeric,
  irrigated_agriculture_rate numeric,
  rain_agriculture_rate numeric,
  currency_code text,
  source text,
  source_label_ar text,
  is_runtime_official boolean,
  effective_from timestamptz,
  notes_ar text,
  source_schema_name text,
  source_owner text,
  billing_owner text,
  billing_integration_mode text,
  public_contract text
)
language sql
stable
security definer
set search_path = public, zakat
as $$
  select
    id,
    config_key,
    status,
    gold_nisab_grams,
    gold_gram_price_ils,
    agriculture_nisab_kg,
    cash_and_trade_rate,
    irrigated_agriculture_rate,
    rain_agriculture_rate,
    currency_code,
    source,
    source_label_ar,
    is_runtime_official,
    effective_from,
    notes_ar,
    source_schema_name,
    source_owner,
    billing_owner,
    billing_integration_mode,
    public_contract
  from public.v_zakat_public_config_v1
$$;

create or replace view public.v_zakat_billing_integration_contract_v1 as
select
  'zakat'::text as zakat_operational_owner,
  'billing_system'::text as financial_owner,
  'platform_services'::text as public_service_interface_owner,
  'public'::text as public_surface_owner,
  false::boolean as payment_workflow_enabled_by_this_pack,
  'billing integration contract only; payment intents/receipts/transactions must be implemented in a dedicated billing mega batch'::text as decision;

comment on schema zakat is 'Operational Zakat domain owner for PalWakf: config/rules/guidance/campaigns. Financial events belong to billing_system.';
comment on table zakat.public_config is 'Active public Zakat configuration owned by zakat schema; exposed through public.v_zakat_public_config_v1 only.';
comment on view public.v_zakat_public_config_v1 is 'Read-only public wrapper over zakat.public_config. Public is not the owner.';
comment on function public.rpc_zakat_public_config_v1() is 'Read-only public RPC wrapper over zakat.public_config.';

commit;
