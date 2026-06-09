-- Platform Development 10D — anon revoke result intake + browser console placeholder hardening UAT
-- READ ONLY: this script records expected evidence after SQL 05/06 and Flutter hardening.
-- It does not create functions, grant privileges, or mutate data.

with checks(section, check_key, passed, note) as (
  values
    ('sql06_result', 'anon_blocked_all_owner_write_rpcs', true, 'User evidence after SQL 05/06 shows anon execute revoked for all eight owner-write RPCs.'),
    ('sql06_result', 'authenticated_execute_retained', true, 'authenticated execute remains present; SQL guards enforce actor permissions.'),
    ('sql06_result', 'owner_write_rpcs_still_installed', true, 'Function presence remains true for all eight owner-write RPCs after anon revoke.'),
    ('browser_console', 'placeholder_external_request_detected_before_10d', true, 'Screenshot evidence showed via.placeholder.com/150 net::ERR_CONNECTION_CLOSED.'),
    ('browser_console', 'public_placeholder_image_hardening_applied', true, '10D blocks known demo placeholder hosts in public image rendering paths.'),
    ('browser_console', 'browser_console_clean_after_10d_retest', false, 'Retest required after applying 10D and running Flutter staging.'),
    ('negative_uat', 'negative_uat_actor_bundle_passed', false, 'Negative actor-case evidence is still required before production approval.'),
    ('runtime_reroute', 'flutter_write_reroute_production_enabled', false, 'Production write reroute remains disabled; staging flag only.'),
    ('production_gate', 'production_approved', false, 'Production remains blocked until console retest and Negative UAT pass.'),
    ('sovereign_boundary', 'no_auth_users_migration', true, 'No auth.users migration or mutation is authorized.'),
    ('sovereign_boundary', 'no_waqf_assets_mutation', true, 'No waqf_assets/waqf/awqaf_system mutation is authorized.')
)
select * from checks;
