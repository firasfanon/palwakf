import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/data/models/media_gallery_item.dart';
import 'package:waqf/presentation/screens/admin/main/management/breaking_news_management/breaking_news_management_screen.dart';
import 'package:waqf/presentation/screens/admin/main/management/friday_sermons_management/friday_sermons_management_screen.dart';
import 'package:waqf/presentation/screens/admin/main/management/hero_slider_management/hero_slider_management_screen.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/sections/activities_management_section.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/sections/announcements_management_section.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/sections/media_gallery_management_section.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/sections/news_management_section.dart';
import 'package:waqf/presentation/widgets/admin/admin_layout.dart';

import '../../data/models/pwf_platform_center_content_item.dart';
import '../providers/pwf_platform_center_content_providers.dart';

class MediaCenterNewsOperationalPage extends StatelessWidget {
  const MediaCenterNewsOperationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaCenterOperationalPage(
      currentRoute: AppRoutes.adminMediaCenterNews,
      governanceFamilyKey: 'news',
      title: 'إدارة الأخبار',
      subtitle:
          'إدارة الأخبار الوزارية وأخبار الوحدات مباشرة: إنشاء، بحث، تحرير، معاينة، نشر، وأرشفة ضمن نطاق home أو slug.',
      icon: Icons.newspaper_outlined,
      primaryLabel: 'إضافة خبر',
      previewRoute: AppRoutes.news,
      child: NewsManagementSection(),
    );
  }
}

class MediaCenterAnnouncementsOperationalPage extends StatelessWidget {
  const MediaCenterAnnouncementsOperationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaCenterOperationalPage(
      currentRoute: AppRoutes.adminMediaCenterAnnouncements,
      governanceFamilyKey: 'announcements',
      title: 'إدارة الإعلانات',
      subtitle:
          'إدارة إعلانات الوزارة والوحدات مباشرة مع ضبط الأولوية وتاريخ النشر وحالة الظهور دون المرور بصفحة تعريفية عامة.',
      icon: Icons.campaign_outlined,
      primaryLabel: 'إضافة إعلان',
      previewRoute: AppRoutes.announcements,
      child: AnnouncementsManagementSection(),
    );
  }
}

class MediaCenterActivitiesOperationalPage extends StatelessWidget {
  const MediaCenterActivitiesOperationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaCenterOperationalPage(
      currentRoute: AppRoutes.adminMediaCenterActivities,
      governanceFamilyKey: 'activities',
      title: 'إدارة الأنشطة',
      subtitle:
          'إدارة الأنشطة الدورية والتشغيلية للوزارة والوحدات عبر مساحة عمل مباشرة مع فلترة النطاق والحالة والتصنيف.',
      icon: Icons.event_note_outlined,
      primaryLabel: 'إضافة نشاط',
      previewRoute: AppRoutes.activities,
      child: ActivitiesManagementSection(),
    );
  }
}

class MediaCenterEventsOperationalPage extends StatelessWidget {
  const MediaCenterEventsOperationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaCenterOperationalPage(
      currentRoute: AppRoutes.adminMediaCenterEvents,
      governanceFamilyKey: 'events',
      title: 'إدارة الفعاليات',
      subtitle:
          'إدارة الفعاليات كتصنيف تشغيلي داخل الأنشطة دون إنشاء جدول محتوى موازٍ، مع إبقاء الفصل واضحًا في واجهة الإدارة.',
      icon: Icons.celebration_outlined,
      primaryLabel: 'إضافة فعالية',
      previewRoute: AppRoutes.activities,
      child: ActivitiesManagementSection(mode: ActivitiesManagementMode.events),
    );
  }
}

class MediaCenterPhotosOperationalPage extends StatelessWidget {
  const MediaCenterPhotosOperationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaCenterOperationalPage(
      currentRoute: AppRoutes.adminMediaCenterPhotos,
      governanceFamilyKey: 'photos',
      title: 'إدارة معرض الصور',
      subtitle:
          'رفع وتنظيم صور الوزارة والوحدات مع ضبط الصورة المصغرة، النص البديل، النطاق، وحالة النشر.',
      icon: Icons.photo_library_outlined,
      primaryLabel: 'رفع صورة',
      previewRoute: '/home/gallery',
      child: MediaGalleryManagementSection(
        initialType: MediaType.photo,
        allowTypeChange: false,
        headerTitle: 'مساحة إدارة الصور',
        headerDescription:
            'إدارة الصور الوزارية وصور الوحدات مباشرة ضمن media_gallery_items ونطاق home أو slug.',
      ),
    );
  }
}

class MediaCenterVideosOperationalPage extends StatelessWidget {
  const MediaCenterVideosOperationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaCenterOperationalPage(
      currentRoute: AppRoutes.adminMediaCenterVideos,
      governanceFamilyKey: 'videos',
      title: 'إدارة الفيديوهات',
      subtitle:
          'إضافة وتنظيم الفيديوهات والروابط الخارجية مع ضبط الوصف والمعاينة والنطاق قبل النشر.',
      icon: Icons.ondemand_video_outlined,
      primaryLabel: 'إضافة فيديو',
      previewRoute: '/home/gallery',
      child: MediaGalleryManagementSection(
        initialType: MediaType.video,
        allowTypeChange: false,
        headerTitle: 'مساحة إدارة الفيديوهات',
        headerDescription:
            'إدارة فيديوهات الوزارة والوحدات مباشرة ضمن media_gallery_items، مع دعم الروابط الخارجية ونطاق home أو slug.',
      ),
    );
  }
}

class MediaCenterBreakingNewsOperationalPage extends StatelessWidget {
  const MediaCenterBreakingNewsOperationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaCenterOperationalPage(
      currentRoute: AppRoutes.adminMediaCenterBreakingNews,
      governanceFamilyKey: 'breaking_news',
      title: 'إدارة الأخبار العاجلة',
      subtitle:
          'إدارة الرسائل العاجلة ذات الظهور المباشر والمقيّد زمنيًا على الصفحة الرئيسية، مع صلاحية مركزية وأثر تدقيقي واضح.',
      icon: Icons.priority_high_outlined,
      primaryLabel: 'إضافة عاجل',
      previewRoute: AppRoutes.home,
      accentColor: Color(0xFFB22222),
      operationalLabel: 'نشر عاجل مركزي',
      child: BreakingNewsManagementScreen(embedded: true),
    );
  }
}

class MediaCenterFridaySermonsOperationalPage extends StatelessWidget {
  const MediaCenterFridaySermonsOperationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaCenterOperationalPage(
      currentRoute: AppRoutes.adminMediaCenterFridaySermons,
      governanceFamilyKey: 'friday_sermons',
      title: 'إدارة خُطب الجمعة',
      subtitle:
          'إدارة محتوى متخصص يحتاج اعتمادًا إداريًا/شرعيًا، مع بحث وأرشفة وربط بتاريخ الخطبة والملف أو النص.',
      icon: Icons.mic_none_outlined,
      primaryLabel: 'إضافة خطبة',
      previewRoute: AppRoutes.fridaySermon,
      child: FridaySermonsManagementScreen(),
    );
  }
}

class MediaCenterHeroSliderOperationalPage extends StatelessWidget {
  const MediaCenterHeroSliderOperationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaCenterOperationalPage(
      currentRoute: AppRoutes.adminMediaCenterHeroSlider,
      governanceFamilyKey: 'hero_slider',
      title: 'إدارة السلايدر والحملات البصرية',
      subtitle:
          'إدارة الشرائح والرسائل البصرية وCTA وترتيب الظهور ضمن الصفحة الرئيسية، دون تحويلها إلى خبر أو إعلان نصي.',
      icon: Icons.slideshow_outlined,
      primaryLabel: 'إضافة شريحة',
      previewRoute: AppRoutes.home,
      child: HeroSliderManagementScreen(embedded: true),
    );
  }
}

class MediaCenterSocialPostsOperationalPage extends StatelessWidget {
  const MediaCenterSocialPostsOperationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaCenterCompletedOperationalPage(
      currentRoute: AppRoutes.adminMediaCenterSocialPosts,
      governanceFamilyKey: 'social_posts',
      title: 'إدارة الاجتماعيات',
      subtitle:
          'تهاني وتعازي ومناسبات اجتماعية رسمية ضمن المركز الإعلامي، وليست خدمة جمهور أو معاملة إلكترونية.',
      icon: Icons.groups_2_outlined,
      primaryLabel: 'إضافة منشور اجتماعي',
      previewRoute: AppRoutes.socialPosts,
      bullets: [
        'تصنيف المحتوى إلى تهنئة، تعزية، مناسبة اجتماعية، أو مشاركة رسمية.',
        'تحديد نطاق النشر: الوزارة أو الوحدة، مع مراجعة صياغة وحساسية اجتماعية.',
        'منع ظهور الاجتماعيات داخل مركز الخدمات أو بوابة الخدمات الإلكترونية.',
      ],
    );
  }
}

