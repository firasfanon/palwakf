import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:waqf/app/routing/app_routes.dart';

import '../../../data/services/pwf_services_request_rpc_adapter.dart';
import 'package:waqf/features/platform/media_center/data/models/pwf_platform_center_content_item.dart';
import 'package:waqf/features/platform/media_center/presentation/providers/pwf_platform_center_content_providers.dart';

import '../pwf_web_page_scaffold.dart';
import '../../widgets/pwf_section_container.dart';

class PwfMediaCenterPublicHubScreen extends StatelessWidget {
  const PwfMediaCenterPublicHubScreen({super.key, required this.unitSlug});

  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    return PwfPlatformFrontendHubPage(
      unitSlug: unitSlug,
      contentFamilyKey: 'media_center',
      title: 'المركز الإعلامي',
      subtitle:
          'بوابة المحتوى الرسمي للوزارة والوحدات: أخبار، إعلانات، أنشطة، فعاليات، اجتماعيات، وسائط، تقارير، ومرصد حماية المقدسات.',
      eyebrow: 'إعلام رسمي موثق',
      icon: Icons.perm_media_outlined,
      primaryRoute: AppRoutes.news,
      primaryLabel: 'تصفح الأخبار',
      secondaryRoute: AppRoutes.sanctitiesObservatory,
      secondaryLabel: 'مرصد حماية المقدسات',
      metrics: const [
        PwfFrontendMetric(
          label: 'عائلات محتوى',
          value: '12+',
          icon: Icons.category_outlined,
        ),
        PwfFrontendMetric(
          label: 'فصل تشغيلي',
          value: 'أنشطة / فعاليات',
          icon: Icons.event_available_outlined,
        ),
        PwfFrontendMetric(
          label: 'حوكمة',
          value: 'نشر بمراجعة',
          icon: Icons.verified_user_outlined,
        ),
      ],
      cards: const [
        PwfFrontendHubCard(
          title: 'الأخبار',
          description:
              'الأخبار الرسمية للوزارة والوحدات مع فصل واضح بين محتوى الوزارة ومحتوى المديريات.',
          route: AppRoutes.news,
          icon: Icons.newspaper_outlined,
        ),
        PwfFrontendHubCard(
          title: 'الإعلانات',
          description:
              'إعلانات عامة أو موجهة حسب النطاق، مع تاريخ ظهور وحالة نشر واضحة.',
          route: AppRoutes.announcements,
          icon: Icons.campaign_outlined,
        ),
        PwfFrontendHubCard(
          title: 'الأنشطة',
          description: 'توثيق النشاط المؤسسي والميداني كأرشيف عمل رسمي.',
          route: AppRoutes.activities,
          icon: Icons.event_note_outlined,
        ),
        PwfFrontendHubCard(
          title: 'الفعاليات',
          description:
              'أحداث لها موعد ومكان وحالة قادمة أو منتهية، منفصلة عن أرشيف الأنشطة.',
          route: AppRoutes.events,
          icon: Icons.celebration_outlined,
        ),
        PwfFrontendHubCard(
          title: 'الاجتماعيات',
          description:
              'تهاني وتعازي ومناسبات اجتماعية رسمية، وليست خدمات اجتماعية أو معاملات جمهور.',
          route: AppRoutes.socialPosts,
          icon: Icons.groups_2_outlined,
        ),
        PwfFrontendHubCard(
          title: 'خُطب الجمعة',
          description:
              'أرشفة ونشر محتوى خطب الجمعة وفق اعتماد إداري/شرعي مناسب.',
          route: AppRoutes.fridaySermon,
          icon: Icons.mic_none_outlined,
        ),
        PwfFrontendHubCard(
          title: 'مرصد حماية المقدسات',
          description:
              'رصد حكومي موثق للوقائع والانتهاكات مع إحصائيات وتقارير قابلة للاستشهاد.',
          route: AppRoutes.sanctitiesObservatory,
          icon: Icons.shield_outlined,
        ),
        PwfFrontendHubCard(
          title: 'مكتبة المواد الإعلامية',
          description:
              'صور وفيديوهات ومواد تعريفية وهوية إعلامية قابلة للنشر والاستخدام المؤسسي.',
          route: AppRoutes.mediaCenter,
          icon: Icons.folder_special_outlined,
        ),
      ],
      infoBlocks: const [
        PwfFrontendInfoBlock(
          title: 'قاعدة النشر',
          body:
              'كل محتوى منشور يجب أن يحمل نطاقًا واضحًا: وزارة، وحدة، أو نظام مرتبط، مع حالة نشر وأثر تدقيق.',
        ),
        PwfFrontendInfoBlock(
          title: 'الفصل المعتمد',
          body:
              'الاجتماعيات والأنشطة والفعاليات تبقى داخل المركز الإعلامي، ولا تُنقل إلى مركز الخدمات.',
        ),
      ],
    );
  }
}

class PwfLegalReferencesPublicScreen extends StatelessWidget {
  const PwfLegalReferencesPublicScreen({super.key, required this.unitSlug});

  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    return PwfPlatformFrontendHubPage(
      unitSlug: unitSlug,
      contentFamilyKey: 'legal_references',
      title: 'الأنظمة والقوانين والتعليمات',
      subtitle:
          'مرجع رسمي للقوانين والأنظمة والتعليمات والتعاميم والأدلة والنماذج ذات العلاقة بالمؤسسة وخدماتها.',
      eyebrow: 'مراجع حكومية رسمية',
      icon: Icons.gavel_outlined,
      primaryRoute: AppRoutes.services,
      primaryLabel: 'العودة لدليل الخدمات',
      secondaryRoute: AppRoutes.mediaCenter,
      secondaryLabel: 'المركز الإعلامي',
      metrics: const [
        PwfFrontendMetric(
          label: 'أنواع مراجع',
          value: '6',
          icon: Icons.rule_folder_outlined,
        ),
        PwfFrontendMetric(
          label: 'نطاق العرض',
          value: 'عام / داخلي',
          icon: Icons.visibility_outlined,
        ),
        PwfFrontendMetric(
          label: 'مصدر ملفات',
          value: 'مركز الوثائق',
          icon: Icons.folder_copy_outlined,
        ),
      ],
      cards: const [
        PwfFrontendHubCard(
          title: 'القوانين والأنظمة',
          description:
              'فهرسة القوانين والأنظمة واللوائح ذات العلاقة بعمل المؤسسة.',
          route: AppRoutes.legalReferences,
          icon: Icons.balance_outlined,
        ),
        PwfFrontendHubCard(
          title: 'التعليمات والتعاميم',
          description: 'تعليمات وتعاميم عامة أو داخلية حسب الصلاحية والنطاق.',
          route: AppRoutes.legalReferences,
          icon: Icons.rule_folder_outlined,
        ),
        PwfFrontendHubCard(
          title: 'الأدلة الإجرائية',
          description:
              'أدلة خدمة وإجراءات رسمية مرتبطة بدليل الخدمات والنماذج.',
          route: AppRoutes.legalReferences,
          icon: Icons.assignment_outlined,
        ),
        PwfFrontendHubCard(
          title: 'النماذج الرسمية',
          description:
              'نماذج عامة أو مرتبطة بالخدمات، قابلة للربط بمركز الوثائق.',
          route: AppRoutes.legalReferences,
          icon: Icons.description_outlined,
        ),
        PwfFrontendHubCard(
          title: 'القرارات ذات العلاقة',
          description: 'قرارات وتعليمات تنفيذية ذات أثر تنظيمي أو خدمي.',
          route: AppRoutes.legalReferences,
          icon: Icons.fact_check_outlined,
        ),
        PwfFrontendHubCard(
          title: 'الأسئلة المرجعية',
          description:
              'إجابات مختصرة قابلة للربط لاحقًا بالمساعد الداخلي مع الاستشهاد بالمصدر.',
          route: AppRoutes.legalReferences,
          icon: Icons.help_outline_rounded,
        ),
      ],
      infoBlocks: const [
        PwfFrontendInfoBlock(
          title: 'ليست محتوى إعلاميًا',
          body:
              'هذه الصفحة مرجع حكومي رسمي يخدم الجمهور والموظفين والوحدات، ولا تُدار كخبر أو إعلان.',
        ),
        PwfFrontendInfoBlock(
          title: 'الربط المستقبلي',
          body:
              'يرتبط هذا القسم بمركز الوثائق كمصدر ملفات، وبالمساعد الداخلي للإجابات المستندة إلى الاستشهادات.',
        ),
      ],
    );
  }
}

