-- Platform Development 10F
-- Production gate redecision after staging reroute evidence and before Negative UAT closure.
-- Read-only. Production remains not approved.

with gate(section, check_key, passed, note) as (
  values
    ('gate_input', 'owner_write_rpcs_installed', true, '10B SQL apply and SQL06 evidence confirm functions remain installed.'),
    ('gate_input', 'anon_execute_revoked', true, '10C/SQL06 evidence confirms anon_blocked=true for all owner-write RPCs.'),
    ('gate_input', 'flutter_reroute_staging_startup_passed', true, 'Flutter staging started with PWF_OWNER_WRITE_RPC_WRITE_REROUTE=true.'),
    ('gate_input', 'public_route_browser_console_clean_home_about_contact', true, 'Public route console retest accepted for /home, /home/about, and /home/contact.'),
    ('gate_input', 'negative_uat_actor_bundle_passed', false, 'Actual negative actor-case evidence has not been supplied/passed in this pack.'),
    ('gate_input', 'owner_write_rpc_denied_attempts_supplied', false, 'Denied RPC/write attempt evidence is still required.'),
    ('gate_input', 'browser_console_clean_for_admin_write_surfaces', false, 'Admin/write-surface console evidence still required.'),
    ('production_gate', 'flutter_write_reroute_production_enabled', false, 'Production reroute remains disabled.'),
    ('production_gate', 'production_approved', false, 'Production is not approved until Negative UAT and admin/write console evidence pass.'),
    ('sovereign_boundary', 'no_auth_users_migration', true, 'auth.users remains Supabase Auth identity source.'),
    ('sovereign_boundary', 'no_waqf_assets_mutation', true, 'No waqf_assets/waqf/awqaf_system DDL or DML is included.')
)
select * from gate;
