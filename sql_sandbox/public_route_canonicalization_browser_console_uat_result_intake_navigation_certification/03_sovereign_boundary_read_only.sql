-- Sovereign boundary marker; read-only constant output.
select * from (values
('no_sql_production_change', true, 'This result-intake pack contains no production SQL.'),
('no_public_media_extraction', true, 'No data extraction or migration is included.'),
('no_locations_authority_change', true, 'No locations authority change is included.'),
('no_waq_assets_mutation', true, 'No waqf/waqf_assets/awqaf_system mutation is included.')
) as t(check_key, passed, note);
