import 'package:flutter/material.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/data/models/media_gallery_item.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/sections/activities_management_section.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/sections/announcements_management_section.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/sections/media_gallery_management_section.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/sections/news_management_section.dart';
import 'package:waqf/presentation/widgets/admin/admin_layout.dart';

import 'shared_content_registry.dart';
import 'widgets/scoped_cards_section_management_section.dart';
import 'widgets/scoped_footer_links_management_section.dart';
import 'widgets/scoped_mini_map_teaser_management_section.dart';
import 'widgets/scoped_statistics_management_section.dart';

class SharedContentManagementScreen extends StatelessWidget {
  const SharedContentManagementScreen({
    super.key,
    this.initialTabIndex = 0,
    this.currentRoute = AppRoutes.adminSharedContent,
    this.mediaOnly = false,
    this.platformSurfaceOnly = false,
  });

  final int initialTabIndex;
  final String currentRoute;
  final bool mediaOnly;
  final bool platformSurfaceOnly;

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: currentRoute,
      child: _SharedContentManagementWorkspace(
        initialTabIndex: initialTabIndex,
        currentRoute: currentRoute,
        mediaOnly: mediaOnly,
        platformSurfaceOnly: platformSurfaceOnly,
      ),
    );
  }
}

class _SharedContentManagementWorkspace extends StatelessWidget {
  const _SharedContentManagementWorkspace({
    required this.initialTabIndex,
    required this.currentRoute,
    required this.mediaOnly,
    required this.platformSurfaceOnly,
  });

  final int initialTabIndex;
  final String currentRoute;
  final bool mediaOnly;
  final bool platformSurfaceOnly;

  @override
  Widget build(BuildContext context) {
    final tabs = mediaOnly
        ? _SharedContentTabs.mediaTabs
        : platformSurfaceOnly
        ? _SharedContentTabs.platformTabs
        : _SharedContentTabs.allTabs;
    final children = mediaOnly
        ? _SharedContentTabs.mediaChildren
        : platformSurfaceOnly
        ? _SharedContentTabs.platformChildren
        : _SharedContentTabs.allChildren;
    final safeIndex = initialTabIndex.clamp(0, tabs.length - 1).toInt();
    final isMediaCenterSubRoute =
        mediaOnly &&
        currentRoute.startsWith('/admin/media-center/') &&
        currentRoute != AppRoutes.adminMediaCenter;
    final isSurfacesServicesSubRoute =
        platformSurfaceOnly &&
        currentRoute.startsWith('/admin/surfaces-services/') &&
        currentRoute != AppRoutes.adminSurfacesServices;

    return DefaultTabController(
      length: tabs.length,
      initialIndex: safeIndex,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMediaCenterSubRoute &&
                          !isSurfacesServicesSubRoute) ...[
                        _SharedContentPageIntro(
                          mediaOnly: mediaOnly,
                          platformSurfaceOnly: platformSurfaceOnly,
                        ),
                        const SizedBox(height: 16),
                        _SharedContentOverviewCard(
                          mediaOnly: mediaOnly,
                          platformSurfaceOnly: platformSurfaceOnly,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SharedTabBarHeaderDelegate(
                  minExtent: 72,
                  maxExtent: 72,
                  child: Container(
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    alignment: Alignment.centerRight,
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          tabs: tabs,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: TabBarView(children: children),
          ),
        ),
      ),
    );
  }
}

class _SharedContentTabs {
  const _SharedContentTabs._();

  static const mediaTabs = <Widget>[
    Tab(text: 'الأخبار', icon: Icon(Icons.newspaper, size: 18)),
    Tab(text: 'الإعلانات', icon: Icon(Icons.campaign, size: 18)),
    Tab(text: 'الأنشطة', icon: Icon(Icons.event_note, size: 18)),
    Tab(text: 'الفعاليات', icon: Icon(Icons.celebration, size: 18)),
    Tab(text: 'معرض الصور', icon: Icon(Icons.photo_library, size: 18)),
    Tab(text: 'الفيديوهات', icon: Icon(Icons.ondemand_video, size: 18)),
  ];