class MediaCenterPressReleasesOperationalPage extends StatelessWidget {
  const MediaCenterPressReleasesOperationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaCenterCompletedOperationalPage(
      currentRoute: AppRoutes.adminMediaCenterPressReleases,
      governanceFamilyKey: 'press_releases',
      title: 'إدارة البيانات الصحفية',
      subtitle:
          'مساحة تحرير رسمية للبيانات الصحفية: رقم البيان، الجهة المصدرة، تاريخ الإصدار، المرفق، وحالة الاعتماد قبل النشر.',
      icon: Icons.article_outlined,
      primaryLabel: 'إضافة بيان صحفي',
      previewRoute: AppRoutes.pressReleases,
      officialCommunicationSpec: _OfficialCommunicationSpec.pressRelease,
      bullets: [
        'تمييز البيان الصحفي عن الخبر والإعلان والتصريح الرسمي.',
        'إسناد البيان إلى جهة رسمية ورقم مرجعي وتاريخ إصدار قابلين للتدقيق.',
        'إظهار البيان في الواجهة العامة فقط بعد اعتماد مركزي وأثر تدقيق.',
      ],
    );
  }
}

class MediaCenterOfficialStatementsOperationalPage extends StatelessWidget {
  const MediaCenterOfficialStatementsOperationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaCenterCompletedOperationalPage(
      currentRoute: AppRoutes.adminMediaCenterOfficialStatements,
      governanceFamilyKey: 'official_statements',
      title: 'إدارة التصريحات الرسمية',
      subtitle:
          'مساحة تحرير للتصريحات المنسوبة: اسم المتحدث، الصفة، جهة التخويل، الموضوع، وتاريخ التصريح قبل النشر.',
      icon: Icons.record_voice_over_outlined,
      primaryLabel: 'إضافة تصريح رسمي',
      previewRoute: AppRoutes.officialStatements,
      officialCommunicationSpec: _OfficialCommunicationSpec.officialStatement,
      bullets: [
        'تسجيل اسم المتحدث وصفته والجهة والتاريخ والموضوع.',
        'اعتماد مركزي قبل النشر بسبب حساسية النسبة الرسمية.',
        'ربط التصريح بخبر أو بيان عند الحاجة دون تكرار المحتوى.',
      ],
    );
  }
}

class MediaCenterAwarenessCampaignsOperationalPage extends StatelessWidget {
  const MediaCenterAwarenessCampaignsOperationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaCenterCompletedOperationalPage(
      currentRoute: AppRoutes.adminMediaCenterAwarenessCampaigns,
      governanceFamilyKey: 'awareness_campaigns',
      title: 'إدارة الحملات التوعوية',
      subtitle:
          'حملات ذات هدف وفترة وجمهور مستهدف ومواد مصاحبة، وليست مجرد شريحة في السلايدر.',
      icon: Icons.campaign_outlined,
      primaryLabel: 'إضافة حملة توعوية',
      previewRoute: AppRoutes.awarenessCampaigns,
      bullets: [
        'تعريف هدف الحملة والفترة الزمنية والجمهور المستهدف.',
        'ربط الحملة بالصور والفيديوهات والسلايدر والمواد الإعلامية عند الحاجة.',
        'قياس أثر الحملة عبر تقارير إعلامية لاحقة لا عبر خبر واحد فقط.',
      ],
    );
  }
}

class MediaCenterEditorialCalendarOperationalPage extends StatelessWidget {
  const MediaCenterEditorialCalendarOperationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaCenterCompletedOperationalPage(
      currentRoute: AppRoutes.adminMediaCenterEditorialCalendar,
      governanceFamilyKey: 'editorial_calendar',
      title: 'الأجندة الإعلامية',
      subtitle: 'تقويم تخطيط النشر والتغطيات والحملات والمناسبات القادمة.',
      icon: Icons.calendar_month_outlined,
      primaryLabel: 'إضافة بند للأجندة',
      previewRoute: AppRoutes.mediaCenter,
      bullets: [
        'تخطيط أخبار وفعاليات وحملات قبل النشر.',
        'تمييز التخطيط الإعلامي عن الفعالية العامة أو النشاط المؤسسي.',
        'إظهار عناصر الأجندة حسب الصلاحية لا للجمهور تلقائيًا.',
      ],
    );
  }
}

class MediaCenterMediaLibraryOperationalPage extends StatelessWidget {
  const MediaCenterMediaLibraryOperationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaCenterCompletedOperationalPage(
      currentRoute: AppRoutes.adminMediaCenterMediaLibrary,
      governanceFamilyKey: 'media_library',
      title: 'مكتبة المواد الإعلامية',
      subtitle:
          'أصول رسمية مثل الشعار، القوالب، الصور المعتمدة، والكتيبات الإعلامية.',
      icon: Icons.folder_special_outlined,
      primaryLabel: 'إضافة مادة إعلامية',
      previewRoute: AppRoutes.mediaCenter,
      bullets: [
        'حفظ مواد الهوية الإعلامية والأصول البصرية الرسمية.',
        'ربط الملفات بمركز الوثائق عند الحاجة دون نسخ عشوائي.',
        'إتاحة التحميل حسب الصلاحية والنطاق.',
      ],
    );
  }
}

class MediaCenterSanctitiesObservatoryOperationalPage extends StatelessWidget {
  const MediaCenterSanctitiesObservatoryOperationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaCenterCompletedOperationalPage(
      currentRoute: AppRoutes.adminMediaCenterSanctitiesObservatory,
      governanceFamilyKey: 'sanctities_observatory',
      title: 'مرصد حماية المقدسات',
      subtitle:
          'رصد موثق للانتهاكات والاعتداءات على المقدسات والأماكن الوقفية مع إحصائيات وتقارير رسمية.',
      icon: Icons.shield_outlined,
      primaryLabel: 'تسجيل واقعة',
      previewRoute: AppRoutes.sanctitiesObservatory,
      bullets: [
        'تسجيل نوع الواقعة والمكان والتاريخ ودرجة التحقق والحالة.',
        'ربط الأدلة بمركز الوثائق والقضايا والمهام عند الحاجة.',
        'استخدام المستكشف للتحليل المكاني فقط، وwaqf_assets لاحقًا كربط سيادي.',
      ],
    );
  }
}

class MediaCenterMediaReportsOperationalPage extends StatelessWidget {
  const MediaCenterMediaReportsOperationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaCenterCompletedOperationalPage(
      currentRoute: AppRoutes.adminMediaCenterMediaReports,
      governanceFamilyKey: 'media_reports',
      title: 'التقارير الإعلامية',
      subtitle:
          'تقارير منشورة أو داخلية تلخص حملات أو تغطيات أو إنجازات إعلامية.',
      icon: Icons.summarize_outlined,
      primaryLabel: 'إضافة تقرير',
      previewRoute: AppRoutes.mediaCenter,
      bullets: [
        'تمييز التقرير الإعلامي عن التقرير الإداري الداخلي.',
        'ربط التقرير بمواد إعلامية وأدلة عند الحاجة.',
        'تحديد مستوى النشر: عام أو داخلي أو للوحدات.',
      ],
    );
  }
}

class MediaCenterMediaCoverageOperationalPage extends StatelessWidget {
  const MediaCenterMediaCoverageOperationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaCenterCompletedOperationalPage(
      currentRoute: AppRoutes.adminMediaCenterMediaCoverage,
      governanceFamilyKey: 'media_coverage',
      title: 'التغطيات والرصد الإعلامي',
      subtitle:
          'أرشفة ومتابعة ما ينشر عن الوزارة أو قضايا الأوقاف في الإعلام الخارجي.',
      icon: Icons.travel_explore_outlined,
      primaryLabel: 'إضافة تغطية',
      previewRoute: AppRoutes.mediaCenter,
      bullets: [
        'تسجيل المصدر والرابط والتاريخ والتقييم والحاجة للمتابعة.',
        'فصل الرصد الداخلي عن المحتوى المنشور للجمهور.',
        'إحالة ما يحتاج ردًا إلى مهمة أو بيان صحفي حسب الحالة.',
      ],
    );
  }
}

