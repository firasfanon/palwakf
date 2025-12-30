import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/web/web_public_page.dart';

class FormerMinistersScreen extends StatelessWidget {
  const FormerMinistersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebPublicPage(
        title: 'الوزراء السابقون',
        subtitle: 'توثيق موجز لتعاقب الوزراء ودورهم في تطوير الوزارة',
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIntroSection(),
              const SizedBox(height: 24),
              ..._getFormerMinisters().map((minister) => _buildMinisterCard(minister)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'الوزراء السابقون'),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          _buildIntroSection(),
          const SizedBox(height: 24),
          ..._getFormerMinisters().map((minister) => _buildMinisterCard(minister)),
        ],
      ),
    );
  }

  Widget _buildIntroSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تاريخ الوزارة',
              style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'تعاقب على إدارة وزارة الأوقاف والشؤون الدينية عدد من الوزراء الذين ساهموا في تطوير عمل الوزارة وخدمة المساجد والأوقاف الإسلامية.',
              style: AppTextStyles.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinisterCard(Map<String, dynamic> minister) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.islamicGreen.withValues(alpha:0.1),
              child: Text(
                minister['name'].toString().split(' ')[0][0] +
                    minister['name'].toString().split(' ').last[0],
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.islamicGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    minister['name'],
                    style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'فترة الوزارة: ${minister['period']}',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    minister['description'],
                    style: AppTextStyles.bodyMedium,
                  ),
                  if (minister['achievements'] != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      'أبرز الإنجازات:',
                      style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...List<String>.from(minister['achievements']).map(
                          (achievement) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 16)),
                            Expanded(child: Text(achievement, style: AppTextStyles.bodySmall)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFormerMinisters() {
    return [
      {
        'name': 'د. يوسف سلامة',
        'period': '2019 - 2023',
        'description': 'عمل على تطوير البنية التحتية للمساجد وتحديث الأنظمة الإلكترونية',
        'achievements': [
          'إطلاق نظام إلكتروني لإدارة المساجد',
          'افتتاح 25 مسجداً جديداً',
          'تدريب 500 إمام وخطيب',
        ],
      },
      {
        'name': 'الشيخ محمود الهباش',
        'period': '2013 - 2019',
        'description': 'ركز على تعزيز دور الوزارة في المجتمع الفلسطيني',
        'achievements': [
          'توسيع برامج التعليم الديني',
          'تعزيز العلاقات مع المؤسسات الدينية الدولية',
          'ترميم المساجد التاريخية',
        ],
      },
    ];
  }
}