-- Database Wave B-1A — Sovereign Boundary Check (READ ONLY)

select
  'sovereign_boundary' as section,
  'no_waq_assets_mutation_in_this_script' as check_key,
  true as passed,
  'Read-only readiness pack only; no waqf/waqf_assets/awqaf_system DML, no extraction, no compatibility activation for critical systems.' as note
union all
select
  'sovereign_boundary',
  'no_media_wrapper_activation_in_this_script',
  true,
  'Media readiness is assessed only; wrappers are not activated in this pack.'
union all
select
  'sovereign_boundary',
  'no_locations_wrapper_activation_in_this_script',
  true,
  'Locations authority gate remains open; no location wrapper activation is performed.'
union all
select
  'sovereign_boundary',
  'wave_b1b_not_authorized',
  true,
  'Selective sovereign extraction remains blocked after this pack.';
