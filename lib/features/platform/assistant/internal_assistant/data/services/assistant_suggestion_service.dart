// ignore_for_file: unused_element
import 'package:flutter/material.dart';

import '../../../assistant_core/data/models/feature_card_item.dart';
import '../../../assistant_core/data/models/quick_action_item.dart';
import '../models/assistant_context.dart';
import '../models/assistant_knowledge_source.dart';
import 'assistant_action_catalog_service.dart';
import 'assistant_capability_service.dart';
import 'assistant_doc_reference_service.dart';
import 'assistant_system_bridge_service.dart';
import 'assistant_knowledge_governance_service.dart';

class AssistantSuggestionService {
  const AssistantSuggestionService({
    AssistantActionCatalogService actionCatalog =
        const AssistantActionCatalogService(),
    AssistantKnowledgeGovernanceService governance =
        const AssistantKnowledgeGovernanceService(),
    AssistantCapabilityService capabilityService =
        const AssistantCapabilityService(),
    AssistantDocReferenceService docReferenceService =
        const AssistantDocReferenceService(),
    AssistantSystemBridgeService systemBridgeService =
        const AssistantSystemBridgeService(),
  }) : _actionCatalog = actionCatalog,
       _governance = governance,
       _capabilityService = capabilityService,
       _docReferenceService = docReferenceService,
       _systemBridgeService = systemBridgeService;

  final AssistantActionCatalogService _actionCatalog;
  final AssistantKnowledgeGovernanceService _governance;
  final AssistantCapabilityService _capabilityService;
  final AssistantDocReferenceService _docReferenceService;
  final AssistantSystemBridgeService _systemBridgeService;

  List<QuickActionItem> quickActions({
    required AssistantContext context,
    required bool isArabic,
  }) {
    return _actionCatalog
        .actionsFor(context)
        .map((action) {
          return QuickActionItem(
            id: action.id,
            label: isArabic ? action.labelAr : action.labelEn,
            icon: action.icon,
            route: action.route,
            message: isArabic
                ? (action.messageAr ?? action.labelAr)
                : (action.messageEn ?? action.labelEn),
          );
        })
        .toList(growable: false);
  }

