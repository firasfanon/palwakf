-- NOT AUTHORIZED.
-- Future production apply skeleton only. Do not run.
select
  '99_future_production_apply_skeleton_not_authorized'::text as section,
  false as production_apply_authorized,
  false as ddl_dml_authorized,
  false as grant_revoke_authorized,
  false as compatibility_views_removal_authorized,
  'TEXT_REVIEW_ONLY_DO_NOT_RUN'::text as decision,
  true as read_only;
