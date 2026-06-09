-- Public Runtime Completion Gate — read only
select 'public_runtime_completion_gate' as section,
       'public-platform-runtime-completion-accepted-other-systems-unblocked' as decision,
       true as browser_console_evidence_accepted,
       false as deployed_to_production,
       false as wave_b1b_authorized,
       false as public_media_extraction_authorized,
       false as waqf_assets_mutation_authorized;
