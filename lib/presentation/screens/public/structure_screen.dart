import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/web/web_public_page.dart';

class StructureScreen extends StatelessWidget {
  const StructureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebPublicPage(
        title: 'الهيكل التنظيمي',
        subtitle: 'الدوائر والإدارات الرئيسية في وزارة الأوقاف والشؤون الدينية',
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIntroCard(),
              const SizedBox(height: 24),
              _buildOrganizationChart(),
              const SizedBox(height: 24),
              _buildDepartments(),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'الهيكل التنظيمي'),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          _buildIntroCard(),
          const SizedBox(height: 24),
          _buildOrganizationChart(),
          const SizedBox(height: 24),
          _buildDepartments(),
        ],
      ),
    );
  }

  Widget _buildIntroCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'نبذة عن الهيكل التنظيمي',
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'يتكون الهيكل التنظيمي لوزارة الأوقاف والشؤون الدينية من عدة إدارات ودوائر متخصصة تعمل بشكل متكامل لتحقيق أهداف الوزارة.',
              style: AppTextStyles.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizationChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          children: [
            _buildOrgNode('معالي الوزير', true),
            _buildConnector(),
            _buildOrgNode('وكيل الوزارة', false),
            _buildConnector(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: _buildOrgNode('المساعد الإداري', false)),
                const SizedBox(width: 8),
                Expanded(child: _buildOrgNode('المساعد الفني', false)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrgNode(String title, bool isTop) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: isTop ? AppColors.islamicGreen : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: isTop ? AppColors.islamicGreen : AppColors.borderLight,
          width: 2,
        ),
      ),
      child: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          fontWeight: FontWeight.bold,
          color: isTop ? Colors.white : Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildConnector() {
    return Container(
      width: 2,
      height: 24,
      color: AppColors.borderMedium,
      margin: const EdgeInsets.symmetric(vertical: 4),
    );
  }

  Widget _buildDepartments() {
    final departments = [
      {
        'name': 'دائرة المساجد',
        'description': 'تشرف على جميع المساجد والمصليات في فلسطين',
        'icon': Icons.mosque,
      },
      {
        'name': 'دائرة الأوقاف',
        'description': 'تدير وتنظم الأملاك والأراضي الوقفية',
        'icon': Icons.landscape,
      },
      {
        'name': 'دائرة الشؤون الدينية',
        'description': 'تنظم الأنشطة والفعاليات الدينية',
        'icon': Icons.event,
      },
      {
        'name': 'دائرة الحج والعمرة',
        'description': 'تنظم مواسم الحج والعمرة',
        'icon': Icons.flight,
      },
      {
        'name': 'دائرة التعليم الديني',
        'description': 'تشرف على المعاهد والمراكز التعليمية الدينية',
        'icon': Icons.school,
      },
      {
        'name': 'دائرة الإفتاء',
        'description': 'تقدم الفتاوى والإرشاد الديني',
        'icon': Icons.menu_book,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الدوائر والإدارات',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...departments.map((dept) => _buildDepartmentCard(dept)),
      ],
    );
  }

  Widget _buildDepartmentCard(Map<String, dynamic> dept) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.islamicGreen.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(dept['icon'] as IconData, color: AppColors.islamicGreen),
        ),
        title: Text(
          dept['name'],
          style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(dept['description'], style: AppTextStyles.bodySmall),
      ),
    );
  }
}