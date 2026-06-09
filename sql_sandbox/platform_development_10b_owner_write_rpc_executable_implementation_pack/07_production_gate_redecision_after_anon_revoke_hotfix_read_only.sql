-- Platform Development 10C
-- Production gate redecision after anon revoke hotfix: read-only.

with gate(section, check_key, passed, note) as (
  values
    ('10b_apply_result', 'owner_write_rpcs_created', true, 'SQL02 evidence showed all eight owner-write RPCs installed.'),
    ('10b_apply_result', 'locked_search_path_present', true, 'SQL02 evidence showed explicit function search_path config.'),
    ('10b_apply_result', 'authenticated_execute_grants_present', true, 'SQL02 evidence showed authenticated execute grants present.'),
    ('10c_hotfix_required', 'anon_execute_privilege_detected_before_hotfix', true, 'SQL02 evidence detected anon execute privilege; 10C hotfix must be applied.'),
    ('10c_hotfix_expected', 'anon_execute_revoked_after_05_and_06', false, 'Run SQL 05 then SQL 06 to confirm anon is blocked before any production decision.'),
    ('negative_uat', 'negative_uat_passed', false, 'Negative actor-case UAT remains required after privilege hotfix.'),
    ('browser_console', 'browser_console_clean', false, 'Flutter staging with PWF_OWNER_WRITE_RPC_WRITE_REROUTE=true still needs browser console evidence.'),
    ('runtime_reroute', 'flutter_write_reroute_production_enabled', false, 'Production reroute remains disabled until negative UAT and console evidence pass.'),
    ('production_gate', 'production_approved', false, 'Production is not approved by 10C hotfix alone.'),
    ('sovereign_boundary', 'no_auth_users_migration', true, 'No auth.users migration or mutation is authorized.'),
    ('sovereign_boundary', 'no_waqf_assets_mutation', true, 'No waqf_assets/waqf/awqaf_system mutation is authorized.')
)
select * from gate order by section, check_key;