class PwfSanctitiesObservatoryPublicScreen extends StatelessWidget {
  const PwfSanctitiesObservatoryPublicScreen({
    super.key,
    required this.unitSlug,
  });

  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    return PwfPlatformFrontendHubPage(
      unitSlug: unitSlug,
      contentFamilyKey: 'sanctities_observatory',
      title: 'مرصد حماية المقدسات',
      subtitle:
          'توثيق حكومي منضبط للوقائع والانتهاكات والاعتداءات على المقدسات والأماكن الوقفية مع إحصائيات وتقارير رسمية.',
      eyebrow: 'رصد وتوثيق وتحليل',
      icon: Icons.shield_outlined,
      primaryRoute: AppRoutes.mediaCenter,
      primaryLabel: 'فتح المركز الإعلامي',
      secondaryRoute: AppRoutes.legalReferences,
      secondaryLabel: 'المراجع الرسمية',
      metrics: const [
        PwfFrontendMetric(
          label: 'مصادر تحقق',
          value: 'متعددة',
          icon: Icons.fact_check_outlined,
        ),
        PwfFrontendMetric(
          label: 'ربط قانوني',
          value: 'cases',
          icon: Icons.gavel_outlined,
        ),
        PwfFrontendMetric(
          label: 'تحليل مكاني',
          value: 'mustakshif',
          icon: Icons.map_outlined,
        ),
      ],
      cards: const [
        PwfFrontendHubCard(
          title: 'سجل الوقائع',
          description: 'وقائع موثقة حسب المكان والنوع والتاريخ ومستوى التحقق.',
          route: AppRoutes.sanctitiesObservatory,
          icon: Icons.article_outlined,
        ),
        PwfFrontendHubCard(
          title: 'المواقع المشمولة',
          description:
              'المسجد الأقصى، الحرم الإبراهيمي، المساجد، المقامات، والمقابر الوقفية.',
          route: AppRoutes.sanctitiesObservatory,
          icon: Icons.location_on_outlined,
        ),
        PwfFrontendHubCard(
          title: 'الإحصائيات',
          description: 'مؤشرات حسب المحافظة ونوع المكان والحالة ودرجة التحقق.',
          route: AppRoutes.sanctitiesObservatory,
          icon: Icons.bar_chart_outlined,
        ),
        PwfFrontendHubCard(
          title: 'التقارير الرسمية',
          description: 'تقارير شهرية أو خاصة قابلة للنشر والاستشهاد المؤسسي.',
          route: AppRoutes.sanctitiesObservatory,
          icon: Icons.summarize_outlined,
        ),
        PwfFrontendHubCard(
          title: 'الأدلة والمرفقات',
          description:
              'ربط أدلة الصور والوثائق لاحقًا بمركز الوثائق دون ازدواجية تخزين.',
          route: AppRoutes.sanctitiesObservatory,
          icon: Icons.attach_file_outlined,
        ),
        PwfFrontendHubCard(
          title: 'المتابعة',
          description:
              'إحالة الوقائع إلى القضايا أو المهام عند الحاجة وفق صلاحيات واضحة.',
          route: AppRoutes.sanctitiesObservatory,
          icon: Icons.task_alt_outlined,
        ),
      ],
      infoBlocks: const [
        PwfFrontendInfoBlock(
          title: 'لغة حكومية موثقة',
          body:
              'المرصد لا يستخدم خطابًا انفعاليًا؛ يعرض وقائع موثقة، مصادر تحقق، وإحصائيات قابلة للتدقيق.',
        ),
        PwfFrontendInfoBlock(
          title: 'حدود السيادة',
          body:
              'mustakshif للتحليل المكاني فقط، وwaqf_assets يصبح رابطًا سياديًا عند اكتماله لاحقًا.',
        ),
      ],
    );
  }
}

class PwfMediaFamilyPublicScreen extends StatelessWidget {
  const PwfMediaFamilyPublicScreen({
    super.key,
    required this.unitSlug,
    required this.familyKey,
  });

  final String unitSlug;
  final String familyKey;

  @override
  Widget build(BuildContext context) {
    final spec = _PwfMediaFamilySpec.resolve(familyKey);
    return PwfPlatformFrontendHubPage(
      unitSlug: unitSlug,
      contentFamilyKey: familyKey.replaceAll('-', '_'),
      title: spec.title,
      subtitle: spec.subtitle,
      eyebrow: spec.eyebrow,
      icon: spec.icon,
      primaryRoute: AppRoutes.mediaCenter,
      primaryLabel: 'العودة إلى المركز الإعلامي',
      secondaryRoute: AppRoutes.sanctitiesObservatory,
      secondaryLabel: 'مرصد حماية المقدسات',
      metrics: spec.metrics,
      cards: spec.cards,
      infoBlocks: spec.infoBlocks,
    );
  }
}

class _PwfMediaFamilySpec {
  const _PwfMediaFamilySpec({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.eyebrow,
    required this.icon,
    required this.metrics,
    required this.cards,
    required this.infoBlocks,
  });

  final String key;
  final String title;
  final String subtitle;
  final String eyebrow;
  final IconData icon;
  final List<PwfFrontendMetric> metrics;
  final List<PwfFrontendHubCard> cards;
  final List<PwfFrontendInfoBlock> infoBlocks;

  static _PwfMediaFamilySpec resolve(String key) {
    return _specs[key] ?? _specs['media-library']!;
  }

