-- READ ONLY: inspect fallback surfaces.
select
  'user_scope_assignments_surface_presence' as section,
  to_regclass('public.user_scope_assignments') is not null as public_user_scope_assignments_present,
  to_regclass('core.user_scope_assignments') is not null as core_user_scope_assignments_present,
  to_regclass('public.user_scope_assignment_units') is not null as public_user_scope_assignment_units_present,
  to_regclass('core.user_scope_assignment_units') is not null as core_user_scope_assignment_units_present,
  true as read_only;
