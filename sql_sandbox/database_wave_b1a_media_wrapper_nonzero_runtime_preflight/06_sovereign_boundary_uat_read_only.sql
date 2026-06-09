-- Database Wave B-1A — Media Wrapper Nonzero + Runtime Reroute Preflight
-- 06: Sovereign boundary UAT (READ ONLY)
-- Permanent schemas are not mutated by this script.

select *
from (
  values
    ('sovereign_boundary','no_waq_assets_mutation_in_this_script',true,'Read-only preflight only; no waqf/waqf_assets/awqaf_system DML.'),
    ('sovereign_boundary','no_public_media_extraction_in_this_script',true,'Legacy public media tables remain unchanged; no import/move/delete.'),
    ('sovereign_boundary','no_flutter_runtime_reroute_in_this_script',true,'No Dart/Flutter file is modified by this SQL preflight.'),
    ('sovereign_boundary','media_gallery_assets_still_excluded',true,'public.media_gallery_items remains excluded pending asset/content mapping.'),
    ('sovereign_boundary','public_news_legacy_still_excluded',true,'public.news remains excluded pending duplicate/legacy shape review.'),
    ('sovereign_boundary','services_compatibility_closure_preserved',true,'Services compatibility closure remains unchanged.'),
    ('sovereign_boundary','locations_authority_gate_preserved',true,'Locations authority gate remains open; no locations wrapper activation.'),
    ('sovereign_boundary','wave_b1b_not_authorized',true,'Selective sovereign extraction remains blocked.'),
    ('sovereign_boundary','production_not_approved',true,'This pack cannot approve production; it only prepares preflight evidence.')
) as t(section, check_key, passed, note);
