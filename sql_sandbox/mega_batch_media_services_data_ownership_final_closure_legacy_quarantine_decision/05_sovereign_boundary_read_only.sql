-- Script 05: Sovereign boundary read-only
-- Purpose: prove this batch does not authorize sovereign mutations.

select * from (values
  ('sovereign_boundary','no_waq_assets_mutation_in_this_script', true, 'Read-only closure/quarantine decision only; no waqf/waq_assets/awqaf_system DML.'),
  ('sovereign_boundary','public_is_wrappers_only', true, 'public remains compatibility views/RPC wrappers; no sovereign storage ownership is assigned to public.'),
  ('sovereign_boundary','legacy_public_media_services_preserved', true, 'No DROP/DELETE/UPDATE is authorized for public media/services legacy tables.'),
  ('sovereign_boundary','media_center_owner_confirmed', true, 'media_center is the owner of media content and future asset mapping.'),
  ('sovereign_boundary','platform_services_owner_confirmed', true, 'platform_services is the owner of services catalog/request workflows.'),
  ('sovereign_boundary','production_delete_archive_not_approved', true, 'Any destructive archive/delete requires a separate explicit Mega Batch and approval.')
) as t(section, check_key, passed, note);