class MediaCenterWaqfImpactStoriesOperationalPage extends StatelessWidget {
  const MediaCenterWaqfImpactStoriesOperationalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MediaCenterCompletedOperationalPage(
      currentRoute: AppRoutes.adminMediaCenterWaqfImpactStories,
      governanceFamilyKey: 'waqf_impact_stories',
      title: 'قصص الأثر الوقفي',
      subtitle:
          'عرض أثر الوقف والمشاريع الوقفية بصياغة حكومية موثقة وغير دعائية.',
      icon: Icons.auto_stories_outlined,
      primaryLabel: 'إضافة قصة أثر',
      previewRoute: AppRoutes.mediaCenter,
      bullets: [
        'ربط القصة بمشروع أو أصل وقفي عند اكتمال waqf_assets.',
        'إظهار الأثر المجتمعي بلغة رسمية موثقة.',
        'منع المبالغة الدعائية أو النشر دون دليل ومراجعة.',
      ],
    );
  }
}

class _OfficialCommunicationField {
  const _OfficialCommunicationField({
    required this.key,
    required this.label,
    required this.helperText,
    this.requiredBeforeApproval = false,
  });

  final String key;
  final String label;
  final String helperText;
  final bool requiredBeforeApproval;
}

class _OfficialCommunicationSpec {
  const _OfficialCommunicationSpec({
    required this.workspaceLabel,
    required this.formIntro,
    required this.fields,
    required this.leadingIcon,
  });

  final String workspaceLabel;
  final String formIntro;
  final List<_OfficialCommunicationField> fields;
  final IconData leadingIcon;

  static const pressRelease = _OfficialCommunicationSpec(
    workspaceLabel: 'سجل البيانات الصحفية',
    formIntro:
        'استخدم بيانات تعريف رسمية قابلة للتدقيق. لا تستخدم هذا المسار للخبر اليومي أو الإعلان.',
    leadingIcon: Icons.article_outlined,
    fields: [
      _OfficialCommunicationField(
        key: 'release_number',
        label: 'رقم البيان / المرجع',
        helperText: 'رقم صادر رسميًا أو مرجع داخلي معتمد.',
        requiredBeforeApproval: true,
      ),
      _OfficialCommunicationField(
        key: 'issuer_name',
        label: 'الجهة المصدرة',
        helperText: 'مثال: وزارة الأوقاف والشؤون الدينية.',
        requiredBeforeApproval: true,
      ),
      _OfficialCommunicationField(
        key: 'issue_date',
        label: 'تاريخ الإصدار',
        helperText: 'يُكتب بصيغة YYYY-MM-DD.',
      ),
      _OfficialCommunicationField(
        key: 'reference_number',
        label: 'مرجع قرار/وثيقة (اختياري)',
        helperText: 'مرجع داخلي أو وثيقة منشورة قابلة للتحقق.',
      ),
    ],
  );

  static const officialStatement = _OfficialCommunicationSpec(
    workspaceLabel: 'سجل التصريحات الرسمية',
    formIntro:
        'يُستخدم فقط للتصريح المنسوب إلى متحدث مخوّل. لا ينشر اسم متحدث أو صفة دون توثيق المصدر.',
    leadingIcon: Icons.record_voice_over_outlined,
    fields: [
      _OfficialCommunicationField(
        key: 'speaker_name',
        label: 'اسم المتحدث',
        helperText: 'الاسم الرسمي كما يظهر في التفويض أو المصدر المعتمد.',
        requiredBeforeApproval: true,
      ),
      _OfficialCommunicationField(
        key: 'speaker_title',
        label: 'الصفة الوظيفية',
        helperText: 'مثل: الوزير، الناطق الرسمي، مدير عام.',
        requiredBeforeApproval: true,
      ),
      _OfficialCommunicationField(
        key: 'speaker_authority',
        label: 'جهة التخويل/الإسناد',
        helperText: 'الجهة التي تثبت صفة المتحدث أو مصدر التصريح.',
      ),
      _OfficialCommunicationField(
        key: 'statement_date',
        label: 'تاريخ التصريح',
        helperText: 'يُكتب بصيغة YYYY-MM-DD.',
      ),
      _OfficialCommunicationField(
        key: 'topic',
        label: 'موضوع التصريح',
        helperText: 'وصف مختصر للموضوع الرسمي.',
      ),
    ],
  );
}

class MediaCenterCompletedOperationalPage extends StatelessWidget {
  const MediaCenterCompletedOperationalPage({
    super.key,
    required this.currentRoute,
    required this.governanceFamilyKey,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryLabel,
    required this.previewRoute,
    required this.bullets,
    this.officialCommunicationSpec,
  });

  final String currentRoute;
  final String governanceFamilyKey;
  final String title;
  final String subtitle;
  final IconData icon;
  final String primaryLabel;
  final String previewRoute;
  final List<String> bullets;
  final _OfficialCommunicationSpec? officialCommunicationSpec;

  @override
  Widget build(BuildContext context) {
    return MediaCenterOperationalPage(
      currentRoute: currentRoute,
      governanceFamilyKey: governanceFamilyKey,
      title: title,
      subtitle: subtitle,
      icon: icon,
      primaryLabel: primaryLabel,
      previewRoute: previewRoute,
      child: _CompletedMediaCenterWorkspace(
        title: title,
        familyKey: governanceFamilyKey,
        primaryLabel: primaryLabel,
        previewRoute: previewRoute,
        bullets: bullets,
        officialCommunicationSpec: officialCommunicationSpec,
      ),
    );
  }
}

class _CompletedMediaCenterWorkspace extends ConsumerStatefulWidget {
  const _CompletedMediaCenterWorkspace({
    required this.title,
    required this.familyKey,
    required this.primaryLabel,
    required this.previewRoute,
    required this.bullets,
    this.officialCommunicationSpec,
  });

  final String title;
  final String familyKey;
  final String primaryLabel;
  final String previewRoute;
  final List<String> bullets;
  final _OfficialCommunicationSpec? officialCommunicationSpec;

  @override
  ConsumerState<_CompletedMediaCenterWorkspace> createState() =>
      _CompletedMediaCenterWorkspaceState();
}

