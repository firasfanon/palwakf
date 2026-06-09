-- N2.16 Dynamic Registry Browser Evidence Read-only UAT
-- Safe/read-only; no DML.
select 'schema' as section, 'platform_schema_exists' as check_key,
       exists(select 1 from information_schema.schemata where schema_name = 'platform') as passed,
       'platform schema exists' as note
union all
select 'views','public_dynamic_views_exist',
       exists(select 1 from information_schema.views where table_schema='public' and table_name='v_platform_system_registry')
       and exists(select 1 from information_schema.views where table_schema='public' and table_name='v_platform_system_sections'),
       'public dynamic registry/sections views exist'
union all
select 'sovereign_boundary','no_waq_assets_mutation_in_this_script',true,
       'Read-only evidence only; no waqf/waq_assets/awqaf_system DML.';
