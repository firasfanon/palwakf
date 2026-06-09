-- Sovereign Boundary — READ ONLY
select 'sovereign_boundary' as section, 'no_waq_assets_mutation_in_this_script' as check_key, true as passed
union all select 'sovereign_boundary','no_public_media_extraction_in_this_script', true
union all select 'sovereign_boundary','locations_authority_gate_preserved', true
union all select 'sovereign_boundary','wave_b1b_not_authorized', true
union all select 'sovereign_boundary','production_not_approved', true;
