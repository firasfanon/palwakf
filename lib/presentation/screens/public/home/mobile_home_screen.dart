// lib/presentation/screens/public/mobile_home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../../app/routing/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../widgets/common/bottom_nav_bar.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/home/activities_section.dart';
import '../../../widgets/home/announcements_section.dart';
import '../../../widgets/home/hero_slider.dart';

import '../../../widgets/home/news_section.dart';
import '../../../widgets/home/services_section.dart';
import '../../../widgets/home/stats_section.dart';




/// Mobile-optimized Home Screen
/// Features: Bottom navigation, vertical scrolling, stacked sections
class MobileHomeScreen extends ConsumerStatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  ConsumerState<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends ConsumerState<MobileHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'وزارة الأوقاف والشؤون الدينية',
        showBackButton: false,
        showUserProfile: true,
        showGreeting: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 300),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  const HeroSlider(),
                  _buildMinisterSection(),
                  const StatsSection(),
                  const AnnouncementsSection(),
                  const NewsSection(),
                  const ServicesSection(),
                  const ActivitiesSection(),
                  _buildQuickLinksSection(),
                  _buildContactSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  void _onBottomNavTap(int index) {
    setState(() => _currentIndex = index);

    switch (index) {
      case 0: break; // Already on home
      case 1: context.go(AppRoutes.news); break;
      case 2: context.go(AppRoutes.services); break;
      case 3: context.go(AppRoutes.mosques); break;
      case 4: context.go(AppRoutes.about); break;
    }
  }

  Widget _buildMinisterSection() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            decoration: const BoxDecoration(
              gradient: AppConstants.islamicGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppConstants.radiusL),
                topRight: Radius.circular(AppConstants.radiusL),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  'كلمة معالي الوزير',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppConstants.islamicGreen, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(Icons.person, size: 40, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'د. محمود الهباش',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.islamicGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'وزير الأوقاف والشؤون الدينية',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'نرحب بكم في موقع وزارة الأوقاف والشؤون الدينية الفلسطينية...',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: AppConstants.paddingM,
              right: AppConstants.paddingM,
              bottom: AppConstants.paddingM,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => context.go(AppRoutes.minister),
                child: const Text('اقرأ المزيد'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinksSection() {
    final quickLinks = [
      {'title': 'دليل المساجد', 'icon': Icons.mosque, 'route': AppRoutes.mosques, 'color': AppConstants.islamicGreen},
      {'title': 'الخدمات الإلكترونية', 'icon': Icons.computer, 'route': AppRoutes.eservices, 'color': AppConstants.goldenYellow},
      {'title': 'المشاريع', 'icon': Icons.construction, 'route': AppRoutes.projects, 'color': AppConstants.info},
      {'title': 'اتصل بنا', 'icon': Icons.contact_phone, 'route': AppRoutes.contact, 'color': AppConstants.sageGreen},
    ];

    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'روابط سريعة',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppConstants.islamicGreen,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: quickLinks.length,
            itemBuilder: (context, index) {
              final link = quickLinks[index];
              return GestureDetector(
                onTap: () => context.go(link['route'] as String),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    border: Border.all(color: (link['color'] as Color).withValues(alpha:0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: link['color'] as Color,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(AppConstants.radiusM),
                            bottomRight: Radius.circular(AppConstants.radiusM),
                          ),
                        ),
                        child: Icon(link['icon'] as IconData, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          link['title'] as String,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppConstants.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingM),
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        gradient: AppConstants.islamicGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.contact_phone, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'تواصل معنا',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildContactItem(
            icon: Icons.location_on,
            title: 'العنوان',
            content: 'رام الله - فلسطين\nشارع الإرسال - مجمع الوزارات',
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.phone,
            title: 'الهاتف',
            content: '+970-2-2406340',
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            icon: Icons.email,
            title: 'البريد الإلكتروني',
            content: 'info@awqaf.ps',
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () => context.go(AppRoutes.contact),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppConstants.islamicGreen,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text('اتصل بنا'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white.withValues(alpha:0.9), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha:0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}