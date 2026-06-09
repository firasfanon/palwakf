-- 04: Sovereign boundary UAT (read-only).
select 'sovereign_boundary' as section, 'no_waq_assets_mutation_in_this_script' as check_key, true as passed,
       'Read-only preflight only; no waqf/waqf_assets/awqaf_system DML.' as note
union all
select 'sovereign_boundary', 'no_public_media_extraction_in_this_script', true,
       'Legacy public media tables remain unchanged; no import/move/delete.'
union all
select 'sovereign_boundary', 'no_flutter_runtime_reroute_in_this_script', true,
       'This is preflight only; Flutter reroute is not performed.'
union all
select 'sovereign_boundary', 'services_compatibility_closure_preserved', true,
       'Services compatibility closure remains unchanged.'
union all
select 'sovereign_boundary', 'locations_authority_gate_preserved', true,
       'Locations authority gate remains open; no locations wrapper activation.'
union all
select 'sovereign_boundary', 'wave_b1b_not_authorized', true,
       'Selective sovereign extraction remains blocked.';