class _CompletedMediaCenterWorkspaceState
    extends ConsumerState<_CompletedMediaCenterWorkspace> {
  String _query = '';
  String _scope = 'الكل';
  String _status = 'الكل';

  PwfPlatformCenterContentQuery _contentQuery() =>
      PwfPlatformCenterContentQuery(
        familyKey: widget.familyKey,
        unitSlug: 'home',
        publishedOnly: false,
        limit: 50,
      );

  List<PwfPlatformCenterContentItem> _filterRows(
    List<PwfPlatformCenterContentItem> rows,
  ) {
    final q = _query.trim().toLowerCase();
    return rows
        .where((row) {
          final matchesQuery =
              q.isEmpty ||
              row.title.toLowerCase().contains(q) ||
              row.ownerName.toLowerCase().contains(q);
          final scopeLabel = _scopeLabel(row.scopeType);
          final statusLabel = _statusLabel(row.status);
          final matchesScope = _scope == 'الكل' || scopeLabel == _scope;
          final matchesStatus = _status == 'الكل' || statusLabel == _status;
          return matchesQuery && matchesScope && matchesStatus;
        })
        .toList(growable: false);
  }

  Future<void> _openCreateDraft() async {
    final result = await showDialog<_DraftFormResult>(
      context: context,
      builder: (context) => _DraftContentDialog(
        title: widget.primaryLabel,
        familyKey: widget.familyKey,
        officialCommunicationSpec: widget.officialCommunicationSpec,
      ),
    );
    if (result == null) return;
    await _saveDraftResult(result);
  }

  Future<void> _openEdit(PwfPlatformCenterContentItem row) async {
    if (row.isFallback) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لا يمكن تحرير عناصر fallback. طبّق backend وseed ثم حرر السجلات الحقيقية.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final result = await showDialog<_DraftFormResult>(
      context: context,
      builder: (context) => _DraftContentDialog(
        title: 'تحرير المحتوى',
        familyKey: widget.familyKey,
        initialItem: row,
        officialCommunicationSpec: widget.officialCommunicationSpec,
      ),
    );
    if (result == null) return;
    await _saveDraftResult(result, id: row.id);
  }

  Future<void> _saveDraftResult(_DraftFormResult result, {String? id}) async {
    final repository = ref.read(pwfPlatformCenterContentRepositoryProvider);
    final draft = PwfPlatformCenterContentDraft(
      id: id,
      familyKey: widget.familyKey,
      title: result.title,
      summary: result.summary,
      body: result.body,
      scopeType: result.scope == 'وحدة' ? 'unit' : 'central',
      unitSlug: result.scope == 'وحدة' ? result.unitSlug : 'home',
      categoryKey: result.categoryKey,
      documentUrl: result.documentUrl,
      metadata: result.metadata,
    );
    final write = id == null
        ? await repository.createDraft(draft)
        : await repository.updateDraft(draft);
    if (!mounted) return;
    ref.invalidate(pwfPlatformCenterContentListProvider(_contentQuery()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(write.messageAr),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _runAction(
    PwfPlatformCenterContentItem row,
    String action,
  ) async {
    if (action == 'edit') {
      await _openEdit(row);
      return;
    }
    final repository = ref.read(pwfPlatformCenterContentRepositoryProvider);
    final result = await repository.transition(
      id: row.id,
      familyKey: widget.familyKey,
      action: action,
    );
    if (!mounted) return;
    ref.invalidate(pwfPlatformCenterContentListProvider(_contentQuery()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.messageAr),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncRows = ref.watch(
      pwfPlatformCenterContentListProvider(_contentQuery()),
    );

    return asyncRows.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stackTrace) =>
          _DataBindingErrorPanel(error: error.toString()),
      data: (sourceRows) {
        final rows = _filterRows(sourceRows);
        final metrics = <_MetricCardData>[
          _MetricCardData(
            label: 'مسودات',
            value: sourceRows.where((e) => e.isDraft).length.toString(),
            icon: Icons.edit_note_outlined,
          ),
          _MetricCardData(
            label: 'قيد المراجعة',
            value: sourceRows.where((e) => e.isReview).length.toString(),
            icon: Icons.fact_check_outlined,
          ),
          _MetricCardData(
            label: 'جاهز للنشر',
            value: sourceRows.where((e) => e.isPublished).length.toString(),
            icon: Icons.verified_outlined,
          ),
          _MetricCardData(
            label: 'مصدر البيانات',
            value: sourceRows.any((e) => e.isFallback) ? 'fallback' : 'RPC',
            icon: Icons.storage_outlined,
          ),
        ];

        return ListView(
          padding: EdgeInsets.zero,
          children: [
            _OperationalCompletionBanner(
              title: widget.title,
              previewRoute: widget.previewRoute,
              homepageSectionKey: _homepageSectionKey(widget.familyKey),
              dataContract: _dataContract(widget.familyKey),
            ),
            if (widget.officialCommunicationSpec != null) ...[
              const SizedBox(height: 14),
              _OfficialCommunicationBriefPanel(
                spec: widget.officialCommunicationSpec!,
                rows: sourceRows,
              ),
            ],
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 980;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final metric in metrics)
                      SizedBox(
                        width: compact
                            ? double.infinity
                            : (constraints.maxWidth - 36) / 4,
                        child: _MetricCard(data: metric),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            _AdminFiltersBar(
              query: _query,
              scope: _scope,
              status: _status,
              onQueryChanged: (value) => setState(() => _query = value),
              onScopeChanged: (value) =>
                  setState(() => _scope = value ?? 'الكل'),
              onStatusChanged: (value) =>
                  setState(() => _status = value ?? 'الكل'),
              onReset: () => setState(() {
                _query = '';
                _scope = 'الكل';
                _status = 'الكل';
              }),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.icon(
                onPressed: _openCreateDraft,
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: Text(widget.primaryLabel),
              ),
            ),
            const SizedBox(height: 14),
            _RowsPanel(
              title: 'سجل الإدارة التشغيلي',
              rows: rows,
              emptyLabel: 'لا توجد عناصر مطابقة للفلاتر الحالية.',
              onAction: _runAction,
              officialCommunicationSpec: widget.officialCommunicationSpec,
            ),
            const SizedBox(height: 14),
            _WorkflowAndGovernancePanel(
              bullets: widget.bullets,
              homepageSectionKey: _homepageSectionKey(widget.familyKey),
              dataContract: _dataContract(widget.familyKey),
            ),
          ],
        );
      },
    );
  }
}

class _OperationalCompletionBanner extends StatelessWidget {
  const _OperationalCompletionBanner({
    required this.title,
    required this.previewRoute,
    required this.homepageSectionKey,
    required this.dataContract,
  });

  final String title;
  final String previewRoute;
  final String homepageSectionKey;
  final String dataContract;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 820;
          final text = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إكمال صفحة $title',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'تم تحويل الصفحة من مخطط نظري إلى مساحة إدارة تشغيلية: فلاتر، سجل عناصر، حالات نشر، حوكمة، وربط بقسم الصفحة الرئيسية $homepageSectionKey. مصدر البيانات التشغيلي: $dataContract.',
                style: const TextStyle(color: Color(0xFF475569), height: 1.6),
              ),
            ],
          );
          final actions = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => context.go(previewRoute),
                icon: const Icon(Icons.open_in_new_outlined, size: 18),
                label: const Text('معاينة الصفحة العامة'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.adminHomeManagement),
                icon: const Icon(Icons.view_quilt_outlined, size: 18),
                label: const Text('إدارة قسم الرئيسية'),
              ),
            ],
          );
          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [text, const SizedBox(height: 12), actions],
            );
          }
          return Row(
            children: [
              Expanded(child: text),
              const SizedBox(width: 18),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _AdminFiltersBar extends StatelessWidget {
  const _AdminFiltersBar({
    required this.query,
    required this.scope,
    required this.status,
    required this.onQueryChanged,
    required this.onScopeChanged,
    required this.onStatusChanged,
    required this.onReset,
  });

  final String query;
  final String scope;
  final String status;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String?> onScopeChanged;
  final ValueChanged<String?> onStatusChanged;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 860;
          final queryField = TextFormField(
            initialValue: query,
            onChanged: onQueryChanged,
            decoration: const InputDecoration(
              labelText: 'بحث في العنوان أو الجهة',
              prefixIcon: Icon(Icons.search_outlined),
              border: OutlineInputBorder(),
              isDense: true,
            ),
          );
          final filters = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: compact ? double.infinity : 180,
                child: DropdownButtonFormField<String>(
                  initialValue: scope,
                  decoration: const InputDecoration(
                    labelText: 'النطاق',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const ['الكل', 'الوزارة', 'وحدة']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: onScopeChanged,
                ),
              ),
              SizedBox(
                width: compact ? double.infinity : 190,
                child: DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(
                    labelText: 'الحالة',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const ['الكل', 'مسودة', 'قيد المراجعة', 'جاهز للنشر']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: onStatusChanged,
                ),
              ),
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh_outlined, size: 18),
                label: const Text('تصفير'),
              ),
            ],
          );
          if (compact) {
            return Column(
              children: [queryField, const SizedBox(height: 10), filters],
            );
          }
          return Row(
            children: [
              Expanded(child: queryField),
              const SizedBox(width: 12),
              filters,
            ],
          );
        },
      ),
    );
  }
}

class _RowsPanel extends StatelessWidget {
  const _RowsPanel({
    required this.title,
    required this.rows,
    required this.emptyLabel,
    required this.onAction,
    this.officialCommunicationSpec,
  });

  final String title;
  final List<PwfPlatformCenterContentItem> rows;
  final String emptyLabel;
  final void Function(PwfPlatformCenterContentItem row, String action) onAction;
  final _OfficialCommunicationSpec? officialCommunicationSpec;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (rows.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                emptyLabel,
                style: const TextStyle(color: Color(0xFF64748B)),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 860;
                return Column(
                  children: [
                    for (final row in rows) ...[
                      _AdminRowCard(
                        row: row,
                        compact: compact,
                        onAction: onAction,
                        officialCommunicationSpec: officialCommunicationSpec,
                      ),
                      if (row != rows.last) const SizedBox(height: 10),
                    ],
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _AdminRowCard extends StatelessWidget {
  const _AdminRowCard({
    required this.row,
    required this.compact,
    required this.onAction,
    this.officialCommunicationSpec,
  });

  final PwfPlatformCenterContentItem row;
  final bool compact;
  final void Function(PwfPlatformCenterContentItem row, String action) onAction;
  final _OfficialCommunicationSpec? officialCommunicationSpec;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusLabel(row.status) == 'جاهز للنشر'
        ? const Color(0xFF047857)
        : _statusLabel(row.status) == 'قيد المراجعة'
        ? const Color(0xFFB45309)
        : const Color(0xFF475569);
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          row.title,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 8,
          runSpacing: 5,
          children: [
            _SmallPill(
              label: _scopeLabel(row.scopeType),
              icon: Icons.account_tree_outlined,
            ),
            _SmallPill(label: row.ownerName, icon: Icons.apartment_outlined),
            _SmallPill(
              label: _statusLabel(row.status),
              icon: Icons.circle,
              color: statusColor,
            ),
          ],
        ),
        if (officialCommunicationSpec != null) ...[
          const SizedBox(height: 7),
          _OfficialCommunicationMetadataLine(
            spec: officialCommunicationSpec!,
            metadata: row.metadata,
          ),
        ],
      ],
    );
    final workflowActions = _workflowActionsFor(row);
    final actions = Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final item in workflowActions)
          TextButton.icon(
            onPressed: () => onAction(row, item.action),
            icon: Icon(item.icon, size: 18),
            label: Text(item.label),
          ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 10), actions],
            )
          : Row(
              children: [
                Expanded(child: title),
                actions,
              ],
            ),
    );
  }
}

