import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/web/web_public_page.dart';

class MinisterScreen extends StatelessWidget {
  const MinisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return WebPublicPage(
        title: 'كلمة معالي الوزير',
        subtitle: 'رسالة الوزارة ورؤيتها للمسجد والوقف وخدمة المجتمع',
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, c) {
                  final wide = c.maxWidth >= 980;
                  if (!wide) {
                    return Column(
                      children: [
                        _buildMinisterProfile(),
                        const SizedBox(height: 24),
                        _buildMessage(),
                        const SizedBox(height: 24),
                        _buildContactInfo(),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 380,
                        child: Column(
                          children: [
                            _buildMinisterProfile(),
                            const SizedBox(height: 24),
                            _buildContactInfo(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 30),
                      Expanded(child: _buildMessage()),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'كلمة معالي الوزير'),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        children: [
          _buildMinisterProfile(),
          const SizedBox(height: 24),
          _buildMessage(),
          const SizedBox(height: 24),
          _buildContactInfo(),
        ],
      ),
    );
  }

  Widget _buildMinisterProfile() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.islamicGreen.withValues(alpha:0.1),
              child: const Icon(Icons.person, size: 60, color: AppColors.islamicGreen),
            ),
            const SizedBox(height: 16),
            Text(
              'د. محمود الهباش',
              style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'وزير الأوقاف والشؤون الدينية',
              style: AppTextStyles.titleMedium.copyWith(color: AppColors.islamicGreen),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.school, 'دكتوراه في الشريعة الإسلامية'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.work, 'خبرة أكثر من 20 عاماً في العمل الديني'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.book, 'مؤلف عدة كتب في الفقه الإسلامي'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.islamicGreen),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
      ],
    );
  }

  Widget _buildMessage() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.format_quote, color: AppColors.islamicGreen, size: 32),
                const SizedBox(width: 8),
                Text(
                  'كلمة معالي الوزير',
                  style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'بسم الله الرحمن الرحيم',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.islamicGreen,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'إخواني وأخواتي الأعزاء،',
              style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'يسعدني أن أرحب بكم في الموقع الإلكتروني لوزارة الأوقاف والشؤون الدينية الفلسطينية. نسعى في هذه الوزارة إلى خدمة المساجد والأوقاف الإسلامية في جميع أنحاء فلسطين، والعمل على تعزيز القيم الإسلامية السمحة في مجتمعنا.',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 12),
            const Text(
              'إن رسالتنا تتمثل في الحفاظ على المقدسات الإسلامية، وإدارة الأوقاف بكفاءة وشفافية، وتوفير الخدمات الدينية للمواطنين، ونشر الوعي الديني الصحيح.',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 12),
            const Text(
              'نحن ملتزمون بتطوير عمل الوزارة وتحديثه، والاستفادة من التكنولوجيا الحديثة لتسهيل تقديم خدماتنا للمواطنين. كما نعمل على تأهيل وتدريب الأئمة والخطباء ليكونوا قدوة حسنة في مجتمعنا.',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 16),
            Text(
              'د. محمود الهباش',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              'وزير الأوقاف والشؤون الدينية',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'للتواصل مع مكتب الوزير',
              style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.email, color: AppColors.islamicGreen),
              title: Text('minister@awqaf.ps'),
              contentPadding: EdgeInsets.zero,
            ),
            const ListTile(
              leading: Icon(Icons.phone, color: AppColors.islamicGreen),
              title: Text(AppConstants.phoneNumber),
              contentPadding: EdgeInsets.zero,
            ),
            const ListTile(
              leading: Icon(Icons.location_on, color: AppColors.islamicGreen),
              title: Text(AppConstants.address),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}