-- Mega Batch — Zakat Official Config Wrapper + Production Content Certification
-- Apply script: creates governed Zakat public config under platform_services
-- and exposes public read-only wrappers.

create schema if not exists platform_services;

create table if not exists platform_services.zakat_public_config (
  config_key text primary key default 'default',
  gold_nisab_grams numeric not null default 85,
  gold_gram_price_ils numeric not null default 180,
  agriculture_nisab_kg numeric not null default 653,
  cash_and_trade_rate numeric not null default 0.025,
  irrigated_agriculture_rate numeric not null default 0.05,
  rain_agriculture_rate numeric not null default 0.10,
  currency_code text not null default 'ILS',
  source_label_ar text not null default 'إعداد رسمي منشور للزكاة العامة',
  notes_ar text,
  is_published boolean not null default true,
  effective_from timestamptz not null default now(),
  effective_to timestamptz,
  updated_at timestamptz not null default now(),
  metadata jsonb not null default '{}'::jsonb,
  constraint zakat_public_config_key_default check (config_key = 'default'),
  constraint zakat_public_config_positive_values check (
    gold_nisab_grams > 0 and
    gold_gram_price_ils > 0 and
    agriculture_nisab_kg > 0 and
    cash_and_trade_rate > 0 and
    irrigated_agriculture_rate > 0 and
    rain_agriculture_rate > 0
  )
);

insert into platform_services.zakat_public_config (
  config_key,
  gold_nisab_grams,
  gold_gram_price_ils,
  agriculture_nisab_kg,
  cash_and_trade_rate,
  irrigated_agriculture_rate,
  rain_agriculture_rate,
  currency_code,
  source_label_ar,
  notes_ar,
  is_published,
  metadata
)
values (
  'default',
  85,
  180,
  653,
  0.025,
  0.05,
  0.10,
  'ILS',
  'إعداد رسمي منشور للزكاة العامة',
  'قيم النِّصاب والنسب منشورة كإعداد رسمي قابل للفحص عبر public.v_zakat_public_config_v1. يمكن تحديث سعر غرام الذهب من لوحة إدارة لاحقة دون تغيير منطق الصفحة.',
  true,
  jsonb_build_object(
    'seed_batch', 'mega_batch_zakat_official_config_wrapper_2026_05_22',
    'canonical_route', '/home/zakat',
    'owner', 'platform_services',
    'public_wrapper', 'public.v_zakat_public_config_v1'
  )
)
on conflict (config_key) do update
set
  gold_nisab_grams = excluded.gold_nisab_grams,
  gold_gram_price_ils = excluded.gold_gram_price_ils,
  agriculture_nisab_kg = excluded.agriculture_nisab_kg,
  cash_and_trade_rate = excluded.cash_and_trade_rate,
  irrigated_agriculture_rate = excluded.irrigated_agriculture_rate,
  rain_agriculture_rate = excluded.rain_agriculture_rate,
  currency_code = excluded.currency_code,
  source_label_ar = excluded.source_label_ar,
  notes_ar = excluded.notes_ar,
  is_published = excluded.is_published,
  updated_at = now(),
  metadata = platform_services.zakat_public_config.metadata || excluded.metadata;

create or replace view public.v_zakat_public_config_v1 as
select
  config_key,
  gold_nisab_grams,
  gold_gram_price_ils,
  agriculture_nisab_kg,
  cash_and_trade_rate,
  irrigated_agriculture_rate,
  rain_agriculture_rate,
  currency_code,
  source_label_ar,
  notes_ar,
  effective_from,
  effective_to,
  'public.v_zakat_public_config_v1'::text as source,
  true::boolean as is_runtime_official,
  metadata
from platform_services.zakat_public_config
where is_published is true
  and effective_from <= now()
  and (effective_to is null or effective_to > now())
order by effective_from desc
limit 1;

create or replace function public.rpc_zakat_public_config_v1()
returns jsonb
language sql
stable
security definer
set search_path = public, platform_services
as $$
  select coalesce((jsonb_agg(to_jsonb(v)))->0, '{}'::jsonb)
  from public.v_zakat_public_config_v1 v;
$$;

grant usage on schema platform_services to authenticated;
grant select on platform_services.zakat_public_config to authenticated;
grant select on public.v_zakat_public_config_v1 to anon, authenticated;
grant execute on function public.rpc_zakat_public_config_v1() to anon, authenticated;

notify pgrst, 'reload schema';
