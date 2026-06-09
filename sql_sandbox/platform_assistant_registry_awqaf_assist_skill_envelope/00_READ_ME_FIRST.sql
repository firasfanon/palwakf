-- PalWakf Platform Assistant Registry + Awqaf Assist Skill Invocation Envelope Pack
-- Default mode: READ ONLY.
-- Decision: PLATFORM_ASSISTANT_REGISTRY_AWQAF_ASSIST_SKILL_INVOCATION_ENVELOPE_PACK_PREPARED_READ_ONLY_DEFAULT
-- Current V4 gate: PRODUCTION_BLOCKED_BALANCED_EVIDENCE_EXECUTION_REQUIRED
-- Run 01..06 first. Do not run 90 without explicit owner approval and execution token. Do not run 99 except text review.
select '00_read_me_first' as section,
       'PLATFORM_ASSISTANT_REGISTRY_AWQAF_ASSIST_SKILL_INVOCATION_ENVELOPE_PACK_PREPARED_READ_ONLY_DEFAULT' as package_key,
       'READ_ONLY_DEFAULT_WITH_OPTIONAL_GUARDED_STAGING_REGISTRATION' as execution_mode,
       false as ddl_dml_authorized_by_default,
       false as grant_revoke_authorized,
       false as production_approved,
       true as read_only;
