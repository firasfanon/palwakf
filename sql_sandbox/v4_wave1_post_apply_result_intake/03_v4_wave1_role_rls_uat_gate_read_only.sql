-- V4 Wave1 Role/RLS UAT Gate (read-only marker)
select
  'v4_wave1_role_rls_uat_gate' as section,
  'ROLE_RLS_UAT_REQUIRED' as rls_status,
  'TEST_OWNER_ADMIN_AUTHENTICATED_ANON_NEGATIVE_PATHS' as required_action,
  false as production_approved,
  true as read_only;