  static const platformTabs = <Widget>[
    Tab(text: 'الروابط السريعة', icon: Icon(Icons.link, size: 18)),
    Tab(
      text: 'الخدمات السريعة',
      icon: Icon(Icons.miscellaneous_services, size: 18),
    ),
    Tab(text: 'الإحصائيات', icon: Icon(Icons.bar_chart, size: 18)),
    Tab(text: 'بوابة الخدمات الإلكترونية', icon: Icon(Icons.hub, size: 18)),
    Tab(text: 'الإبرازات', icon: Icon(Icons.auto_awesome, size: 18)),
    Tab(text: 'الخريطة التمهيدية', icon: Icon(Icons.map_outlined, size: 18)),
  ];

  static const allTabs = <Widget>[...mediaTabs, ...platformTabs];

  static const mediaChildren = <Widget>[
    _SharedContentTabShell(
      title: 'الأخبار',
      description:
          'إدارة الأخبار الوزارية ومحتوى الأخبار الخاص بالوحدات ضمن نفس القالب الديناميكي. home للوزارة، وslug للوحدة.',
      child: NewsManagementSection(),
    ),
    _SharedContentTabShell(
      title: 'الإعلانات',
      description:
          'إدارة الإعلانات المرتبطة بالوزارة أو الوحدات حسب النطاق الحالي.',
      child: AnnouncementsManagementSection(),
    ),
    _SharedContentTabShell(
      title: 'الأنشطة',
      description: 'إدارة الأنشطة غير الحدثية ضمن مسار slug/home المشترك.',
      child: ActivitiesManagementSection(),
    ),
    _SharedContentTabShell(
      title: 'الفعاليات',
      description:
          'إدارة الفعاليات عبر مسار الأنشطة نفسه حتى يتم اعتماد جدول سيادي منفصل للفعاليات لاحقًا.',
      child: ActivitiesManagementSection(mode: ActivitiesManagementMode.events),
    ),
    _SharedContentTabShell(
      title: 'معرض الصور',
      description:
          'إدارة صور الوزارة والوحدات فوق نفس طبقة الرفع الموحدة، دون إنشاء uploader منفصل.',
      child: MediaGalleryManagementSection(
        initialType: MediaType.photo,
        allowTypeChange: false,
        headerTitle: 'إدارة معرض الصور',
        headerDescription:
            'إدارة الصور الوزارية وصور الوحدات بنطاقي home وslug فوق نفس طبقة الرفع الموحدة.',
      ),
    ),
    _SharedContentTabShell(
      title: 'الفيديوهات',
      description:
          'إدارة الفيديوهات المحلية والروابط الخارجية فوق نفس طبقة الرفع الموحدة للمحتوى المشترك.',
      child: MediaGalleryManagementSection(
        initialType: MediaType.video,
        allowTypeChange: false,
        headerTitle: 'إدارة الفيديوهات',
        headerDescription:
            'إدارة فيديوهات الوزارة والوحدات مع دعم الروابط الخارجية ضمن نفس العقد الحاكم.',
      ),
    ),
  ];

