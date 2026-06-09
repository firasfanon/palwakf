select * from (
  values
    ('sovereign_boundary','no_waq_assets_mutation_in_this_script', true, 'Read-only decision/discovery only; no waqf/waqf_assets/awqaf_system DML.'),
    ('sovereign_boundary','no_public_media_extraction_in_this_script', true, 'This pack performs no import/move/delete/extraction.'),
    ('sovereign_boundary','no_locations_activation_in_this_script', true, 'Locations authority is decided but not activated.'),
    ('sovereign_boundary','no_activities_gallery_reroute_in_this_script', true, 'Activities/gallery runtime remains unchanged.'),
    ('sovereign_boundary','no_flutter_runtime_change_in_this_script', true, 'This is discovery/decision only.'),
    ('sovereign_boundary','no_production_sql_in_this_script', true, 'All SQL is SELECT/read-only.'),
    ('methodology','single_mega_batch_policy', true, 'No micro-patches; future execution must be one controlled Mega Batch unless a true blocker appears.')
) as t(section, check_key, passed, note);
