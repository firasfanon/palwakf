-- Mega Batch Public Runtime UAT + Services/Media Shell Closure
-- 03_sovereign_boundary_read_only.sql
-- READ ONLY. No DML.

select 'sovereign_boundary' as section, 'no_waq_assets_mutation_in_this_script' as check_key, true as passed,
       'Read-only runtime shell closure checks only; no waqf/waqf_assets/awqaf_system DML.' as note
union all
select 'sovereign_boundary','no_public_media_extraction_in_this_script',true,'Legacy public media tables are preserved; no import/move/delete is executed.'
union all
select 'sovereign_boundary','locations_authority_gate_preserved',true,'No locations wrapper activation is included.'
union all
select 'sovereign_boundary','wave_b1b_not_authorized',true,'Selective sovereign extraction remains blocked.'
union all
select 'sovereign_boundary','activities_gallery_reroute_not_included',true,'Activities and gallery remain blocked pending rows/mapping approval.'
union all
select 'sovereign_boundary','production_not_approved',true,'This mega batch does not approve production.';
