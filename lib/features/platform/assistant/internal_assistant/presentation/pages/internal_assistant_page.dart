import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../assistant_core/data/models/chat_experience_mode.dart';
import '../../../assistant_core/data/models/feature_card_item.dart';
import '../../../assistant_core/data/models/quick_action_item.dart';
import '../../../assistant_core/data/services/chat_route_context_service.dart';
import '../../../assistant_core/presentation/theme/chat_palette.dart';
import '../../../assistant_core/presentation/widgets/chat_shell.dart';
import '../../data/models/assistant_context.dart';
import '../../data/models/assistant_doc_reference.dart';
import '../../data/models/assistant_system_bridge.dart';
import '../../data/models/assistant_knowledge_source.dart';
import '../../data/services/assistant_capability_service.dart';
import '../../data/services/assistant_doc_reference_service.dart';
import '../../data/services/assistant_system_bridge_service.dart';
import '../../data/services/assistant_knowledge_governance_service.dart';
import '../../data/services/assistant_resume_service.dart';
import '../../data/services/assistant_suggestion_service.dart';
import '../i18n/internal_assistant_i18n.dart';
import '../providers/internal_assistant_provider.dart';
import '../widgets/assistant_context_summary.dart';
import '../widgets/assistant_system_chips.dart';

class InternalAssistantPage extends ConsumerStatefulWidget {
  const InternalAssistantPage({super.key, this.contextSeed});

  final AssistantContextSeed? contextSeed;

  @override
  ConsumerState<InternalAssistantPage> createState() =>
      _InternalAssistantPageState();
}

