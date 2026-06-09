import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/features/platform/home/data/services/pwf_services_request_rpc_adapter.dart';
import 'package:waqf/presentation/widgets/admin/admin_layout.dart';

class PwfSurfacesServicesAdminHubScreen extends StatelessWidget {
  const PwfSurfacesServicesAdminHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: AppRoutes.adminSurfacesServices,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _HubHeader(),
              SizedBox(height: 16),
              _OperationalSummaryStrip(),
              SizedBox(height: 18),
              _ServicesWorkspaceBoard(),
              SizedBox(height: 18),
              _ServiceFamilySection(
                title: 'الطلبات والنماذج',
                subtitle:
                    'مسودة تشغيلية لاستقبال الطلبات وسجل النماذج الرسمية، تمهيدًا للربط لاحقًا مع مركز الوثائق والمهام دون إنشاء SQL إنتاجي الآن.',
                cards: [
                  _ServiceCardData(
                    title: 'استقبال الطلبات',
                    description:
                        'مسار أولي لتصنيف طلبات الخدمة وتحديد المستفيد والمرفقات وخطوة المعالجة التالية.',
                    route: AppRoutes.adminSurfacesServicesRequests,
                    icon: Icons.assignment_rounded,
                    actionLabel: 'فتح الاستقبال',
                  ),
                  _ServiceCardData(
                    title: 'طابور الطلبات',
                    description:
                        'طابور إداري Draft لفرز الطلبات حسب الحالة والأولوية ومصدر البيانات قبل الربط الإنتاجي.',
                    route: AppRoutes.adminSurfacesServicesRequestQueue,
                    icon: Icons.fact_check_rounded,
                    actionLabel: 'فتح الطابور',
                  ),
                  _ServiceCardData(
                    title: 'سجل النماذج',
                    description:
                        'فهرس نماذج الخدمة الرسمية، يربط النموذج بالخدمة والمرجع التنظيمي وحالة النشر.',
                    route: AppRoutes.adminSurfacesServicesFormsRegistry,
                    icon: Icons.snippet_folder_rounded,
                    actionLabel: 'فتح السجل',
                  ),
                  _ServiceCardData(
                    title: 'معاينة تقديم طلب عام',
                    description:
                        'فتح واجهة الزائر الأولية لتقديم طلب خدمة وربطها بصيغة الطلب والنموذج قبل الربط الإنتاجي.',
                    route: AppRoutes.serviceRequestEntry,
                    icon: Icons.open_in_browser_rounded,
                    actionLabel: 'فتح الواجهة',
                  ),
                  _ServiceCardData(
                    title: 'معاينة تتبع الطلب',
                    description:
                        'فتح واجهة الزائر الأولية لتتبع الطلب برقم متابعة تجريبي دون كشف بيانات حساسة.',
                    route: AppRoutes.serviceRequestTracking,
                    icon: Icons.manage_search_rounded,
                    actionLabel: 'فتح التتبع',
                  ),
                ],
              ),
              SizedBox(height: 18),
              _ServiceFamilySection(
                title: 'إدارة الخدمات العامة',
                subtitle:
                    'صفحات وخدمات منصة عامة لها ظهور مباشر للزوار أو للصفحة العامة، وتبقى منفصلة عن المركز الإعلامي.',
                cards: [
                  _ServiceCardData(
                    title: 'الخدمات العامة',
                    description:
                        'إدارة صفحة الخدمات العامة وبطاقات الخدمات الظاهرة للجمهور.',
                    route: AppRoutes.adminServicesPage,
                    icon: Icons.design_services_rounded,
                    actionLabel: 'فتح الإدارة',
                  ),
                  _ServiceCardData(
                    title: 'الشكاوى',
                    description:
                        'إدارة خدمة الشكاوى كخدمة سيادية عامة داخل المنصة.',
                    route: AppRoutes.adminComplaints,
                    icon: Icons.report_gmailerrorred_rounded,
                    actionLabel: 'إدارة الشكاوى',
                  ),
                  _ServiceCardData(
                    title: 'الزكاة',
                    description:
                        'إدارة خدمة الزكاة العامة ضمن نطاق خدمات platform.',
                    route: AppRoutes.adminZakat,
                    icon: Icons.volunteer_activism_rounded,
                    actionLabel: 'إدارة الزكاة',
                  ),
                  _ServiceCardData(
                    title: 'مواقيت الصلاة',
                    description: 'إدارة مواقيت الصلاة وواجهتها العامة.',
                    route: AppRoutes.adminPrayerTimes,
                    icon: Icons.access_time_filled_rounded,
                    actionLabel: 'إدارة المواقيت',
                  ),
                  _ServiceCardData(
                    title: 'القرآن الكريم',
                    description: 'إدارة خدمة القرآن الكريم ضمن المنصة.',
                    route: AppRoutes.adminQuran,
                    icon: Icons.menu_book_rounded,
                    actionLabel: 'إدارة القرآن',
                  ),
                ],
              ),
              SizedBox(height: 18),
              _ServiceFamilySection(
                title: 'إدارة الخدمات الإلكترونية',
                subtitle:
                    'الخدمات الرقمية وصفحة الوصول العام وبطاقات بوابة الخدمات الإلكترونية داخل الواجهة.',
                cards: [
                  _ServiceCardData(
                    title: 'الخدمات الإلكترونية',
                    description:
                        'إدارة صفحة الخدمات الإلكترونية وروابط الوصول إلى الخدمات الرقمية.',
                    route: AppRoutes.adminEServicesPage,
                    icon: Icons.computer_rounded,
                    actionLabel: 'إدارة الصفحة',
                  ),
                  _ServiceCardData(
                    title: 'بوابة الخدمات الإلكترونية',
                    description:
                        'تحرير بطاقات قسم بوابة الخدمات الإلكترونية داخل الصفحة الرئيسية أو صفحة الوحدة.',
                    route: AppRoutes.adminSurfacesServicesEServicesPortal,
                    icon: Icons.hub_rounded,
                    actionLabel: 'إدارة البوابة',
                  ),
                ],
              ),
              SizedBox(height: 18),
              _ServiceFamilySection(
                title: 'إدارة الخدمات السريعة',
                subtitle:
                    'بطاقات مختصرة تقود المستخدم إلى أهم الخدمات وتظهر حسب نطاق home أو الوحدة.',
                cards: [
                  _ServiceCardData(
                    title: 'الخدمات السريعة',
                    description:
                        'تحرير بطاقات الخدمات السريعة حسب نطاق الصفحة الرئيسية أو الوحدة.',
                    route: AppRoutes.adminSurfacesServicesQuickServices,
                    icon: Icons.miscellaneous_services_rounded,
                    actionLabel: 'إدارة الخدمات السريعة',
                  ),
                ],
              ),
              SizedBox(height: 18),
              _ServiceFamilySection(
                title: 'إدارة الروابط',
                subtitle:
                    'تنظيم الروابط السريعة والمهمة دون خلطها بالمحتوى الإعلامي أو صفحات الخدمات المستقلة.',
                cards: [
                  _ServiceCardData(
                    title: 'الروابط السريعة',
                    description:
                        'إدارة الروابط السريعة التي تظهر ضمن واجهات المنصة والوحدات.',
                    route: AppRoutes.adminSurfacesServicesQuickLinks,
                    icon: Icons.link_rounded,
                    actionLabel: 'إدارة الروابط',
                  ),
                  _ServiceCardData(
                    title: 'الروابط المهمة',
                    description:
                        'تنظيم الروابط المهمة ضمن نفس طبقة الروابط المشتركة.',
                    route: AppRoutes.adminSurfacesServicesImportantLinks,
                    icon: Icons.bookmark_added_rounded,
                    actionLabel: 'إدارة الروابط المهمة',
                  ),
                ],
              ),
              SizedBox(height: 18),
              _ServiceFamilySection(
                title: 'إدارة البطاقات',
                subtitle:
                    'بطاقات واجهة مختصرة للتوجيه والإبراز، وتشمل البطاقات المميزة والخريطة التمهيدية.',
                cards: [
                  _ServiceCardData(
                    title: 'البطاقات المميزة',
                    description:
                        'إدارة بطاقات الإبراز التي توجه الزائر إلى خدمات أو صفحات مهمة.',
                    route: AppRoutes.adminSurfacesServicesFeatureHighlights,
                    icon: Icons.auto_awesome_rounded,
                    actionLabel: 'إدارة البطاقات',
                  ),
                  _ServiceCardData(
                    title: 'الخريطة التمهيدية',
                    description:
                        'إدارة بطاقة التقديم للخريطة والمستكشف داخل واجهات المنصة.',
                    route: AppRoutes.adminSurfacesServicesMiniMapTeaser,
                    icon: Icons.map_rounded,
                    actionLabel: 'إدارة الخريطة',
                  ),
                ],
              ),
              SizedBox(height: 18),
              _ServiceFamilySection(
                title: 'إدارة الإحصائيات',
                subtitle:
                    'عدادات وإحصائيات الصفحة الرئيسية وصفحات الوحدات مع ضبط نطاق العرض.',
                cards: [
                  _ServiceCardData(
                    title: 'الإحصائيات',
                    description:
                        'إدارة عدادات وإحصائيات الصفحة الرئيسية وصفحات الوحدات.',
                    route: AppRoutes.adminSurfacesServicesStatistics,
                    icon: Icons.bar_chart_rounded,
                    actionLabel: 'إدارة الإحصائيات',
                  ),
                ],
              ),
              SizedBox(height: 18),
              _ServiceFamilySection(
                title: 'المراجع الرسمية',
                subtitle:
                    'قوانين وأنظمة وتعليمات وتعاميم وأدلة ونماذج مرتبطة بالخدمات، وليست محتوى إعلاميًا.',
                cards: [
                  _ServiceCardData(
                    title: 'الأنظمة والقوانين والتعليمات',
                    description:
                        'إدارة المراجع القانونية والتنظيمية الرسمية وربطها لاحقًا بمركز الوثائق والمساعد الداخلي.',
                    route: AppRoutes.adminSurfacesServicesLegalReferences,
                    icon: Icons.gavel_rounded,
                    actionLabel: 'إدارة المراجع',
                  ),
                  _ServiceCardData(
                    title: 'معاينة المراجع العامة',
                    description:
                        'فتح الصفحة العامة التي تعرض المراجع الرسمية للزوار وفق النطاق والصلاحيات.',
                    route: AppRoutes.legalReferences,
                    icon: Icons.open_in_new_rounded,
                    actionLabel: 'فتح الواجهة',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubHeader extends StatelessWidget {
  const _HubHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [Color(0xFF0B3A70), Color(0xFF145DA0)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مركز الخدمات',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'مدخل تشغيلي واحد لدليل الخدمات، الخدمات الإلكترونية، الطلبات والنماذج، الاستعلامات، الشكاوى، عناصر الإبراز، والمراجع الرسمية.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _OperationalSummaryStrip extends StatelessWidget {
  const _OperationalSummaryStrip();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1020
            ? 3
            : width >= 680
            ? 2
            : 1;
        const spacing = 12.0;
        final itemWidth = columns == 1
            ? width
            : (width - (columns - 1) * spacing) / columns;
        const items = [
          _SummaryItem(
            label: 'تبويب رئيسي واحد',
            value: 'الخدمات والبطاقات',
            icon: Icons.apps_rounded,
          ),
          _SummaryItem(
            label: 'قوائم فرعية',
            value: '10 مسارات تشغيل',
            icon: Icons.account_tree_rounded,
          ),
          _SummaryItem(
            label: 'نطاق العرض',
            value: 'home + slug',
            icon: Icons.public_rounded,
          ),
        ];
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                child: _SummaryCard(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _SummaryItem {
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.item});

  final _SummaryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF0B3A70).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: const Color(0xFF0B3A70)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesWorkspaceBoard extends StatelessWidget {
  const _ServicesWorkspaceBoard();

  @override
  Widget build(BuildContext context) {
    const quickActions = [
      _PriorityActionData(
        title: 'استقبال طلب خدمة',
        description: 'فتح مسودة استقبال الطلبات وربطها بالنماذج.',
        route: AppRoutes.adminSurfacesServicesRequests,
        icon: Icons.assignment_rounded,
      ),
      _PriorityActionData(
        title: 'فرز طابور الطلبات',
        description: 'عرض الطلبات الواردة وحالتها ومصدرها التشغيلي.',
        route: AppRoutes.adminSurfacesServicesRequestQueue,
        icon: Icons.fact_check_rounded,
      ),
      _PriorityActionData(
        title: 'متابعة الشكاوى',
        description: 'فتح قناة الشكاوى والملاحظات والبلاغات.',
        route: AppRoutes.adminComplaints,
        icon: Icons.report_gmailerrorred_rounded,
      ),
      _PriorityActionData(
        title: 'إبراز خدمة',
        description: 'تعديل الخدمات السريعة وبطاقات الدخول.',
        route: AppRoutes.adminSurfacesServicesQuickServices,
        icon: Icons.push_pin_rounded,
      ),
      _PriorityActionData(
        title: 'مراجعة مرجع رسمي',
        description: 'إدارة الأنظمة والقوانين والتعليمات.',
        route: AppRoutes.adminSurfacesServicesLegalReferences,
        icon: Icons.gavel_rounded,
      ),
    ];

    const lanes = [
      _WorkspaceLaneData(
        title: 'استقبال الطلبات والنماذج',
        description:
            'تجميع خدمات الجمهور والنماذج والإفادات المطلوبة في مسار واحد قابل للربط لاحقًا بمركز الوثائق.',
        status: 'مسودة تشغيلية',
        metric: 'طلب + نموذج',
        route: AppRoutes.adminSurfacesServicesRequests,
        icon: Icons.assignment_rounded,
      ),
      _WorkspaceLaneData(
        title: 'سجل النماذج الرسمية',
        description:
            'فهرسة النماذج حسب الخدمة، نوع المستفيد، المرفقات، ومسار المراجعة قبل أي ربط إنتاجي.',
        status: 'Draft',
        metric: 'نماذج مصنفة',
        route: AppRoutes.adminSurfacesServicesFormsRegistry,
        icon: Icons.snippet_folder_rounded,
      ),
      _WorkspaceLaneData(
        title: 'الاستعلامات والمتابعة',
        description:
            'مسار متابعة الطلبات والمهام المرتبطة بالخدمات دون تحويلها إلى محتوى إعلامي.',
        status: 'متابعة',
        metric: 'مهام وخطوات',
        route: AppRoutes.adminTasks,
        icon: Icons.manage_search_rounded,
      ),
      _WorkspaceLaneData(
        title: 'الشكاوى والملاحظات',
        description:
            'قناة تشغيلية للشكاوى والملاحظات والبلاغات، مع قابلية التصعيد إلى المهام أو القضايا لاحقًا.',
        status: 'حساس',
        metric: 'بلاغات الجمهور',
        route: AppRoutes.adminComplaints,
        icon: Icons.fact_check_rounded,
      ),
      _WorkspaceLaneData(
        title: 'إبراز الخدمات والروابط',
        description:
            'إدارة ما يظهر للزائر: روابط، خدمات سريعة، بوابة إلكترونية، إحصائيات، وبطاقات مميزة.',
        status: 'واجهة عامة',
        metric: 'home + unit',
        route: AppRoutes.adminSurfacesServicesQuickLinks,
        icon: Icons.dashboard_customize_rounded,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFB22222).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.workspaces_rounded,
                  color: Color(0xFFB22222),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مساحة العمل اليومية للخدمات',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'لوحة تشغيل مختصرة تبدأ من العمل الفعلي: استقبال، متابعة، شكاوى، وروابط إبراز؛ أما الحوكمة فتظل عند الطلب.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1180
                  ? 4
                  : width >= 860
                  ? 2
                  : 1;
              const spacing = 12.0;
              final actionWidth = columns == 1
                  ? width
                  : (width - (columns - 1) * spacing) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final action in quickActions)
                    SizedBox(
                      width: actionWidth,
                      child: _PriorityActionCard(data: action),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1180
                  ? 4
                  : width >= 860
                  ? 2
                  : 1;
              const spacing = 12.0;
              final laneWidth = columns == 1
                  ? width
                  : (width - (columns - 1) * spacing) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final lane in lanes)
                    SizedBox(
                      width: laneWidth,
                      child: _WorkspaceLaneCard(data: lane),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PriorityActionData {
  const _PriorityActionData({
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

class _PriorityActionCard extends StatelessWidget {
  const _PriorityActionCard({required this.data});

  final _PriorityActionData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.go(data.route),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B3A70).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  data.icon,
                  color: const Color(0xFF0B3A70),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF0B3A70),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceLaneData {
  const _WorkspaceLaneData({
    required this.title,
    required this.description,
    required this.status,
    required this.metric,
    required this.route,
    required this.icon,
  });

  final String title;
  final String description;
  final String status;
  final String metric;
  final String route;
  final IconData icon;
}

class _WorkspaceLaneCard extends StatelessWidget {
  const _WorkspaceLaneCard({required this.data});

  final _WorkspaceLaneData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.go(data.route),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 188),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        data.icon,
                        color: const Color(0xFF0B3A70),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        data.metric,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: const Color(0xFFB22222),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  data.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B3A70).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      data.status,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF0B3A70),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceFamilySection extends StatelessWidget {
  const _ServiceFamilySection({
    required this.title,
    required this.subtitle,
    required this.cards,
  });

  final String title;
  final String subtitle;
  final List<_ServiceCardData> cards;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1280
                  ? 4
                  : width >= 920
                  ? 3
                  : width >= 620
                  ? 2
                  : 1;
              const spacing = 12.0;
              final cardWidth = columns == 1
                  ? width
                  : (width - (columns - 1) * spacing) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: cards
                    .map(
                      (card) => SizedBox(
                        width: cardWidth,
                        child: _ServiceCard(data: card),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ServiceCardData {
  const _ServiceCardData({
    required this.title,
    required this.description,
    required this.route,
    required this.icon,
    required this.actionLabel,
  });

  final String title;
  final String description;
  final String route;
  final IconData icon;
  final String actionLabel;
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.data});

  final _ServiceCardData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.go(data.route),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 178),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B3A70).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(data.icon, color: const Color(0xFF0B3A70)),
                ),
                const SizedBox(height: 12),
                Text(
                  data.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      data.actionLabel,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: const Color(0xFF0B3A70),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.arrow_back_rounded,
                      size: 18,
                      color: Color(0xFF0B3A70),
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

class PwfServiceRequestIntakeAdminScreen extends StatelessWidget {
  const PwfServiceRequestIntakeAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: AppRoutes.adminSurfacesServicesRequests,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: const [
              _RequestIntakeHeader(),
              SizedBox(height: 18),
              _RequestIntakeWorkflowBoard(),
              SizedBox(height: 18),
              _ServiceFamilySection(
                title: 'روابط تشغيل مرتبطة بالاستقبال',
                subtitle:
                    'هذه المسارات تعمل بنمط backend-first بعد نجاح SQL UAT، وتستخدم fallback فقط عند غياب عقود backend لا عند رفض الصلاحيات أو أخطاء runtime.',
                cards: [
                  _ServiceCardData(
                    title: 'دليل الخدمات',
                    description:
                        'اختيار الخدمة التي يستند إليها الطلب وربطها لاحقًا بسياسة الخدمة والرسوم إن وجدت.',
                    route: AppRoutes.adminServicesPage,
                    icon: Icons.design_services_rounded,
                    actionLabel: 'فتح الدليل',
                  ),
                  _ServiceCardData(
                    title: 'سجل النماذج',
                    description:
                        'اختيار النموذج الرسمي المطلوب وإرفاقه بسياسة الخدمة ومتطلبات التقديم.',
                    route: AppRoutes.adminSurfacesServicesFormsRegistry,
                    icon: Icons.snippet_folder_rounded,
                    actionLabel: 'فتح السجل',
                  ),
                  _ServiceCardData(
                    title: 'واجهة تقديم الطلب',
                    description:
                        'معاينة رحلة الزائر من اختيار الخدمة إلى الإرسال عبر RPC الإنتاجي أو إظهار حالة عدم توفر نماذج مفعلة.',
                    route: AppRoutes.serviceRequestEntry,
                    icon: Icons.public_rounded,
                    actionLabel: 'فتح الواجهة',
                  ),
                  _ServiceCardData(
                    title: 'المهام والمتابعة',
                    description:
                        'تحويل الطلبات المقبولة لاحقًا إلى مهام تشغيلية حسب الوحدة والمسؤول.',
                    route: AppRoutes.adminTasks,
                    icon: Icons.task_alt_rounded,
                    actionLabel: 'فتح المهام',
                  ),
                  _ServiceCardData(
                    title: 'الشكاوى والملاحظات',
                    description:
                        'إحالة الطلب الخاطئ أو البلاغ إلى مسار الشكاوى والملاحظات عند الحاجة.',
                    route: AppRoutes.adminComplaints,
                    icon: Icons.report_gmailerrorred_rounded,
                    actionLabel: 'فتح الشكاوى',
                  ),
                ],
              ),
              SizedBox(height: 18),
              _ServiceGovernanceNote(
                title: 'حالة هذه الصفحة بعد M3',
                description:
                    'هذه صفحة عمل backend-first بعد Mega Batch M. الربط الحالي يستخدم platform_services وRPCs إنتاجية عند تثبيت SQL، ويعود إلى fallback فقط عند غياب الدوال أو فشل الاتصال. يبقى waqf_asset_id رابطًا مستقبليًا nullable ولا يلمس waqf_assets.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestIntakeHeader extends StatelessWidget {
  const _RequestIntakeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [Color(0xFF0B3A70), Color(0xFF145DA0)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.assignment_rounded, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'استقبال الطلبات والنماذج',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'مساحة تشغيلية لاستقبال طلبات الخدمة، تصنيفها، ربطها بالنموذج الرسمي، ثم توجيهها إلى الطابور الإداري أو المهام أو مركز الوثائق أو المسار المالي عند الحاجة.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.6,
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

class _RequestIntakeWorkflowBoard extends StatelessWidget {
  const _RequestIntakeWorkflowBoard();

  @override
  Widget build(BuildContext context) {
    const steps = [
      _RequestIntakeStepData(
        title: 'تعريف مقدم الطلب',
        description:
            'فرد، جهة، وحدة داخلية، أو مديرية؛ مع حفظ نطاق الطلب دون تخزين بيانات حساسة داخل هذه المسودة.',
        tag: 'intake.party',
        icon: Icons.person_search_rounded,
      ),
      _RequestIntakeStepData(
        title: 'اختيار الخدمة',
        description:
            'ربط الطلب بدليل الخدمات لتحديد المسار، الرسوم، المدة، والجهة المسؤولة عند اكتمال النموذج.',
        tag: 'service_id',
        icon: Icons.design_services_rounded,
      ),
      _RequestIntakeStepData(
        title: 'اختيار النموذج',
        description:
            'ربط الطلب بنموذج رسمي من سجل النماذج، مع تحديد النسخة وحالة النشر.',
        tag: 'form_id',
        icon: Icons.snippet_folder_rounded,
      ),
      _RequestIntakeStepData(
        title: 'تدقيق المرفقات',
        description:
            'تجهيز قائمة مرفقات مطلوبة ومرفقات اختيارية، والربط لاحقًا بمركز الوثائق عند اعتماده.',
        tag: 'attachments',
        icon: Icons.attach_file_rounded,
      ),
      _RequestIntakeStepData(
        title: 'توجيه المسار',
        description:
            'تحويل الطلب إلى مهمة، شكوى، متابعة مالية، أو مراجعة داخلية حسب نوع الخدمة.',
        tag: 'routing',
        icon: Icons.alt_route_rounded,
      ),
      _RequestIntakeStepData(
        title: 'إشعار ومتابعة',
        description:
            'تهيئة رقم متابعة وحالة أولية عبر RPC الإنتاجي، مع fallback محلي فقط عند غياب عقود backend.',
        tag: 'tracking',
        icon: Icons.notifications_active_rounded,
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مسار استقبال الطلب — Backend-first Workflow',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'الهدف هنا تثبيت تشغيل الاستقبال فوق platform_services: من هو مقدم الطلب، ما الخدمة، ما النموذج، ما المرفقات، وما وجهة المعالجة، مع بقاء Browser UAT هو الحاكم النهائي لسياق المدير المصادق عليه.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1180
                  ? 3
                  : width >= 760
                  ? 2
                  : 1;
              const spacing = 12.0;
              final cardWidth = columns == 1
                  ? width
                  : (width - (columns - 1) * spacing) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final step in steps)
                    SizedBox(
                      width: cardWidth,
                      child: _RequestIntakeStepCard(data: step),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RequestIntakeStepData {
  const _RequestIntakeStepData({
    required this.title,
    required this.description,
    required this.tag,
    required this.icon,
  });

  final String title;
  final String description;
  final String tag;
  final IconData icon;
}

class _RequestIntakeStepCard extends StatelessWidget {
  const _RequestIntakeStepCard({required this.data});

  final _RequestIntakeStepData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 168),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B3A70).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  data.icon,
                  color: const Color(0xFF0B3A70),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  data.tag,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: const Color(0xFFB22222),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            data.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class PwfServiceRequestQueueAdminScreen extends StatefulWidget {
  const PwfServiceRequestQueueAdminScreen({super.key});

  @override
  State<PwfServiceRequestQueueAdminScreen> createState() =>
      _PwfServiceRequestQueueAdminScreenState();
}

class _PwfServiceRequestQueueAdminScreenState
    extends State<PwfServiceRequestQueueAdminScreen> {
  final _adapter = PwfServicesRequestRpcAdapter();
  late Future<List<PwfServiceRequestQueueItem>> _future;
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _future = _adapter.loadAdminQueueDraft(status: _statusFilter);
  }

  void _refresh() {
    setState(() {
      _future = _adapter.loadAdminQueueDraft(status: _statusFilter);
    });
  }

  List<PwfServiceRequestQueueItem> _filter(
    List<PwfServiceRequestQueueItem> items,
  ) {
    if (_statusFilter == 'all') return items;
    return items
        .where((item) => item.status == _statusFilter)
        .toList(growable: false);
  }

  Future<void> _transition(
    PwfServiceRequestQueueItem item,
    String action,
  ) async {
    final result = await _adapter.transitionAdminRequest(
      trackingCode: item.trackingCode,
      action: action,
      publicNote: _publicNoteForAction(action),
      internalNote: 'إجراء من لوحة مركز الخدمات / Mega Batch M',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(result.messageAr)));
    if (result.success) _refresh();
  }

  static String _publicNoteForAction(String action) {
    return switch (action) {
      'start_triage' => 'تم نقل الطلب إلى مرحلة الفرز.',
      'start_review' => 'تم نقل الطلب إلى مرحلة المراجعة.',
      'request_info' => 'الطلب بانتظار استكمال بيانات أو مرفقات من مقدم الطلب.',
      'route' => 'تمت إحالة الطلب إلى الجهة المختصة.',
      'close' => 'تم إغلاق الطلب وفق الإجراء المعتمد.',
      'reject' => 'تعذر استكمال الطلب وفق البيانات المتاحة.',
      _ => 'تم تحديث حالة الطلب.',
    };
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: AppRoutes.adminSurfacesServicesRequestQueue,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _RequestQueueHeader(onRefresh: _refresh),
              const SizedBox(height: 18),
              _RequestQueueFilters(
                selectedStatus: _statusFilter,
                onChanged: (value) {
                  setState(() {
                    _statusFilter = value;
                    _future = _adapter.loadAdminQueueDraft(status: value);
                  });
                },
              ),
              const SizedBox(height: 18),
              FutureBuilder<List<PwfServiceRequestQueueItem>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _RequestQueueLoadingCard();
                  }
                  final items = _filter(
                    snapshot.data ?? PwfServiceRequestQueueItem.fallback,
                  );
                  if (items.isEmpty) {
                    return const _RequestQueueEmptyCard();
                  }
                  return _RequestQueueBoard(
                    items: items,
                    onTransition: _transition,
                  );
                },
              ),
              const SizedBox(height: 18),
              const _ServiceFamilySection(
                title: 'إجراءات مرتبطة بطابور الطلبات',
                subtitle:
                    'الطابور موصول الآن بعقود backend الإنتاجية؛ وتبقى تجربة المتصفح هي الحاكم النهائي لتفعيل انتقالات المدير بسياق مصادق عليه.',
                cards: [
                  _ServiceCardData(
                    title: 'استقبال طلب جديد',
                    description:
                        'فتح مسودة استقبال الطلبات لتسجيل تفاصيل الخدمة والنموذج والمرفقات.',
                    route: AppRoutes.adminSurfacesServicesRequests,
                    icon: Icons.assignment_rounded,
                    actionLabel: 'فتح الاستقبال',
                  ),
                  _ServiceCardData(
                    title: 'سجل النماذج',
                    description:
                        'مراجعة النماذج الرسمية التي يعتمد عليها الطلب قبل الفرز أو الإحالة.',
                    route: AppRoutes.adminSurfacesServicesFormsRegistry,
                    icon: Icons.snippet_folder_rounded,
                    actionLabel: 'فتح السجل',
                  ),
                  _ServiceCardData(
                    title: 'تتبع طلب عام',
                    description:
                        'معاينة تجربة التتبع العامة كما يراها المستفيد، دون كشف بيانات حساسة.',
                    route: AppRoutes.serviceRequestTracking,
                    icon: Icons.manage_search_rounded,
                    actionLabel: 'معاينة التتبع',
                  ),
                  _ServiceCardData(
                    title: 'المهام',
                    description:
                        'الوجهة التشغيلية اللاحقة عند تحويل الطلب إلى متابعة داخلية أو إجراء ميداني.',
                    route: AppRoutes.adminTasks,
                    icon: Icons.task_alt_rounded,
                    actionLabel: 'فتح المهام',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _ServiceGovernanceNote(
                title: 'حالة الطابور الحالية',
                description:
                    'هذا الطابور يعمل بنمط backend-first عبر rpc_services_admin_request_queue_v1. لا تعرض الواجهة بيانات fallback عند رفض الصلاحيات؛ ويجب فحص انتقالات الحالة من متصفح بمستخدم Admin حقيقي.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestQueueHeader extends StatelessWidget {
  const _RequestQueueHeader({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B3A70), Color(0xFF145A9F)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
            ),
            child: const Icon(
              Icons.fact_check_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طابور طلبات الخدمات',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'مساحة عمل إدارية موصولة بالـ RPC لفرز الطلبات، قراءة الحالة، تقدير الأولوية، وتوجيه المسار ضمن سير عمل مركز الخدمات.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onRefresh,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.55)),
            ),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('تحديث'),
          ),
        ],
      ),
    );
  }
}

class _RequestQueueFilters extends StatelessWidget {
  const _RequestQueueFilters({
    required this.selectedStatus,
    required this.onChanged,
  });

  final String selectedStatus;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const statuses = [
      ('all', 'كل الطلبات'),
      ('received', 'مستلم'),
      ('triage', 'قيد الفرز'),
      ('under_review', 'قيد المراجعة'),
      ('waiting_applicant', 'بانتظار المستفيد'),
      ('routed', 'محال'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'تصفية الحالة:',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          for (final status in statuses)
            ChoiceChip(
              label: Text(status.$2),
              selected: selectedStatus == status.$1,
              onSelected: (_) => onChanged(status.$1),
            ),
        ],
      ),
    );
  }
}

class _RequestQueueBoard extends StatelessWidget {
  const _RequestQueueBoard({required this.items, required this.onTransition});

  final List<PwfServiceRequestQueueItem> items;
  final Future<void> Function(PwfServiceRequestQueueItem item, String action)
  onTransition;

  @override
  Widget build(BuildContext context) {
    final rpcCount = items.where((item) => item.rpcBacked).length;
    final fallbackCount = items.length - rpcCount;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'قائمة الطلبات الواردة',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              _RequestQueueMetric(
                label: 'الكل',
                value: items.length.toString(),
              ),
              const SizedBox(width: 8),
              _RequestQueueMetric(label: 'RPC', value: rpcCount.toString()),
              const SizedBox(width: 8),
              _RequestQueueMetric(
                label: 'Fallback',
                value: fallbackCount.toString(),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1120
                  ? 3
                  : width >= 760
                  ? 2
                  : 1;
              const spacing = 12.0;
              final cardWidth = columns == 1
                  ? width
                  : (width - (columns - 1) * spacing) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: cardWidth,
                      child: _RequestQueueCard(
                        item: item,
                        onTransition: onTransition,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RequestQueueMetric extends StatelessWidget {
  const _RequestQueueMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: const Color(0xFF64748B)),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _RequestQueueCard extends StatelessWidget {
  const _RequestQueueCard({required this.item, required this.onTransition});

  final PwfServiceRequestQueueItem item;
  final Future<void> Function(PwfServiceRequestQueueItem item, String action)
  onTransition;

  @override
  Widget build(BuildContext context) {
    final priorityColor = item.priority == 'high'
        ? const Color(0xFFB22222)
        : const Color(0xFF0B3A70);
    return Container(
      constraints: const BoxConstraints(minHeight: 238),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.trackingCode,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF0B3A70),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.priorityLabelAr,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: priorityColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _RequestQueueLine(
            icon: Icons.person_outline_rounded,
            label: item.requesterLabel,
          ),
          _RequestQueueLine(
            icon: Icons.design_services_rounded,
            label: item.serviceLabelAr,
          ),
          _RequestQueueLine(
            icon: Icons.snippet_folder_rounded,
            label: item.formTitleAr,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _RequestQueueChip(
                label: item.statusLabelAr,
                icon: Icons.radio_button_checked_rounded,
              ),
              _RequestQueueChip(
                label: item.assignedTo,
                icon: Icons.account_tree_rounded,
              ),
              _RequestQueueChip(
                label: item.sourceLabelAr,
                icon: item.rpcBacked
                    ? Icons.cloud_done_rounded
                    : Icons.offline_bolt_rounded,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _RequestQueueActions(item: item, onTransition: onTransition),
          const SizedBox(height: 10),
          Text(
            item.updatedAtLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _RequestQueueActions extends StatelessWidget {
  const _RequestQueueActions({required this.item, required this.onTransition});

  final PwfServiceRequestQueueItem item;
  final Future<void> Function(PwfServiceRequestQueueItem item, String action)
  onTransition;

  @override
  Widget build(BuildContext context) {
    final actions = _actionsForStatus(item.status);
    if (actions.isEmpty) {
      return Text(
        'لا توجد إجراءات متاحة لهذه الحالة.',
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: const Color(0xFF64748B)),
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final action in actions)
          OutlinedButton.icon(
            onPressed: item.rpcBacked
                ? () => onTransition(item, action.key)
                : null,
            icon: Icon(action.icon, size: 16),
            label: Text(action.labelAr),
          ),
      ],
    );
  }

  static List<_RequestWorkflowAction> _actionsForStatus(String status) {
    return switch (status) {
      'received' => const [
        _RequestWorkflowAction(
          'start_triage',
          'بدء الفرز',
          Icons.manage_search_rounded,
        ),
        _RequestWorkflowAction('reject', 'رفض', Icons.block_rounded),
      ],
      'triage' => const [
        _RequestWorkflowAction(
          'start_review',
          'مراجعة',
          Icons.fact_check_rounded,
        ),
        _RequestWorkflowAction(
          'request_info',
          'استكمال',
          Icons.assignment_late_rounded,
        ),
      ],
      'under_review' => const [
        _RequestWorkflowAction('route', 'إحالة', Icons.account_tree_rounded),
        _RequestWorkflowAction(
          'request_info',
          'استكمال',
          Icons.assignment_late_rounded,
        ),
        _RequestWorkflowAction('close', 'إغلاق', Icons.check_circle_rounded),
      ],
      'waiting_applicant' => const [
        _RequestWorkflowAction(
          'start_review',
          'استئناف المراجعة',
          Icons.fact_check_rounded,
        ),
        _RequestWorkflowAction('close', 'إغلاق', Icons.check_circle_rounded),
      ],
      'routed' => const [
        _RequestWorkflowAction('close', 'إغلاق', Icons.check_circle_rounded),
      ],
      _ => const [],
    };
  }
}

class _RequestWorkflowAction {
  const _RequestWorkflowAction(this.key, this.labelAr, this.icon);

  final String key;
  final String labelAr;
  final IconData icon;
}

class _RequestQueueLine extends StatelessWidget {
  const _RequestQueueLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF334155)),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestQueueChip extends StatelessWidget {
  const _RequestQueueChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0B3A70)),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFF0B3A70),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestQueueLoadingCard extends StatelessWidget {
  const _RequestQueueLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _RequestQueueEmptyCard extends StatelessWidget {
  const _RequestQueueEmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        'لا توجد طلبات مطابقة للتصفية الحالية.',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
      ),
    );
  }
}

class PwfFormsRegistryAdminScreen extends StatefulWidget {
  const PwfFormsRegistryAdminScreen({super.key});

  @override
  State<PwfFormsRegistryAdminScreen> createState() =>
      _PwfFormsRegistryAdminScreenState();
}

class _PwfFormsRegistryAdminScreenState
    extends State<PwfFormsRegistryAdminScreen> {
  final _adapter = PwfServicesRequestRpcAdapter();
  late Future<List<PwfServiceFormOption>> _future;

  @override
  void initState() {
    super.initState();
    _future = _adapter.loadPublicForms();
  }

  void _refresh() {
    setState(() => _future = _adapter.loadPublicForms());
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: AppRoutes.adminSurfacesServicesFormsRegistry,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _FormsRegistryHeader(onRefresh: _refresh),
              const SizedBox(height: 18),
              FutureBuilder<List<PwfServiceFormOption>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const _RequestQueueLoadingCard();
                  }
                  return _FormsRegistryBoard(
                    forms: snapshot.data ?? PwfServiceFormOption.fallback,
                  );
                },
              ),
              const SizedBox(height: 18),
              const _ServiceFamilySection(
                title: 'روابط تشغيل مرتبطة بسجل النماذج',
                subtitle:
                    'السجل يخدم دليل الخدمات والمراجع الرسمية ومركز الوثائق، ولا يستبدل أي مصدر سيادي أو وثائقي.',
                cards: [
                  _ServiceCardData(
                    title: 'استقبال الطلبات',
                    description:
                        'ربط النموذج بمسار استقبال الطلب ومرحلة التحقق من المرفقات.',
                    route: AppRoutes.adminSurfacesServicesRequests,
                    icon: Icons.assignment_rounded,
                    actionLabel: 'فتح الاستقبال',
                  ),
                  _ServiceCardData(
                    title: 'دليل الخدمات',
                    description:
                        'إظهار النماذج المطلوبة داخل بطاقة الخدمة أو صفحة تفاصيل الخدمة.',
                    route: AppRoutes.adminServicesPage,
                    icon: Icons.design_services_rounded,
                    actionLabel: 'فتح الدليل',
                  ),
                  _ServiceCardData(
                    title: 'المراجع الرسمية',
                    description:
                        'ربط النموذج بالقانون أو التعليمة أو الدليل الإجرائي الذي يستند إليه.',
                    route: AppRoutes.adminSurfacesServicesLegalReferences,
                    icon: Icons.gavel_rounded,
                    actionLabel: 'فتح المراجع',
                  ),
                  _ServiceCardData(
                    title: 'مركز الوثائق',
                    description:
                        'تحويل ملف النموذج لاحقًا إلى أصل وثائقي قابل للاستخراج والاستشهاد.',
                    route: AppRoutes.adminDocuments,
                    icon: Icons.folder_copy_rounded,
                    actionLabel: 'فتح الوثائق',
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const _ServiceGovernanceNote(
                title: 'صيغة السجل الإنتاجية',
                description:
                    'السجل يقرأ من platform_services.service_forms_registry عبر rpc_services_forms_public_v1. الحالات الفارغة تعني عدم وجود نماذج مفعّلة، بينما fallback محصور بغياب عقود SQL.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormsRegistryHeader extends StatelessWidget {
  const _FormsRegistryHeader({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF0B3A70).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.snippet_folder_rounded,
              color: Color(0xFF0B3A70),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سجل النماذج الرسمية',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'سجل موحد للنماذج المرتبطة بالخدمات والمراجع الرسمية؛ يقرأ من قاعدة البيانات عند تفعيل platform_services، مع fallback آمن عند غياب RPC.',
                  style: TextStyle(color: Color(0xFF64748B), height: 1.6),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('تحديث'),
          ),
        ],
      ),
    );
  }
}

class _FormsRegistryBoard extends StatelessWidget {
  const _FormsRegistryBoard({required this.forms});

  final List<PwfServiceFormOption> forms;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'النماذج الرسمية المفعلة',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'تعرض هذه اللوحة النماذج المقروءة من RPC الإنتاجي عند توفره، أو fallback آمن عند غياب قاعدة بيانات مركز الخدمات.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1180
                  ? 4
                  : width >= 820
                  ? 2
                  : 1;
              const spacing = 12.0;
              final cardWidth = columns == 1
                  ? width
                  : (width - (columns - 1) * spacing) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final form in forms)
                    SizedBox(
                      width: cardWidth,
                      child: _FormRegistryDraftCard(form: form),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FormRegistryDraftCard extends StatelessWidget {
  const _FormRegistryDraftCard({required this.form});

  final PwfServiceFormOption form;

  @override
  Widget build(BuildContext context) {
    final attachments = form.requiredAttachments.isEmpty
        ? 'لا توجد مرفقات إلزامية معلنة'
        : form.requiredAttachments.join('، ');
    return Container(
      constraints: const BoxConstraints(minHeight: 214),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B3A70).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  form.rpcBacked
                      ? Icons.cloud_done_rounded
                      : Icons.offline_bolt_rounded,
                  color: const Color(0xFF0B3A70),
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  form.rpcBacked ? 'RPC / قاعدة البيانات' : 'Fallback مؤقت',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: form.rpcBacked
                        ? const Color(0xFF166534)
                        : const Color(0xFFB22222),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            form.titleAr,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _MiniLine(label: 'مفتاح النموذج', value: form.formKey),
          const SizedBox(height: 6),
          _MiniLine(label: 'الخدمة', value: form.serviceKey),
          const SizedBox(height: 6),
          _MiniLine(label: 'الجمهور', value: form.audience),
          const SizedBox(height: 6),
          _MiniLine(label: 'المرفقات', value: attachments),
        ],
      ),
    );
  }
}

class _MiniLine extends StatelessWidget {
  const _MiniLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: const Color(0xFF0B3A70),
            fontWeight: FontWeight.w900,
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceGovernanceNote extends StatelessWidget {
  const _ServiceGovernanceNote({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF92400E)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF92400E),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF92400E),
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

class PwfLegalReferencesAdminScreen extends StatelessWidget {
  const PwfLegalReferencesAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      currentRoute: AppRoutes.adminSurfacesServicesLegalReferences,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: const [
              _LegalReferencesHeader(),
              SizedBox(height: 18),
              _ServiceFamilySection(
                title: 'المراجع القانونية والتنظيمية',
                subtitle:
                    'قسم حكومي رسمي للمراجع التي تخدم الجمهور والموظفين والوحدات، وليس محتوى إعلاميًا.',
                cards: [
                  _ServiceCardData(
                    title: 'القوانين والأنظمة',
                    description:
                        'فهرسة القوانين والأنظمة واللوائح ذات العلاقة بعمل المؤسسة.',
                    route: AppRoutes.legalReferences,
                    icon: Icons.balance_rounded,
                    actionLabel: 'معاينة عامة',
                  ),
                  _ServiceCardData(
                    title: 'التعليمات والتعاميم',
                    description:
                        'تعليمات وتعاميم عامة أو داخلية حسب النطاق والصلاحية.',
                    route: AppRoutes.adminSurfacesServicesLegalReferences,
                    icon: Icons.rule_folder_rounded,
                    actionLabel: 'إدارة التصنيف',
                  ),
                  _ServiceCardData(
                    title: 'الأدلة الإجرائية',
                    description:
                        'أدلة خدمة وإجراءات رسمية قابلة للربط بدليل الخدمات.',
                    route: AppRoutes.adminSurfacesServicesLegalReferences,
                    icon: Icons.assignment_rounded,
                    actionLabel: 'إدارة الأدلة',
                  ),
                  _ServiceCardData(
                    title: 'النماذج الرسمية',
                    description: 'نماذج عامة أو مرتبطة بالخدمات ومركز الوثائق.',
                    route: AppRoutes.adminSurfacesServicesLegalReferences,
                    icon: Icons.description_rounded,
                    actionLabel: 'إدارة النماذج',
                  ),
                ],
              ),
              SizedBox(height: 18),
              _LegalReferencesOperationalWorkspace(),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalReferencesOperationalWorkspace extends StatelessWidget {
  const _LegalReferencesOperationalWorkspace();

  @override
  Widget build(BuildContext context) {
    const rows = [
      _LegalReferenceRow(
        title: 'قانون الأوقاف والشؤون الدينية',
        type: 'قانون',
        scope: 'عام',
        status: 'منشور',
      ),
      _LegalReferenceRow(
        title: 'تعليمات تنظيم النماذج والخدمات',
        type: 'تعليمات',
        scope: 'داخلي/عام',
        status: 'قيد المراجعة',
      ),
      _LegalReferenceRow(
        title: 'دليل إجراءات خدمات الجمهور',
        type: 'دليل إجرائي',
        scope: 'عام',
        status: 'مسودة',
      ),
      _LegalReferenceRow(
        title: 'نماذج الطلبات الرسمية',
        type: 'نموذج',
        scope: 'عام/وحدة',
        status: 'منشور',
      ),
    ];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'سجل إدارة المراجع الرسمية',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.add_rounded),
                label: const Text('إضافة مرجع'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'مساحة إدارة تشغيلية للقوانين والأنظمة والتعليمات والتعاميم والنماذج. الربط الفعلي بالملفات يكون لاحقًا عبر Document Intelligence، بينما الظهور العام يخضع لقسم pwf_legal_references_section في homepage_sections.',
            style: TextStyle(color: Color(0xFF64748B), height: 1.6),
          ),
          const SizedBox(height: 14),
          for (final row in rows) ...[
            _LegalReferenceTile(row: row),
            if (row != rows.last) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _LegalReferenceTile extends StatelessWidget {
  const _LegalReferenceTile({required this.row});

  final _LegalReferenceRow row;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 760;
          final title = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _LegalPill(label: row.type, icon: Icons.category_outlined),
                  _LegalPill(label: row.scope, icon: Icons.visibility_outlined),
                  _LegalPill(label: row.status, icon: Icons.verified_outlined),
                ],
              ),
            ],
          );
          final actions = Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              TextButton.icon(
                onPressed: null,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('تحرير'),
              ),
              TextButton.icon(
                onPressed: null,
                icon: const Icon(Icons.attach_file_outlined, size: 18),
                label: const Text('ربط ملف'),
              ),
              TextButton.icon(
                onPressed: () => context.go(AppRoutes.legalReferences),
                icon: const Icon(Icons.open_in_new_outlined, size: 18),
                label: const Text('معاينة'),
              ),
            ],
          );
          if (compact)
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [title, const SizedBox(height: 10), actions],
            );
          return Row(
            children: [
              Expanded(child: title),
              actions,
            ],
          );
        },
      ),
    );
  }
}

class _LegalPill extends StatelessWidget {
  const _LegalPill({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3A70).withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0B3A70)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _LegalReferenceRow {
  const _LegalReferenceRow({
    required this.title,
    required this.type,
    required this.scope,
    required this.status,
  });

  final String title;
  final String type;
  final String scope;
  final String status;
}

class _LegalReferencesHeader extends StatelessWidget {
  const _LegalReferencesHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF0B3A70).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.gavel_rounded, color: Color(0xFF0B3A70)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الأنظمة والقوانين والتعليمات',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'مرجع رسمي للمؤسسة يربط القوانين والأنظمة والتعليمات والتعاميم والأدلة والنماذج بدليل الخدمات ومركز الوثائق والمساعد الداخلي وفق الصلاحيات.',
                  style: TextStyle(color: Color(0xFF64748B), height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
