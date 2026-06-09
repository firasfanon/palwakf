select * from (values
  ('KEEP_COMPAT_VIEW_TEMPORARILY','Read path stable through public compatibility view','Browser/API smoke + owner acceptance','DESIGN_ONLY_NOT_AUTHORIZED'),
  ('OWNER_SCHEMA_REROUTE_CANDIDATE','Public references can be rerouted to owner schema','Exact rewritten body diff + owner approval + staging function test','DESIGN_ONLY_NOT_AUTHORIZED'),
  ('RPC_WRAPPER_REWRITE_REQUIRED','Public RPC remains but body uses owner wrapper','RLS/role UAT + owner approval','DESIGN_ONLY_NOT_AUTHORIZED'),
  ('WRITE_RISK_MANUAL_REVIEW','Insert/update/delete/transition/security-sensitive function','Manual review + negative UAT + rollback plan + owner approval','DESIGN_ONLY_NOT_AUTHORIZED'),
  ('RLS_POLICY_DECISION_REQUIRED','RLS zero-policy or sensitive RLS disabled affects behavior','Role matrix + negative UAT + owner policy decision','DESIGN_ONLY_NOT_AUTHORIZED'),
  ('DEFER_TO_WAVE3','Collision or out-of-Wave1 scope','Wave3 compare/merge/skip/rename decision','DESIGN_ONLY_NOT_AUTHORIZED')
) as t(decision_key, meaning, required_before_apply, apply_status)
;
