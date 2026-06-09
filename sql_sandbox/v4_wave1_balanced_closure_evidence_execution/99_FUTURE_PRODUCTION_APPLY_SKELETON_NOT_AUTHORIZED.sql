-- FUTURE ONLY. DO NOT RUN AS APPLY.
-- No production apply is authorized in this package.
select
  '99_future_production_apply_skeleton_not_authorized'::text as section,
  false as apply_authorized,
  false as production_approved,
  true as read_only;
