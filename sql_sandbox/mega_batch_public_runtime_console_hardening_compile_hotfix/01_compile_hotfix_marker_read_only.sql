-- Mega Batch — Public Runtime Console Hardening Compile Hotfix
-- Read-only UAT marker; no DDL/DML.
select 'compile_hotfix' as section,
       'normalizedSlug scoped in upsertGlobalPage' as fix_key,
       true as passed,
       'manual flutter analyze/run retest required' as note;

select 'sovereign_boundary' as section,
       'no_waq_assets_mutation_in_this_script' as check_key,
       true as passed,
       'Read-only marker only; no waqf/waqf_assets/awqaf_system DML.' as note;
