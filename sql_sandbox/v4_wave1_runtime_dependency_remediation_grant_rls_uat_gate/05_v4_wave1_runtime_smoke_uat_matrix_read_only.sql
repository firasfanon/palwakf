-- PalWakf V4 Wave1 Runtime Dependency Remediation + Compatibility View Grant Review + Role/RLS UAT Gate
-- Date: 2026-05-31
-- Scope: READ-ONLY unless explicitly stated. This pack does not authorize DDL/DML/GRANT/REVOKE/DROP.
-- Production approval: false


select * from (values
  ('public_home','/home','anonymous','READ_SMOKE','PENDING','Confirm public home loads without 401/403/406/500 and without console errors from compatibility views.'),
  ('public_services','/home/services','anonymous','READ_SMOKE','PENDING','Confirm services listing reads via compatibility surface after Wave1.'),
  ('public_media_news','/home/news','anonymous','READ_SMOKE','PENDING','Confirm media center public reads still work after news/activity/announcement table moves.'),
  ('admin_access','/admin/dashboard','authenticated_admin','READ_SMOKE','PENDING','Confirm admin access/RBAC views and user_system_roles/permissions are stable.'),
  ('admin_media','/admin/media-center/news','authorized_editor','WRITE_RISK_SMOKE','PENDING','Confirm write flows use RPC wrappers or owner schema safely; no direct broken view writes.'),
  ('awqaf_system','/systems/awqaf-system','authorized_awqaf_user','READ_SMOKE','PENDING','Confirm Awqaf System reads content/settings through supported wrappers.'),
  ('complaints','complaints public/admin surfaces','anonymous/authenticated/admin','READ_WRITE_RISK_SMOKE','PENDING','Confirm submit/track/admin flows still work and RLS behavior is unchanged.'),
  ('service_center','service center public/admin surfaces','anonymous/authenticated/admin','READ_WRITE_RISK_SMOKE','PENDING','Confirm service center public/admin flows remain stable after public compatibility views.'),
  ('platform_navigation','/home and eServices cards','anonymous','READ_SMOKE','PENDING','Confirm public navigation services/home_services cards render from compatibility views or owner reads.'),
  ('wave3_exclusion','assistant/core/gis collision tables','admin','NO_MOVE_CONFIRMATION','PENDING','Confirm 9 collision tables are not moved and are not part of Wave1.')
) as t(section, route_or_surface, role_scope, uat_type, uat_status, instruction);
