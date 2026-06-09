-- Platform Database Ownership — SQL 19
-- Dependency bucket normalization for Wave A.
-- READ ONLY. No DDL. No DML. No grants. No destructive action.

with buckets as (
  select * from (values
    (
      'public_surface_self_reference_or_legacy_wrapper',
      'ACCEPT_AS_COMPATIBILITY_SURFACE_UNTIL_EXPLICIT_REPLACEMENT',
      'Public views/RPCs that intentionally preserve compatibility. Do not drop/archive by raw count.',
      false,
      true
    ),
    (
      'owner_schema_dependency_needs_wrapper_review',
      'WAVE_A_REMEDIATION_CANDIDATE',
      'Owner-schema routines/views that still mention or depend on public. Review and create owner wrappers or adjust source references.',
      true,
      false
    ),
    (
      'protected_sovereign_reference_review_only',
      'REVIEW_ONLY_DO_NOT_MIGRATE_IN_PLATFORM_BATCH',
      'GIS/waqf/awqaf sovereign references are not moved by this platform database ownership batch.',
      false,
      true
    ),
    (
      'unclassified_dependency_review_required',
      'MANUAL_CLASSIFICATION_REQUIRED',
      'Extensions/realtime/graphql/topology/staging items require manual classification before any action.',
      false,
      true
    ),
    (
      'routine_source_mentions_public',
      'TEXT_MENTION_REQUIRES_BODY_REVIEW_NOT_AUTOMATIC_BLOCKER',
      'Source text contains public reference. Treat as review item, not as automatic destructive blocker.',
      false,
      true
    ),
    (
      'view_or_rule_dependency',
      'REAL_DEPENDENCY_REVIEW_BY_REFERENCED_OBJECT',
      'View/rule dependency requires referenced-object review before owner remapping.',
      true,
      false
    )
  ) as t(classifier_key, normalized_decision, interpretation, wave_a_candidate, destructive_action_blocked)
)
select
  'dependency_bucket_normalization_wave_a'::text as section,
  classifier_key,
  normalized_decision,
  interpretation,
  wave_a_candidate,
  destructive_action_blocked,
  false::boolean as dependency_zero_certified,
  false::boolean as production_approved,
  true::boolean as read_only
from buckets
order by wave_a_candidate desc, classifier_key;
