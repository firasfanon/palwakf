import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routing/app_routes.dart';
import '../../../core/enums/enums.dart';

class SystemDashboardPlaceholder extends StatelessWidget {
  final SystemKey systemKey;

  const SystemDashboardPlaceholder({super.key, required this.systemKey});

  @override
  Widget build(BuildContext context) {
    final config = _SystemLandingConfig.forKey(systemKey);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LandingHero(config: config),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: config.stats
                        .map(
                          (item) => _StatCard(item: item, color: config.color),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final stacked = constraints.maxWidth < 1080;
                      return Flex(
                        direction: stacked ? Axis.vertical : Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: _QuickRoutesCard(config: config),
                          ),
                          SizedBox(
                            width: stacked ? 0 : 20,
                            height: stacked ? 20 : 0,
                          ),
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                _ScopeSummaryCard(config: config),
                                const SizedBox(height: 16),
                                _ExecutionNotesCard(config: config),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LandingHero extends StatelessWidget {
  const _LandingHero({required this.config});

  final _SystemLandingConfig config;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [config.color, config.color.withValues(alpha: 0.84)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: config.color.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(config.icon, size: 38, color: Colors.white),
          ),
          SizedBox(
            width: 860,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  config.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _HeroChip(label: 'slug: ${config.systemKey.slug}'),
                    const _HeroChip(label: 'system_pages'),
                    const _HeroChip(label: 'PalWakf'),
                    _HeroChip(label: config.familyLabel),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.item, required this.color});

  final _SystemLandingStat item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
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

class _QuickRoutesCard extends StatelessWidget {
  const _QuickRoutesCard({required this.config});
  final _SystemLandingConfig config;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'مداخل العمل السريعة',
      subtitle:
          'الوصول المباشر إلى الصفحة العامة للنظام ومساره الإداري والخدمات الأقرب للاستخدام.',
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        children: config.routes
            .map((item) => _RouteTile(item: item, color: config.color))
            .toList(),
      ),
    );
  }
}

class _RouteTile extends StatelessWidget {
  const _RouteTile({required this.item, required this.color});
  final _SystemLandingRoute item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => context.go(item.route),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.icon, color: color),
              const SizedBox(height: 12),
              Text(
                item.label,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                item.description,
                style: const TextStyle(color: Color(0xFF6B7280), height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScopeSummaryCard extends StatelessWidget {
  const _ScopeSummaryCard({required this.config});
  final _SystemLandingConfig config;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'الربط والسياق',
      subtitle:
          'تثبيت أن هذه الصفحة بوابة نظام ضمن سياق system_pages، وليست صفحة وحدة محلية ولا شاشة تجريبية.',
      child: Column(
        children: [
          _InfoRow(label: 'المفتاح', value: config.systemKey.name),
          _InfoRow(label: 'الاسم العربي', value: config.systemKey.nameAr),
          _InfoRow(label: 'الـ slug', value: config.systemKey.slug),
          _InfoRow(label: 'العائلة البصرية', value: config.familyLabel),
          _InfoRow(label: 'السياق', value: 'system_pages'),
        ],
      ),
    );
  }
}