  static const Map<String, _PwfMediaFamilySpec> _specs = {
    'social-posts': _PwfMediaFamilySpec(
      key: 'social-posts',
      title: 'الاجتماعيات',
      subtitle:
          'تهاني وتعازي ومناسبات اجتماعية رسمية ضمن المركز الإعلامي، وليست خدمات اجتماعية أو معاملات جمهور.',
      eyebrow: 'محتوى اجتماعي إعلامي',
      icon: Icons.groups_2_outlined,
      metrics: [
        PwfFrontendMetric(
          label: 'التصنيف',
          value: 'إعلامي',
          icon: Icons.category_outlined,
        ),
        PwfFrontendMetric(
          label: 'النطاق',
          value: 'وزارة / وحدة',
          icon: Icons.account_tree_outlined,
        ),
        PwfFrontendMetric(
          label: 'النشر',
          value: 'بمراجعة',
          icon: Icons.verified_outlined,
        ),
      ],
      cards: [
        PwfFrontendHubCard(
          title: 'تهاني رسمية',
          description: 'رسائل تهنئة مرتبطة بالمناسبات العامة والمؤسسية.',
          route: AppRoutes.socialPosts,
          icon: Icons.celebration_outlined,
        ),
        PwfFrontendHubCard(
          title: 'تعازي ومواساة',
          description: 'منشورات تعزية بصياغة حكومية منضبطة ومراجعة.',
          route: AppRoutes.socialPosts,
          icon: Icons.volunteer_activism_outlined,
        ),
        PwfFrontendHubCard(
          title: 'مناسبات اجتماعية',
          description:
              'محتوى اجتماعي مرتبط بالمؤسسة أو الوحدات، ضمن سياسة نشر واضحة.',
          route: AppRoutes.socialPosts,
          icon: Icons.event_note_outlined,
        ),
      ],
      infoBlocks: [
        PwfFrontendInfoBlock(
          title: 'التصنيف الصحيح',
          body:
              'الاجتماعيات ضمن المركز الإعلامي، ولا تظهر ضمن مركز الخدمات أو الخدمات الإلكترونية.',
        ),
        PwfFrontendInfoBlock(
          title: 'النطاق',
          body:
              'يمكن أن يكون المحتوى مركزيًا أو مخصصًا للوحدة عبر unitSlug ضمن نفس renderer.',
        ),
      ],
    ),
    'press-releases': _PwfMediaFamilySpec(
      key: 'press-releases',
      title: 'البيانات الصحفية',
      subtitle:
          'بيانات صحفية رسمية مصنفة حسب الموضوع والجهة والحالة وقابلة للأرشفة والاستشهاد.',
      eyebrow: 'بيانات رسمية',
      icon: Icons.description_outlined,
      metrics: [
        PwfFrontendMetric(
          label: 'صياغة',
          value: 'رسمية',
          icon: Icons.edit_document,
        ),
        PwfFrontendMetric(
          label: 'مراجعة',
          value: 'إعلامية',
          icon: Icons.fact_check_outlined,
        ),
        PwfFrontendMetric(
          label: 'أرشفة',
          value: 'قابلة للاستشهاد',
          icon: Icons.archive_outlined,
        ),
      ],
      cards: [
        PwfFrontendHubCard(
          title: 'بيانات الوزارة',
          description: 'بيانات مركزية صادرة عن الوزارة أو الناطق الرسمي.',
          route: AppRoutes.pressReleases,
          icon: Icons.account_balance_outlined,
        ),
        PwfFrontendHubCard(
          title: 'بيانات الوحدات',
          description: 'بيانات نطاقية تظهر عبر unitSlug عند اعتمادها.',
          route: AppRoutes.pressReleases,
          icon: Icons.business_outlined,
        ),
        PwfFrontendHubCard(
          title: 'الأرشيف الصحفي',
          description: 'أرشفة قابلة للبحث حسب التاريخ والموضوع والحالة.',
          route: AppRoutes.pressReleases,
          icon: Icons.folder_copy_outlined,
        ),
      ],
      infoBlocks: [
        PwfFrontendInfoBlock(
          title: 'مصدر رسمي',
          body:
              'البيانات الصحفية لا تختلط بالأخبار القصيرة أو الإعلانات الخدمية.',
        ),
        PwfFrontendInfoBlock(
          title: 'الحوكمة',
          body: 'النشر النهائي يحتاج مراجعة إعلامية وصلاحية نشر مناسبة.',
        ),
      ],
    ),
    'official-statements': _PwfMediaFamilySpec(
      key: 'official-statements',
      title: 'التصريحات الرسمية',
      subtitle: 'تصريحات رسمية موجزة أو موسعة من الجهات المخولة داخل المؤسسة.',
      eyebrow: 'تصريح رسمي',
      icon: Icons.record_voice_over_outlined,
      metrics: [
        PwfFrontendMetric(
          label: 'مصدر',
          value: 'مخول',
          icon: Icons.verified_user_outlined,
        ),
        PwfFrontendMetric(
          label: 'نطاق',
          value: 'عام / وحدة',
          icon: Icons.visibility_outlined,
        ),
        PwfFrontendMetric(
          label: 'أثر',
          value: 'إعلامي',
          icon: Icons.campaign_outlined,
        ),
      ],
      cards: [
        PwfFrontendHubCard(
          title: 'تصريحات عامة',
          description:
              'تصريحات قصيرة قابلة للنشر في الصفحة العامة والمركز الإعلامي.',
          route: AppRoutes.officialStatements,
          icon: Icons.campaign_outlined,
        ),
        PwfFrontendHubCard(
          title: 'تصريحات حسب الموضوع',
          description: 'تصنيف حسب ملف أو مناسبة أو قضية ذات صلة.',
          route: AppRoutes.officialStatements,
          icon: Icons.topic_outlined,
        ),
        PwfFrontendHubCard(
          title: 'تصريحات الوحدات',
          description: 'تصريحات محددة النطاق تظهر عبر صفحات الوحدات.',
          route: AppRoutes.officialStatements,
          icon: Icons.account_tree_outlined,
        ),
      ],
      infoBlocks: [
        PwfFrontendInfoBlock(
          title: 'لا نشر بلا تخويل',
          body: 'هذه العائلة تحتاج جهة مخولة وحالة نشر واضحة.',
        ),
        PwfFrontendInfoBlock(
          title: 'الفصل',
          body: 'التصريحات ليست إعلانات خدمة ولا بديلًا عن البيانات الصحفية.',
        ),
      ],
    ),
    'awareness-campaigns': _PwfMediaFamilySpec(
      key: 'awareness-campaigns',
      title: 'الحملات التوعوية',
      subtitle:
          'حملات توعوية وإرشادية ذات أهداف ورسائل وجمهور مستهدف ومواد نشر مرتبطة.',
      eyebrow: 'حملات وإرشاد',
      icon: Icons.psychology_alt_outlined,
      metrics: [
        PwfFrontendMetric(
          label: 'رسائل',
          value: 'محددة',
          icon: Icons.message_outlined,
        ),
        PwfFrontendMetric(
          label: 'مواد',
          value: 'صور / فيديو',
          icon: Icons.collections_outlined,
        ),
        PwfFrontendMetric(
          label: 'متابعة',
          value: 'مؤشرات',
          icon: Icons.insights_outlined,
        ),
      ],
      cards: [
        PwfFrontendHubCard(
          title: 'حملات دينية وإرشادية',
          description: 'حملات توعية مرتبطة برسالة المؤسسة وخدماتها العامة.',
          route: AppRoutes.awarenessCampaigns,
          icon: Icons.menu_book_outlined,
        ),
        PwfFrontendHubCard(
          title: 'حملات حماية المقدسات',
          description: 'مواد توعية مرتبطة بمرصد حماية المقدسات والاعتداءات.',
          route: AppRoutes.sanctitiesObservatory,
          icon: Icons.shield_outlined,
        ),
        PwfFrontendHubCard(
          title: 'مكتبة المواد',
          description: 'ربط مواد الحملة بمكتبة إعلامية قابلة للنشر.',
          route: AppRoutes.mediaCenter,
          icon: Icons.photo_library_outlined,
        ),
      ],
      infoBlocks: [
        PwfFrontendInfoBlock(
          title: 'أهداف قابلة للقياس',
          body: 'الحملة يجب أن تحمل هدفًا ورسائل وجمهورًا وفترة نشر.',
        ),
        PwfFrontendInfoBlock(
          title: 'لا خلط مع الخدمات',
          body: 'الحملات التوعوية محتوى إعلامي، وليست مسار تقديم معاملة.',
        ),
      ],
    ),
    'media-library': _PwfMediaFamilySpec(
      key: 'media-library',
      title: 'مكتبة المواد الإعلامية',
      subtitle:
          'مكتبة عامة للصور والفيديوهات والمواد التعريفية المرتبطة بالهوية الإعلامية والمنشورات الرسمية.',
      eyebrow: 'أصول إعلامية',
      icon: Icons.folder_special_outlined,
      metrics: [
        PwfFrontendMetric(
          label: 'أنواع',
          value: 'صور / فيديو',
          icon: Icons.perm_media_outlined,
        ),
        PwfFrontendMetric(
          label: 'استخدام',
          value: 'منضبط',
          icon: Icons.security_outlined,
        ),
        PwfFrontendMetric(
          label: 'نطاق',
          value: 'عام / داخلي',
          icon: Icons.visibility_outlined,
        ),
      ],
      cards: [
        PwfFrontendHubCard(
          title: 'الصور',
          description: 'صور رسمية مصنفة حسب الحدث والموضوع والوحدة.',
          route: AppRoutes.mediaCenter,
          icon: Icons.image_outlined,
        ),
        PwfFrontendHubCard(
          title: 'الفيديوهات',
          description: 'مواد فيديو منشورة أو مؤرشفة ضمن سياسة إعلامية.',
          route: AppRoutes.mediaCenter,
          icon: Icons.video_library_outlined,
        ),
        PwfFrontendHubCard(
          title: 'دليل الهوية الإعلامية',
          description: 'مواد وهوية بصرية قابلة للاستخدام المؤسسي المنضبط.',
          route: AppRoutes.mediaCenter,
          icon: Icons.palette_outlined,
        ),
      ],
      infoBlocks: [
        PwfFrontendInfoBlock(
          title: 'مصدر موحد',
          body: 'المكتبة تخدم المركز الإعلامي ولا تستبدل مركز الوثائق.',
        ),
        PwfFrontendInfoBlock(
          title: 'الحقوق',
          body: 'كل مادة يجب أن تكون مملوكة أو مرخصة أو معتمدة للنشر.',
        ),
      ],
    ),
  };
}

