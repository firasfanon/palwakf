-- Platform Development 10F
-- Negative UAT Actor Bundle + Owner-Write RPC Staging Reroute Evidence
-- Read-only evidence matrix. No DDL/DML is performed here.

with evidence(section, check_key, passed, note) as (
  values
    ('accepted_evidence', 'anon_blocked_all_owner_write_rpcs', true, 'SQL06 after 10C showed anon execute revoked for all eight owner-write RPCs.'),
    ('accepted_evidence', 'authenticated_execute_retained', true, 'authenticated execute remains present; SQL guards must enforce actor permissions.'),
    ('accepted_evidence', 'owner_write_rpcs_installed', true, 'All eight owner-write RPCs remain installed.'),
    ('accepted_evidence', 'flutter_reroute_staging_startup_passed', true, 'Flutter started in staging with --dart-define=PWF_OWNER_WRITE_RPC_WRITE_REROUTE=true.'),
    ('accepted_evidence', 'public_route_console_home_clean', true, 'Browser console evidence for /home after 10D shows no placeholder network error.'),
    ('accepted_evidence', 'public_route_console_about_clean', true, 'Browser console evidence for /home/about after 10D shows no placeholder network error.'),
    ('accepted_evidence', 'public_route_console_contact_clean', true, 'Browser console evidence for /home/contact after 10D shows no placeholder network error.'),
    ('negative_uat_required', 'anonymous_denied_owner_write_rpc_attempt', false, 'Must attach denied RPC attempt evidence for anon.'),
    ('negative_uat_required', 'unauthorized_authenticated_denied_owner_write_rpc_attempt', false, 'Must attach denied RPC/write attempt evidence for authenticated but unauthorized user.'),
    ('negative_uat_required', 'scoped_user_denied_out_of_scope_role_permission_grant', false, 'Must attach out-of-scope denial evidence.'),
    ('negative_uat_required', 'unit_admin_denied_platform_wide_unsafe_write', false, 'Must attach platform-wide unsafe write denial evidence.'),
    ('negative_uat_required', 'platform_admin_denied_privilege_escalation', false, 'Must attach privilege escalation denial evidence.'),
    ('negative_uat_required', 'superuser_denied_self_lockout', false, 'Must attach self-lockout denial evidence.'),
    ('production_gate', 'production_approved', false, 'Production remains blocked until all negative actor cases pass and browser console remains clean.'),
    ('sovereign_boundary', 'no_auth_users_migration', true, 'auth.users remains Supabase Auth identity source and is not migrated.'),
    ('sovereign_boundary', 'no_flutter_elevated_secret', true, 'No elevated server secret is authorized in Flutter.'),
    ('sovereign_boundary', 'no_waqf_assets_mutation', true, 'No waqf_assets/waqf/awqaf_system mutation is included or authorized.')
)
select * from evidence;
