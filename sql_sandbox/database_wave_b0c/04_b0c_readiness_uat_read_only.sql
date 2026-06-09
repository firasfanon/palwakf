-- Database Wave B-0C — Runtime Dependency Validation
-- 04_b0c_readiness_uat_read_only.sql
-- Purpose: final read-only UAT checks for B-0C.
-- Read-only. No DDL/DML. No waqf_assets mutation.

select * from (values
  ('b0c_readiness','public_schema_exists', exists(select 1 from information_schema.schemata where schema_name='public'), 'public remains compatibility facade surface.'),
  ('b0c_readiness','platform_services_schema_exists', exists(select 1 from information_schema.schemata where schema_name='platform_services'), 'platform_services is service center owner target.'),
  ('b0c_readiness','media_center_schema_exists', exists(select 1 from information_schema.schemata where schema_name='media_center'), 'media_center is future media owner target; bootstrap maturity still separate.'),
  ('b0c_readiness','gis_schema_exists', exists(select 1 from information_schema.schemata where schema_name='gis'), 'gis is spatial authority target.'),
  ('b0c_readiness','locations_conflict_detectable', exists(select 1 from information_schema.tables where table_schema='public' and table_name='locations') and exists(select 1 from information_schema.tables where table_schema='gis' and table_name='locations'), 'If true, locations authority gate remains open.'),
  ('b0c_readiness','services_runtime_hotspot_detectable', exists(select 1 from information_schema.tables where table_schema='public' and table_name='services'), 'If true, runtime dependencies must be mapped before extraction.'),
  ('b0c_readiness','media_runtime_hotspot_detectable', exists(select 1 from information_schema.tables where table_schema='public' and table_name in ('news_articles','activities','announcements')), 'If true, media runtime dependencies must be mapped before extraction.'),
  ('sovereign_boundary','no_waq_assets_mutation_in_this_script', true, 'Read-only UAT only; this script does not mutate waqf/waqf_assets/awqaf_system.')
) as t(section, check_key, passed, note);
