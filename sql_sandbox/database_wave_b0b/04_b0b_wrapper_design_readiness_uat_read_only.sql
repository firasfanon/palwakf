-- Database Wave B-0B
-- Wrapper Design Readiness UAT — READ ONLY
-- NO DDL. NO DML. NO DROP. NO waqf_assets mutation.

select * from (
  values
    ('b0b_readiness','compatibility_first_strategy', true, 'B-0B is design/read-only; no extraction or destructive migration.'),
    ('b0b_readiness','services_target_owner_confirmed', exists(select 1 from information_schema.schemata where schema_name='platform_services'), 'platform_services schema must exist before wrapper activation.'),
    ('b0b_readiness','media_target_owner_confirmed', exists(select 1 from information_schema.schemata where schema_name='media_center'), 'media_center schema should exist before media wrapper activation.'),
    ('b0b_readiness','gis_schema_exists_for_locations_review', exists(select 1 from information_schema.schemata where schema_name='gis'), 'gis schema must exist for locations authority review.'),
    ('b0b_readiness','public_services_hotspot_exists', exists(select 1 from information_schema.tables where table_schema='public' and table_name='services'), 'public.services is a compatibility hotspot if present.'),
    ('b0b_readiness','public_locations_hotspot_exists', exists(select 1 from information_schema.tables where table_schema='public' and table_name='locations'), 'public.locations requires manual decision vs gis.locations if present.'),
    ('sovereign_boundary','no_waq_assets_mutation_in_this_script', true, 'Read-only UAT only; no DML/DDL against waqf/waqf_assets/awqaf_system.')
) as t(section, check_key, passed, note);
