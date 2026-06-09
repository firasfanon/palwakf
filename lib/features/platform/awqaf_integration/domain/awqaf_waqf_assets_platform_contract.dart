/// Platform-side contract for receiving waqf asset outputs from awqaf_system.
///
/// This file is intentionally read-only and declarative. It does not call
/// Supabase, does not mutate waqf schema tables, and does not replace the
/// awqaf_system review workflow.
class AwqafWaqfAssetsPlatformContract {
  const AwqafWaqfAssetsPlatformContract._();

  static const intakeTitleAr = 'استلام سجل الأصول الوقفية من awqaf_system';
  static const currentJudgment = 'review_ready_for_platform_intake';
  static const baselineZip =
      'palwakf_waqf_assets_registry_consolidated_baseline_after_batch08c_verified_2026_05_09.zip';
  static const baselineSha256 =
      'a0c256c0acbdd4d4780274609ff911c2985e65a0582fd5c6662b3a17b9f2b3e1';
  static const sourcePackage =
      'awqaf_system_waqf_assets_review_workflow_current_state_2026_05_09.zip';

  static const platformRoleAr =
      'استلام مخرجات awqaf_system وفحص جاهزيتها وربطها حوكميًا دون إعادة بناء waqf_assets.';

  static const doNotTouchTables = <String>[
    'waqf.waqf_assets',
    'waqf.waqf_asset_source_records',
    'waqf.waqf_asset_review_events',
    'waqf.waqf_asset_duplicate_candidates',
    'waqf.waqf_asset_source_parcel_match_candidates',
    'waqf.waqf_asset_parcel_links',
    'waqf.waqf_asset_normalization_dictionary',
    'waqf.waqf_asset_rbac_permissions',
    'waqf.waqf_asset_rbac_assignments',
  ];

  static const doNotReplaceRpcs = <String>[
    'waqf.rpc_waqf_asset_source_record_create_draft_v1',
    'waqf.rpc_waqf_asset_source_record_commit_review_decision_v1',
    'waqf.rpc_waqf_asset_source_duplicate_candidate_decision_v1',
    'waqf.rpc_waqf_asset_source_parcel_match_decision_v1',
    'public.rpc_waqf_asset_source_record_create_draft_v1',
    'public.rpc_waqf_asset_source_record_commit_review_decision_v1',
    'public.rpc_waqf_asset_source_duplicate_candidate_decision_v1',
    'public.rpc_waqf_asset_source_parcel_match_decision_v1',
  ];

  static const allowedPlatformIntakeActions = <String>[
    'Contract alignment',
    'Read-only dashboard summaries after awqaf_system stabilizes outputs',
    'Route/sidebar registration for intake visibility only',
    'Platform RBAC permission mapping without bypassing awqaf_system RBAC',
    'Assistant/document_intelligence/cases/tasks/billing references through waqf_asset_id after contract approval',
    'Mustakshif spatial read-only analysis contract only',
  ];

  static const unsafePlatformActions = <String>[
    'Create draft assets from the platform side',
    'Create approved assets from the platform side',
    'Create sovereign parcel links from the platform side',
    'Decide duplicate merges from the platform side',
    'Expose unapproved assets publicly or on public maps',
    'Replace awqaf_system RPCs or review workflow files',
  ];

  static const p1IntegrationGates = <String>[
    'dart format inside awqaf_system real workspace',
    'flutter analyze inside awqaf_system real workspace',
    'Browser UAT for awqaf_system admin pages',
    'GoRouter route tests',
    'PostgREST/RLS test using real authenticated users',
    'Draft detail page and public visibility safety test',
    'Review-events UI/timeline test or explicit deferral',
    'Clean up or disable temporary SQL Editor UAT actor when UAT ends',
  ];

  static const uatEvidence = <String, String>{
    'installed_functions': '4/4',
    'active_uat_super_admin_assignments': '1 temporary actor',
    'source_decision_state':
        '5 / 1 doc_review / 1 field_review / 1 reviewed / 1 in_review / 1 draft_created',
    'missing_lgu': '0',
    'draft_assets_from_batch07_sources': '1',
    'approved_assets_from_batch07_sources': '0',
    'draft_internal_only_assets': '1',
    'duplicate_decision_execution': '1 reviewed without merge',
    'parcel_candidate_execution':
        '1 accepted candidate only, no sovereign parcel link',
    'batch07_uat_parcel_links_created': '0',
    'review_event_trace': '11',
  };
}
