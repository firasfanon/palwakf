-- Platform Development 10B
-- Production gate re-decision after executable pack installation.
-- This remains false until post-apply catalog UAT, negative UAT, role/browser console evidence, and rollback evidence pass.

select * from (values
  ('implementation_pack_created', true, '10B includes executable SQL bodies for the eight owner-write RPCs.'),
  ('owner_write_rpcs_created_after_apply', false, 'Run 01 then 02 to confirm catalog presence; this decision file itself does not assert apply success.'),
  ('flutter_write_reroute_code_added', true, 'Repository write paths can use RPCs only when PWF_OWNER_WRITE_RPC_WRITE_REROUTE=true.'),
  ('flutter_write_reroute_production_enabled', false, 'Production reroute remains disabled until UAT evidence closes.'),
  ('negative_uat_passed', false, 'Negative UAT evidence is still required after apply.'),
  ('browser_console_clean', false, 'Browser console evidence is still required after apply.'),
  ('production_approved', false, 'Production is not approved by 10B pack generation alone.'),
  ('no_auth_users_migration', true, 'auth.users remains Supabase Auth identity source and is not migrated.'),
  ('no_waqf_assets_mutation', true, 'No waqf_assets/waqf/awqaf_system DDL or DML is included.')
) as t(check_key, passed, note);