class _WorkflowAndGovernancePanel extends StatelessWidget {
  const _WorkflowAndGovernancePanel({
    required this.bullets,
    required this.homepageSectionKey,
    required this.dataContract,
  });

  final List<String> bullets;
  final String homepageSectionKey;
  final String dataContract;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3A70).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF0B3A70).withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الحوكمة والربط بالصفحة الرئيسية',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SmallPill(
                label: 'section: $homepageSectionKey',
                icon: Icons.view_quilt_outlined,
              ),
              _SmallPill(label: dataContract, icon: Icons.storage_outlined),
              const _SmallPill(
                label: 'مسودة ← مراجعة ← جاهز للنشر',
                icon: Icons.published_with_changes_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (final bullet in bullets)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 19,
                    color: Color(0xFF0B3A70),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(bullet, style: const TextStyle(height: 1.55)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MetricCardData {
  const _MetricCardData({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});

  final _MetricCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0B3A70).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: const Color(0xFF0B3A70), size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                Text(
                  data.label,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
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

class _SmallPill extends StatelessWidget {
  const _SmallPill({
    required this.label,
    required this.icon,
    this.color = const Color(0xFF0B3A70),
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveMaxWidth =
            constraints.maxWidth.isFinite && constraints.maxWidth < 260
            ? constraints.maxWidth
            : 260.0;

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: color.withValues(alpha: 0.18)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OfficialCommunicationBriefPanel extends StatelessWidget {
  const _OfficialCommunicationBriefPanel({
    required this.spec,
    required this.rows,
  });

  final _OfficialCommunicationSpec spec;
  final List<PwfPlatformCenterContentItem> rows;

  @override
  Widget build(BuildContext context) {
    final missingMetadata = rows.where((row) => spec.fields.any(
      (field) => field.requiredBeforeApproval && (row.metadata[field.key]?.toString().trim().isEmpty ?? true),
    )).length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3A70).withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF0B3A70).withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF0B3A70).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(spec.leadingIcon, color: const Color(0xFF0B3A70)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(spec.workspaceLabel, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                Text(spec.formIntro, style: const TextStyle(color: Color(0xFF475569), height: 1.45)),
                if (missingMetadata > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '$missingMetadata سجل يحتاج استكمال حقول التعريف الرسمية قبل إرساله للمراجعة أو الاعتماد.',
                    style: const TextStyle(color: Color(0xFF92400E), fontWeight: FontWeight.w700),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OfficialCommunicationMetadataLine extends StatelessWidget {
  const _OfficialCommunicationMetadataLine({
    required this.spec,
    required this.metadata,
  });

  final _OfficialCommunicationSpec spec;
  final Map<String, dynamic> metadata;

  @override
  Widget build(BuildContext context) {
    final entries = spec.fields
        .where((field) => metadata[field.key]?.toString().trim().isNotEmpty ?? false)
        .take(2)
        .toList(growable: false);
    if (entries.isEmpty) {
      return const Text(
        'حقول التعريف الرسمية غير مكتملة',
        style: TextStyle(color: Color(0xFFB45309), fontSize: 12, fontWeight: FontWeight.w700),
      );
    }
    return Text(
      entries.map((field) => '${field.label}: ${metadata[field.key]}').join(' • '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
    );
  }
}

class _OfficialCommunicationFormFields extends StatelessWidget {
  const _OfficialCommunicationFormFields({
    required this.spec,
    required this.controllers,
  });

  final _OfficialCommunicationSpec spec;
  final Map<String, TextEditingController> controllers;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(spec.workspaceLabel, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(spec.formIntro, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, height: 1.4)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final field in spec.fields)
                SizedBox(
                  width: 320,
                  child: TextFormField(
                    controller: controllers[field.key],
                    validator: (value) => null,
                    decoration: InputDecoration(
                      labelText: field.label,
                      helperText: field.helperText,
                      helperMaxLines: 2,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DraftFormResult {
  const _DraftFormResult({
    required this.title,
    required this.summary,
    required this.body,
    required this.scope,
    required this.unitSlug,
    required this.categoryKey,
    required this.documentUrl,
    required this.metadata,
  });

  final String title;
  final String summary;
  final String body;
  final String scope;
  final String unitSlug;
  final String categoryKey;
  final String documentUrl;
  final Map<String, dynamic> metadata;
}

class _DraftContentDialog extends StatefulWidget {
  const _DraftContentDialog({
    required this.title,
    required this.familyKey,
    this.initialItem,
    this.officialCommunicationSpec,
  });

  final String title;
  final String familyKey;
  final PwfPlatformCenterContentItem? initialItem;
  final _OfficialCommunicationSpec? officialCommunicationSpec;

  @override
  State<_DraftContentDialog> createState() => _DraftContentDialogState();
}

class _DraftContentDialogState extends State<_DraftContentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _summaryController;
  late final TextEditingController _bodyController;
  late final TextEditingController _unitSlugController;
  late final TextEditingController _documentUrlController;
  late final TextEditingController _metadataController;
  late final Map<String, TextEditingController> _officialFieldControllers;
  late String _scope;
  late String _categoryKey;

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _titleController = TextEditingController(text: item?.title ?? '');
    _summaryController = TextEditingController(text: item?.summary ?? '');
    _bodyController = TextEditingController(text: item?.body ?? '');
    _unitSlugController = TextEditingController(
      text: item?.unitSlug == 'home' ? '' : item?.unitSlug ?? '',
    );
    _documentUrlController = TextEditingController(
      text: item?.documentUrl ?? '',
    );
    _metadataController = TextEditingController(
      text: _initialMetadataText(item),
    );
    _officialFieldControllers = {
      for (final field in widget.officialCommunicationSpec?.fields ?? const <_OfficialCommunicationField>[])
        field.key: TextEditingController(text: item?.metadata[field.key]?.toString() ?? ''),
    };
    _scope = _scopeLabel(item?.scopeType ?? 'central') == 'وحدة'
        ? 'وحدة'
        : 'الوزارة';
    _categoryKey = (item?.categoryKey.trim().isNotEmpty ?? false)
        ? item!.categoryKey
        : _categoriesForFamily(widget.familyKey).first.value;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _bodyController.dispose();
    _unitSlugController.dispose();
    _documentUrlController.dispose();
    _metadataController.dispose();
    for (final controller in _officialFieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categoriesForFamily(widget.familyKey);
    if (!categories.any((item) => item.value == _categoryKey)) {
      _categoryKey = categories.first.value;
    }
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 720,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'العنوان',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().length < 3)
                      ? 'أدخل عنوانًا واضحًا.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _summaryController,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'الملخص',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().length < 10)
                      ? 'أدخل ملخصًا لا يقل عن 10 أحرف.'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _bodyController,
                  minLines: 5,
                  maxLines: 9,
                  decoration: const InputDecoration(
                    labelText: 'النص التفصيلي / body_ar',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().length < 20)
                      ? 'أدخل نصًا تفصيليًا لا يقل عن 20 حرفًا.'
                      : null,
                ),
                if (widget.officialCommunicationSpec != null) ...[
                  const SizedBox(height: 12),
                  _OfficialCommunicationFormFields(
                    spec: widget.officialCommunicationSpec!,
                    controllers: _officialFieldControllers,
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _categoryKey,
                        decoration: const InputDecoration(
                          labelText: 'التصنيف',
                          border: OutlineInputBorder(),
                        ),
                        items: categories
                            .map(
                              (item) => DropdownMenuItem(
                                value: item.value,
                                child: Text(item.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setState(
                          () => _categoryKey = value ?? categories.first.value,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _scope,
                        decoration: const InputDecoration(
                          labelText: 'النطاق',
                          border: OutlineInputBorder(),
                        ),
                        items: const ['الوزارة', 'وحدة']
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => _scope = value ?? 'الوزارة'),
                      ),
                    ),
                  ],
                ),
                if (_scope == 'وحدة') ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _unitSlugController,
                    decoration: const InputDecoration(
                      labelText: 'معرّف الوحدة / unitSlug',
                      helperText:
                          'اختر/أدخل slug وحدة حقيقي من core.org_units أو view معتمد. لا تستخدم unit-demo.',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        _scope == 'وحدة' &&
                            (value == null || value.trim().isEmpty)
                        ? 'أدخل unitSlug حقيقي.'
                        : null,
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _documentUrlController,
                  decoration: const InputDecoration(
                    labelText: 'رابط ملف/وثيقة اختياري',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _metadataController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'حقول metadata مختصرة',
                    helperText:
                        'صيغة key=value في كل سطر، مثل speaker=... أو event_location=...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () {
            if (!(_formKey.currentState?.validate() ?? false)) return;
            Navigator.of(context).pop(
              _DraftFormResult(
                title: _titleController.text,
                summary: _summaryController.text,
                body: _bodyController.text,
                scope: _scope,
                unitSlug: _unitSlugController.text.trim(),
                categoryKey: _categoryKey,
                documentUrl: _documentUrlController.text.trim(),
                metadata: {
                  ..._parseMetadata(_metadataController.text),
                  for (final entry in _officialFieldControllers.entries)
                    if (entry.value.text.trim().isNotEmpty)
                      entry.key: entry.value.text.trim(),
                },
              ),
            );
          },
          child: Text(
            widget.initialItem == null ? 'حفظ مسودة' : 'حفظ التعديلات',
          ),
        ),
      ],
    );
  }
}

class _CategoryOption {
  const _CategoryOption(this.value, this.label);

  final String value;
  final String label;
}

List<_CategoryOption> _categoriesForFamily(String familyKey) {
  switch (familyKey) {
    case 'press_releases':
      return const [
        _CategoryOption('official_press_release', 'بيان صحفي رسمي'),
      ];
    case 'official_statements':
      return const [
        _CategoryOption('authorized_statement', 'تصريح رسمي مخوّل'),
      ];
    case 'awareness_campaigns':
      return const [_CategoryOption('public_awareness', 'حملة توعوية عامة')];
    case 'sanctities_observatory':
      return const [_CategoryOption('incident_report', 'واقعة/تقرير موثق')];
    case 'legal_references':
      return const [
        _CategoryOption('law', 'قانون'),
        _CategoryOption('instruction', 'تعليمات'),
        _CategoryOption('procedure_guide', 'دليل إجرائي'),
      ];
    case 'events':
      return const [_CategoryOption('public_event', 'فعالية عامة')];
    case 'media_reports':
      return const [_CategoryOption('media_report', 'تقرير إعلامي')];
    case 'media_coverage':
      return const [_CategoryOption('coverage', 'تغطية إعلامية')];
    case 'waqf_impact_stories':
      return const [_CategoryOption('impact_story', 'قصة أثر وقفي')];
    case 'social_posts':
      return const [
        _CategoryOption('general', 'اجتماعيات عامة'),
        _CategoryOption('condolence', 'تعزية'),
        _CategoryOption('congratulation', 'تهنئة'),
      ];
    default:
      return const [_CategoryOption('general', 'عام')];
  }
}

String _initialMetadataText(PwfPlatformCenterContentItem? item) {
  if (item == null || item.metadata.isEmpty) return '';
  final allowed = <String>[
    'speaker',
    'event_location',
    'event_date',
    'verification_level',
    'reference_type',
    'campaign_start',
    'campaign_end',
  ];
  return allowed
      .where(item.metadata.containsKey)
      .map((key) => '$key=${item.metadata[key]}')
      .join('\n');
}

Map<String, dynamic> _parseMetadata(String raw) {
  final output = <String, dynamic>{};
  for (final line in raw.split('\n')) {
    final index = line.indexOf('=');
    if (index <= 0) continue;
    final key = line.substring(0, index).trim();
    final value = line.substring(index + 1).trim();
    if (key.isNotEmpty && value.isNotEmpty) output[key] = value;
  }
  return output;
}

class _DataBindingErrorPanel extends StatelessWidget {
  const _DataBindingErrorPanel({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        'تعذر تحميل مصدر البيانات التشغيلي: $error',
        style: const TextStyle(color: Color(0xFF92400E)),
      ),
    );
  }
}

String _scopeLabel(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized == 'unit' || normalized == 'وحدة') return 'وحدة';
  if (normalized == 'central' ||
      normalized == 'ministry' ||
      normalized == 'home' ||
      normalized == 'الوزارة')
    return 'الوزارة';
  return value.trim().isEmpty ? 'الوزارة' : value;
}

String _statusLabel(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized == 'published' || value == 'منشور') return 'منشور';
  if (normalized == 'ready_to_publish' || value == 'جاهز للنشر')
    return 'جاهز للنشر';
  if (normalized == 'scheduled' || value == 'مجدول') return 'مجدول';
  if (normalized == 'archived' || value == 'مؤرشف') return 'مؤرشف';
  if (normalized == 'rejected' || value == 'مرفوض') return 'مرفوض';
  if (normalized == 'review' ||
      normalized == 'in_review' ||
      value == 'قيد المراجعة')
    return 'قيد المراجعة';
  if (normalized == 'draft' || value == 'مسودة') return 'مسودة';
  return value.trim().isEmpty ? 'مسودة' : value;
}

List<({String action, IconData icon, String label})> _workflowActionsFor(
  PwfPlatformCenterContentItem row,
) {
  final status = _statusLabel(row.status);
  final actions = <({String action, IconData icon, String label})>[
    (action: 'edit', icon: Icons.edit_outlined, label: 'تحرير'),
  ];
  if (status == 'مسودة') {
    actions.add((
      action: 'submit_review',
      icon: Icons.fact_check_outlined,
      label: 'إرسال للمراجعة',
    ));
  } else if (status == 'قيد المراجعة') {
    actions.add((
      action: 'approve',
      icon: Icons.verified_outlined,
      label: 'اعتماد للنشر',
    ));
    actions.add((action: 'reject', icon: Icons.block_outlined, label: 'رفض'));
  } else if (status == 'جاهز للنشر') {
    actions.add((
      action: 'publish',
      icon: Icons.publish_outlined,
      label: 'نشر',
    ));
    actions.add((
      action: 'schedule',
      icon: Icons.schedule_outlined,
      label: 'جدولة',
    ));
  } else if (status == 'مجدول') {
    actions.add((
      action: 'publish',
      icon: Icons.publish_outlined,
      label: 'نشر الآن',
    ));
  } else if (status == 'منشور') {
    actions.add((
      action: 'archive',
      icon: Icons.archive_outlined,
      label: 'أرشفة',
    ));
  }
  return actions;
}

String _homepageSectionKey(String familyKey) {
  switch (familyKey) {
    case 'social_posts':
      return 'pwf_social_posts_section';
    case 'press_releases':
      return 'pwf_press_releases_section';
    case 'official_statements':
      return 'pwf_official_statements_section';
    case 'awareness_campaigns':
      return 'pwf_awareness_campaigns_section';
    case 'sanctities_observatory':
      return 'pwf_sanctities_observatory_section';
    case 'events':
      return 'pwf_events_section';
    default:
      return 'pwf_media_center_highlights';
  }
}

String _dataContract(String familyKey) {
  final normalized = familyKey.trim().replaceAll('-', '_');
  switch (normalized) {
    case 'news':
      return 'media_center.v_unit_public_news_runtime_v1 — legacy quarantine للـ public.news_articles';
    case 'announcements':
      return 'media_center.v_unit_public_announcements_runtime_v1 — legacy quarantine للـ public.announcements';
    case 'activities':
    case 'events':
      return 'media_center.v_unit_public_activities_runtime_v1 — legacy quarantine للجداول العامة القديمة';
    case 'social_posts':
      return 'media_center.v_unit_public_social_posts_runtime_v1 — legacy quarantine للجداول العامة القديمة';
    default:
      return 'media_center.v_unit_public_content_runtime_v1(family_key=$normalized) — legacy quarantine للجداول العامة القديمة';
  }
}

class MediaCenterOperationalPage extends StatelessWidget {
  const MediaCenterOperationalPage({
    super.key,
    required this.currentRoute,
    required this.governanceFamilyKey,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryLabel,
    required this.previewRoute,
    required this.child,
    this.accentColor = const Color(0xFF0B3A70),
    this.operationalLabel = 'خدمة تشغيلية مباشرة',
  });

  final String currentRoute;
  final String governanceFamilyKey;
  final String title;
  final String subtitle;
  final IconData icon;
  final String primaryLabel;
  final String previewRoute;
  final Widget child;
  final Color accentColor;
  final String operationalLabel;

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: currentRoute,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                child: _MediaCenterOperationalHeader(
                  currentRoute: currentRoute,
                  governanceFamilyKey: governanceFamilyKey,
                  title: title,
                  subtitle: subtitle,
                  icon: icon,
                  primaryLabel: primaryLabel,
                  previewRoute: previewRoute,
                  accentColor: accentColor,
                  operationalLabel: operationalLabel,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                  child: ClipRect(child: child),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaCenterOperationalHeader extends StatelessWidget {
  const _MediaCenterOperationalHeader({
    required this.currentRoute,
    required this.governanceFamilyKey,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryLabel,
    required this.previewRoute,
    required this.accentColor,
    required this.operationalLabel,
  });

  final String currentRoute;
  final String governanceFamilyKey;
  final String title;
  final String subtitle;
  final IconData icon;
  final String primaryLabel;
  final String previewRoute;
  final Color accentColor;
  final String operationalLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 980;
          final titleBlock = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        _OperationalChip(label: operationalLabel, color: accentColor),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: compact ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF475569),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final actions = Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: () => context.go(currentRoute),
                icon: const Icon(Icons.edit_note_outlined, size: 18),
                label: Text(primaryLabel),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go(
                  AppRoutes.adminMediaCenterFamilyGovernance(
                    governanceFamilyKey,
                  ),
                ),
                icon: const Icon(Icons.policy_outlined, size: 18),
                label: const Text('حوكمة الصفحة'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go(previewRoute),
                icon: const Icon(Icons.open_in_new_outlined, size: 18),
                label: const Text('عرض عام'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.adminMediaCenter),
                icon: const Icon(Icons.dashboard_customize_outlined, size: 18),
                label: const Text('لوحة المركز'),
              ),
            ],
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [titleBlock, const SizedBox(height: 12), actions],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: titleBlock),
              const SizedBox(width: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: actions,
              ),
            ],
          );
        },
      ),
    );
  }
}