class PwfPublicRequestEntryScreen extends StatefulWidget {
  const PwfPublicRequestEntryScreen({super.key, required this.unitSlug});

  final String unitSlug;

  @override
  State<PwfPublicRequestEntryScreen> createState() =>
      _PwfPublicRequestEntryScreenState();
}

class _PwfPublicRequestEntryScreenState
    extends State<PwfPublicRequestEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _summaryController = TextEditingController();
  final _adapter = PwfServicesRequestRpcAdapter();

  String _audience = 'فرد / مواطن';
  String _service = 'طلب إفادة أو وثيقة';
  String _form = 'نموذج طلب خدمة عامة';
  String? _trackingNo;
  String? _adapterSource;
  bool _loadingForms = true;
  bool _submitting = false;
  List<PwfServiceFormOption> _forms = const <PwfServiceFormOption>[];

  @override
  void initState() {
    super.initState();
    _loadForms();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _loadForms() async {
    final forms = await _adapter.loadPublicForms();
    if (!mounted) return;
    setState(() {
      _forms = forms;
      _loadingForms = false;
      if (!_forms.any((option) => option.titleAr == _form) &&
          _forms.isNotEmpty) {
        _form = _forms.first.titleAr;
      }
    });
  }

  PwfServiceFormOption? get _selectedForm {
    for (final option in _forms) {
      if (option.titleAr == _form) return option;
    }
    return null;
  }

  Future<void> _submitRequest() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    final result = await _adapter.submitRequest(
      PwfServiceRequestSubmitDraft(
        requesterName: _nameController.text,
        requesterContact: _phoneController.text,
        requesterTypeAr: _audience,
        serviceLabelAr: _service,
        formTitleAr: _form,
        requestSummary: _summaryController.text,
        unitSlug: widget.unitSlug,
        formOptions: _forms,
      ),
    );
    if (!mounted) return;
    setState(() {
      _trackingNo = result.trackingCode;
      _adapterSource = result.sourceLabelAr;
      _submitting = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.messageAr)));
  }

  @override
  Widget build(BuildContext context) {
    return PwfWebPageScaffold(
      unitSlug: widget.unitSlug,
      title: 'تقديم طلب خدمة',
      showTitleSection: true,
      child: PwfSectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PublicServiceHero(
              title: 'تقديم طلب خدمة',
              subtitle:
                  'واجهة عامة backend-first موصولة بمركز الخدمات الإنتاجي. تستخدم RPCs عند توفرها، وتمنع fallback الوهمي عند وجود backend فعلي بلا بيانات.',
              eyebrow: 'مركز الخدمات / الطلبات والنماذج',
              icon: Icons.assignment_outlined,
              primaryLabel: 'تتبع طلب',
              primaryRoute: AppRoutes.serviceRequestTracking,
              secondaryLabel: 'دليل الخدمات',
              secondaryRoute: AppRoutes.services,
            ),
            const SizedBox(height: 18),
            _PublicRequestAdapterStatusCard(
              loadingForms: _loadingForms,
              forms: _forms,
              adapterSource: _adapterSource,
            ),
            const SizedBox(height: 18),
            _PublicRequestStepper(currentStep: _trackingNo == null ? 1 : 2),
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 900;
                final form = _PublicRequestFormCard(
                  formKey: _formKey,
                  nameController: _nameController,
                  phoneController: _phoneController,
                  summaryController: _summaryController,
                  audience: _audience,
                  service: _service,
                  form: _form,
                  forms: _forms,
                  submitting: _submitting,
                  onAudienceChanged: (value) =>
                      setState(() => _audience = value),
                  onServiceChanged: (value) => setState(() => _service = value),
                  onFormChanged: (value) => setState(() => _form = value),
                  onSubmit: _submitting ? null : _submitRequest,
                );
                final side = _PublicRequestSidePanel(
                  trackingNo: _trackingNo,
                  adapterSource: _adapterSource,
                  audience: _audience,
                  service: _service,
                  form: _form,
                  selectedForm: _selectedForm,
                );
                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [form, const SizedBox(height: 14), side],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: form),
                    const SizedBox(width: 16),
                    Expanded(child: side),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            const _PublicServiceGovernanceNote(
              title: 'حدود هذه الدفعة',
              body:
                  'بعد نجاح SQL UAT أصبحت الواجهة تستهدف backend الإنتاجي أولًا. يظهر fallback فقط عند غياب الدوال أو الجداول، أما الحالات الفارغة فتُعرض كحالة بيانات حقيقية.',
            ),
          ],
        ),
      ),
    );
  }
}

class PwfPublicRequestTrackingScreen extends StatefulWidget {
  const PwfPublicRequestTrackingScreen({super.key, required this.unitSlug});

  final String unitSlug;

  @override
  State<PwfPublicRequestTrackingScreen> createState() =>
      _PwfPublicRequestTrackingScreenState();
}

