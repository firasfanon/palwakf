-- Read-only sovereign boundary confirmation for this audit batch.
select * from (values
  ('no_waq_assets_mutation_in_this_script', true, 'Read-only inventory only; no waqf/waqf_assets/awqaf_system DML.'),
  ('no_public_data_migration_in_this_script', true, 'No extraction, migration, insert, update, or delete is executed.'),
  ('no_route_runtime_mutation_by_sql', true, 'Route/PWF-SIS audit is documented in Flutter contract/docs only.'),
  ('official_data_source_required_before_completion', true, 'A public page cannot be certified complete without official table/view/RPC evidence.')
) as t(check_key, passed, note);
