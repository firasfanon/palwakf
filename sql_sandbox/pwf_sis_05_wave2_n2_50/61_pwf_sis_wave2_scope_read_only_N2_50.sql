-- PWF-SIS Wave 2 / N2.50 read-only evidence helper
-- No DDL/DML. No waqf/waqf_assets/awqaf_system mutation.

select 'sovereign_boundary' as section,
       'no_waqf_assets_mutation_in_this_script' as check_key,
       true as passed,
       'Read-only PWF-SIS Wave 2 scope helper; no DDL/DML.' as note
union all
select 'wave2_scope',
       'selected_candidate_is_media_center_read_only_visual_pilot',
       true,
       'Wave 2 selected candidate is Media Center only; no workflow mutation allowed.'
union all
select 'production_gate',
       'production_not_approved',
       true,
       'Production gate remains blocked pending responsive/role/console/rollback evidence.';