  static const platformChildren = <Widget>[
    _SharedContentTabShell(
      title: 'الروابط السريعة',
      description:
          'إدارة الروابط السريعة المشتركة بين home وslug دون إنشاء بنية موازية جديدة.',
      child: ScopedFooterLinksManagementSection(
        mode: ScopedFooterLinksMode.quickLinks,
        title: 'الروابط السريعة',
        description:
            'تحرير quick_links بحسب النطاق الحالي، لتغذي الروابط السريعة وعناصر الربط المرتبطة بالسياق.',
      ),
    ),
    _SharedContentTabShell(
      title: 'الخدمات السريعة',
      description:
          'إدارة بطاقات الخدمات السريعة التي تظهر على الصفحة الديناميكية بحسب home أو slug.',
      child: ScopedFooterLinksManagementSection(
        mode: ScopedFooterLinksMode.services,
        title: 'الخدمات السريعة',
        description:
            'تحرير services_links فوق نفس footer settings scoped ليظهر في PwfQuickServicesSection حسب السياق.',
      ),
    ),
    _SharedContentTabShell(
      title: 'الإحصائيات',
      description:
          'إدارة العدادات والإحصائيات المشتركة بحسب home أو slug داخل نفس الصفحة الديناميكية.',
      child: ScopedStatisticsManagementSection(),
    ),
    _SharedContentTabShell(
      title: 'بوابة الخدمات الإلكترونية',
      description:
          'إدارة بطاقات eServices portal بنفس منطق العناصر المشتركة والسياق الديناميكي.',
      child: ScopedCardsSectionManagementSection(
        sectionName: 'pwf_eservices_portal',
        title: 'بوابة الخدمات الإلكترونية',
        description:
            'تحرير بطاقات eServices portal بحسب home أو slug داخل نفس الصفحة الديناميكية، مع انعكاس مباشر على صفحة الخدمات العامة.',
        publicPreviewRoute: AppRoutes.eservices,
        defaultTitle: 'بوابة الخدمات الإلكترونية',
        defaultSubtitle:
            'وصول مباشر إلى الخدمات الإلكترونية والنماذج والإجراءات العامة المتاحة',
        defaultItems: [
          ScopedCardEditableItem(
            icon: 'credit_card',
            title: 'الدفع الإلكتروني',
            description:
                'خدمات الدفع الإلكتروني للرسوم والمستحقات الخاصة بالأوقاف والمساجد',
            linkLabel: 'استخدام الخدمة',
            route: '/under-construction',
          ),
          ScopedCardEditableItem(
            icon: 'building',
            title: 'خدمات العقارات الوقفية',
            description:
                'إدارة وتأجير واستثمار العقارات الوقفية التابعة للوزارة',
            linkLabel: 'الانتقال للخدمة',
            route: '/under-construction',
          ),
          ScopedCardEditableItem(
            icon: 'file_signature',
            title: 'الطلبات والنماذج',
            description:
                'نماذج عامة وطلبات مرتبطة بخدمات الوزارة والوحدات التابعة',
            linkLabel: 'عرض النماذج',
            route: '/under-construction',
          ),
        ],
      ),
    ),
    _SharedContentTabShell(
      title: 'الإبرازات',
      description:
          'إدارة بطاقات الإبراز المختصرة التي تظهر داخل الصفحة العامة بحسب home أو slug.',
      child: ScopedCardsSectionManagementSection(
        sectionName: 'pwf_feature_highlights',
        title: 'الإبرازات',
        description:
            'تحرير بطاقات الإبراز الأساسية للوزارة أو الوحدة داخل نفس القالب، مع دعم الروابط ونصوص الأزرار داخل الواجهة العامة.',
        publicPreviewRoute: AppRoutes.home,
        defaultTitle: 'بوابة الوزارة الرقمية',
        defaultSubtitle:
            'استكشف أبرز الخدمات العامة والمحتوى الرقمي والروابط الرسمية',
        defaultItems: [
          ScopedCardEditableItem(
            icon: 'dashboard',
            title: 'واجهة موحدة',
            description:
                'الوصول إلى الأخبار والخدمات والروابط والمحتوى العام من مكان واحد.',
            linkLabel: 'الانتقال للصفحة الرئيسية',
            route: AppRoutes.home,
          ),
          ScopedCardEditableItem(
            icon: 'search',
            title: 'وصول سريع',
            description:
                'الوصول السريع إلى الخدمات الإلكترونية والمحتوى العام الأكثر استخداماً.',
            linkLabel: 'الخدمات الإلكترونية',
            route: AppRoutes.eservices,
          ),
          ScopedCardEditableItem(
            icon: 'verified',
            title: 'محتوى موثوق',
            description:
                'محتوى عام ورسمي صادر عن الوزارة ويجري تحديثه عبر المنصة.',
            linkLabel: 'استكشاف الأخبار',
            route: AppRoutes.news,
          ),
        ],
      ),
    ),
    _SharedContentTabShell(
      title: 'الخريطة التمهيدية',
      description:
          'إدارة القسم التمهيدي للخريطة داخل الصفحة العامة وفق home أو slug.',
      child: ScopedMiniMapTeaserManagementSection(),
    ),
  ];

  static const allChildren = <Widget>[...mediaChildren, ...platformChildren];
}

class _SharedContentPageIntro extends StatelessWidget {
  const _SharedContentPageIntro({
    required this.mediaOnly,
    required this.platformSurfaceOnly,
  });

