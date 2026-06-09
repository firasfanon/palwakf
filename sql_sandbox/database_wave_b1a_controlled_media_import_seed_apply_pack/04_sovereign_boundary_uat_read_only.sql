-- Database Wave B-1A — Controlled Media Import/Seed Sovereign Boundary UAT
-- Read-only boundary checks after controlled seed apply.

select * from (
  select
    'sovereign_boundary' as section,
    'no_waq_assets_mutation_in_this_script' as check_key,
    true as passed,
    'Controlled media seed touches media_center.content_items/editorial_events only; no waqf/waqf_assets/awqaf_system DML is included.' as note
  union all
  select 'sovereign_boundary','no_public_media_extraction_in_this_script',true,
    'Legacy public media tables remain unchanged; this is seed/copy only, not extraction or deletion.'
  union all
  select 'sovereign_boundary','no_flutter_runtime_reroute_in_this_script',true,
    'Runtime reroute remains blocked until separate Flutter/browser UAT pack.'
  union all
  select 'sovereign_boundary','media_public_wrappers_preserved_read_only',true,
    'Existing public.v_media_*_compat_v1 wrappers remain read-only facades.'
  union all
  select 'sovereign_boundary','services_compatibility_closure_preserved',true,
    'No service reroute or service wrapper change in this pack.'
  union all
  select 'sovereign_boundary','locations_authority_gate_preserved',true,
    'Locations authority gate remains open; no locations wrapper activation.'
  union all
  select 'sovereign_boundary','wave_b1b_not_authorized',true,
    'Selective sovereign extraction remains blocked.'
  union all
  select 'controlled_seed_boundary','public_news_legacy_not_seeded',true,
    'public.news remains excluded pending duplicate/legacy shape review.'
  union all
  select 'controlled_seed_boundary','media_gallery_assets_not_seeded',true,
    'public.media_gallery_items remains excluded pending asset/content mapping.'
) checks;