class MediaCenterGovernanceInfoPage extends StatelessWidget {
  const MediaCenterGovernanceInfoPage({super.key, this.familyKey});

  final String? familyKey;

  @override
  Widget build(BuildContext context) {
    final info = MediaCenterGovernanceInfo.resolve(familyKey);
    return AdminLayout(
      currentRoute: familyKey == null
          ? AppRoutes.adminMediaCenterGovernance
          : AppRoutes.adminMediaCenterFamilyGovernance(familyKey!),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: ListView(
            padding: const EdgeInsets.all(22),
            children: [
              _GovernanceHeader(info: info),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final columns = width >= 1100 ? 3 : (width >= 760 ? 2 : 1);
                  final spacing = 12.0;
                  final cardWidth = (width - spacing * (columns - 1)) / columns;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: _GovernanceInfoCard(
                          title: 'مبرر الصفحة',
                          icon: Icons.info_outline,
                          text: info.rationale,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _GovernanceInfoCard(
                          title: 'مصدر البيانات',
                          icon: Icons.storage_outlined,
                          text: info.dataSource,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _GovernanceInfoCard(
                          title: 'نطاق النشر',
                          icon: Icons.public_outlined,
                          text: info.publishingScope,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _GovernanceInfoCard(
                          title: 'مالك المحتوى',
                          icon: Icons.manage_accounts_outlined,
                          text: info.owner,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _GovernanceInfoCard(
                          title: 'سير التحرير',
                          icon: Icons.account_tree_outlined,
                          text: info.workflow,
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: _GovernanceInfoCard(
                          title: 'قيود النشر',
                          icon: Icons.gpp_maybe_outlined,
                          text: info.constraints,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              _GovernanceActions(info: info),
            ],
          ),
        ),
      ),
    );
  }
}

class _GovernanceHeader extends StatelessWidget {
  const _GovernanceHeader({required this.info});

  final MediaCenterGovernanceInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0B3A70).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(info.icon, color: const Color(0xFF0B3A70)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'هذه الصفحة تعرض معلومات الحوكمة الخاصة بالخدمة نفسها، دون إقحامها داخل واجهة الإدارة اليومية.',
                  style: const TextStyle(color: Color(0xFF64748B), height: 1.5),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => context.go(info.adminRoute),
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('العودة للخدمة'),
          ),
        ],
      ),
    );
  }
}

