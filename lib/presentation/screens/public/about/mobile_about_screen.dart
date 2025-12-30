// lib/presentation/screens/public/about/mobile_about_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../../app/routing/app_routes.dart';

/// Mobile-optimized About Screen
/// Features: Vertical scrolling, stacked sections, mobile-friendly layout
class MobileAboutScreen extends StatelessWidget {
  const MobileAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'عن الوزارة'),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          _buildHeroSection(),
          const SizedBox(height: 24),
          _buildQuickLinks(context),
          const SizedBox(height: 24),
          _buildAboutContent(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        decoration: BoxDecoration(
          gradient: AppColors.islamicGradient,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Column(
          children: [
            const Icon(Icons.account_balance, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              AppConstants.appName,
              style: AppTextStyles.headlineSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'نعمل على خدمة المساجد والأوقاف الإسلامية في فلسطين',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white.withValues(alpha:0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    final links = [
      {
        'title': 'كلمة الوزير',
        'icon': Icons.person,
        'route': AppRoutes.minister
      },
      {
        'title': 'الرؤية والرسالة',
        'icon': Icons.flag,
        'route': AppRoutes.visionMission
      },
      {
        'title': 'الهيكل التنظيمي',
        'icon': Icons.account_tree,
        'route': AppRoutes.structure
      },
      {
        'title': 'الوزراء السابقون',
        'icon': Icons.history,
        'route': AppRoutes.formerMinisters
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: links.length,
      itemBuilder: (context, index) {
        final link = links[index];
        return Card(
          child: InkWell(
            onTap: () => context.go(link['route'] as String),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  link['icon'] as IconData,
                  size: 32,
                  color: AppColors.islamicGreen,
                ),
                const SizedBox(height: 8),
                Text(
                  link['title'] as String,
                  style: AppTextStyles.titleSmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نبذة عن الوزارة',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'وزارة الأوقاف والشؤون الدينية الفلسطينية هي الجهة المسؤولة عن إدارة وتنظيم شؤون المساجد والأوقاف الإسلامية في دولة فلسطين.',
                  style: AppTextStyles.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'المهام الرئيسية',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildBulletPoint('الإشراف على المساجد والمصليات في جميع أنحاء فلسطين'),
                _buildBulletPoint('إدارة الأوقاف الإسلامية والحفاظ عليها'),
                _buildBulletPoint('تنظيم شؤون الأئمة والخطباء'),
                _buildBulletPoint('الإشراف على التعليم الديني'),
                _buildBulletPoint('تنظيم مواسم الحج والعمرة'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 18)),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}