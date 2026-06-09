select * from (values
  ('LANE_C_MEDIA_CENTER','C001-C014','readiness/family/editorial/audit/CMS feed functions','READ_PATH_REVIEW_THEN_OPTIONAL_OWNER_SCHEMA_REROUTE','media runtime smoke + editorial owner sign-off'),
  ('LANE_B_SERVICE_NAVIGATION','B001-B011','service queue/transition/catalog/home services functions','KEEP_COMPAT_VIEW_UNTIL_RPC_BODY_REVIEW','service submit/track/admin queue smoke + write-risk review')
) as t(lane_key, candidate_range, area, recommended_decision, required_evidence)
;