class _GovernanceInfoCard extends StatelessWidget {
  const _GovernanceInfoCard({
    required this.title,
    required this.icon,
    required this.text,
  });

  final String title;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 160),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0B3A70), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(color: Color(0xFF475569), height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _GovernanceActions extends StatelessWidget {
  const _GovernanceActions({required this.info});

  final MediaCenterGovernanceInfo info;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3A70).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF0B3A70).withValues(alpha: 0.12),
        ),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        children: [
          FilledButton.icon(
            onPressed: () => context.go(info.adminRoute),
            icon: const Icon(Icons.edit_note_outlined, size: 18),
            label: const Text('فتح صفحة الإدارة'),
          ),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.adminMediaCenter),
            icon: const Icon(Icons.dashboard_customize_outlined, size: 18),
            label: const Text('لوحة المركز'),
          ),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.adminMediaCenterGovernance),
            icon: const Icon(Icons.fact_check_outlined, size: 18),
            label: const Text('حوكمة عامة'),
          ),
        ],
      ),
    );
  }
}

class MediaCenterGovernanceInfo {
  const MediaCenterGovernanceInfo({
    required this.familyKey,
    required this.title,
    required this.icon,
    required this.adminRoute,
    required this.rationale,
    required this.dataSource,
    required this.publishingScope,
    required this.owner,
    required this.workflow,
    required this.constraints,
  });

  final String familyKey;
  final String title;
  final IconData icon;
  final String adminRoute;
  final String rationale;
  final String dataSource;
  final String publishingScope;
  final String owner;
  final String workflow;
  final String constraints;

  static MediaCenterGovernanceInfo resolve(String? familyKey) {
    return _byKey[familyKey] ?? _overview;
  }

  static const _overview = MediaCenterGovernanceInfo(
    familyKey: 'overview',
    title: 'حوكمة المركز الإعلامي',
    icon: Icons.policy_outlined,
    adminRoute: AppRoutes.adminMediaCenter,
    rationale:
        'إطار عام يجمع الخدمات الإعلامية دون توحيد طبيعتها الوظيفية أو إلغاء الفروق بين الأخبار، الإعلانات، الأنشطة، الوسائط، العاجل، الخطب، والسلايدر.',
    dataSource:
        'مصادر سيادية مباشرة: media_center.content_items و core.org_units و owner-schema runtime views؛ public.* محفوظ كـ legacy evidence فقط وليس مسار تشغيل.',
    publishingScope:
        'الوزارة تظهر على الصفحة الرئيسية، والوحدة تظهر في صفحة الوحدة، مع إبراز مختصر متبادل دون نقل ملكية المحتوى.',
    owner:
        'الإعلام المركزي يملك النشر العام، ومديرو الوحدات يملكون محتوى وحداتهم ضمن الصلاحيات.',
    workflow: 'مسودة ← مراجعة تحريرية ← اعتماد ← نشر/جدولة ← أرشفة.',
    constraints:
        'لا تنشأ جداول محتوى موازية، ولا ينشر محتوى وحدة على الصفحة الرئيسية دون موافقة مركزية وأثر تدقيق.',
  );

