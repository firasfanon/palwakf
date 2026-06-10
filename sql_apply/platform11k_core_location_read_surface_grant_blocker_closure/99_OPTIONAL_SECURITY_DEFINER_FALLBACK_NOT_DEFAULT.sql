-- DO NOT RUN BY DEFAULT.
-- This pack uses direct least-privilege authenticated grants.
-- SECURITY DEFINER fallback requires separate explicit owner approval.

select
  'platform11k_core_location_security_definer_fallback_not_default' as section,
  'NOT_AUTHORIZED_IN_THIS_PACK' as status,
  false as production_approved;
