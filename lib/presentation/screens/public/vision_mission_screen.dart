import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/web/web_public_page.dart';

class VisionMissionScreen extends StatelessWidget {
  const VisionMissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final blocks = <Widget>[
      _buildVisionCard(context),
      const SizedBox(height: 24),
      _buildMissionCard(context),
      const SizedBox(height: 24),
      _buildValuesCard(context),
    ];

    // IMPORTANT: WebPublicPage already scrolls the whole page.
    // Avoid nesting ListView inside it (causes white/red screens and loops on Web).
    if (kIsWeb) {
      return WebPublicPage(
        title: 'الرؤية والرسالة',
        subtitle: 'إطار موجز يوضح توجهات الوزارة وأهدافها',
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: blocks,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'الرؤية والرسالة'),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: blocks,
      ),
    );
  }

  Widget _buildVisionCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.visibility, color: AppColors.islamicGreen, size: 32),
                const SizedBox(width: 12),
                Text(
                  'رؤيتنا',
                  style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'تعزيز دور الوقف في التنمية المجتمعية وترسيخ قيم العدل والتكافل.',
              style: AppTextStyles.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag, color: AppColors.islamicGreen, size: 32),
                const SizedBox(width: 12),
                Text(
                  'رسالتنا',
                  style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'إدارة وتنمية الأوقاف بكفاءة وشفافية، وتقديم خدمات دينية واجتماعية بجودة عالية.',
              style: AppTextStyles.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValuesCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.islamicGreen, size: 32),
                const SizedBox(width: 12),
                Text(
                  'قيمنا',
                  style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _Bullet(text: 'الشفافية والمساءلة'),
            const _Bullet(text: 'العدالة وتكافؤ الفرص'),
            const _Bullet(text: 'خدمة المجتمع'),
            const _Bullet(text: 'الحفاظ على المال الوقفي'),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