  static const _byKey = <String, MediaCenterGovernanceInfo>{
    'news': MediaCenterGovernanceInfo(
      familyKey: 'news',
      title: 'حوكمة الأخبار',
      icon: Icons.newspaper_outlined,
      adminRoute: AppRoutes.adminMediaCenterNews,
      rationale:
          'إدارة الأخبار الرسمية للوزارة والوحدات مع منع خلط خبر الوحدة بخبر الوزارة إلا عبر اعتماد مركزي.',
      dataSource: 'media_center.content_items → media_center.v_unit_public_news_runtime_v1.',
      publishingScope:
          'home لأخبار الوزارة، وslug لأخبار الوحدة، مع إمكانية إبراز مختصر وفق قرار تحريري.',
      owner: 'الإعلام المركزي ومديرو الوحدات حسب نطاق الخبر.',
      workflow:
          'مسودة خبر ← مراجعة لغة وتصنيف وصورة ← اعتماد ← نشر/تثبيت/تمييز ← أرشفة.',
      constraints:
          'العنوان والصورة والنطاق والحالة إلزامية قبل الظهور العام، وخبر الوحدة لا ينتقل للرئيسية دون موافقة.',
    ),
    'announcements': MediaCenterGovernanceInfo(
      familyKey: 'announcements',
      title: 'حوكمة الإعلانات',
      icon: Icons.campaign_outlined,
      adminRoute: AppRoutes.adminMediaCenterAnnouncements,
      rationale:
          'الإعلان مادة رسمية أو تشغيلية مرتبطة بزمن وأولوية، وليست خبرًا سرديًا.',
      dataSource: 'media_center.content_items → media_center.v_unit_public_announcements_runtime_v1.',
      publishingScope:
          'إعلانات الوزارة تظهر في المسار العام، وإعلانات الوحدة تظهر داخل صفحة الوحدة أو حسب الصلاحية.',
      owner: 'الإعلام المركزي أو مدير الوحدة حسب نطاق الإعلان.',
      workflow:
          'مسودة إعلان ← مراجعة التاريخ والأولوية ← اعتماد ← نشر/إخفاء تلقائي ← أرشفة.',
      constraints:
          'الأولوية وتاريخ البداية/النهاية وحالة الظهور يجب أن تكون واضحة قبل النشر.',
    ),
    'activities': MediaCenterGovernanceInfo(
      familyKey: 'activities',
      title: 'حوكمة الأنشطة',
      icon: Icons.event_note_outlined,
      adminRoute: AppRoutes.adminMediaCenterActivities,
      rationale:
          'توثيق نشاط مؤسسي دوري أو تشغيلي لا يحتاج دائمًا نفس حساسية الخبر العاجل أو الإعلان.',
      dataSource: 'media_center.content_items → media_center.v_unit_public_activities_runtime_v1.',
      publishingScope:
          'أنشطة الوزارة في الصفحة/المسار العام، وأنشطة الوحدة في صفحة الوحدة.',
      owner: 'الإعلام المركزي والوحدة المالكة للنشاط.',
      workflow: 'إدخال نشاط ← مراجعة تصنيف وتاريخ ← نشر ← أرشفة.',
      constraints: 'يجب تمييز النشاط عن الفعالية عند وجود موعد/مكان/حضور محدد.',
    ),
    'events': MediaCenterGovernanceInfo(
      familyKey: 'events',
      title: 'حوكمة الفعاليات',
      icon: Icons.celebration_outlined,
      adminRoute: AppRoutes.adminMediaCenterEvents,
      rationale:
          'الفعالية حدث بزمن ومكان وحضور، وتُدار مرحليًا كتصنيف داخل الأنشطة لا كجدول مستقل.',
      dataSource: 'media_center.content_items → media_center.v_unit_public_activities_runtime_v1 مع family_key=events عند توفره.',
      publishingScope:
          'فعاليات الوزارة أو الوحدة حسب النطاق، مع عرض مناسب للفعاليات القادمة والمنتهية.',
      owner: 'الإعلام المركزي أو الوحدة المنظمة.',
      workflow:
          'مسودة فعالية ← مراجعة الموعد والمكان ← اعتماد ← نشر/إغلاق ← أرشفة.',
      constraints: 'لا يُنشأ جدول فعاليات مستقل قبل قرار معماري صريح.',
    ),
    'photos': MediaCenterGovernanceInfo(
      familyKey: 'photos',
      title: 'حوكمة معرض الصور',
      icon: Icons.photo_library_outlined,
      adminRoute: AppRoutes.adminMediaCenterPhotos,
      rationale:
          'إدارة أصول بصرية تحتاج معاينة وحقوق ونص بديل، لا مجرد سجل نصي.',
      dataSource: 'media_center.media_gallery_items/content_assets → media_center.v_unit_public_gallery_runtime_v1.',
      publishingScope:
          'صور الوزارة في الصفحة/المعرض العام، وصور الوحدة ضمن صفحة الوحدة أو معرضها.',
      owner: 'الجهة المالكة للصورة مع مراجعة الإعلام عند الظهور العام.',
      workflow:
          'رفع صورة ← مراجعة الجودة والحقوق والنص البديل ← اعتماد ← نشر ← أرشفة.',
      constraints: 'لا تُنشر صورة دون وصف مناسب وصورة مصغرة ونطاق واضح.',
    ),
    'videos': MediaCenterGovernanceInfo(
      familyKey: 'videos',
      title: 'حوكمة الفيديوهات',
      icon: Icons.ondemand_video_outlined,
      adminRoute: AppRoutes.adminMediaCenterVideos,
      rationale:
          'الفيديو يعتمد رابطًا/ملفًا ومعاينة ووصفًا، وله قيود مختلفة عن الصور والنصوص.',
      dataSource: 'media_center.media_gallery_items/content_assets → media_center.v_unit_public_gallery_runtime_v1.',
      publishingScope: 'فيديوهات الوزارة أو الوحدة حسب النطاق وحقوق النشر.',
      owner: 'الإعلام المركزي أو الوحدة المالكة للفيديو.',
      workflow: 'إضافة فيديو ← تحقق الرابط/المعاينة ← اعتماد ← نشر ← أرشفة.',
      constraints: 'يجب تحقق الرابط/المعاينة والوصف قبل الظهور العام.',
    ),
    'breaking_news': MediaCenterGovernanceInfo(
      familyKey: 'breaking_news',
      title: 'حوكمة الأخبار العاجلة',
      icon: Icons.priority_high_outlined,
      adminRoute: AppRoutes.adminMediaCenterBreakingNews,
      rationale:
          'الأخبار العاجلة ذات أثر فوري على الصفحة الرئيسية، لذلك تحتاج صلاحية مركزية وزمن ظهور مضبوط.',
      dataSource: 'media_center.content_items/platform_content surface settings → unit/home scoped breaking wrapper.',
      publishingScope: 'غالبًا مركزي على الصفحة الرئيسية أو شريط العاجل.',
      owner: 'الإعلام المركزي أو من يفوضه رسميًا.',
      workflow:
          'مسودة عاجل ← مراجعة مركزية سريعة ← نشر محدد الزمن ← إخفاء/انتهاء تلقائي.',
      constraints:
          'لا تنشر كعاجل إلا عند الحاجة، ويجب تحديد الأولوية وتاريخ الانتهاء.',
    ),
    'friday_sermons': MediaCenterGovernanceInfo(
      familyKey: 'friday_sermons',
      title: 'حوكمة خُطب الجمعة',
      icon: Icons.mic_none_outlined,
      adminRoute: AppRoutes.adminMediaCenterFridaySermons,
      rationale:
          'الخطب محتوى تخصصي لا يعامل كمادة إعلامية عامة فقط؛ يحتاج اعتمادًا إداريًا/شرعيًا.',
      dataSource: 'media_center.friday_sermons أو owner-schema sermon surface؛ public.friday_sermons legacy evidence only.',
      publishingScope: 'صفحة خُطب الجمعة العامة أو الأرشيف المخصص.',
      owner: 'الإدارة المختصة بخطب الجمعة.',
      workflow:
          'إضافة خطبة ← مراجعة النص/الملف/التاريخ ← اعتماد ← نشر ← أرشفة.',
      constraints:
          'التاريخ والعنوان والملف أو النص يجب أن تكون واضحة قبل النشر.',
    ),
    'hero_slider': MediaCenterGovernanceInfo(
      familyKey: 'hero_slider',
      title: 'حوكمة السلايدر والحملات البصرية',
      icon: Icons.slideshow_outlined,
      adminRoute: AppRoutes.adminMediaCenterHeroSlider,
      rationale:
          'السلايدر واجهة وحملة بصرية وليس خبرًا أو إعلانًا نصيًا؛ يحتاج تصميمًا وترتيبًا وCTA.',
      dataSource: 'core.org_unit_profiles/platform_content surface settings → core.v_unit_public_surface_profile_runtime_v1.',
      publishingScope: 'الصفحة الرئيسية والحملات البصرية المعتمدة.',
      owner: 'الإعلام المركزي وإدارة الصفحة الرئيسية.',
      workflow:
          'مسودة شريحة ← مراجعة الصورة والرابط والترتيب ← اعتماد ← نشر/جدولة ← أرشفة.',
      constraints:
          'الصورة وCTA وترتيب الشرائح لا تُعدل دون اختبار الواجهة العامة.',
    ),
  };
}

class _OperationalChip extends StatelessWidget {
  const _OperationalChip({
    required this.label,
    this.color = const Color(0xFFD4AF37),
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}