class _PwfPublicRequestTrackingScreenState
    extends State<PwfPublicRequestTrackingScreen> {
  final _trackingController = TextEditingController();
  final _adapter = PwfServicesRequestRpcAdapter();

  bool _loading = false;
  PwfServiceRequestTrackingResult? _result;

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  Future<void> _trackRequest() async {
    final trackingNo = _trackingController.text.trim();
    if (trackingNo.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('أدخل رقم المتابعة أولًا.')));
      return;
    }
    setState(() => _loading = true);
    final result = await _adapter.trackRequest(trackingNo);
    if (!mounted) return;
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PwfWebPageScaffold(
      unitSlug: widget.unitSlug,
      title: 'تتبع طلب خدمة',
      showTitleSection: true,
      child: PwfSectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _PublicServiceHero(
              title: 'تتبع طلب خدمة',
              subtitle:
                  'واجهة تتبع backend-first تعرض الحالة العامة دون كشف بيانات حساسة. رقم المتابعة يجب أن يكون صادرًا من طلب حقيقي أو اختبار UAT معتمد.',
              eyebrow: 'مركز الخدمات / الاستعلامات والمتابعة',
              icon: Icons.manage_search_outlined,
              primaryLabel: 'تقديم طلب جديد',
              primaryRoute: AppRoutes.serviceRequestEntry,
              secondaryLabel: 'دليل الخدمات',
              secondaryRoute: AppRoutes.services,
            ),
            const SizedBox(height: 18),
            _PublicTrackingLookupCard(
              controller: _trackingController,
              loading: _loading,
              searched: _result != null,
              onSearch: _loading ? null : _trackRequest,
            ),
            const SizedBox(height: 18),
            if (_result != null) ...[
              _PublicTrackingResultCard(result: _result!),
              const SizedBox(height: 18),
            ],
            const _PublicServiceGovernanceNote(
              title: 'سياسة التتبع المقترحة',
              body:
                  'يجب ألا يكشف رقم المتابعة بيانات شخصية حساسة. عند الربط الإنتاجي يعرض النظام الحالة العامة والجهة المسؤولة والخطوة التالية فقط، مع تحقق إضافي عند عرض التفاصيل.',
            ),
          ],
        ),
      ),
    );
  }
}

class _PublicServiceHero extends StatelessWidget {
  const _PublicServiceHero({
    required this.title,
    required this.subtitle,
    required this.eyebrow,
    required this.icon,
    required this.primaryLabel,
    required this.primaryRoute,
    required this.secondaryLabel,
    required this.secondaryRoute,
  });

  final String title;
  final String subtitle;
  final String eyebrow;
  final IconData icon;
  final String primaryLabel;
  final String primaryRoute;
  final String secondaryLabel;
  final String secondaryRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [Color(0xFF0B3A70), Color(0xFF145DA0)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: const TextStyle(
                  color: Color(0xFFFDE68A),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.go(primaryRoute),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: Text(primaryLabel),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFEAB308),
                      foregroundColor: const Color(0xFF0B1220),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go(secondaryRoute),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: Text(secondaryLabel),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.42),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
          final iconBox = Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Icon(icon, color: const Color(0xFFFDE68A), size: 48),
          );
          if (compact) return content;
          return Row(
            children: [
              Expanded(child: content),
              const SizedBox(width: 20),
              iconBox,
            ],
          );
        },
      ),
    );
  }
}

class _PublicRequestAdapterStatusCard extends StatelessWidget {
  const _PublicRequestAdapterStatusCard({
    required this.loadingForms,
    required this.forms,
    required this.adapterSource,
  });

  final bool loadingForms;
  final List<PwfServiceFormOption> forms;
  final String? adapterSource;

  @override
  Widget build(BuildContext context) {
    final rpcBacked = forms.any((form) => form.rpcBacked);
    final source = loadingForms
        ? 'جارٍ فحص RPC'
        : rpcBacked
        ? 'النماذج من RPC'
        : 'نماذج fallback محلية';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _PublicStatusChip(
            label: source,
            icon: rpcBacked ? Icons.cloud_done : Icons.cloud_off,
          ),
          _PublicStatusChip(
            label: 'عدد النماذج: ${forms.length}',
            icon: Icons.description_outlined,
          ),
          _PublicStatusChip(
            label: adapterSource ?? 'لم يتم إرسال طلب بعد',
            icon: Icons.sync_alt_rounded,
          ),
          const Text(
            'هذه البطاقة تجعل حالة الربط واضحة: backend-first بعد Mega M/M1، وfallback يظهر فقط عند غياب عقود SQL لا عند عدم وجود بيانات.',
            style: TextStyle(color: Color(0xFF64748B), height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _PublicStatusChip extends StatelessWidget {
  const _PublicStatusChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF0B3A70), size: 17),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicRequestStepper extends StatelessWidget {
  const _PublicRequestStepper({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('اختيار الخدمة', Icons.design_services_outlined),
      ('تعبئة الطلب', Icons.edit_rounded),
      ('استلام رقم متابعة', Icons.confirmation_number_outlined),
      ('المراجعة الداخلية', Icons.fact_check_outlined),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (int i = 0; i < steps.length; i++)
          _PublicStepPill(
            label: steps[i].$1,
            icon: steps[i].$2,
            active: i <= currentStep,
          ),
      ],
    );
  }
}

class _PublicStepPill extends StatelessWidget {
  const _PublicStepPill({
    required this.label,
    required this.icon,
    required this.active,
  });

  final String label;
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF0B3A70) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active ? const Color(0xFF0B3A70) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: active ? Colors.white : const Color(0xFF64748B),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF475569),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicRequestFormCard extends StatelessWidget {
  const _PublicRequestFormCard({
    required this.formKey,
    required this.nameController,
    required this.phoneController,
    required this.summaryController,
    required this.audience,
    required this.service,
    required this.form,
    required this.forms,
    required this.submitting,
    required this.onAudienceChanged,
    required this.onServiceChanged,
    required this.onFormChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController summaryController;
  final String audience;
  final String service;
  final String form;
  final List<PwfServiceFormOption> forms;
  final bool submitting;
  final ValueChanged<String> onAudienceChanged;
  final ValueChanged<String> onServiceChanged;
  final ValueChanged<String> onFormChanged;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final formTitles = forms
        .map((option) => option.titleAr)
        .toSet()
        .toList(growable: false);
    final hasForms = formTitles.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'بيانات الطلب',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم مقدم الطلب',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'أدخل اسم مقدم الطلب' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف أو وسيلة التواصل',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? 'أدخل وسيلة تواصل' : null,
            ),
            const SizedBox(height: 12),
            _PublicDropdownField(
              label: 'صفة مقدم الطلب',
              value: audience,
              values: const ['فرد / مواطن', 'مؤسسة', 'وحدة داخلية', 'مديرية'],
              onChanged: onAudienceChanged,
            ),
            const SizedBox(height: 12),
            _PublicDropdownField(
              label: 'الخدمة المطلوبة',
              value: service,
              values: const [
                'طلب إفادة أو وثيقة',
                'طلب خدمة عامة',
                'استفسار خدمة',
                'طلب عام متعلق بخدمات الأوقاف',
                'ملاحظة أو بلاغ',
              ],
              onChanged: onServiceChanged,
            ),
            const SizedBox(height: 12),
            if (hasForms)
              _PublicDropdownField(
                label: 'النموذج المقترح',
                value: formTitles.contains(form) ? form : formTitles.first,
                values: formTitles,
                onChanged: onFormChanged,
              )
            else
              const _PublicNoFormsAvailableNotice(),
            const SizedBox(height: 12),
            TextFormField(
              controller: summaryController,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'ملخص الطلب',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value ?? '').trim().length < 10
                  ? 'أدخل وصفًا مختصرًا لا يقل عن 10 أحرف'
                  : null,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: hasForms ? onSubmit : null,
              icon: submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(submitting ? 'جارٍ إرسال الطلب...' : 'إرسال الطلب'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0B3A70),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PublicNoFormsAvailableNotice extends StatelessWidget {
  const _PublicNoFormsAvailableNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF92400E)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'لا توجد نماذج خدمات مفعّلة حاليًا في backend. لا يمكن إرسال طلب جديد قبل تفعيل نموذج واحد على الأقل.',
              style: TextStyle(
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w800,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicDropdownField extends StatelessWidget {
  const _PublicDropdownField({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: values.contains(value) ? value : values.first,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final item in values)
          DropdownMenuItem(value: item, child: Text(item)),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

class _PublicRequestSidePanel extends StatelessWidget {
  const _PublicRequestSidePanel({
    required this.trackingNo,
    required this.adapterSource,
    required this.audience,
    required this.service,
    required this.form,
    required this.selectedForm,
  });

  final String? trackingNo;
  final String? adapterSource;
  final String audience;
  final String service;
  final String form;
  final PwfServiceFormOption? selectedForm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ملخص مسار الطلب',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              _PublicInfoRow(label: 'صفة مقدم الطلب', value: audience),
              _PublicInfoRow(label: 'الخدمة', value: service),
              _PublicInfoRow(label: 'النموذج', value: form),
              if (selectedForm != null) ...[
                _PublicInfoRow(
                  label: 'مفتاح النموذج',
                  value: selectedForm!.formKey,
                ),
                _PublicInfoRow(
                  label: 'مصدر النموذج',
                  value: selectedForm!.rpcBacked ? 'RPC' : 'Fallback',
                ),
              ],
              const Divider(height: 24),
              if (trackingNo == null)
                const Text(
                  'لم يتم إصدار رقم متابعة بعد.',
                  style: TextStyle(color: Color(0xFF64748B), height: 1.5),
                )
              else ...[
                Text(
                  adapterSource ?? 'مصدر غير محدد',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                SelectableText(
                  trackingNo!,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFFB22222),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _PublicServiceGovernanceNote(
          title: 'المرفقات لاحقًا',
          body: selectedForm?.requiredAttachments.isEmpty ?? true
              ? 'يعرض النموذج المرفقات المطلوبة لاحقًا بعد اعتماد سجل النماذج وقاعدة البيانات.'
              : "المرفقات المقترحة: ${selectedForm!.requiredAttachments.join('، ')}.",
        ),
      ],
    );
  }
}

class _PublicInfoRow extends StatelessWidget {
  const _PublicInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicTrackingLookupCard extends StatelessWidget {
  const _PublicTrackingLookupCard({
    required this.controller,
    required this.loading,
    required this.searched,
    required this.onSearch,
  });

  final TextEditingController controller;
  final bool loading;
  final bool searched;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 700;
          final field = TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'رقم المتابعة',
              hintText: 'مثال: PWF-123456',
              border: OutlineInputBorder(),
            ),
          );
          final button = FilledButton.icon(
            onPressed: onSearch,
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.search_rounded),
            label: Text(
              loading
                  ? 'جارٍ التتبع...'
                  : searched
                  ? 'تحديث نتيجة التتبع'
                  : 'عرض حالة الطلب',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0B3A70),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [field, const SizedBox(height: 12), button],
            );
          }
          return Row(
            children: [
              Expanded(child: field),
              const SizedBox(width: 12),
              button,
            ],
          );
        },
      ),
    );
  }
}

