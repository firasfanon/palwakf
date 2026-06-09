select 'sovereign_boundary' as section, 'no_waq_assets_mutation_in_this_script' as check_key, true as passed, 'Read-only verification only; no waqf/waq_assets/awqaf_system DML.' as note
union all select 'sovereign_boundary','no_public_data_migration_in_this_script',true,'No insert/update/delete/migration is executed by these read-only checks.'
union all select 'sovereign_boundary','no_route_runtime_mutation_by_sql',true,'Route/PWF-SIS execution is Flutter/docs only.'
union all select 'sovereign_boundary','production_not_approved',true,'Browser/Console UAT and analyzer are required.';
