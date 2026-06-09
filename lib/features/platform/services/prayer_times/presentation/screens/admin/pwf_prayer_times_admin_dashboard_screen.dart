import 'package:flutter/material.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/features/platform/services/shared/presentation/widgets/pwf_platform_service_admin_screen.dart';

class PwfPrayerTimesAdminDashboardScreen extends StatelessWidget {
  const PwfPrayerTimesAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PwfPlatformServiceAdminScreen(
      currentRoute: AppRoutes.adminPrayerTimes,
      title: 'إدارة خدمة مواقيت الصلاة',
      subtitle:
          'صفحة إدارية فعلية لإدارة المدن، طرق الاحتساب، حالة المصدر، والمحتوى التوضيحي المرتبط بخدمة المواقيت داخل المنصة.',
      stats: const [
        PwfServiceAdminStat(
          label: 'المدن المعروضة',
          value: '12',
          icon: Icons.location_city_outlined,
          hint: 'قابلة للتوسعة لاحقًا عبر CRUD سيادي',
        ),
        PwfServiceAdminStat(
          label: 'طرق الاحتساب',
          value: '3',
          icon: Icons.tune_rounded,
          hint: 'افتراضي + احتياطي + موسمي',
        ),
        PwfServiceAdminStat(
          label: 'مصدر التوقيت',
          value: 'خارجي',
          icon: Icons.cloud_sync_outlined,
          hint: 'حل مرحلي حتى اعتماد مصدر سيادي',
        ),
        PwfServiceAdminStat(
          label: 'القبلة/الهجري',
          value: 'مفعّل',
          icon: Icons.explore_outlined,
          hint: 'يعرض داخل الصفحة العامة بالفعل',
        ),
      ],
      quickActions: const [
        PwfServiceAdminAction(
          label: 'فتح الصفحة العامة',
          icon: Icons.open_in_new_rounded,
          route: AppRoutes.prayerTimes,
        ),
        PwfServiceAdminAction(
          label: 'إدارة الصفحة الرئيسية',
          icon: Icons.space_dashboard_outlined,
          route: AppRoutes.adminHomeManagement,
        ),
        PwfServiceAdminAction(
          label: 'المحتوى المشترك',
          icon: Icons.article_outlined,
          route: AppRoutes.adminSharedContent,
        ),
      ],
      tabs: [
        PwfServiceAdminTab(
          label: 'نظرة عامة',
          icon: Icons.dashboard_outlined,
          child: _overviewTab(),
        ),
        PwfServiceAdminTab(
          label: 'المدن والطرق',
          icon: Icons.location_on_outlined,
          child: _citiesTab(),
        ),
        PwfServiceAdminTab(
          label: 'المصدر والتحديث',
          icon: Icons.sync_rounded,
          child: _sourceTab(),
        ),
        PwfServiceAdminTab(
          label: 'التقارير والنشر',
          icon: Icons.insights_outlined,
          child: _reportsTab(),
        ),
      ],
    );
  }

  Widget _overviewTab() {
    return Column(
      children: [
        PwfAdminSectionCard(
          title: 'ما الذي تديره هذه الصفحة؟',
          subtitle:
              'إدارة فعلية أولية لخدمة المواقيت بدل الاكتفاء بإعادة فتح الصفحة العامة.',
          child: PwfAdminBulletList(
            items: [
              'إدارة قائمة المدن والمناطق الظاهرة للمستخدمين.',
              'إدارة طريقة الاحتساب الافتراضية وربط الطرق البديلة.',
              'متابعة حالة المصدر الخارجي المؤقت وسجل آخر تحديث.',
              'إدارة الرسائل التوضيحية والتعريفية المرتبطة بفقه المواقيت والقبلة.',
            ],
          ),
        ),
        SizedBox(height: 16),
        PwfAdminSectionCard(
          title: 'ملخص الحالة الحالية',
          subtitle: 'مرجع تنفيذي سريع قبل إغلاق طبقة البيانات الفعلية.',
          child: Column(
            children: [
              PwfAdminInfoRow(
                label: 'آخر تحديث يومي ناجح',
                value: '2026-04-15 04:10 ص',
              ),
              PwfAdminInfoRow(
                label: 'طريقة الاحتساب الافتراضية',
                value: 'القدس / أم القرى المعدلة',
                trailing: PwfAdminBadge(label: 'افتراضي'),
              ),
              PwfAdminInfoRow(
                label: 'رسالة الصفحة العامة',
                value: 'توضح أن مصدر المواقيت الحالي مرحلي ويخضع للمراجعة',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _citiesTab() {
    final cities = const [
      ('القدس', 'الطريقة الافتراضية', 'نشطة'),
      ('غزة', 'الطريقة الافتراضية', 'نشطة'),
      ('الخليل', 'طريقة احتياطية', 'نشطة'),
      ('نابلس', 'طريقة احتياطية', 'مراجعة'),
    ];
    return Column(
      children: [
        PwfAdminSectionCard(
          title: 'إعدادات المدن وطرق الاحتساب',
          subtitle:
              'واجهة إدارة مباشرة للحقول المرجعية قبل ربطها بالجداول السيادية.',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'اسم المدينة',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'رمز المدينة/الوحدة',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'طريقة الاحتساب',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'المنطقة الزمنية',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              SwitchListTile.adaptive(
                value: true,
                onChanged: null,
                title: Text('تفعيل المدينة في الصفحة العامة'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PwfAdminSectionCard(
          title: 'سجل المدن الحالية',
          subtitle: 'تمثيل إداري أولي للسجل قبل تفعيل CRUD الفعلي.',
          child: Column(
            children: cities
                .map(
                  (city) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      tileColor: const Color(0xFFF8FAFC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      leading: const CircleAvatar(
                        child: Icon(Icons.location_city_outlined),
                      ),
                      title: Text(city.$1),
                      subtitle: Text('الطريقة: ${city.$2}'),
                      trailing: PwfAdminBadge(label: city.$3),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }

  Widget _sourceTab() {
    return Column(
      children: [
        PwfAdminSectionCard(
          title: 'المصدر والمزامنة',
          subtitle:
              'إدارة واضحة لحالة المصدر الحالي وخطة الاستبدال بمصدر سيادي لاحقًا.',
          child: Column(
            children: [
              PwfAdminInfoRow(label: 'نوع المصدر الحالي', value: 'API خارجي'),
              PwfAdminInfoRow(
                label: 'وضع الاعتماد',
                value: 'حل مرحلي يحتاج استبدالًا لاحقًا',
              ),
              PwfAdminInfoRow(label: 'التحديث التلقائي', value: 'مرة يوميًا'),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Base URL / Reference',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'مهلة التحديث بالدقائق',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              SwitchListTile.adaptive(
                value: true,
                onChanged: null,
                title: Text('تفعيل التحديث اليومي'),
              ),
              SwitchListTile.adaptive(
                value: false,
                onChanged: null,
                title: Text('استخدام مصدر سيادي بديل (لاحقًا)'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reportsTab() {
    return Column(
      children: [
        PwfAdminSectionCard(
          title: 'تقارير ونشر الخدمة',
          subtitle:
              'مؤشرات وقرارات نشر مرتبطة بالمحتوى والبيانات المعروضة للجمهور.',
          child: Column(
            children: [
              PwfAdminInfoRow(label: 'عدد المدن النشطة', value: '12'),
              PwfAdminInfoRow(
                label: 'أيام التحديث الناجح هذا الشهر',
                value: '15/15',
              ),
              PwfAdminInfoRow(label: 'عدد رسائل التوضيح المنشورة', value: '3'),
              PwfAdminInfoRow(label: 'حالة الصفحة العامة', value: 'منشورة'),
            ],
          ),
        ),
        SizedBox(height: 16),
        PwfAdminSectionCard(
          title: 'ضوابط حاكمة',
          subtitle: 'ما يجب الالتزام به عند تطوير الخدمة لاحقًا.',
          child: PwfAdminBulletList(
            items: [
              'مواقيت الصلاة خدمة منصة عامة وليست نظامًا مستقلًا.',
              'الهوية العامة من المنصة، بينما البطاقات والمحتوى الداخلي خاصان بالخدمة.',
              'استبدال المصدر الخارجي بمصدر داخلي سيادي يتم لاحقًا دون كسر الصفحة العامة.',
            ],
          ),
        ),
      ],
    );
  }
}
