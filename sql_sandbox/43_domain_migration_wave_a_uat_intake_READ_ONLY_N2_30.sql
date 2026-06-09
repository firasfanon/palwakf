-- N2.30 read-only UAT intake
select 'inventory_contract' as section, 'schema_inventory_decisions_exists' as check_key,
       to_regclass('platform.schema_inventory_decisions') is not null as passed,
       'Inventory decision table must exist.' as note
union all
select 'domain_program', 'site_content_schema_exists', exists(select 1 from information_schema.schemata where schema_name='site_content'), 'site_content schema exists'
union all
select 'domain_program', 'media_center_schema_exists', exists(select 1 from information_schema.schemata where schema_name='media_center'), 'media_center schema exists'
union all
select 'sovereign_boundary', 'no_waq_assets_mutation_in_this_script', true, 'Read-only UAT only; no waqf/waqf_assets/awqaf_system DML.';
