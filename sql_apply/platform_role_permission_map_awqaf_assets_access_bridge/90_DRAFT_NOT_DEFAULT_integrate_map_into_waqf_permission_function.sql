-- DO NOT RUN BY DEFAULT.
-- This is only a decision placeholder.
-- Runtime integration requires separate authorization because it changes RBAC behavior.

select
  'platform_role_permission_map_integration_draft_not_default' as section,
  'NOT_AUTHORIZED_IN_THIS_PACK' as status,
  false as production_approved;