  List<FeatureCardItem> featureCards({
    required AssistantContext context,
    required bool isArabic,
  }) {
    final governanceScope =
        context.knowledgeScopeLabel ??
        _governance.scopeLabelAr(AssistantKnowledgeScope.internal);
    switch (context.systemKey) {
      case 'mustakshif':
      case 'mustakshif_alwaqf':
        return [
          FeatureCardItem(
            id: 'map-analysis',
            icon: Icons.map_rounded,
            title: isArabic ? 'التحليل المكاني' : 'Spatial analysis',
            description: isArabic
                ? 'ابحث عن الأصل الوقفي وافتح الخريطة والطبقات والتاريخ من داخل السياق الحالي.'
                : 'Search for the waqf asset and open the map, layers, and history from the current context.',
            route: '/mustakshif?panel=map',
          ),
          FeatureCardItem(
            id: 'history-explorer',
            icon: Icons.timeline_rounded,
            title: isArabic ? 'مرحلة التاريخ' : 'History phase',
            description: isArabic
                ? 'اقتراحات مباشرة للوصول إلى المقارنة التاريخية والسلالات الإدارية.'
                : 'Direct suggestions for historical comparison and administrative lineage.',
            route: '/mustakshif/history?tab=timeline',
          ),
          FeatureCardItem(
            id: 'mustakshif-governance',
            icon: Icons.rule_rounded,
            title: isArabic ? 'نطاق المعرفة' : 'Knowledge scope',
            description: isArabic
                ? 'النطاق الحالي: $governanceScope'
                : 'Current scope: $governanceScope',
          ),
        ];
      case 'waqf_cases_system':
        return [
          FeatureCardItem(
            id: 'case-tracking',
            icon: Icons.gavel_rounded,
            title: isArabic ? 'متابعة القضايا' : 'Case tracking',
            description: isArabic
                ? 'اقتراحات لفتح القضايا والجلسات والوثائق المرتبطة بالأصل الوقفي.'
                : 'Suggestions to open cases, hearings, and documents related to the waqf asset.',
            route: '/admin/cases?status=open',
          ),
          FeatureCardItem(
            id: 'case-governance',
            icon: Icons.rule_rounded,
            title: isArabic ? 'نطاق المعرفة' : 'Knowledge scope',
            description: isArabic
                ? 'النطاق الحالي: $governanceScope'
                : 'Current scope: $governanceScope',
          ),
        ];
      case 'billing_system':
        return [
          FeatureCardItem(
            id: 'contracts',
            icon: Icons.description_rounded,
            title: isArabic ? 'العقود والإشغالات' : 'Contracts & occupancies',
            description: isArabic
                ? 'الوصول إلى العقود والفواتير والمتأخرات بحسب الأصل الوقفي أو الوحدة.'
                : 'Reach contracts, invoices, and arrears by waqf asset or unit.',
            route: '/billing?tab=contracts',
          ),
          FeatureCardItem(
            id: 'billing-governance',
            icon: Icons.rule_rounded,
            title: isArabic ? 'نطاق المعرفة' : 'Knowledge scope',
            description: isArabic
                ? 'النطاق الحالي: $governanceScope'
                : 'Current scope: $governanceScope',
          ),
        ];
      case 'tasks_system':
        return [
          FeatureCardItem(
            id: 'task-follow-up',
            icon: Icons.task_alt_rounded,
            title: isArabic ? 'المتابعة التشغيلية' : 'Operational follow-up',
            description: isArabic
                ? 'اقتراحات لمهام اليوم والمتأخرات والمهام المرتبطة بالأصل الوقفي.'
                : 'Suggestions for today tasks, overdue items, and waqf-asset tasks.',
            route: '/tasks?filter=today',
          ),
          FeatureCardItem(
            id: 'tasks-governance',
            icon: Icons.rule_rounded,
            title: isArabic ? 'نطاق المعرفة' : 'Knowledge scope',
            description: isArabic
                ? 'النطاق الحالي: $governanceScope'
                : 'Current scope: $governanceScope',
          ),
        ];
      case 'awqaf_system':
      default:
        return [
          FeatureCardItem(
            id: 'master-data',
            icon: Icons.apartment_rounded,
            title: isArabic ? 'البيانات السيادية' : 'Sovereign master data',
            description: isArabic
                ? 'اقتراحات مرتبطة بالأوقاف والواقفين والجغرافيا والسياسات ضمن النظام الحالي.'
                : 'Suggestions tied to endowments, endowers, geography, and policies in the current system.',
            route: '/admin/dashboard?focus=endowments',
          ),
          FeatureCardItem(
            id: 'unit-pages',
            icon: Icons.web_rounded,
            title: isArabic ? 'صفحات الوحدات' : 'Unit pages',
            description: isArabic
                ? 'يساعدك على فتح إدارة الصفحة الرئيسية وصفحات الوحدات والروابط العامة.'
                : 'Helps open home management, unit pages, and public links.',
            route: '/admin/home-management?tab=unit_pages',
          ),
          FeatureCardItem(
            id: 'governance',
            icon: Icons.rule_rounded,
            title: isArabic ? 'الحوكمة والمعرفة' : 'Governance & knowledge',
            description: isArabic
                ? 'النطاق الحالي: $governanceScope'
                : 'Current scope: $governanceScope',
          ),
        ];
    }
  }

