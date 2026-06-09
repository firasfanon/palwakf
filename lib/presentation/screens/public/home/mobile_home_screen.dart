// lib/presentation/screens/public/mobile_home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../app/routing/unit_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/media_gallery_item.dart';
import '../../../widgets/common/bottom_nav_bar.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/home/activities_section.dart';
import '../../../widgets/home/announcements_section.dart';
import '../../../widgets/home/breaking_news_slider.dart';
import '../../../widgets/home/hero_slider.dart';
import '../../../widgets/home/media_gallery_section.dart';
import '../../../widgets/home/minister_word_section.dart';
import '../../../widgets/home/news_section.dart';
import '../../../widgets/home/services_section.dart';
import '../../../widgets/home/stats_section.dart';

/// Mobile-optimized Home Screen
/// Features: Bottom navigation, vertical scrolling, stacked sections
class MobileHomeScreen extends ConsumerStatefulWidget {
  final String unitSlug;
  final String? unitTitle;

  const MobileHomeScreen({super.key, this.unitSlug = 'home', this.unitTitle});

  @override
  ConsumerState<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends ConsumerState<MobileHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final title = (widget.unitTitle ?? '').trim();
    final appTitle = (title.isNotEmpty
        ? title
        : 'وزارة الأوقاف والشؤون الدينية');

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.unitSlug == 'home'
            ? 'وزارة الأوقاف والشؤون الدينية'
            : appTitle,
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
                  HeroSlider(unitSlug: widget.unitSlug),
                  BreakingNewsSlider(unitSlug: widget.unitSlug),
                  if (widget.unitSlug == 'home') const MinisterWordSection(),
                  const StatsSection(),
                  NewsSection(unitSlug: widget.unitSlug),
                  AnnouncementsSection(unitSlug: widget.unitSlug),
                  MediaGallerySection(
                    title: 'معرض الصور',
                    unitSlug: widget.unitSlug,
                    mediaType: MediaType.photo,
                    previewLimit: 10,
                  ),
                  MediaGallerySection(
                    title: 'معرض الفيديو',
                    unitSlug: widget.unitSlug,
                    mediaType: MediaType.video,
                    previewLimit: 10,
                  ),
                  ActivitiesSection(unitSlug: widget.unitSlug),
                  const ServicesSection(),
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
      case 0:
        break; // Already on home
      case 1:
        context.go(UnitRoutes.news(widget.unitSlug));
        break;
      case 2:
        context.go(AppRoutes.services);
        break;
      case 3:
        context.go(AppRoutes.mosques);
        break;
      case 4:
        context.go(AppRoutes.about);
        break;
    }
  }

  Widget _buildQuickLinksSection() {
    final quickLinks = [
      {
        'title': 'دليل المساجد',
        'icon': Icons.mosque,
        'route': AppRoutes.mosques,
        'color': AppConstants.islamicGreen,
      },
      {
        'title': 'الخدمات الإلكترونية',
        'icon': Icons.computer,
        'route': AppRoutes.eservices,
        'color': AppConstants.goldenYellow,
      },
      {
        'title': 'المشاريع',
        'icon': Icons.construction,
        'route': AppRoutes.projects,
        'color': AppConstants.info,
      },
      {
        'title': 'اتصل بنا',
        'icon': Icons.contact_phone,
        'route': AppRoutes.contact,
        'color': AppConstants.sageGreen,
      },
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
                    border: Border.all(
                      color: (link['color'] as Color).withValues(alpha: 0.3),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
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
                        child: Icon(
                          link['icon'] as IconData,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          link['title'] as String,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
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
        Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
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
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
