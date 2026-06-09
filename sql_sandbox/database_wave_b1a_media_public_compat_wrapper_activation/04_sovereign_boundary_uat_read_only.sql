-- Database Wave B-1A — Sovereign Boundary UAT for Media Public Compatibility Wrapper Activation
-- Read-only boundary assertions. This script does not mutate anything.

select *
from (
  values
    ('sovereign_boundary','no_waq_assets_mutation_in_this_script',true,'Read-only UAT only; no waqf/waqf_assets/awqaf_system DML.'),
    ('sovereign_boundary','no_public_media_extraction_in_this_script',true,'Legacy public media tables remain unchanged; no import/move/delete.'),
    ('sovereign_boundary','media_public_wrappers_activated_read_only',true,'Only public.v_media_*_compat_v1 and rpc_media_content_compat_v1 are activated as read-only facades.'),
    ('sovereign_boundary','no_flutter_runtime_reroute_in_this_script',true,'Runtime reroute is not part of this SQL pack.'),
    ('sovereign_boundary','services_compatibility_closure_preserved',true,'No service reroute or service wrapper change in this pack.'),
    ('sovereign_boundary','locations_authority_gate_preserved',true,'Locations authority gate remains open; no locations wrapper activation.'),
    ('sovereign_boundary','wave_b1b_not_authorized',true,'Selective sovereign extraction remains blocked.')
) as t(section, check_key, passed, note);