class _PublicTrackingResultCard extends StatelessWidget {
  const _PublicTrackingResultCard({required this.result});

  final PwfServiceRequestTrackingResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نتيجة تتبع: ${result.trackingCode}',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PublicStatusChip(
                label: result.sourceLabelAr,
                icon: result.rpcBacked ? Icons.cloud_done : Icons.cloud_off,
              ),
              _PublicStatusChip(
                label: 'الحالة: ${result.status}',
                icon: Icons.timeline,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            result.publicNote,
            style: const TextStyle(color: Color(0xFF64748B), height: 1.5),
          ),
          const SizedBox(height: 16),
          for (final step in result.steps) _PublicTrackingStep(step: step),
        ],
      ),
    );
  }
}

class _PublicTrackingStep extends StatelessWidget {
  const _PublicTrackingStep({required this.step});

  final PwfServiceRequestTimelineStep step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: step.done ? const Color(0xFF0B3A70) : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: step.done
                    ? const Color(0xFF0B3A70)
                    : const Color(0xFFCBD5E1),
              ),
            ),
            child: Icon(
              step.done ? Icons.check_rounded : Icons.more_horiz_rounded,
              color: step.done ? Colors.white : const Color(0xFF64748B),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.titleAr,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  step.descriptionAr,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PublicServiceGovernanceNote extends StatelessWidget {
  const _PublicServiceGovernanceNote({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF92400E)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF92400E),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF78350F),
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PwfEventsPublicScreen extends StatelessWidget {
  const PwfEventsPublicScreen({super.key, required this.unitSlug});

  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    return PwfPlatformFrontendHubPage(
      unitSlug: unitSlug,
      contentFamilyKey: 'events',
      title: 'الفعاليات',
      subtitle:
          'أحداث رسمية لها موعد ومكان وحضور وحالة، وتختلف وظيفيًا عن الأنشطة المؤسسية أو أرشيف الأعمال الميدانية.',
      eyebrow: 'فعاليات رسمية',
      icon: Icons.event_available_outlined,
      primaryRoute: AppRoutes.activities,
      primaryLabel: 'عرض الأنشطة',
      secondaryRoute: AppRoutes.mediaCenter,
      secondaryLabel: 'المركز الإعلامي',
      metrics: const [
        PwfFrontendMetric(
          label: 'التصنيف',
          value: 'فعالية',
          icon: Icons.category_outlined,
        ),
        PwfFrontendMetric(
          label: 'الحقول',
          value: 'وقت / مكان',
          icon: Icons.schedule_outlined,
        ),
        PwfFrontendMetric(
          label: 'الحالة',
          value: 'قادمة / منتهية',
          icon: Icons.published_with_changes_outlined,
        ),
      ],
      cards: const [
        PwfFrontendHubCard(
          title: 'فعاليات قادمة',
          description:
              'أحداث لها موعد ومكان وحالة قادمة، ويمكن ربطها بالتسجيل أو الدعوة عند الحاجة.',
          route: AppRoutes.events,
          icon: Icons.event_available_outlined,
        ),
        PwfFrontendHubCard(
          title: 'فعاليات منتهية',
          description:
              'أرشفة الفعاليات المنتهية مع التغطيات والنتائج والمواد الإعلامية.',
          route: AppRoutes.events,
          icon: Icons.event_busy_outlined,
        ),
        PwfFrontendHubCard(
          title: 'تغطيات الفعاليات',
          description:
              'ربط الفعالية بالصور والفيديوهات والأخبار والتقارير الإعلامية.',
          route: AppRoutes.mediaCenter,
          icon: Icons.photo_library_outlined,
        ),
      ],
      infoBlocks: const [
        PwfFrontendInfoBlock(
          title: 'الفصل عن الأنشطة',
          body:
              'الفعالية حدث بزمن ومكان وحضور، أما النشاط فهو توثيق عمل مؤسسي أو ميداني.',
        ),
        PwfFrontendInfoBlock(
          title: 'النطاق',
          body:
              'يمكن عرض فعاليات الوزارة أو الوحدة من نفس البنية الديناميكية عبر unitSlug.',
        ),
      ],
    );
  }
}

