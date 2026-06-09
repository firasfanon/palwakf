-- Mega Batch — Public Main Pages PWF-SIS Polish Browser/Console UAT Result Intake + Final Certification Decision
-- READ-ONLY marker. No SQL production change is included.
select 'public_main_pages_pwf_sis_polish_uat_result_intake' as section,
       'FINAL_MAIN_PAGES_CERTIFICATION_DEFERRED_PENDING_BROWSER_CONSOLE_EVIDENCE' as decision,
       'No post-apply Browser/Console evidence submitted with this intake request.' as note;

select 'sovereign_boundary' as section,
       'no_waq_assets_mutation_in_this_script' as check_key,
       true as passed,
       'This marker is SELECT-only and does not touch waqf/waqf_assets/awqaf_system.' as note;
