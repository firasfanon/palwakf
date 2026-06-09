
-- Read-only UAT for Zakat domain ownership realignment.
select 'zakat_domain_presence' as section, 'schema.zakat' as contract_name,
       exists(select 1 from information_schema.schemata where schema_name='zakat') as passed
union all
select 'zakat_domain_presence', 'table.zakat.public_config',
       exists(select 1 from information_schema.tables where table_schema='zakat' and table_name='public_config')
union all
select 'zakat_domain_presence', 'view.public.v_zakat_public_config_v1',
       exists(select 1 from information_schema.views where table_schema='public' and table_name='v_zakat_public_config_v1')
union all
select 'zakat_domain_presence', 'rpc.public.rpc_zakat_public_config_v1',
       exists(select 1 from information_schema.routines where routine_schema='public' and routine_name='rpc_zakat_public_config_v1');

select 'zakat_public_config_payload' as section,
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
       source_owner,
       billing_owner,
       billing_integration_mode,
       is_runtime_official
from public.v_zakat_public_config_v1;

select 'zakat_public_config_gate' as section,
       case
         when exists(select 1 from public.v_zakat_public_config_v1 where source_owner='zakat' and billing_owner='billing_system' and is_runtime_official is true)
         then 'ZAKAT_SCHEMA_WRAPPER_READY_BROWSER_UAT_REQUIRED'
         else 'ZAKAT_SCHEMA_WRAPPER_BLOCKED'
       end as decision;