class PwfPlatformFrontendHubPage extends ConsumerWidget {
  const PwfPlatformFrontendHubPage({
    super.key,
    required this.unitSlug,
    this.contentFamilyKey,
    required this.title,
    required this.subtitle,
    required this.eyebrow,
    required this.icon,
    required this.cards,
    required this.metrics,
    required this.infoBlocks,
    required this.primaryRoute,
    required this.primaryLabel,
    required this.secondaryRoute,
    required this.secondaryLabel,
  });

  final String unitSlug;
  final String? contentFamilyKey;
  final String title;
  final String subtitle;
  final String eyebrow;
  final IconData icon;
  final List<PwfFrontendHubCard> cards;
  final List<PwfFrontendMetric> metrics;
  final List<PwfFrontendInfoBlock> infoBlocks;
  final String primaryRoute;
  final String primaryLabel;
  final String secondaryRoute;
  final String secondaryLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PwfWebPageScaffold(
      unitSlug: unitSlug,
      title: title,
      showTitleSection: true,
      child: PwfSectionContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FrontendHeroCard(
              eyebrow: eyebrow,
              title: title,
              subtitle: subtitle,
              icon: icon,
              primaryRoute: primaryRoute,
              primaryLabel: primaryLabel,
              secondaryRoute: secondaryRoute,
              secondaryLabel: secondaryLabel,
            ),
            const SizedBox(height: 18),
            _FrontendMetricStrip(metrics: metrics),
            const SizedBox(height: 22),
            _FrontendSectionTitle(
              title: 'المداخل التشغيلية',
              subtitle:
                  'بطاقات عامة قابلة للربط لاحقًا بمصادر CMS/RPC دون تغيير تجربة المستخدم.',
            ),
            const SizedBox(height: 14),
            _FrontendCardsGrid(cards: cards),
            if (contentFamilyKey != null) ...[
              const SizedBox(height: 22),
              _PublishedContentPanel(
                query: PwfPlatformCenterContentQuery(
                  familyKey: contentFamilyKey!,
                  unitSlug: unitSlug,
                  publishedOnly: true,
                  limit: 6,
                ),
              ),
            ],
            const SizedBox(height: 22),
            _FrontendSectionTitle(
              title: 'ملاحظات الحوكمة',
              subtitle:
                  'تعرض للزائر بصياغة مختصرة، بينما تبقى التفاصيل الإدارية داخل لوحة التحكم.',
            ),
            const SizedBox(height: 14),
            _FrontendInfoGrid(infoBlocks: infoBlocks),
          ],
        ),
      ),
    );
  }
}

class PwfPlatformCenterContentDetailScreen extends ConsumerWidget {
  const PwfPlatformCenterContentDetailScreen({
    super.key,
    required this.unitSlug,
    required this.familyKey,
    required this.id,
  });

  final String unitSlug;
  final String familyKey;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalizedFamily = familyKey.replaceAll('-', '_');
    final asyncItem = ref.watch(
      pwfPlatformCenterContentDetailProvider(
        PwfPlatformCenterContentDetailQuery(
          id: id,
          familyKey: normalizedFamily,
          unitSlug: unitSlug,
        ),
      ),
    );
    return PwfWebPageScaffold(
      unitSlug: unitSlug,
      title: 'تفاصيل المحتوى',
      showTitleSection: true,
      child: PwfSectionContainer(
        child: asyncItem.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => _FrontendDataNote(
            title: 'تعذر تحميل تفاصيل المحتوى',
            body: error.toString(),
          ),
          data: (item) {
            if (item == null) {
              return const _FrontendDataNote(
                title: 'المحتوى غير متاح',
                body:
                    'قد يكون العنصر غير منشور، أو لا يطابق نطاق الوحدة، أو لم يتم تطبيق RPC التفصيلي بعد.',
              );
            }
            final body = item.body.trim().isNotEmpty ? item.body : item.summary;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FrontendHeroCard(
                  eyebrow: _publicFamilyLabel(normalizedFamily),
                  title: item.title,
                  subtitle: item.summary,
                  icon: _publicFamilyIcon(normalizedFamily),
                  primaryRoute: item.route.trim().isEmpty
                      ? AppRoutes.mediaCenter
                      : item.route,
                  primaryLabel: 'العودة للقائمة',
                  secondaryRoute: AppRoutes.mediaCenter,
                  secondaryLabel: 'المركز الإعلامي',
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FrontendMiniPill(
                      label: item.ownerName,
                      icon: Icons.apartment_outlined,
                    ),
                    _FrontendMiniPill(
                      label: _publicStatusLabel(item.status),
                      icon: Icons.verified_outlined,
                    ),
                    _FrontendMiniPill(
                      label: item.categoryKey.isEmpty
                          ? 'عام'
                          : item.categoryKey,
                      icon: Icons.category_outlined,
                    ),
                    if (item.documentUrl != null)
                      const _FrontendMiniPill(
                        label: 'مرفق',
                        icon: Icons.attach_file_outlined,
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Text(
                    body,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
                if (item.documentUrl != null) ...[
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () async =>
                        _openExternalDocument(item.documentUrl!),
                    icon: const Icon(Icons.open_in_new_outlined),
                    label: const Text('فتح المرفق أو الرابط المرجعي'),
                  ),
                ],
                const SizedBox(height: 18),
                const _FrontendDataNote(
                  title: 'حاكمية النشر',
                  body:
                      'تظهر هذه الصفحة للعناصر المنشورة فقط عبر public.v_platform_center_content أو RPC تفصيلي آمن، ولا تعرض المسودات العامة.',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PublishedContentPanel extends ConsumerWidget {
  const _PublishedContentPanel({required this.query});

  final PwfPlatformCenterContentQuery query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(pwfPlatformCenterContentListProvider(query));
    return asyncItems.when(
      loading: () => const LinearProgressIndicator(minHeight: 3),
      error: (error, stackTrace) => _FrontendDataNote(
        title: 'تعذر تحميل المحتوى المنشور',
        body: error.toString(),
      ),
      data: (items) {
        if (items.isEmpty) {
          return const _FrontendDataNote(
            title: 'لا توجد عناصر منشورة بعد',
            body:
                'يعتمد الظهور هنا على عناصر منشورة من مصدر البيانات الرسمي أو RPC wrapper المعتمد.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _FrontendSectionTitle(
              title: 'أحدث العناصر المنشورة',
              subtitle: items.any((item) => item.isFallback)
                  ? 'بيانات fallback تشغيلية إلى حين تفعيل RPC/Views، ولا تُعامل كمحتوى إنتاجي نهائي.'
                  : 'محتوى منشور من مصدر البيانات الرسمي لهذا القسم.',
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1000
                    ? 3
                    : (constraints.maxWidth >= 680 ? 2 : 1);
                const spacing = 12.0;
                final width = columns == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - (columns - 1) * spacing) /
                          columns;
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final item in items)
                      SizedBox(
                        width: width,
                        child: _PublishedContentCard(item: item),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _PublishedContentCard extends StatelessWidget {
  const _PublishedContentCard({required this.item});

  final PwfPlatformCenterContentItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: item.route.trim().isEmpty
          ? null
          : () => context.go(_detailRouteFor(item)),
      child: Container(
        constraints: const BoxConstraints(minHeight: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FrontendMiniPill(
                  label: item.ownerName,
                  icon: Icons.apartment_outlined,
                ),
                _FrontendMiniPill(
                  label: _publicStatusLabel(item.status),
                  icon: Icons.verified_outlined,
                ),
                if (item.isFallback)
                  const _FrontendMiniPill(
                    label: 'fallback',
                    icon: Icons.info_outline,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.title,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.summary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF475569), height: 1.55),
            ),
          ],
        ),
      ),
    );
  }
}

class _FrontendDataNote extends StatelessWidget {
  const _FrontendDataNote({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF78350F),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(color: Color(0xFF92400E), height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _FrontendMiniPill extends StatelessWidget {
  const _FrontendMiniPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3A70).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF0B3A70).withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0B3A70)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0B3A70),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _openExternalDocument(String rawUrl) async {
  final text = rawUrl.trim();
  if (text.isEmpty) return;
  final uri = Uri.tryParse(text);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

String _detailRouteFor(PwfPlatformCenterContentItem item) {
  if (item.isFallback || item.id.trim().isEmpty || item.route.trim().isEmpty)
    return item.route;
  final base = item.route.endsWith('/')
      ? item.route.substring(0, item.route.length - 1)
      : item.route;
  return '$base/${item.id}';
}

String _publicFamilyLabel(String familyKey) {
  switch (familyKey) {
    case 'social_posts':
      return 'الاجتماعيات';
    case 'press_releases':
      return 'البيانات الصحفية';
    case 'official_statements':
      return 'التصريحات الرسمية';
    case 'awareness_campaigns':
      return 'الحملات التوعوية';
    case 'sanctities_observatory':
      return 'مرصد حماية المقدسات';
    case 'legal_references':
      return 'المراجع الرسمية';
    case 'events':
      return 'الفعاليات';
    default:
      return 'المركز الإعلامي';
  }
}

IconData _publicFamilyIcon(String familyKey) {
  switch (familyKey) {
    case 'press_releases':
      return Icons.description_outlined;
    case 'official_statements':
      return Icons.record_voice_over_outlined;
    case 'awareness_campaigns':
      return Icons.campaign_outlined;
    case 'sanctities_observatory':
      return Icons.shield_outlined;
    case 'legal_references':
      return Icons.gavel_outlined;
    case 'events':
      return Icons.event_available_outlined;
    case 'social_posts':
      return Icons.groups_2_outlined;
    default:
      return Icons.article_outlined;
  }
}

String _publicStatusLabel(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized == 'published' ||
      normalized == 'ready_to_publish' ||
      value == 'جاهز للنشر' ||
      value == 'منشور')
    return 'منشور';
  if (normalized == 'review' ||
      normalized == 'in_review' ||
      value == 'قيد المراجعة')
    return 'قيد المراجعة';
  return value.trim().isEmpty ? 'مسودة' : value;
}

class PwfFrontendHubCard {
  const PwfFrontendHubCard({
    required this.title,
    required this.description,
    required this.route,
    required this.icon,
  });

  final String title;
  final String description;
  final String route;
  final IconData icon;
}

class PwfFrontendMetric {
  const PwfFrontendMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class PwfFrontendInfoBlock {
  const PwfFrontendInfoBlock({required this.title, required this.body});

  final String title;
  final String body;
}

class _FrontendHeroCard extends StatelessWidget {
  const _FrontendHeroCard({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryRoute,
    required this.primaryLabel,
    required this.secondaryRoute,
    required this.secondaryLabel,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;
  final String primaryRoute;
  final String primaryLabel;
  final String secondaryRoute;
  final String secondaryLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [Color(0xFF0B3A70), Color(0xFF145DA0)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final textPanel = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFEAB308).withValues(alpha: 0.38),
                  ),
                ),
                child: Text(
                  eyebrow,
                  style: const TextStyle(
                    color: Color(0xFFFDE68A),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                  height: 1.75,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _FrontendHeroButton(
                    label: primaryLabel,
                    route: primaryRoute,
                    primary: true,
                  ),
                  _FrontendHeroButton(
                    label: secondaryLabel,
                    route: secondaryRoute,
                    primary: false,
                  ),
                ],
              ),
            ],
          );

          final iconPanel = Container(
            width: 118,
            height: 118,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: Icon(icon, color: const Color(0xFFFDE68A), size: 56),
          );

          return compact
              ? textPanel
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: textPanel),
                    const SizedBox(width: 24),
                    iconPanel,
                  ],
                );
        },
      ),
    );
  }
}

