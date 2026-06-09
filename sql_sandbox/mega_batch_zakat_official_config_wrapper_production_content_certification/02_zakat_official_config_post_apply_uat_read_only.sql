-- Read-only UAT after applying official Zakat config wrapper.

select
  'zakat_official_config_presence' as section,
  'platform_services.zakat_public_config' as contract_name,
  to_regclass('platform_services.zakat_public_config') is not null as passed
union all
select
  'zakat_official_config_presence',
  'public.v_zakat_public_config_v1',
  to_regclass('public.v_zakat_public_config_v1') is not null
union all
select
  'zakat_official_config_presence',
  'public.rpc_zakat_public_config_v1',
  exists (
    select 1 from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname = 'rpc_zakat_public_config_v1'
  );

select
  'zakat_official_config_runtime_values' as section,
  count(*) as row_count,
  min(gold_nisab_grams) as gold_nisab_grams,
  min(gold_gram_price_ils) as gold_gram_price_ils,
  min(agriculture_nisab_kg) as agriculture_nisab_kg,
  min(cash_and_trade_rate) as cash_and_trade_rate,
  min(irrigated_agriculture_rate) as irrigated_agriculture_rate,
  min(rain_agriculture_rate) as rain_agriculture_rate,
  bool_and(is_runtime_official) as official_runtime_source
from public.v_zakat_public_config_v1;

select
  'zakat_official_config_gate_decision' as section,
  case
    when (select count(*) from public.v_zakat_public_config_v1) = 1
      then 'ZAKAT_OFFICIAL_CONFIG_WRAPPER_SQL_PASSED_BROWSER_UAT_REQUIRED'
    else 'ZAKAT_OFFICIAL_CONFIG_WRAPPER_SQL_BLOCKED'
  end as decision;
