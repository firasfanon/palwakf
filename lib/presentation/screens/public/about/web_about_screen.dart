// lib/presentation/screens/public/about/web_about_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../app/routing/app_routes.dart';
import '../../../widgets/web/web_app_bar.dart';
import '../../../widgets/web/web_container.dart';
import '../../../widgets/web/web_footer.dart';

/// Web-optimized About Screen
/// Features: Horizontal navbar, multi-column layout, footer, responsive design
class WebAboutScreen extends StatelessWidget {
  const WebAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WebAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(context),
            _buildQuickLinksSection(context),
            _buildAboutContentSection(),
            _buildMissionVisionSection(),
            const WebFooter(),
          ],
        ),
      ),
    );
  }

  // Hero Section with gradient background
  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100),
      decoration: const BoxDecoration(
        gradient: AppConstants.islamicGradient,
      ),
      child: WebContainer(
        child: Column(
          children: [
            const Icon(Icons.account_balance, size: 100, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'نعمل على خدمة المساجد والأوقاف الإسلامية في فلسطين',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white.withValues(alpha:0.95),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Quick Links Section - 4 columns
  Widget _buildQuickLinksSection(BuildContext context) {
    final links = [
      {
        'title': 'كلمة الوزير',
        'icon': Icons.person,
        'route': AppRoutes.minister,
        'description': 'اطلع على كلمة معالي الوزير',
        'color': AppConstants.islamicGreen,
      },
      {
        'title': 'الرؤية والرسالة',
        'icon': Icons.flag,
        'route': AppRoutes.visionMission,
        'description': 'تعرف على رؤية الوزارة ورسالتها',
        'color': AppConstants.goldenYellow,
      },
      {
        'title': 'الهيكل التنظيمي',
        'icon': Icons.account_tree,
        'route': AppRoutes.structure,
        'description': 'استعرض الهيكل التنظيمي للوزارة',
        'color': AppConstants.info,
      },
      {
        'title': 'الوزراء السابقون',
        'icon': Icons.history,
        'route': AppRoutes.formerMinisters,
        'description': 'تعرف على الوزراء السابقين',
        'color': AppConstants.sageGreen,
      },
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: WebContainer(
        child: Column(
          children: [
            Text(
              'أقسام الوزارة',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.islamicGreen,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: links.map((link) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _buildQuickLinkCard(
                      context: context,
                      icon: link['icon'] as IconData,
                      title: link['title'] as String,
                      description: link['description'] as String,
                      route: link['route'] as String,
                      color: link['color'] as Color,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLinkCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required String route,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppConstants.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // About Content Section - 2 columns (60% / 40%)
  Widget _buildAboutContentSection() {
    return Container(
      color: AppColors.surfaceVariant,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: WebContainer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Content (60%)
            Expanded(
              flex: 6,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نبذة عن الوزارة',
                        style: AppTextStyles.displaySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.islamicGreen,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'وزارة الأوقاف والشؤون الدينية الفلسطينية هي الجهة المسؤولة عن إدارة وتنظيم شؤون المساجد والأوقاف الإسلامية في دولة فلسطين.',
                        style: AppTextStyles.headlineSmall.copyWith(
                          height: 1.8,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'المهام الرئيسية',
                        style: AppTextStyles.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.islamicGreen,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildBulletPoint(
                        'الإشراف على المساجد والمصليات في جميع أنحاء فلسطين',
                        Icons.mosque,
                      ),
                      _buildBulletPoint(
                        'إدارة الأوقاف الإسلامية والحفاظ عليها',
                        Icons.landscape,
                      ),
                      _buildBulletPoint(
                        'تنظيم شؤون الأئمة والخطباء',
                        Icons.people,
                      ),
                      _buildBulletPoint(
                        'الإشراف على التعليم الديني',
                        Icons.school,
                      ),
                      _buildBulletPoint(
                        'تنظيم مواسم الحج والعمرة',
                        Icons.flight,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 30),

            // Sidebar (40%)
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _buildStatisticsCard(),
                  const SizedBox(height: 20),
                  _buildContactCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppConstants.islamicGreen.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppConstants.islamicGreen,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                text,
                style: AppTextStyles.titleMedium.copyWith(height: 1.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final stats = [
      {'label': 'مسجد', 'value': '1,250', 'icon': Icons.mosque},
      {'label': 'أرض وقفية', 'value': '850', 'icon': Icons.landscape},
      {'label': 'إمام وخطيب', 'value': '3,200', 'icon': Icons.people},
      {'label': 'نشاط سنوي', 'value': '450', 'icon': Icons.event},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: AppConstants.islamicGreen),
                const SizedBox(width: 12),
                Text(
                  'إحصائيات سريعة',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...stats.map((stat) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppConstants.islamicGreen.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        stat['icon'] as IconData,
                        color: AppConstants.islamicGreen,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat['value'] as String,
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppConstants.islamicGreen,
                            ),
                          ),
                          Text(
                            stat['label'] as String,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppConstants.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppConstants.islamicGradient,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.contact_phone, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Text(
                  'تواصل معنا',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildContactItem(
              icon: Icons.location_on,
              text: 'رام الله - فلسطين\nشارع الإرسال',
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              icon: Icons.phone,
              text: '+970-2-2406340',
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              icon: Icons.email,
              text: 'info@awqaf.ps',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // Mission & Vision Section
  Widget _buildMissionVisionSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: WebContainer(
        child: Row(
          children: [
            Expanded(
              child: _buildMissionVisionCard(
                title: 'رؤيتنا',
                icon: Icons.visibility,
                content:
                'أن نكون المرجع الديني الأول في فلسطين، نساهم في بناء مجتمع ملتزم بالقيم الإسلامية الأصيلة.',
                color: AppConstants.islamicGreen,
              ),
            ),
            const SizedBox(width: 30),
            Expanded(
              child: _buildMissionVisionCard(
                title: 'رسالتنا',
                icon: Icons.flag,
                content:
                'تقديم خدمات دينية متميزة للمجتمع الفلسطيني من خلال إدارة فعالة للمساجد والأوقاف والحفاظ على التراث الإسلامي.',
                color: AppConstants.goldenYellow,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionVisionCard({
    required String title,
    required IconData icon,
    required String content,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: AppTextStyles.titleMedium.copyWith(
                height: 1.8,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}