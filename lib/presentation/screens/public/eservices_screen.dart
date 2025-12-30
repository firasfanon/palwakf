import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/web/web_public_page.dart';

class EServicesScreen extends StatelessWidget {
  const EServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _buildServiceCard(
        title: 'خدمات المساجد',
        description: 'إدارة بيانات المساجد والمشاريع والخدمات ذات الصلة.',
        icon: Icons.mosque,
      ),
      _buildServiceCard(
        title: 'خدمات الأوقاف',
        description: 'خدمات متعلقة بالأراضي الوقفية والإدارة والاستثمار.',
        icon: Icons.account_balance,
      ),
      _buildServiceCard(
        title: 'خدمات الزكاة',
        description: 'التقديم للاستفادة، والاستعلام، والخدمات المرتبطة.',
        icon: Icons.volunteer_activism,
      ),
      _buildServiceCard(
        title: 'خدمات الحج والعمرة',
        description: 'متابعة التسجيلات، والإرشادات، والمعلومات الرسمية.',
        icon: Icons.flight_takeoff,
      ),
    ];

    // IMPORTANT: WebPublicPage already scrolls the whole page.
    // Avoid nesting ListView inside it (causes white/red screens and loops on Web).
    if (kIsWeb) {
      return WebPublicPage(
        title: 'الخدمات الإلكترونية',
        subtitle: 'خدمات الوزارة الإلكترونية وروابط النماذج والمعاملات',
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...cards,
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'الخدمات الإلكترونية'),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: cards,
      ),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.islamicGreen.withValues(alpha: 0.12),
          child: Icon(icon, color: AppColors.islamicGreen),
        ),
        title: Text(title, style: AppTextStyles.titleMedium),
        subtitle: Text(description),
        trailing: const Icon(Icons.open_in_new),
        onTap: () {
          // TODO: ربط كل خدمة بصفحة/رابط فعلي حسب متطلبات الوزارة.
        },
      ),
    );
  }
}
