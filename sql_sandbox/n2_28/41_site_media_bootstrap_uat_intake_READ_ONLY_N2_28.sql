-- N2.28 READ ONLY
select 'schema' as section, 'site_content_schema_exists' as check_key,
       (to_regnamespace('site_content') is not null) as passed,
       'site_content schema exists if bootstrap was applied' as note
union all
select 'schema', 'media_center_schema_exists',
       (to_regnamespace('media_center') is not null),
       'media_center schema exists if bootstrap was applied'
union all
select 'sovereign_boundary','no_waq_assets_mutation_in_this_script', true,
       'Read-only UAT only; no waqf/waq_assets/awqaf_system DML.';
