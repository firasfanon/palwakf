import 'package:flutter/material.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/features/platform/services/shared/presentation/widgets/pwf_platform_service_admin_screen.dart';

class PwfQuranAdminDashboardScreen extends StatelessWidget {
  const PwfQuranAdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PwfPlatformServiceAdminScreen(
      currentRoute: AppRoutes.adminQuran,
      title: 'إدارة خدمة القرآن الكريم',
      subtitle:
          'مساحة إدارية فعلية لإدارة محتوى القراءة، إعدادات العرض، الرسائل التعريفية، والخطط التكميلية لخدمة القرآن داخل المنصة.',
      stats: const [
        PwfServiceAdminStat(
          label: 'السور المعروضة',
          value: '114',
          icon: Icons.menu_book_rounded,
          hint: 'قراءة عامة مع تخصيصات عرض',
        ),
        PwfServiceAdminStat(
          label: 'حالة البيانات',
          value: 'محمّلة محليًا',
          icon: Icons.dataset_outlined,
          hint: 'تمهيدًا لحوكمة مصدر أكثر رسمية لاحقًا',
        ),
        PwfServiceAdminStat(
          label: 'التخصيصات',
          value: '4',
          icon: Icons.tune_rounded,
          hint: 'حجم خط، عرض، مرجع، قراءة',
        ),
        PwfServiceAdminStat(
          label: 'مرحلة الإدارة',
          value: 'توسعة',
          icon: Icons.auto_stories_outlined,
          hint: 'بعد تثبيت الصفحة العامة والهوية',
        ),
      ],
      quickActions: const [
        PwfServiceAdminAction(
          label: 'فتح الصفحة العامة',
          icon: Icons.open_in_new_rounded,
          route: AppRoutes.quran,
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
          label: 'المحتوى والمصادر',
          icon: Icons.dataset_outlined,
          child: _contentTab(),
        ),
        PwfServiceAdminTab(
          label: 'التجربة والإعدادات',
          icon: Icons.tune_rounded,
          child: _experienceTab(),
        ),
        PwfServiceAdminTab(
          label: 'التقارير والحوكمة',
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
          title: 'الدور الإداري الحالي',
          subtitle:
              'هذه الصفحة تضبط الخدمة إداريًا بدل الاكتفاء بالتحويل إلى صفحة القراءة العامة.',
          child: PwfAdminBulletList(
            items: [
              'إدارة رسالة الصفحة العامة وبطاقاتها التعريفية.',
              'إدارة المصدر المرجعي لبيانات السور والآيات والتأكد من ثباته.',
              'إدارة التخصيصات المسموح عرضها للمستخدم النهائي.',
              'تخطيط التوسعات اللاحقة مثل التلاوات والبحث والمحفوظات.',
            ],
          ),
        ),
        SizedBox(height: 16),
        PwfAdminSectionCard(
          title: 'ملخص تشغيل سريع',
          subtitle: 'مؤشرات أولية لإدارة الخدمة داخل المنصة.',
          child: Column(
            children: [
              PwfAdminInfoRow(
                label: 'وضع الصفحة العامة',
                value: 'منشورة داخل shell المنصة',
                trailing: PwfAdminBadge(label: 'نشطة'),
              ),
              PwfAdminInfoRow(
                label: 'مصدر القراءة الحالي',
                value: 'مخزن محلي/مرجعي داخل التطبيق',
              ),
              PwfAdminInfoRow(
                label: 'حالة التخصيصات',
                value: 'مفعّلة وتدار من أدوات المنصة العامة',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _contentTab() {
    final items = const [
      ('مصدر السور والآيات', 'نشط', 'مرجعي محلي'),
      ('بطاقة تعريف الخدمة', 'منشورة', 'واجهة عامة'),
      ('قسم السور المقترحة', 'قيد التطوير', 'إداري'),
    ];
    return Column(
      children: [
        PwfAdminSectionCard(
          title: 'إعدادات المحتوى والمصدر',
          subtitle:
              'واجهة إدارة أولية لمصدر البيانات والرسائل التعريفية المرتبطة بخدمة القرآن.',
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
                  labelText: 'وصف الخدمة',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'مرجع المصدر',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'إصدار البيانات',
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
                title: Text('إظهار بطاقات تعريفية قبل القراءة'),
              ),
              SwitchListTile.adaptive(
                value: false,
                onChanged: null,
                title: Text('تفعيل مصدر صوتي/تلاوة لاحقًا'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        PwfAdminSectionCard(
          title: 'سجل عناصر المحتوى',
          subtitle: 'عناصر إدارية أولية مرتبطة بالخدمة.',
          child: Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      tileColor: const Color(0xFFF8FAFC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      leading: const CircleAvatar(
                        child: Icon(Icons.library_books_outlined),
                      ),
                      title: Text(item.$1),
                      subtitle: Text('النطاق: ${item.$3}'),
                      trailing: PwfAdminBadge(label: item.$2),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }

  Widget _experienceTab() {
    return Column(
      children: [
        PwfAdminSectionCard(
          title: 'إعدادات تجربة القراءة',
          subtitle:
              'ضبط ما يُعرض للمستخدم العام في صفحة القرآن دون إعادة فصلها عن أدوات المنصة.',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'الحد الأدنى لحجم الخط',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'الحد الأعلى لحجم الخط',
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
                title: Text('إظهار أدوات القراءة المساعدة'),
              ),
              SwitchListTile.adaptive(
                value: true,
                onChanged: null,
                title: Text('تفعيل الحفظ المحلي للمفضلات'),
              ),
              SwitchListTile.adaptive(
                value: false,
                onChanged: null,
                title: Text('إظهار ترجمة مرافقة (مرحليًا)'),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        PwfAdminSectionCard(
          title: 'نطاقات تطوير لاحقة',
          subtitle:
              'أمثلة على الخدمات التكميلية التي ينبغي أن تدار من هنا لاحقًا.',
          child: PwfAdminBulletList(
            items: [
              'بحث موسع في السور والآيات.',
              'تلاوات صوتية مع تحكم بالمشغل.',
              'إدارة السور المقترحة أو البطاقات التعليمية.',
              'مزامنة تفضيلات القراءة مع حساب المستخدم عند الحاجة.',
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
          title: 'تقارير ومرجعيات',
          subtitle:
              'مؤشرات أولية تساعد على إدارة الخدمة قبل بناء تقارير بيانات أوسع.',
          child: Column(
            children: [
              PwfAdminInfoRow(label: 'عدد السور المتاحة', value: '114'),
              PwfAdminInfoRow(
                label: 'عدد البطاقات التعريفية النشطة',
                value: '3',
              ),
              PwfAdminInfoRow(
                label: 'حالة أدوات الوصول',
                value: 'مدمجة مع أدوات المنصة العامة',
              ),
              PwfAdminInfoRow(
                label: 'تاريخ آخر مراجعة تنظيمية',
                value: '2026-04-15',
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        PwfAdminSectionCard(
          title: 'ضوابط حاكمة',
          subtitle: 'تذكير بما يجب أن يبقى منسجمًا مع عقد المنصة.',
          child: PwfAdminBulletList(
            items: [
              'خدمة القرآن صفحة منصة عامة وليست نظامًا شبه مستقل.',
              'أدوات الوصول والقراءة المساعدة يجب أن تتغذى من أدوات المنصة العامة.',
              'أي توسيع في التلاوات أو البحث أو المفضلات يجب أن يحافظ على بساطة الصفحة العامة وعدم تشويه shell المنصة.',
            ],
          ),
        ),
      ],
    );
  }
}
