import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/core/layout/pwf_global_layout_contract.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const cards = [
      _ReportCategory(
        title: 'تقارير المحتوى العام',
        subtitle:
            'الأخبار والإعلانات والأنشطة وخطب الجمعة والميديا عبر home وslug.',
        icon: Icons.newspaper_rounded,
        color: Color(0xFF0F4C81),
        route: AppRoutes.adminSharedContent,
        bullets: [
          'توزيع المحتوى حسب الوحدة والنطاق',
          'مراجعة النشر والنشاط والحذف الجماعي',
          'مراقبة كثافة الصفحة الرئيسية والتفاصيل',
        ],
      ),
      _ReportCategory(
        title: 'تقارير الحوكمة والمنصة',
        subtitle:
            'المستخدمون والوحدات وبوابة الإدارة العامة وتماسك مسارات المنصة.',
        icon: Icons.admin_panel_settings_rounded,
        color: Color(0xFF1F6B45),
        route: AppRoutes.adminSettings,
        bullets: [
          'مراقبة البنية الإدارية والصلاحيات',
          'ثبات تبويب المنصة والأنظمة المرتبطة',
          'تجميع نقاط الصيانة والتنفيذ المرحلي',
        ],
      ),
      _ReportCategory(
        title: 'تقارير الأنظمة المرتبطة',
        subtitle:
            'الوصول إلى أنظمة mustakshif والقضايا والمهام والمساجد والفوترة.',
        icon: Icons.widgets_rounded,
        color: Color(0xFF7A1F2B),
        route: AppRoutes.adminDashboard,
        bullets: [
          'متابعة الأنظمة شبه المستقلة المرتبطة بالمنصة',
          'تثبيت الفرق بين admin / system / unit',
          'رصد جاهزية مسارات النظام والهبوط البصري',
        ],
      ),
    ];

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
                  _ReportsHero(),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: const [
                      _KpiCard(
                        label: 'فئات التقارير',
                        value: '03',
                        icon: Icons.dashboard_customize_outlined,
                        color: Color(0xFF0F4C81),
                      ),
                      _KpiCard(
                        label: 'وجهات التتبع',
                        value: 'Admin + Public',
                        icon: Icons.compare_arrows_outlined,
                        color: Color(0xFF1F6B45),
                      ),
                      _KpiCard(
                        label: 'حالة التنفيذ',
                        value: 'مرحلية',
                        icon: Icons.timeline_outlined,
                        color: Color(0xFF7A1F2B),
                      ),
                      _KpiCard(
                        label: 'التصدير',
                        value: 'Excel / PDF',
                        icon: Icons.file_download_outlined,
                        color: Color(0xFFB22222),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width =
                          constraints.hasBoundedWidth &&
                              constraints.maxWidth.isFinite
                          ? constraints.maxWidth
                          : MediaQuery.sizeOf(context).width;
                      final stacked = width < 1080;
                      final categoryColumn = Column(
                        mainAxisSize: MainAxisSize.min,
                        children: cards
                            .map(
                              (card) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _ReportCategoryCard(category: card),
                              ),
                            )
                            .toList(),
                      );
                      const sideColumn = Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ReportsExecutionCard(),
                          SizedBox(height: 16),
                          _ReportsExportCard(),
                        ],
                      );

                      if (stacked) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            categoryColumn,
                            const SizedBox(height: 20),
                            sideColumn,
                          ],
                        );
                      }

                      final leftWidth = (width * .58).clamp(520.0, 780.0);
                      final rightWidth = (width - leftWidth - 20)
                          .clamp(360.0, 520.0)
                          .toDouble();
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: leftWidth.toDouble(),
                            child: categoryColumn,
                          ),
                          const SizedBox(width: 20),
                          SizedBox(width: rightWidth, child: sideColumn),
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

class _ReportsHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4C81), Color(0xFF0C3E6A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مركز التقارير والمتابعة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'واجهة إدارية أوضح لتجميع التقارير التنفيذية بدل الشاشة الفارغة السابقة، مع توجيه مباشر إلى مسارات التقارير الفعلية داخل المنصة.',
            style: TextStyle(color: Colors.white, height: 1.6, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
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
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PwfSafeText(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                PwfSafeText(
                  label,
                  maxLines: 2,
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

class _ReportCategoryCard extends StatelessWidget {
  const _ReportCategoryCard({required this.category});
  final _ReportCategory category;
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
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(category.icon, color: category.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PwfSafeText(
                      category.title,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    PwfSafeText(
                      category.subtitle,
                      maxLines: 3,
                      softWrap: true,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...category.bullets.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: category.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item, style: const TextStyle(height: 1.55)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => context.go(category.route),
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('فتح المسار المرتبط'),
              style: FilledButton.styleFrom(
                backgroundColor: category.color,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportsExecutionCard extends StatelessWidget {
  const _ReportsExecutionCard();
  @override
  Widget build(BuildContext context) {
    return _SideCard(
      title: 'ماذا تغلق هذه الصفحة؟',
      subtitle:
          'تحويل التقارير من شاشة فارغة إلى مركز إداري منظم يربط بين التتبع والتنفيذ.',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LineItem('تجميع أقرب فئات التقارير داخل صفحة واحدة.'),
          _LineItem('توضيح مسارات الإدارة المرتبطة بدل ترك الصفحة بلا توجيه.'),
          _LineItem(
            'تثبيت أن التقارير جزء من سير العمل وليس شاشة ثانوية مهملة.',
          ),
        ],
      ),
    );
  }
}

class _ReportsExportCard extends StatelessWidget {
  const _ReportsExportCard();
  @override
  Widget build(BuildContext context) {
    return _SideCard(
      title: 'ملاحظات التصدير',
      subtitle:
          'مرجع سريع لما يجب مراعاته عند استكمال مسارات Excel / PDF لاحقًا.',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LineItem('اعتماد مربع حوار اختيار النطاق قبل التصدير.'),
          _LineItem('PDF متعدد الصفحات مع دعم عربي ولاتيني.'),
          _LineItem('حفظ اتساق الهوية البصرية في الغلاف والجداول.'),
        ],
      ),
    );
  }
}

class _SideCard extends StatelessWidget {
  const _SideCard({
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
          PwfSafeText(
            title,
            maxLines: 2,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          PwfSafeText(
            subtitle,
            maxLines: 3,
            softWrap: true,
            style: const TextStyle(color: Color(0xFF6B7280), height: 1.5),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _LineItem extends StatelessWidget {
  const _LineItem(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Color(0xFF0F4C81)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(height: 1.55))),
        ],
      ),
    );
  }
}

class _ReportCategory {
  const _ReportCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
    required this.bullets,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;
  final List<String> bullets;
}