  String welcomeMessage({
    required AssistantContext context,
    required bool isArabic,
  }) {
    final pageLabel = context.currentPageLabel ?? context.currentRoute;
    final permissionsLabel = context.permissions.isEmpty
        ? (isArabic ? 'صلاحيات عامة فقط' : 'General permissions only')
        : context.permissions.join(' • ');
    final topActions = _topActionLabels(
      context,
      isArabic: isArabic,
    ).join(isArabic ? '، ' : ', ');
    final capability = _capabilityService.resolve(context);
    final docsCount = _docReferenceService.referencesFor(context).length;
    final bridge = _systemBridgeService.resolve(context);
    return isArabic
        ? 'مرحبًا ${context.displayName}!\n\n'
              'أنت الآن داخل ${context.systemLabel} بصلاحية ${context.roleLabel}.\n'
              'الصفحة الحالية: $pageLabel\n'
              'النطاق المعرفي: ${context.knowledgeScopeLabel ?? 'داخلي'}\n'
              'وضع الوصول: ${capability.accessModeAr}\n\n'
              'أقرب الإجراءات المناسبة لك الآن: $topActions\n'
              'صلاحياتك الحالية: $permissionsLabel\n'
              '${bridge == null ? '' : 'جسر النظام النشط: ${bridge.titleAr}\n'}'
              'المرجعيات الداخلية المتاحة لك الآن: $docsCount'
        : 'Welcome ${context.displayName}!\n\n'
              'You are inside ${context.systemLabel} with the role ${context.roleLabel}.\n'
              'Current page: $pageLabel\n'
              'Knowledge scope: ${context.knowledgeScopeLabel ?? 'Internal'}\n'
              'Access mode: ${capability.accessModeEn}\n\n'
              'Best actions for you now: $topActions\n'
              'Current permissions: $permissionsLabel\n'
              '${bridge == null ? '' : 'Active system bridge: ${bridge.titleEn}\n'}'
              'Available internal references right now: $docsCount';
  }

  String followupReply({
    required AssistantContext context,
    required String userMessage,
    required bool isArabic,
  }) {
    final lower = userMessage.toLowerCase();
    final topActions = _topActionLabels(context, isArabic: isArabic);

    if (lower.contains('resume') ||
        lower.contains('تابع') ||
        lower.contains('اكمل')) {
      final last = context.lastActionLabel;
      if (last != null && last.trim().isNotEmpty) {
        return isArabic
            ? 'سأعتبر أن نقطة الاستئناف هي: $last. يمكنك فتحها مباشرة من بطاقة الاستئناف أو من الاقتراحات العملية أدناه.'
            : 'I will treat "$last" as the resume point. You can open it directly from the resume card or the practical suggestions below.';
      }
    }

    if (lower.contains('permission') || lower.contains('صلاح')) {
      final permissions = context.permissions.isEmpty
          ? (isArabic
                ? 'لا توجد صلاحيات تفصيلية ممررة حاليًا.'
                : 'No detailed permissions were passed yet.')
          : context.permissions.join(', ');
      return isArabic
          ? 'صلاحياتك الحالية داخل ${context.systemLabel}: $permissions'
          : 'Your current permissions inside ${context.systemLabel}: $permissions';
    }

    if (lower.contains('source') ||
        lower.contains('مصدر') ||
        lower.contains('معرفة')) {
      return isArabic
          ? 'نطاق الإجابة الحالي هو: ${context.knowledgeScopeLabel ?? 'داخلي'}. أستخدم فقط مصادر داخلية معتمدة مرتبطة بالنظام والصفحة الحالية.'
          : 'The current answer scope is: ${context.knowledgeScopeLabel ?? 'Internal'}. I only use approved internal sources tied to the current system and page.';
    }

    if (lower.contains('bridge') ||
        lower.contains('جسر') ||
        lower.contains('system link') ||
        lower.contains('ربط النظام')) {
      final bridge = _systemBridgeService.resolve(context);
      if (bridge == null) {
        return isArabic
            ? 'لا يوجد جسر نظام مفعّل بعد لهذا السياق. أستخدم الآن الإرشاد الداخلي العام المرتبط بالنظام والصفحة الحالية.'
            : 'There is no active system bridge for this context yet. I currently use general internal guidance tied to the system and current page.';
      }
      final steps = (isArabic ? bridge.nextStepsAr : bridge.nextStepsEn)
          .map((e) => '• $e')
          .join('\n');
      return isArabic
          ? '${bridge.titleAr}\n${bridge.summaryAr}\n\nالخطوات/الضوابط الحالية:\n$steps'
          : '${bridge.titleEn}\n${bridge.summaryEn}\n\nCurrent steps / guardrails:\n$steps';
    }

    if (lower.contains('وثيقة') ||
        lower.contains('doc') ||
        lower.contains('docs') ||
        lower.contains('مرجع') ||
        lower.contains('policy') ||
        lower.contains('حوكمة')) {
      final docs = _docReferenceService
          .referencesFor(context)
          .take(3)
          .toList(growable: false);
      if (docs.isEmpty) {
        return isArabic
            ? 'لا توجد مرجعيات داخلية إضافية متاحة لك في هذا السياق خارج إرشاد المسار الحالي.'
            : 'There are no extra internal references available for you in this context beyond current route guidance.';
      }
      final lines = docs
          .map(
            (e) => isArabic
                ? '• ${e.titleAr}: ${e.path}'
                : '• ${e.titleEn}: ${e.path}',
          )
          .join('\n');
      return isArabic
          ? 'المرجعيات الأقرب لك الآن داخل ${context.systemLabel}:\n$lines'
          : 'The closest references for you now inside ${context.systemLabel}:\n$lines';
    }

    if (lower.contains('rbac') ||
        lower.contains('role') ||
        lower.contains('دور') ||
        lower.contains('صلاح')) {
      final capability = _capabilityService.resolve(context);
      final labels = isArabic
          ? capability.capabilityLabelsAr.join('، ')
          : capability.capabilityLabelsEn.join(', ');
      return isArabic
          ? 'الدور الحالي: ${context.roleLabel}. وضع الوصول: ${capability.accessModeAr}. القدرات المتاحة: $labels'
          : 'Current role: ${context.roleLabel}. Access mode: ${capability.accessModeEn}. Available capabilities: $labels';
    }

    if (lower.contains('افتح') ||
        lower.contains('open') ||
        lower.contains('اذهب') ||
        lower.contains('go to')) {
      return isArabic
          ? 'سأتعامل مع طلبك كإجراء تنقّل داخل ${context.systemLabel}. أقرب الاختصارات لك الآن: ${topActions.join('، ')}. استخدم الأزرار المقترحة لأنها تفتح صفحات جاهزة مع فلاتر أولية مرتبطة بالسياق الحالي.'
          : 'I will treat your request as an in-system navigation action inside ${context.systemLabel}. Your closest shortcuts now are: ${topActions.join(', ')}. Use the suggested buttons because they open ready pages with initial filters tied to the current context.';
    }

    return isArabic
        ? 'فهمت سؤالك: "$userMessage"\n\nأنا الآن داخل ${context.systemLabel} وعلى الصفحة ${context.currentPageLabel ?? context.currentRoute}. سأركز على اقتراحات عملية مرتبطة بهذه الصفحة، وأقرب الخطوات المناسبة الآن هي: ${topActions.join('، ')}.'
        : 'I understand your request: "$userMessage"\n\nI am currently inside ${context.systemLabel} on ${context.currentPageLabel ?? context.currentRoute}. I will focus on practical suggestions tied to this page, and the most relevant next steps now are: ${topActions.join(', ')}.';
  }