  final bool mediaOnly;
  final bool platformSurfaceOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mediaOnly
              ? 'إدارة مواد المركز الإعلامي'
              : platformSurfaceOnly
              ? 'إدارة الخدمات والبطاقات'
              : 'إدارة المحتوى والعناصر المشتركة',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          mediaOnly
              ? 'هذه البوابة تعرض العائلات الإعلامية فقط: الأخبار، الإعلانات، الأنشطة، الفعاليات، الصور، والفيديوهات. تبقى عناصر الصفحة غير الإعلامية في إدارة المحتوى المشترك/الواجهة العامة.'
              : platformSurfaceOnly
              ? 'هذه البوابة تعرض عناصر الخدمات والبطاقات فقط: الروابط السريعة، الخدمات السريعة، الإحصائيات، بوابة الخدمات الإلكترونية، الإبرازات، والخريطة التمهيدية. تبقى المواد الإعلامية داخل المركز الإعلامي.'
              : 'هذه البوابة تدير الأخبار والإعلانات والأنشطة والفعاليات ومعرض الصور والفيديوهات والروابط السريعة والخدمات السريعة والإحصائيات ضمن نفس العقد الحاكم للصفحة الديناميكية: home يغذي الصفحة الرئيسية، وslug يغذي نفس القالب عند الوحدة.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF4B5563),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _SharedContentOverviewCard extends StatelessWidget {
  const _SharedContentOverviewCard({
    required this.mediaOnly,
    required this.platformSurfaceOnly,
  });

  final bool mediaOnly;
  final bool platformSurfaceOnly;

  @override
  Widget build(BuildContext context) {
    final families = mediaOnly
        ? SharedContentRegistry.mediaFamilies
        : platformSurfaceOnly
        ? SharedContentRegistry.platformSurfaceFamilies
        : SharedContentRegistry.families;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1500
            ? 4
            : width >= 1100
            ? 3
            : width >= 760
            ? 2
            : 1;
        final spacing = 12.0;
        final cardWidth = columns == 1
            ? width
            : (width - ((columns - 1) * spacing)) / columns;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'حوكمة النطاق',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                mediaOnly
                    ? 'الوزارة / PalWakf تنشر ما يظهر على الصفحة الرئيسية، والوحدة تنشر ما يظهر داخل صفحة الوحدة. يسمح بعرض مختصر متبادل دون نقل ملكية المحتوى أو خلط صلاحيات النشر.'
                    : platformSurfaceOnly
                    ? 'الخدمات والبطاقات تُدار كنطاق واجهة عامة وخدمات platform، وليست مركزًا إعلاميًا. home يغذي الصفحة الرئيسية، وslug يغذي صفحات الوحدات عند تفعيل الأقسام المسموحة.'
                    : 'الوزارة / PalWakf تدخل ما يغذي الصفحة الرئيسية، بينما الوحدة تدخل ما يظهر في نفس الصفحة الديناميكية عند slug الخاص بها. المرجع الإداري هو org_unit_id، أما العرض فيبقى عبر slug.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4B5563),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: spacing,
                runSpacing: 12,
                children: families
                    .map(
                      (family) => SizedBox(
                        width: cardWidth,
                        child: _FamilyBadge(family: family),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FamilyBadge extends StatelessWidget {
  const _FamilyBadge({required this.family});

  final SharedContentFamily family;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3A70).withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF0B3A70).withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(family.icon, color: const Color(0xFF0B3A70)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  family.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            family.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF4B5563),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'home: ${family.homeBehavior}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            'slug: ${family.slugBehavior}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          if (family.note != null) ...[
            const SizedBox(height: 8),
            Text(
              family.note!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B7280),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SharedContentTabShell extends StatelessWidget {
  const _SharedContentTabShell({
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _SharedTabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  _SharedTabBarHeaderDelegate({
    required this.minExtent,
    required this.maxExtent,
    required this.child,
  });

  @override
  final double minExtent;

  @override
  final double maxExtent;

  final Widget child;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SharedTabBarHeaderDelegate oldDelegate) {
    return oldDelegate.minExtent != minExtent ||
        oldDelegate.maxExtent != maxExtent ||
        oldDelegate.child != child;
  }
}
