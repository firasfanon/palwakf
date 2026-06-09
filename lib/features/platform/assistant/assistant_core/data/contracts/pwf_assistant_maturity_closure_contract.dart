import 'package:flutter/foundation.dart';

/// Governing maturity contract for the existing PalWakf Assistant system.
///
/// This is not a creation contract. It records the closure gates required to
/// move the already integrated assistant from foundation/integration into
/// production maturity: RAG, citations, tool governance, RBAC/RLS, document
/// intelligence bridge, waqf-assets assistance, evals, and production gate.
@immutable
class PwfAssistantMaturityClosureContract {
  const PwfAssistantMaturityClosureContract._();

  static const String batchKey = 'platform_assistant_maturity_closure';
  static const String systemKey = 'assistant';
  static const String decision =
      'assistant_existing_system_maturity_closure_required_not_creation';

  static const bool isExistingPlatformSystem = true;
  static const bool creationWorkAllowed = false;
  static const bool productionApproved = false;
  static const bool serviceRoleInFlutterAllowed = false;
  static const bool directWaqfAssetsMutationAllowed = false;
  static const bool directAuthUsersMutationAllowed = false;

  static const List<String> maturityPillars = <String>[
    'rag_retrieval_contract',
    'mandatory_citations_contract',
    'tool_registry_and_audit_contract',
    'rbac_rls_scope_enforcement',
    'document_intelligence_bridge',
    'waqf_assets_assistant_scope',
    'assistant_evaluation_suite',
    'production_gate_evidence',
  ];

  static const List<String> blockedUntilEvidence = <String>[
    'runtime_rag_index_sql_apply',
    'citation_schema_and_answer_renderer_uat',
    'tool_invocation_rbac_negative_uat',
    'assistant_tables_rls_positive_negative_uat',
    'document_intelligence_candidate_to_rag_review_uat',
    'waqf_assets_read_only_answer_scope_uat',
    'eval_set_pass_thresholds',
    'full_route_console_clean_for_assistant_surfaces',
  ];

  static const List<String> allowedNextImplementationSurfaces = <String>[
    '/assistant/chat',
    '/admin/assistant',
    '/admin/document-intelligence',
    '/systems/awqaf-system',
    '/systems/awqaf-system/waqf-assets',
    '/home',
  ];
}

@immutable
class PwfAssistantMaturityGateItem {
  const PwfAssistantMaturityGateItem({
    required this.key,
    required this.labelAr,
    required this.labelEn,
    required this.status,
    required this.productionBlocking,
    required this.requiredEvidence,
  });

  final String key;
  final String labelAr;
  final String labelEn;
  final PwfAssistantMaturityGateStatus status;
  final bool productionBlocking;
  final List<String> requiredEvidence;
}

enum PwfAssistantMaturityGateStatus {
  founded,
  partial,
  evidenceRequired,
  blocked,
  passed,
}

@immutable
class PwfAssistantMaturitySnapshot {
  const PwfAssistantMaturitySnapshot({
    required this.decision,
    required this.productionApproved,
    required this.gates,
  });

  final String decision;
  final bool productionApproved;
  final List<PwfAssistantMaturityGateItem> gates;

  bool get hasBlockingGate => gates.any(
    (gate) =>
        gate.productionBlocking &&
        gate.status != PwfAssistantMaturityGateStatus.passed,
  );
}
