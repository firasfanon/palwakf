import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../assistant_core/data/models/chat_experience_mode.dart';
import '../../../assistant_core/data/models/feature_card_item.dart';
import '../../../assistant_core/data/models/quick_action_item.dart';
import '../../../assistant_core/presentation/theme/chat_palette.dart';
import '../../../assistant_core/data/services/chat_route_context_service.dart';
import '../../../assistant_core/presentation/widgets/chat_shell.dart';
import 'package:waqf/features/platform/public_runtime/presentation/widgets/pwf_public_interactive_tool_shell.dart';
import '../i18n/public_chatbot_i18n.dart';
import '../providers/public_chatbot_provider.dart';

class PublicChatbotPage extends ConsumerStatefulWidget {
  const PublicChatbotPage({
    super.key,
    this.unitId = defaultUnitId,
    this.publicSessionId,
    this.embedInPublicShell = false,
  });

  static const String defaultUnitId = 'public-platform-unit';

  final String unitId;
  final String? publicSessionId;
  final bool embedInPublicShell;

  @override
  ConsumerState<PublicChatbotPage> createState() => _PublicChatbotPageState();
}

class _PublicChatbotPageState extends ConsumerState<PublicChatbotPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(publicChatbotProvider.notifier)
          .ensureBootstrapped(
            context,
            unitId: widget.unitId,
            publicSessionId: widget.publicSessionId,
            currentRoute: GoRouterState.of(context).uri.toString(),
          );
    });
  }

  void _handleQuickAction(
    PublicChatbotNotifier notifier,
    QuickActionItem action,
  ) {
    if (action.route != null && action.route!.trim().isNotEmpty) {
      context.go(action.route!);
      return;
    }
    final message = action.message ?? action.label;
    notifier.onQuickAction(context: context, question: message);
  }

  void _handleFeatureTap(PublicChatbotNotifier notifier, FeatureCardItem item) {
    if (item.route != null && item.route!.trim().isNotEmpty) {
      context.go(item.route!);
      return;
    }
    notifier.onQuickAction(context: context, question: item.title);
  }

  @override
  Widget build(BuildContext context) {
    final i18n = PublicChatbotI18n.of(context);
    final state = ref.watch(publicChatbotProvider);
    final notifier = ref.read(publicChatbotProvider.notifier);
    final routeContext = ChatRouteContextService.resolve(
      GoRouterState.of(context).uri.toString(),
      fallbackUnitSlug: widget.unitId,
    );

    final topContent = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ChatPalette.panelFor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ChatPalette.borderFor(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_user_rounded, color: ChatPalette.royalRed),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              i18n.isArabic
                  ? 'أنت الآن في صفحة ${routeContext.pageLabelAr}. اسأل عن الخدمات والمعلومات العامة المرتبطة بهذه الصفحة، وسأوجهك إلى المسار المناسب عند الحاجة.'
                  : 'You are now on ${routeContext.pageLabelEn}. Ask about public information or services related to this page.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    final chatShell = ChatShell(
      pageTitle: i18n.pageTitle,
      headerTitle: i18n.headerTitle,
      headerSubtitle: i18n.headerSubtitle,
      headerIcon: Icons.support_agent_rounded,
      mode: ChatExperienceMode.publicChatbot,
      messages: state.messages,
      isBotTyping: state.isBotTyping,
      inputHint: i18n.inputHint,
      errorMessage: state.errorMessage,
      quickActions: i18n.quickActions(),
      featureItems: i18n.featureCards(),
      topContent: topContent,
      embedInParent: widget.embedInPublicShell,
      showHeader: !widget.embedInPublicShell,
      allowVoiceInteraction: true,
      onSend: (text) => notifier.sendUserMessage(context: context, text: text),
      onQuickAction: (action) => _handleQuickAction(notifier, action),
      onFeatureTap: (item) => _handleFeatureTap(notifier, item),
    );

    if (widget.embedInPublicShell) {
      return PwfPublicInteractiveToolShell(
        unitSlug: widget.unitId,
        canonicalRoute: '/home/chat',
        title: i18n.pageTitle,
        subtitle:
            'مساعد عام يجيب عن الأسئلة الشائعة ويوجهك إلى الصفحات والخدمات المناسبة داخل الموقع.',
        icon: Icons.support_agent_rounded,
        child: chatShell,
      );
    }

    return chatShell;
  }
}
