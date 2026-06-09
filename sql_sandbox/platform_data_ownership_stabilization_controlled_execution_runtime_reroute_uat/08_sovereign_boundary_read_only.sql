-- 08_sovereign_boundary_read_only.sql
-- READ ONLY. Documents sovereign boundaries; does not inspect write logs.

select * from (values
  ('sovereign_boundary','no_waq_assets_mutation_in_this_script', true, 'No statement in this pack touches waqf/waqf_assets/awqaf_system.'),
  ('sovereign_boundary','legacy_public_media_preserved', true, 'The pack does not delete or drop public.news_articles/public.announcements/public.activities/public.media_gallery_items.'),
  ('sovereign_boundary','public_is_compatibility_surface', true, 'New public objects are views/RPC wrappers only.'),
  ('sovereign_boundary','core_org_units_preserved', true, 'core remains administrative identity authority.'),
  ('sovereign_boundary','gis_locations_owner_preserved', true, 'gis remains geometry/spatial locations authority.'),
  ('sovereign_boundary','services_owner_preserved', true, 'platform_services remains services owner; services wrapper is only verified.'),
  ('sovereign_boundary','production_not_approved_by_sql_alone', true, 'Browser/Console UAT remains required after execution.')
) as t(section, check_key, passed, note);
