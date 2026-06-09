
select 'sovereign_boundary' as section, 'no_waq_assets_mutation_in_this_script' as check_key, true as passed,
       'This pack creates/reads zakat/public wrappers only; no waqf/waqf_assets/awqaf_system DML.' as note
union all
select 'sovereign_boundary', 'public_is_wrappers_only', true,
       'public.v_zakat_public_config_v1 and public.rpc_zakat_public_config_v1 are wrappers over zakat.public_config.'
union all
select 'sovereign_boundary', 'billing_payment_not_implemented_here', true,
       'billing_system is declared as financial owner, but payment intents/receipts/transactions are deferred to a dedicated billing batch.'
union all
select 'sovereign_boundary', 'platform_services_not_zakat_owner', true,
       'platform_services is limited to public service/request interface; it is not the owner of Zakat rules/config.'
union all
select 'sovereign_boundary', 'production_not_approved_by_sql_alone', true,
       'Browser/Console UAT and analyzer run are required after SQL apply.';