class _ExecutionNotesCard extends StatelessWidget {
  const _ExecutionNotesCard({required this.config});
  final _SystemLandingConfig config;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'ملاحظات تنفيذية',
      subtitle:
          'تذكير سريع بالقرارات المعمارية التي تحكم هذه الصفحة داخل PalWakf.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: config.notes
            .map(
              (note) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: config.color,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        note,
                        style: const TextStyle(
                          height: 1.6,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFF6B7280), height: 1.5),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SystemLandingConfig {
  const _SystemLandingConfig({
    required this.systemKey,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.familyLabel,
    required this.stats,
    required this.routes,
    required this.notes,
  });

  final SystemKey systemKey;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String familyLabel;
  final List<_SystemLandingStat> stats;
  final List<_SystemLandingRoute> routes;
  final List<String> notes;

  static _SystemLandingConfig forKey(SystemKey key) {
    switch (key) {
      case SystemKey.mustakshif:
        return _SystemLandingConfig(
          systemKey: key,
          title: 'بوابة مستكشف الوقف',
          subtitle:
              'هبوط نظامي واضح للمجال المكاني والتاريخي يربط الخرائط والطبقات والتحليلات ضمن هوية system_pages.',
          icon: Icons.map_rounded,
          color: const Color(0xFF0F4C81),
          familyLabel: 'الأزرق السيادي / system_pages',
          stats: const [
            _SystemLandingStat('GIS + Hist', '02', Icons.layers_outlined),
            _SystemLandingStat(
              'وضع التحليل',
              'مكاني',
              Icons.travel_explore_rounded,
            ),
            _SystemLandingStat('التركيز', 'waqf_assets', Icons.place_outlined),
          ],
          routes: const [
            _SystemLandingRoute(
              'فتح المستكشف',
              AppRoutes.mustakshif,
              Icons.open_in_new_rounded,
              'الدخول إلى الواجهة العامة للنظام.',
            ),
            _SystemLandingRoute(
              'لوحة الإدارة',
              AppRoutes.adminDashboard,
              Icons.admin_panel_settings_outlined,
              'العودة إلى البيئة الإدارية العامة.',
            ),
            _SystemLandingRoute(
              'الخريطة العامة',
              AppRoutes.home,
              Icons.public_outlined,
              'الرجوع إلى الصفحة العامة للمنصة.',
            ),
          ],
          notes: [
            'مستكشف الوقف نظام شبه مستقل مرتبط بالمنصة، وليس صفحة وحدة تقليدية.',
            'يمثل system_pages ولا يرث الصفحة الوزارية حرفيًا.',
            'تركيزه الأساسي spatial / historical / analytical فقط.',
          ],
        );
      case SystemKey.cases:
        return _SystemLandingConfig(
          systemKey: key,
          title: 'بوابة نظام القضايا',
          subtitle:
              'نقطة دخول أوضح لمسار القضايا الوقفية مع إبراز الربط بالمنصة وعدم اعتباره وحدة منفصلة.',
          icon: Icons.gavel_rounded,
          color: const Color(0xFF7A1F2B),
          familyLabel: 'الحجري الملكي / system_pages',
          stats: const [
            _SystemLandingStat('النطاق', 'قضايا', Icons.folder_open_rounded),
            _SystemLandingStat('العلاقة', 'waqf_asset', Icons.link_rounded),
            _SystemLandingStat('الواجهة', 'حوكمة', Icons.rule_folder_outlined),
          ],
          routes: const [
            _SystemLandingRoute(
              'فتح النظام',
              AppRoutes.cases,
              Icons.open_in_new_rounded,
              'الدخول إلى واجهة النظام العامة.',
            ),
            _SystemLandingRoute(
              'الإدارة',
              AppRoutes.adminCases,
              Icons.manage_accounts_outlined,
              'المسار الإداري التشغيلي للقضايا.',
            ),
            _SystemLandingRoute(
              'المنصة',
              AppRoutes.adminSettings,
              Icons.dashboard_customize_outlined,
              'العودة إلى بوابة إدارة المنصة.',
            ),
          ],
          notes: [
            'القضايا تبقى نظامًا تخصصيًا متصلًا بالعقد الحاكم للمنصة.',
            'لا يعيد تعريف master data بل يربطها عبر الكيانات السيادية.',
            'نمط الهبوط هنا يجب أن يكون أوضح من placeholder العام السابق.',
          ],
        );
      case SystemKey.tasks:
        return _SystemLandingConfig(
          systemKey: key,
          title: 'بوابة نظام المهام',
          subtitle:
              'مدخل أوضح لإدارة المهام التشغيلية وربطها بالقضايا والأصول والعقود عند الحاجة.',
          icon: Icons.task_alt_rounded,
          color: const Color(0xFF1F6B45),
          familyLabel: 'الأخضر الوقفي / system_pages',
          stats: const [
            _SystemLandingStat('الوضع', 'تشغيلي', Icons.tune_rounded),
            _SystemLandingStat('التركيز', 'Workflow', Icons.route_outlined),
            _SystemLandingStat('الربط', 'متعدد الكيانات', Icons.hub_outlined),
          ],
          routes: const [
            _SystemLandingRoute(
              'فتح النظام',
              AppRoutes.tasks,
              Icons.open_in_new_rounded,
              'الدخول إلى واجهة المهام.',
            ),
            _SystemLandingRoute(
              'لوحة الإدارة',
              AppRoutes.adminDashboard,
              Icons.admin_panel_settings_outlined,
              'العودة إلى لوحة الإدارة.',
            ),
            _SystemLandingRoute(
              'بوابة المنصة',
              AppRoutes.adminSettings,
              Icons.settings_outlined,
              'فتح بوابة المنصة.',
            ),
          ],
          notes: [
            'المهام نظام تشغيلي، وليس مصدرًا سياديًا للبيانات المرجعية.',
            'يرتبط بالقضية أو الأصل أو العقد عند الحاجة دون إعادة تعريفها.',
            'الهدف هو الوصول الواضح لا شاشة خام fallback فقط.',
          ],
        );
      case SystemKey.mosques:
        return _SystemLandingConfig(
          systemKey: key,
          title: 'بوابة نظام المساجد',
          subtitle:
              'واجهة نظامية أوضح للمساجد والخدمات المرتبطة بها ضمن هوية المنصة السيادية.',
          icon: Icons.mosque_rounded,
          color: const Color(0xFF0B4AA2),
          familyLabel: 'الأزرق السيادي / system_pages',
          stats: const [
            _SystemLandingStat('النطاق', 'مساجد', Icons.mosque_outlined),
            _SystemLandingStat(
              'الخدمات',
              'إرشاد + صيانة',
              Icons.miscellaneous_services_outlined,
            ),
            _SystemLandingStat(
              'الوصول',
              'عام + إداري',
              Icons.compare_arrows_outlined,
            ),
          ],
          routes: const [
            _SystemLandingRoute(
              'فتح النظام',
              AppRoutes.mosquesSystem,
              Icons.open_in_new_rounded,
              'الدخول إلى المسار العام للنظام.',
            ),
            _SystemLandingRoute(
              'المسار الإداري',
              AppRoutes.adminMosques,
              Icons.admin_panel_settings_outlined,
              'إدارة نظام المساجد.',
            ),
            _SystemLandingRoute(
              'الخدمات العامة',
              AppRoutes.services,
              Icons.handyman_outlined,
              'العودة إلى خدمات المنصة.',
            ),
          ],
          notes: [
            'نظام المساجد يظل جزءًا من PalWakf، لا علامة منفصلة.',
            'يمكن توسيعه لاحقًا ببطاقات مؤشرات وربط خرائطي أعمق.',
            'الواجهة الحالية هنا ترفع مستوى الهبوط البصري والوظيفي فقط.',
          ],
        );
      case SystemKey.billing:
        return _SystemLandingConfig(
          systemKey: key,
          title: 'بوابة الفوترة',
          subtitle:
              'هبوط أوضح لمسار العقود والفواتير والمتأخرات ضمن العلاقة مع الأصل الوقفي والعقود.',
          icon: Icons.receipt_long_rounded,
          color: const Color(0xFF7A1F2B),
          familyLabel: 'الحجري الملكي / system_pages',
          stats: const [
            _SystemLandingStat('العقود', 'نشطة', Icons.assignment_outlined),
            _SystemLandingStat('المدفوعات', 'تحصيل', Icons.payments_outlined),
            _SystemLandingStat(
              'الارتباط',
              'waqf_asset',
              Icons.home_work_outlined,
            ),
          ],
          routes: const [
            _SystemLandingRoute(
              'فتح النظام',
              AppRoutes.billing,
              Icons.open_in_new_rounded,
              'الدخول إلى بوابة الفوترة العامة.',
            ),
            _SystemLandingRoute(
              'لوحة الإدارة',
              AppRoutes.adminDashboard,
              Icons.admin_panel_settings_outlined,
              'العودة إلى الإدارة.',
            ),
            _SystemLandingRoute(
              'المنصة',
              AppRoutes.adminSettings,
              Icons.settings_outlined,
              'بوابة الحوكمة العامة.',
            ),
          ],
          notes: [
            'الفوترة نظام تخصصي مرتبط بالأصل والعقد والتحصيل.',
            'لا يعيد تعريف master data، بل يستهلكها عبر الربط السيادي.',
            'تم رفع الصفحة من placeholder عام إلى landing workspace أوضح.',
          ],
        );
      default:
        return _SystemLandingConfig(
          systemKey: key,
          title: 'بوابة نظام ${key.nameAr}',
          subtitle:
              'صفحة هبوط نظامية أوضح من placeholder الخام، مع تثبيت السياق والمسارات الأقرب للاستخدام داخل PalWakf.',
          icon: Icons.widgets_rounded,
          color: const Color(0xFF0F4C81),
          familyLabel: 'الأزرق السيادي / system_pages',
          stats: const [
            _SystemLandingStat(
              'السياق',
              'system_pages',
              Icons.web_asset_outlined,
            ),
            _SystemLandingStat('الهوية', 'PalWakf', Icons.approval_outlined),
            _SystemLandingStat(
              'الحالة',
              'جاهز للتوسعة',
              Icons.trending_up_rounded,
            ),
          ],
          routes: const [
            _SystemLandingRoute(
              'الصفحة الرئيسية',
              AppRoutes.home,
              Icons.home_outlined,
              'العودة إلى الصفحة الرئيسية للمنصة.',
            ),
            _SystemLandingRoute(
              'بوابة الإدارة',
              AppRoutes.adminSettings,
              Icons.settings_outlined,
              'العودة إلى بوابة إدارة المنصة.',
            ),
            _SystemLandingRoute(
              'لوحة التحكم',
              AppRoutes.adminDashboard,
              Icons.dashboard_outlined,
              'فتح لوحة التحكم العامة.',
            ),
          ],
          notes: [
            'هذه الصفحة ليست وحدة محلية ولا علامة مستقلة، بل system_pages داخل PalWakf.',
            'الغرض منها تقديم هبوط بصري أوضح ومهني فوق المسار القائم.',
          ],
        );
    }
  }
}

class _SystemLandingStat {
  const _SystemLandingStat(this.label, this.value, this.icon);
  final String label;
  final String value;
  final IconData icon;
}

class _SystemLandingRoute {
  const _SystemLandingRoute(
    this.label,
    this.route,
    this.icon,
    this.description,
  );
  final String label;
  final String route;
  final IconData icon;
  final String description;
}
