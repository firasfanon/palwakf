-- FUTURE ONLY. NOT AUTHORIZED.
-- Awqaf Assist write/review/approval intent enablement is out of scope.
-- Any current write intent must return blocked_action.
select '99_future_write_intent_enablement' as section,
       false as write_enabled,
       false as review_enabled,
       false as approval_enabled,
       false as production_approved,
       'NOT_AUTHORIZED' as decision;
