-- Read-only skill invocation envelope definition.
select 'awqaf_assist_skill_envelope' as section,
       'awqaf_assist' as skill_key,
       'awqaf_system' as system_key,
       'read_only_evidence_grounded_beta' as mode,
       'explain_source_record|summarize_asset|lookup_evidence|check_write_readiness' as allowed_intents,
       'write/review/approval intents must return blocked_action' as required_guardrail,
       false as write_enabled,
       false as production_approved,
       true as read_only;
