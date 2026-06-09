-- GUARDED STAGING OPTION ONLY. NOT AUTHORIZED BY DEFAULT.
-- This script is intentionally a non-executable skeleton until registry table names and owner approvals are supplied.
-- Required token pattern if converted later:
-- select set_config('request.pwf_execution_token','PWF_ASSISTANT_REGISTRY_AWQAF_ASSIST_STAGING_APPROVED', true);
-- Required evidence before conversion:
-- 1. platform assistant owner approval
-- 2. awqaf_system owner approval
-- 3. permission/audit UAT
-- 4. no direct sovereign reads
-- 5. no service_role in Flutter
select '90_guarded_staging_registration_option' as section,
       false as executable_apply_in_this_pack,
       false as ddl_dml_authorized_by_default,
       false as production_approved,
       'TEXT_REVIEW_ONLY_UNTIL_EXPLICIT_OWNER_APPROVAL' as decision;
