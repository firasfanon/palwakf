-- Sovereign boundary evidence — read only
select 'sovereign_boundary' as section, 'no_waq_assets_mutation_in_this_script' as check_key, true as passed, 'Read-only completion marker only.' as note
union all select 'sovereign_boundary', 'no_public_media_extraction_in_this_script', true, 'No import/move/delete from legacy public media tables.'
union all select 'sovereign_boundary', 'locations_authority_gate_preserved', true, 'No locations wrapper activation.'
union all select 'sovereign_boundary', 'wave_b1b_not_authorized', true, 'Wave B-1B remains blocked.'
union all select 'sovereign_boundary', 'activities_gallery_reroute_not_included', true, 'Activities/gallery remain blocked pending explicit mapping approval.'
union all select 'sovereign_boundary', 'production_deployment_not_executed', true, 'Candidate decision only; no deployment action.';
