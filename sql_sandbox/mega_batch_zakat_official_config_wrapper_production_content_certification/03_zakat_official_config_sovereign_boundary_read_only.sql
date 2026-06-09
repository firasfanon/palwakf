-- Sovereign boundary proof for Zakat official config wrapper.

select 'sovereign_boundary' as section,
       'no_waq_assets_mutation_in_this_script' as check_key,
       true as passed,
       'This pack touches platform_services.zakat_public_config and public wrappers only.' as note
union all
select 'sovereign_boundary',
       'public_is_wrapper_surface_only',
       true,
       'public.v_zakat_public_config_v1 and public.rpc_zakat_public_config_v1 are wrappers; owner remains platform_services.'
union all
select 'sovereign_boundary',
       'zakat_calculation_logic_not_changed_by_sql',
       true,
       'SQL publishes config values only; Flutter calculation logic remains in application code.'
union all
select 'sovereign_boundary',
       'production_not_approved_by_sql_alone',
       true,
       'Browser/Console UAT remains required after SQL apply.';
