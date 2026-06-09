import '../contracts/pwf_assistant_maturity_closure_contract.dart';

/// Static maturity gate service for the existing PalWakf Assistant.
///
/// Runtime RAG/tooling/backend implementation must be added behind this gate,
/// not by weakening public access or bypassing RBAC/RLS.
class PwfAssistantMaturityGateService {
  const PwfAssistantMaturityGateService();

  PwfAssistantMaturitySnapshot currentSnapshot() {
    return const PwfAssistantMaturitySnapshot(
      decision: PwfAssistantMaturityClosureContract.decision,
      productionApproved:
          PwfAssistantMaturityClosureContract.productionApproved,
      gates: <PwfAssistantMaturityGateItem>[
        PwfAssistantMaturityGateItem(
          key: 'rag_retrieval_contract',
          labelAr: 'عقد الاسترجاع المعزز RAG',
          labelEn: 'RAG retrieval contract',
          status: PwfAssistantMaturityGateStatus.evidenceRequired,
          productionBlocking: true,
          requiredEvidence: <String>[
            'assistant.rag_documents/rag_chunks or approved equivalent exists',
            'public/internal read wrappers are separated',
            'retrieval respects source sensitivity and unit/system scope',
          ],
        ),
        PwfAssistantMaturityGateItem(
          key: 'mandatory_citations_contract',
          labelAr: 'عقد الاستشهادات الإلزامية',
          labelEn: 'Mandatory citations contract',
          status: PwfAssistantMaturityGateStatus.evidenceRequired,
          productionBlocking: true,
          requiredEvidence: <String>[
            'every knowledge answer has source ids and snippets',
            'public answer renderer hides internal-only metadata',
            'unsupported answers fail closed instead of hallucinating',
          ],
        ),
        PwfAssistantMaturityGateItem(
          key: 'tool_registry_and_audit_contract',
          labelAr: 'سجل الأدوات والأوديت',
          labelEn: 'Tool registry and audit',
          status: PwfAssistantMaturityGateStatus.evidenceRequired,
          productionBlocking: true,
          requiredEvidence: <String>[
            'tool registry defines allowed tools per role/scope',
            'tool invocation is audited',
            'negative UAT proves unauthorized tools are denied',
          ],
        ),
        PwfAssistantMaturityGateItem(
          key: 'rbac_rls_scope_enforcement',
          labelAr: 'RBAC/RLS للمساعد',
          labelEn: 'Assistant RBAC/RLS enforcement',
          status: PwfAssistantMaturityGateStatus.evidenceRequired,
          productionBlocking: true,
          requiredEvidence: <String>[
            'assistant schema has RLS enabled',
            'public/anon can only access public chatbot scope',
            'internal assistant access follows platform roles and unit scope',
          ],
        ),
        PwfAssistantMaturityGateItem(
          key: 'document_intelligence_bridge',
          labelAr: 'جسر ذكاء الوثائق',
          labelEn: 'Document intelligence bridge',
          status: PwfAssistantMaturityGateStatus.partial,
          productionBlocking: true,
          requiredEvidence: <String>[
            'document candidate export RPC is applied and UAT-tested',
            'candidate review/approval precedes indexing',
            'document sensitivity is preserved in RAG retrieval',
          ],
        ),
        PwfAssistantMaturityGateItem(
          key: 'waqf_assets_assistant_scope',
          labelAr: 'مساعد الأصول الوقفية',
          labelEn: 'Waqf-assets assistant scope',
          status: PwfAssistantMaturityGateStatus.evidenceRequired,
          productionBlocking: true,
          requiredEvidence: <String>[
            'waqf_assets answers are read-only unless explicit write token exists',
            'asset context uses waqf_asset_id/national_asset_code',
            'negative UAT proves cross-unit leakage is denied',
          ],
        ),
        PwfAssistantMaturityGateItem(
          key: 'assistant_evaluation_suite',
          labelAr: 'حزمة تقييمات المساعد',
          labelEn: 'Assistant evaluation suite',
          status: PwfAssistantMaturityGateStatus.evidenceRequired,
          productionBlocking: true,
          requiredEvidence: <String>[
            'golden question set exists for public/internal/waqf-assets/docs',
            'citation coverage threshold is met',
            'unsafe tool and data-leakage tests pass',
          ],
        ),
        PwfAssistantMaturityGateItem(
          key: 'production_gate_evidence',
          labelAr: 'بوابة الإنتاج',
          labelEn: 'Production gate evidence',
          status: PwfAssistantMaturityGateStatus.blocked,
          productionBlocking: true,
          requiredEvidence: <String>[
            'flutter analyze clean',
            'assistant route matrix browser/console clean',
            'SQL/RLS positive and negative UAT clean',
            'production approval recorded explicitly',
          ],
        ),
      ],
    );
  }
}