class _FrontendHeroButton extends StatelessWidget {
  const _FrontendHeroButton({
    required this.label,
    required this.route,
    required this.primary,
  });

  final String label;
  final String route;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => context.go(route),
      icon: Icon(
        primary ? Icons.arrow_back_rounded : Icons.open_in_new_rounded,
      ),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: primary
            ? const Color(0xFFEAB308)
            : Colors.white.withValues(alpha: 0.12),
        foregroundColor: primary ? const Color(0xFF0B1220) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _FrontendMetricStrip extends StatelessWidget {
  const _FrontendMetricStrip({required this.metrics});

  final List<PwfFrontendMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 900
            ? 3
            : width >= 620
            ? 2
            : 1;
        const spacing = 12.0;
        final itemWidth = columns == 1
            ? width
            : (width - (columns - 1) * spacing) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in metrics)
              SizedBox(
                width: itemWidth,
                child: _FrontendMetricCard(metric: item),
              ),
          ],
        );
      },
    );
  }
}

class _FrontendMetricCard extends StatelessWidget {
  const _FrontendMetricCard({required this.metric});

  final PwfFrontendMetric metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFB22222).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(metric.icon, color: const Color(0xFFB22222)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  metric.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FrontendSectionTitle extends StatelessWidget {
  const _FrontendSectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF64748B), height: 1.6),
        ),
      ],
    );
  }
}

class _FrontendCardsGrid extends StatelessWidget {
  const _FrontendCardsGrid({required this.cards});

  final List<PwfFrontendHubCard> cards;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1120
            ? 4
            : width >= 820
            ? 3
            : width >= 560
            ? 2
            : 1;
        const spacing = 14.0;
        final cardWidth = columns == 1
            ? width
            : (width - (columns - 1) * spacing) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards)
              SizedBox(
                width: cardWidth,
                child: _FrontendActionCard(card: card),
              ),
          ],
        );
      },
    );
  }
}

class _FrontendActionCard extends StatelessWidget {
  const _FrontendActionCard({required this.card});

  final PwfFrontendHubCard card;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.go(card.route),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 204),
          child: Ink(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(card.icon, color: const Color(0xFFB22222), size: 30),
                const SizedBox(height: 12),
                Text(
                  card.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  card.description,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'فتح الصفحة',
                      style: TextStyle(
                        color: Color(0xFF0B3A70),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF0B3A70),
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FrontendInfoGrid extends StatelessWidget {
  const _FrontendInfoGrid({required this.infoBlocks});

  final List<PwfFrontendInfoBlock> infoBlocks;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 760 ? 2 : 1;
        const spacing = 14.0;
        final blockWidth = columns == 1 ? width : (width - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final block in infoBlocks)
              SizedBox(
                width: blockWidth,
                child: _FrontendInfoCard(block: block),
              ),
          ],
        );
      },
    );
  }
}

class _FrontendInfoCard extends StatelessWidget {
  const _FrontendInfoCard({required this.block});

  final PwfFrontendInfoBlock block;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF0B3A70)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  block.title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  block.body,
                  style: const TextStyle(color: Color(0xFF64748B), height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
