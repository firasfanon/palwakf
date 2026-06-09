import 'package:flutter/material.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/features/platform/services/shared/presentation/widgets/pwf_platform_service_admin_screen.dart';

class PwfZakatAdminDashboardScreen extends StatelessWidget {
  const PwfZakatAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PwfPlatformServiceAdminScreen(
      currentRoute: AppRoutes.adminZakat,
      title: 'إدارة خدمة الزكاة',
      subtitle:
          'صفحة إدارية فعلية لإدارة ضبط الخدمة العامة، قنوات التبرع، رسائل الصفحة، ومسار الطلبات والمتابعة على مستوى المنصة.',
      stats: const [
        PwfServiceAdminStat(
          label: 'قنوات التبرع',
          value: '4',
          icon: Icons.volunteer_activism_outlined,
          hint: 'نقدي، حسابات بنكية، QR، حملات موسمية',
        ),
        PwfServiceAdminStat(
          label: 'نماذج الخدمة',
          value: '3',
          icon: Icons.description_outlined,
          hint: 'طلب مساعدة، استفسار، جهة شريكة',
        ),
        PwfServiceAdminStat(
          label: 'حالة النشر',
          value: 'مفعّلة',
          icon: Icons.public_rounded,
          hint: 'الصفحة العامة مربوطة بالهوية العامة للمنصة',
        ),
        PwfServiceAdminStat(
          label: 'أولوية التطوير',
          value: 'عالية',
          icon: Icons.priority_high_rounded,
          hint: 'خدمة عامة مرتبطة بالجمهور والإحالات والحوكمة المالية',
        ),
      ],
      quickActions: const [
        PwfServiceAdminAction(
          label: 'فتح الصفحة العامة',
          icon: Icons.open_in_new_rounded,
          route: AppRoutes.zakat,
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
          label: 'الطلبات',
          icon: Icons.assignment_outlined,
          child: _requestsTab(),
        ),
        PwfServiceAdminTab(
          label: 'القنوات والمحتوى',
          icon: Icons.campaign_outlined,
          child: _channelsTab(),
        ),
        PwfServiceAdminTab(
          label: 'التقارير والحوكمة',
          icon: Icons.query_stats_rounded,
          child: _reportsTab(),
        ),
      ],
    );
  }

  Widget _overviewTab() {
    return Column(
      children: [
        PwfAdminSectionCard(
          title: 'نطاق الإدارة الحالي',
          subtitle:
              'هذه الصفحة لم تعد مجرد رابط للواجهة العامة، بل مساحة إدارية فعلية تجمع عناصر الحوكمة الأساسية للخدمة.',
          child: PwfAdminBulletList(
            items: [
              'تعريف الرسائل العامة والبطاقات الرئيسية الظاهرة في صفحة الزكاة.',
              'مراجعة قنوات التبرع والحالات النشطة/المجمدة لكل قناة.',
              'متابعة الطلبات الواردة ومسار الإحالة أو المراجعة قبل ربطها تشغيليًا بأنظمة أخرى.',
              'تثبيت مؤشرات الأداء والتقارير المرجعية على مستوى المنصة.',
            ],
          ),
        ),
        SizedBox(height: 16),
        PwfAdminSectionCard(
          title: 'ملخص تشغيلي سريع',
          subtitle: 'مؤشرات عمل أولية لحين إغلاق طبقة البيانات الفعلية للخدمة.',
          child: Column(
            children: [
              PwfAdminInfoRow(
                label: 'آخر تحديث للرسالة العامة',
                value: '2026-04-15 11:20 ص',
                trailing: PwfAdminBadge(label: 'منشور'),
              ),
              PwfAdminInfoRow(
                label: 'الجهة الإشرافية الحالية',
                value: 'إدارة المحتوى العام + الجهة المالية المختصة',
              ),
              PwfAdminInfoRow(
                label: 'وضع الطلبات الواردة',
                value: 'تجميع مرجعي أولي، بانتظار دورة بيانات سيادية كاملة',
              ),
              PwfAdminInfoRow(
                label: 'التكامل المتوقع لاحقًا',
                value: 'مهام + إشعارات + تقارير + قنوات دفع محكومة',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _requestsTab() {
    final items = const [
      ('طلب مساعدة علاجية', 'جديد', 'بيت لحم', 'عالية'),
      ('طلب سلة غذائية', 'قيد المراجعة', 'الخليل', 'متوسطة'),
      ('استفسار عن آلية التبرع', 'محال', 'الوزارة', 'منخفضة'),
      ('طلب شراكة مع جمعية', 'يتطلب اعتماد', 'نابلس', 'عالية'),
    ];
    return Column(
      children: [
        PwfAdminSectionCard(
          title: 'لوحة متابعة الطلبات',
          subtitle: 'نموذج إدارة فعلي لمسار الطلبات المتوقعة داخل خدمة الزكاة.',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'بحث بالاسم/المرجع',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'الوحدة/المدينة',
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
                        labelText: 'الحالة',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'نوع الطلب',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PwfAdminSectionCard(
          title: 'أمثلة سجلات تشغيلية',
          subtitle: 'تخطيط واجهة السجل قبل ربطه الفعلي بقاعدة البيانات.',
          child: Column(
            children: items
                .map(
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      tileColor: const Color(0xFFF8FAFC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      leading: const CircleAvatar(
                        child: Icon(Icons.assignment_outlined),
                      ),
                      title: Text(row.$1),
                      subtitle: Text('الوحدة: ${row.$3} • الأولوية: ${row.$4}'),
                      trailing: PwfAdminBadge(
                        label: row.$2,
                        color: row.$2 == 'جديد'
                            ? const Color(0xFFFFF4E5)
                            : row.$2 == 'قيد المراجعة'
                            ? const Color(0xFFE8F0FE)
                            : const Color(0xFFEFFAF3),
                        textColor: row.$2 == 'جديد'
                            ? const Color(0xFF9A3412)
                            : row.$2 == 'قيد المراجعة'
                            ? const Color(0xFF0F4C81)
                            : const Color(0xFF166534),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }

  Widget _channelsTab() {
    return Column(
      children: [
        PwfAdminSectionCard(
          title: 'رسائل الصفحة والقنوات',
          subtitle:
              'ضبط المحتوى الإداري المعروض في الصفحة العامة وقنوات المساهمة المعتمدة.',
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'عنوان الـ Hero',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'وصف مختصر للخدمة',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'سعر غرام الذهب',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'النصاب الحالي',
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
                title: Text('إظهار قسم قنوات التبرع'),
              ),
              SwitchListTile.adaptive(
                value: true,
                onChanged: null,
                title: Text('إظهار حاسبة الزكاة في الصفحة العامة'),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        PwfAdminSectionCard(
          title: 'قنوات معروضة حاليًا',
          subtitle: 'تمثيل إداري أولي قبل بناء CRUD فعلي للقنوات.',
          child: Column(
            children: [
              PwfAdminInfoRow(
                label: 'حساب بنكي رئيسي',
                value: 'نشط • مرتبط بالرسالة الرئيسية',
                trailing: PwfAdminBadge(
                  label: 'نشط',
                  color: Color(0xFFEFFAF3),
                  textColor: Color(0xFF166534),
                ),
              ),
              PwfAdminInfoRow(
                label: 'QR للتبرع السريع',
                value: 'ظاهر على الصفحة العامة',
                trailing: PwfAdminBadge(label: 'منشور'),
              ),
              PwfAdminInfoRow(
                label: 'حملة موسمية',
                value: 'مجدولة لشهر رمضان',
                trailing: PwfAdminBadge(
                  label: 'مجدول',
                  color: Color(0xFFFFF4E5),
                  textColor: Color(0xFF9A3412),
                ),
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
          title: 'التقارير والمؤشرات',
          subtitle:
              'لوحة مرجعية تساعد على تحويل الخدمة إلى مساحة تشغيلية قابلة للإدارة لاحقًا.',
          child: Column(
            children: [
              PwfAdminInfoRow(
                label: 'الطلبات الجديدة هذا الأسبوع',
                value: '18',
              ),
              PwfAdminInfoRow(label: 'طلبات تحتاج اعتمادًا', value: '5'),
              PwfAdminInfoRow(label: 'قنوات نشطة', value: '4'),
              PwfAdminInfoRow(
                label: 'محتوى منشور مرتبط بالخدمة',
                value: '7 عناصر',
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        PwfAdminSectionCard(
          title: 'ضوابط حاكمة',
          subtitle: 'تذكير تنفيذي بما يجب أن يظل تحت سيادة المنصة.',
          child: PwfAdminBulletList(
            items: [
              'الزكاة خدمة منصة عامة وليست نظامًا ماليًا مستقلًا بحد ذاته.',
              'أي تدفق تحصيل أو دفع لاحق يجب أن يخضع لحوكمة مالية وسيادية أعلى.',
              'Top Bar وHeader وFooter من المنصة العامة، بينما Hero وCards خاصة بالخدمة.',
              'ربط الطلبات بالمهام والإشعارات يتم لاحقًا دون تكرار المرجعيات.',
            ],
          ),
        ),
      ],
    );
  }
}