class _InternalAssistantPageState extends ConsumerState<InternalAssistantPage> {
  final _suggestionService = const AssistantSuggestionService();
  final _resumeService = const AssistantResumeService();
  final _governance = const AssistantKnowledgeGovernanceService();
  final _capabilityService = const AssistantCapabilityService();
  final _docReferenceService = const AssistantDocReferenceService();
  final _systemBridgeService = const AssistantSystemBridgeService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(internalAssistantProvider.notifier)
          .ensureBootstrapped(context, seed: widget.contextSeed);
    });
  }

  void _handleQuickAction(
    InternalAssistantNotifier notifier,
    QuickActionItem action,
  ) {
    if (action.route != null && action.route!.trim().isNotEmpty) {
      context.go(action.route!);
      return;
    }
    final message = action.message ?? action.label;
    notifier.onQuickAction(context: context, question: message);
  }

  void _handleFeatureTap(
    InternalAssistantNotifier notifier,
    FeatureCardItem item,
  ) {
    if (item.route != null && item.route!.trim().isNotEmpty) {
      context.go(item.route!);
      return;
    }
    notifier.onQuickAction(context: context, question: item.title);
  }

  @override
  Widget build(BuildContext context) {
    final i18n = InternalAssistantI18n.of(context);
    final state = ref.watch(internalAssistantProvider);
    final notifier = ref.read(internalAssistantProvider.notifier);
    final contextData = state.contextData;

    final quickActions = contextData == null
        ? const <QuickActionItem>[]
        : _suggestionService.quickActions(
            context: contextData,
            isArabic: i18n.isArabic,
          );

    final routeContext = contextData == null
        ? null
        : ChatRouteContextService.resolve(
            contextData.currentRoute,
            fallbackUnitSlug:
                contextData.unitSlug ?? contextData.unitId ?? 'home',
          );
    final List<AssistantKnowledgeSource> allowedSources =
        (contextData == null || routeContext == null)
        ? const <AssistantKnowledgeSource>[]
        : _governance.internalSources(
            routeContext: routeContext,
            roleLabel: contextData.roleLabel,
            permissions: contextData.permissions,
          );
    final sourcesPreview = allowedSources
        .take(3)
        .map((e) => i18n.isArabic ? e.labelAr : e.labelEn)
        .join(' • ');

    final capability = contextData == null
        ? null
        : _capabilityService.resolve(contextData);
    final List<AssistantDocReference> docReferences = contextData == null
        ? const <AssistantDocReference>[]
        : _docReferenceService.referencesFor(contextData);
    final AssistantSystemBridge? systemBridge = contextData == null
        ? null
        : _systemBridgeService.resolve(contextData);

    final resumeAction = contextData == null
        ? null
        : _resumeService.buildResumeAction(
            contextData,
            isArabic: i18n.isArabic,
          );

    final featureItems = contextData == null
        ? const <FeatureCardItem>[]
        : _suggestionService.featureCards(
            context: contextData,
            isArabic: i18n.isArabic,
          );

    Widget? topContent;
    if (contextData != null) {
      topContent = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AssistantContextSummary(
            contextData: contextData,
            isArabic: i18n.isArabic,
          ),
          const SizedBox(height: 14),
          AssistantSystemChips(
            contextData: contextData,
            isArabic: i18n.isArabic,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ChatPalette.panelFor(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ChatPalette.borderFor(context)),
            ),
            child: Row(
              children: [
                const Icon(Icons.rule_rounded, color: ChatPalette.royalRed),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    i18n.isArabic
                        ? 'النطاق المعرفي الحالي: ${contextData.knowledgeScopeLabel ?? _governance.scopeLabelAr(_governance.scopeForMode(isInternal: true))}. '
                              'السياق التشغيلي: ${contextData.surfaceKey}. المصادر المسموح بها: ${allowedSources.length}. '
                              '${sourcesPreview.isEmpty ? '' : 'أبرزها: $sourcesPreview. '}'
                              'الأفعال الحالية محكومة بالصلاحيات والسياق الحاليين، ولا يتم اقتراح تنفيذ مباشر خارج هذا النطاق.'
                        : 'Current knowledge scope: ${contextData.knowledgeScopeLabel ?? 'Internal'}. '
                              'Operational surface: ${contextData.surfaceKey}. Allowed sources: ${allowedSources.length}. '
                              '${sourcesPreview.isEmpty ? '' : 'Main sources: $sourcesPreview. '}'
                              'Current actions are governed by your permissions and current context, with no direct execution outside this scope.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (capability != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ChatPalette.panelFor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ChatPalette.borderFor(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        color: ChatPalette.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          i18n.isArabic
                              ? 'وضع الوصول: ${capability.accessModeAr} · الفئة: ${capability.roleTierAr}'
                              : 'Access mode: ${capability.accessModeEn} · Tier: ${capability.roleTierEn}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final label
                          in (i18n.isArabic
                              ? capability.capabilityLabelsAr
                              : capability.capabilityLabelsEn))
                        Chip(label: Text(label)),
                    ],
                  ),
                ],
              ),
            ),
          ],
          if (systemBridge != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ChatPalette.panelFor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ChatPalette.borderFor(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.hub_rounded, color: ChatPalette.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          i18n.isArabic
                              ? systemBridge.titleAr
                              : systemBridge.titleEn,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      Chip(
                        label: Text(
                          i18n.isArabic
                              ? systemBridge.statusLabelAr
                              : systemBridge.statusLabelEn,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    i18n.isArabic
                        ? systemBridge.summaryAr
                        : systemBridge.summaryEn,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final step
                          in (i18n.isArabic
                              ? systemBridge.nextStepsAr
                              : systemBridge.nextStepsEn))
                        Chip(label: Text(step)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final path in systemBridge.docPaths.take(3)) ...[
                    SelectableText(
                      path,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: ChatPalette.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ],
              ),
            ),
          ],
          if (docReferences.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ChatPalette.panelFor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ChatPalette.borderFor(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        color: ChatPalette.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          i18n.isArabic
                              ? 'المرجعيات الداخلية المقترحة لهذه الشاشة'
                              : 'Suggested internal references for this screen',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final item in docReferences.take(4)) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: ChatPalette.borderFor(context),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            i18n.isArabic ? item.titleAr : item.titleEn,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            i18n.isArabic ? item.summaryAr : item.summaryEn,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          SelectableText(
                            item.path,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: ChatPalette.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          if (resumeAction != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ChatPalette.panelFor(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ChatPalette.borderFor(context)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.replay_circle_filled_rounded,
                    color: ChatPalette.royalRed,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      resumeAction.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _handleQuickAction(notifier, resumeAction),
                    child: Text(i18n.isArabic ? 'ابدأ' : 'Start'),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }

    return ChatShell(
      pageTitle: i18n.pageTitle,
      headerTitle: i18n.headerTitle,
      headerSubtitle: i18n.headerSubtitle,
      headerIcon: Icons.assistant,
      mode: ChatExperienceMode.internalAssistant,
      messages: state.messages,
      isBotTyping: state.isBotTyping,
      inputHint: i18n.inputHint,
      errorMessage: state.errorMessage,
      quickActions: quickActions,
      featureItems: featureItems,
      allowVoiceInteraction: true,
      topContent: topContent,
      onSend: (text) => notifier.sendUserMessage(context: context, text: text),
      onQuickAction: (action) => _handleQuickAction(notifier, action),
      onFeatureTap: (item) => _handleFeatureTap(notifier, item),
    );
  }
}
