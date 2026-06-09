import '../../../assistant_core/data/services/chat_route_context_service.dart';
import '../models/assistant_context.dart';
import '../models/assistant_system_bridge.dart';

class AssistantSystemBridgeService {
  const AssistantSystemBridgeService();

  AssistantSystemBridge? resolve(AssistantContext context) {
    final routeContext = ChatRouteContextService.resolve(
      context.currentRoute,
      fallbackUnitSlug: context.unitSlug ?? context.unitId ?? 'home',
    );

    switch (routeContext.systemKey) {
      case 'mustakshif':
      case 'mustakshif_alwaqf':
        final assetHint = context.hasAssetContext
            ? 'يرتبط المسار الحالي بأصل وقفي/رمز وطني ويجب المحافظة على هذا السياق عند التنقل بين الخريطة، الطبقات، والتاريخ.'
            : 'المسار الحالي لا يحمل أصلًا وقفيًا محددًا بعد، لذلك تُعطى الأولوية للبحث ثم الخريطة ثم الطبقات.';
        final assetHintEn = context.hasAssetContext
            ? 'The current route is tied to a waqf asset/national code and this context must be preserved across map, layers, and history.'
            : 'The current route does not carry a specific waqf asset yet, so search, then map, then layers are prioritized.';
        return AssistantSystemBridge(
          id: 'mustakshif-bridge-v1',
          systemKey: 'mustakshif',
          titleAr: 'جسر مساعد مستكشف الوقف',
          titleEn: 'Mustakshif assistant bridge',
          summaryAr:
              'هذا الجسر يربط المساعد الداخلي بسياق مستكشف الوقف تدريجيًا دون فتح RAG واسع، مع الحفاظ على سياق الأصل الوقفي والصفحة الحالية.',
          summaryEn:
              'This bridge links the internal assistant to Mustakshif context incrementally without opening broad RAG, while preserving the current waqf-asset and page context.',
          statusLabelAr: 'المرحلة الرابعة — مفعّل لنظام واحد',
          statusLabelEn: 'Phase 4 — active for one system',
          nextStepsAr: <String>[
            'استخدام نفس سياق route الحالي عند فتح الخريطة والطبقات والتاريخ.',
            'الاعتماد على docs/systems ومرجع Mustakshif قبل أي توسع في التنفيذ الذكي.',
            assetHint,
          ],
          nextStepsEn: <String>[
            'Use the current route context consistently when opening map, layers, and history.',
            'Rely on docs/systems and Mustakshif references before any broader intelligent execution.',
            assetHintEn,
          ],
          docPaths: const <String>[
            'docs/systems/MUSTAKSHIF_ASSISTANT_BRIDGE_v1.md',
            'docs/systems/README_MASTER.md',
            'docs/admin/ASSISTANT_PHASE4_SYSTEM_BRIDGES_v1.md',
          ],
          routeHints: const <String>[
            '/mustakshif',
            '/mustakshif/history',
            '/mustakshif?panel=layers',
          ],
        );
      default:
        return null;
    }
  }
}
