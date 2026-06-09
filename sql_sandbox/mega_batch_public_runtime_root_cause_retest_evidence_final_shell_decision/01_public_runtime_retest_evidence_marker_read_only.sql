-- Mega Batch: Public Runtime Root-Cause Retest Evidence Intake + Final Shell Decision
-- Read-only marker only. No DDL/DML. No production mutation.
select 'public_runtime_root_cause_retest_evidence_final_shell_decision' as batch_key,
       true as no_waq_assets_mutation,
       true as no_public_media_extraction,
       true as no_wave_b1b,
       true as no_locations_activation,
       true as no_activities_gallery_reroute,
       'final-shell-certification-accepted-for-provided-public-runtime-surfaces' as decision;