  String _contextSummaryAr(AssistantContext context) {
    final parts = <String>[];
    final unit = (context.unitSlug ?? context.unitId ?? '').trim();
    final assetId = (context.waqfAssetId ?? '').trim();
    final assetCode = (context.nationalAssetCode ?? '').trim();
    if (unit.isNotEmpty) {
      parts.add('الوحدة الحالية: $unit.');
    }
    if (assetId.isNotEmpty) {
      parts.add('الأصل الوقفي الحالي: $assetId.');
    } else if (assetCode.isNotEmpty) {
      parts.add('الرمز الوطني الحالي: $assetCode.');
    }
    return parts.join(' ');
  }

  String _contextSummaryEn(AssistantContext context) {
    final parts = <String>[];
    final unit = (context.unitSlug ?? context.unitId ?? '').trim();
    final assetId = (context.waqfAssetId ?? '').trim();
    final assetCode = (context.nationalAssetCode ?? '').trim();
    if (unit.isNotEmpty) {
      parts.add('Current unit: $unit.');
    }
    if (assetId.isNotEmpty) {
      parts.add('Current waqf asset: $assetId.');
    } else if (assetCode.isNotEmpty) {
      parts.add('Current national code: $assetCode.');
    }
    return parts.join(' ');
  }

  List<String> _topActionLabels(
    AssistantContext context, {
    required bool isArabic,
  }) {
    final actions = _actionCatalog.actionsFor(context).take(3);
    return actions
        .map((a) => isArabic ? a.labelAr : a.labelEn)
        .toList(growable: false);
  }
}
