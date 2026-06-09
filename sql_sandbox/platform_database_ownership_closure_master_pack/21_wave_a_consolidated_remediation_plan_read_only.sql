-- Platform Database Ownership Closure — DB Dependency Remediation Pack Wave A
-- Consolidated read-only plan. No DDL, no DML, no GRANT, no DROP, no archive/delete.
-- Purpose: convert SQL 15/19/20 classifier output into deterministic Wave A decisions.

with accepted_classifier as (
  select * from (values
    ('classifier_output_intaken', true, 'SQL 15 classified output accepted; raw 502 is not a flat blocker.'),
    ('flutter_literal_remediation', true, 'Scanned Flutter direct .from literals were centralized; remaining scanned direct literal count = 0.'),
    ('raw_502_not_flat_blocker', true, 'Raw count includes compatibility wrappers, text mentions, review-only sovereign references, and genuine candidates.'),
    ('production_gate', false, 'Production remains NOT_APPROVED until UAT, RLS, and governance approvals are supplied.')
  ) as t(gate_key, passed, note)
),
bucket_normalization as (
  select * from (values
    ('owner_schema_dependency_needs_wrapper_review', 'WAVE_A_REMEDIATION_CANDIDATE', true, false, 'Create/review owner wrappers or adjust source references after body review.'),
    ('view_or_rule_dependency', 'REAL_DEPENDENCY_REVIEW_BY_REFERENCED_OBJECT', true, false, 'Review referenced object and decide owner-wrapper versus accepted compatibility view.'),
    ('protected_sovereign_reference_review_only', 'REVIEW_ONLY_DO_NOT_MIGRATE_IN_PLATFORM_BATCH', false, true, 'GIS/waqf/awqaf references are not moved by this platform batch.'),
    ('public_surface_self_reference_or_legacy_wrapper', 'ACCEPT_AS_COMPATIBILITY_SURFACE_UNTIL_EXPLICIT_REPLACEMENT', false, true, 'Compatibility views/RPCs are accepted and not counted as destructive blockers by raw count.'),
    ('routine_source_mentions_public', 'TEXT_MENTION_REQUIRES_BODY_REVIEW_NOT_AUTOMATIC_BLOCKER', false, true, 'Text mentions need body review; not automatic blockers.'),
    ('unclassified_dependency_review_required', 'MANUAL_CLASSIFICATION_REQUIRED', false, true, 'Extensions/realtime/graphql/topology/staging need manual classification.')
  ) as t(classifier_key, normalized_decision, wave_a_candidate, destructive_action_blocked, interpretation)
),
wave_a_scope as (
  select * from (values
    ('core', 'owner_schema_dependency_needs_wrapper_review', 'RBAC/admin/org-unit helper functions and views that still mention public.'),
    ('assistant', 'owner_schema_dependency_needs_wrapper_review', 'Assistant admin/auth helper functions; no new assistant creation.'),
    ('tasks', 'owner_schema_dependency_needs_wrapper_review', 'Tasks audit helper functions requiring owner-wrapper review.'),
    ('platform_access', 'view_or_rule_dependency', 'RBAC compatibility views and registry views; preserve public wrappers until explicit replacement.'),
    ('platform_content', 'view_or_rule_dependency', 'Header/footer/homepage/site-page compatibility surfaces; preserve public wrappers until replacement.'),
    ('media_center', 'view_or_rule_dependency', 'Media compatibility views/RPCs; preserve public runtime until owner schema reads are certified.'),
    ('platform_services', 'view_or_rule_dependency', 'Services/complaints compatibility surfaces; preserve public runtime until RPC/RLS UAT.'),
    ('document_intelligence', 'view_or_rule_dependency', 'Document RPC compatibility surfaces; bridge needs separate UAT.'),
    ('awqaf_system', 'protected_sovereign_reference_review_only', 'Review-only in this platform batch; no waqf/awqaf mutation.'),
    ('gis', 'protected_sovereign_reference_review_only', 'GIS references are read-only wrappers only.'),
    ('extensions_realtime_graphql_topology', 'unclassified_dependency_review_required', 'Manual classification only; no remediation in Wave A execution.')
  ) as t(scope_family, classifier_key, wave_a_treatment)
)
select
  'wave_a_consolidated_classifier_acceptance' as section,
  gate_key,
  passed,
  note,
  false as production_approved,
  false as destructive_sql_authorized,
  false as exact_public_table_replacement_authorized,
  true as read_only,
  true as no_auth_users_migration,
  true as no_flutter_elevated_secret,
  true as no_waqf_assets_mutation
from accepted_classifier
union all
select
  'wave_a_bucket_normalization' as section,
  classifier_key as gate_key,
  wave_a_candidate as passed,
  normalized_decision || ' — ' || interpretation as note,
  false,
  false,
  false,
  true,
  true,
  true,
  true
from bucket_normalization
union all
select
  'wave_a_scope_treatment' as section,
  scope_family as gate_key,
  classifier_key in ('owner_schema_dependency_needs_wrapper_review', 'view_or_rule_dependency') as passed,
  classifier_key || ' — ' || wave_a_treatment as note,
  false,
  false,
  false,
  true,
  true,
  true,
  true
from wave_a_scope;
