select * from (values
  ('A001-A016','platform_access read/RBAC helpers','public.admin_users / roles / permissions references','OWNER_SCHEMA_REROUTE_OR_KEEP_COMPAT_REVIEW','RBAC owner sign-off + negative role UAT'),
  ('A017-A020','platform_access write-risk role/permission RPCs','controlled writes through platform owner helpers','WRITE_RISK_MANUAL_REVIEW','owner approval + self-lockout + escalation UAT'),
  ('A021-A024','platform owner write helper functions','already in platform schema with owner references','OWNER_REVIEW_REQUIRED','platform_access owner sign-off')
) as t(candidate_range, area, observed_reference_pattern, recommended_decision, required_evidence)
;
