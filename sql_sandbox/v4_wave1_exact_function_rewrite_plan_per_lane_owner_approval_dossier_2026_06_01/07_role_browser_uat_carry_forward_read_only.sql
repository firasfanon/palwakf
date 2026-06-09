select * from (values
  ('role_rls_uat','35 RLS-enabled zero-policy targets','NEGATIVE_UAT_REQUIRED','anon/authenticated/unauthorized/out-of-scope evidence'),
  ('sensitive_rls_disabled','10 sensitive RLS-disabled targets','OWNER_APPROVAL_REQUIRED','owner decision before production'),
  ('grant_delta','platform_access grant deltas','OWNER_REVIEW_REQUIRED','no GRANT/REVOKE in this pack'),
  ('browser_runtime','6 runtime smoke surfaces','BROWSER_UAT_REQUIRED','platform_access/media_center/service_center/navigation/core_gis/awqaf_system smoke')
) as t(blocker_group, object_key, blocker_status, required_evidence)
;
