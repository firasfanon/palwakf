// lib/presentation/screens/public/web_home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';
import 'package:waqf/presentation/widgets/home/breaking_news_slider.dart';
import 'package:waqf/presentation/widgets/home/hero_slider.dart';
import 'package:waqf/presentation/widgets/web/web_app_bar.dart';
import 'package:waqf/presentation/widgets/web/web_container.dart';
import 'package:waqf/presentation/widgets/web/web_footer.dart';



/// Web-optimized Home Screen - DATABASE DRIVEN
/// Fetches all content from Supabase
class WebHomeScreen extends ConsumerStatefulWidget {
  const WebHomeScreen({super.key});

  @override
  ConsumerState<WebHomeScreen> createState() => _WebHomeScreenState();
}

class _WebHomeScreenState extends ConsumerState<WebHomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch all section providers
    final ministerState = ref.watch(ministerSectionNotifierProvider);
    final statsState = ref.watch(statisticsSectionNotifierProvider);
    final newsState = ref.watch(newsSectionNotifierProvider);
    final annState = ref.watch(announcementsSectionNotifierProvider);

    return Scaffold(
      appBar: const WebAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section - Fetches from hero_slides table
            _buildHeroSection(),

            const BreakingNewsSlider(),

            // Stats Section - Fetches from homepage_sections table
            _buildStatsSection(statsState.settings),

            // News + Sidebar Layout
            _buildNewsAndSidebar(
              ministerSettings: ministerState.settings,
              newsSettings: newsState.settings,
              announcementsSettings: annState.settings,
            ),

            // Services Section (static for now - can be made dynamic later)
            _buildServicesSection(),

            const WebFooter(),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // HERO SECTION
  // =====================================================
  Widget _buildHeroSection() {
    return const HeroSlider(); // This widget should fetch from DB internally
  }

  // =====================================================
  // STATS SECTION (Database-Driven)
  // =====================================================
  Widget _buildStatsSection(StatisticsSectionSettings? settings) {
    // Default counters if no settings
    final counters = settings?.counters ??
        [
          const StatisticCounter(
            label: 'مسجد',
            value: 1250,
            icon: 'mosque',
            color: '#2D5016',
            target: 1500,
          ),
          const StatisticCounter(
            label: 'أرض وقفية',
            value: 850,
            icon: 'landscape',
            color: '#C4A962',
            target: 1000,
          ),
          const StatisticCounter(
            label: 'إمام وخطيب',
            value: 3200,
            icon: 'people',
            color: '#3B82F6',
            target: 4000,
          ),
          const StatisticCounter(
            label: 'نشاط سنوي',
            value: 450,
            icon: 'event',
            color: '#22C55E',
            target: 500,
          ),
        ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: WebContainer(
        child: Column(
          children: [
            Text(
              'إحصائيات الوزارة',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.islamicGreen,
              ),
            ),

            const SizedBox(height: 20),

            // Dynamic counters from database
            settings?.layout == 'row'
                ? _buildStatsRow(counters, settings)
                : _buildStatsGrid(counters, settings),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
      List<StatisticCounter> counters, StatisticsSectionSettings? settings) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: counters.length > 3 ? 4 : counters.length,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1,
      ),
      itemCount: counters.length,
      itemBuilder: (context, index) {
        final counter = counters[index];
        return _buildStatCard(
          counter: counter,
          showProgress: settings?.showProgress ?? false,
          showTargets: settings?.showTargets ?? false,
        );
      },
    );
  }

  Widget _buildStatsRow(
      List<StatisticCounter> counters, StatisticsSectionSettings? settings) {
    return Row(
      children: counters.map((counter) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _buildStatCard(
              counter: counter,
              showProgress: settings?.showProgress ?? false,
              showTargets: settings?.showTargets ?? false,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatCard({
    required StatisticCounter counter,
    bool showProgress = false,
    bool showTargets = false,
  }) {
    final color = _parseColor(counter.color);
    final icon = _parseIcon(counter.icon);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: color.withValues(alpha:0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 40),
          ),
          const SizedBox(height: 20),

          // Value
          Text(
            counter.value.toString(),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),

          // Label
          Text(
            counter.label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          // Progress bar (if enabled)
          if (showProgress && counter.target > 0) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: counter.value / counter.target,
              backgroundColor: Colors.grey[200],
              color: color,
              minHeight: 6,
            ),
          ],

          // Target (if enabled)
          if (showTargets && counter.target > 0) ...[
            const SizedBox(height: 8),
            Text(
              'الهدف: ${counter.target}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =====================================================
  // NEWS + SIDEBAR (Database-Driven)
  // =====================================================
  Widget _buildNewsAndSidebar({
    MinisterSectionSettings? ministerSettings,
    NewsSectionSettings? newsSettings,
    AnnouncementsSectionSettings? announcementsSettings,
  }) {
    return Container(
      color: AppColors.surfaceVariant,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: WebContainer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // News Section (60%)
            Expanded(
              flex: 6,
              child: _buildNewsSection(newsSettings),
            ),

            const SizedBox(width: 40),

            // Sidebar (40%)
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _buildMinisterCard(ministerSettings),
                  const SizedBox(height: 20),
                  _buildAnnouncementsCard(announcementsSettings),
                  const SizedBox(height: 20),
                  _buildQuickLinksCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsSection(NewsSectionSettings? settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'آخر الأخبار',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.islamicGreen,
              ),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.news),
              child: const Text('عرض جميع الأخبار →'),
            ),
          ],
        ),
        const SizedBox(height: 30),

        // TODO: Fetch actual news from database
        // For now, show sample news (you'll replace this with actual DB fetch)
        ..._getSampleNews(settings?.showCount ?? 3).map(
              (article) => _buildNewsCard(
            article: article,
            showCategories: settings?.showCategories ?? true,
            showViewCounts: settings?.showViewCounts ?? true,
            showDates: settings?.showDates ?? true,
            showExcerpts: settings?.showExcerpts ?? true,
            showImages: settings?.showImages ?? true,
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCard({
    required Map<String, dynamic> article,
    bool showCategories = true,
    bool showViewCounts = true,
    bool showDates = true,
    bool showExcerpts = true,
    bool showImages = true,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: InkWell(
        // IMPORTANT:
        // هذه البطاقة تعتمد على بيانات تجريبية (Map) وليست NewsArticle كاملة.
        // صفحة التفاصيل تعتمد على NewsArticle، لذا لتجنّب شاشة حمراء/بيضاء
        // ننقلك إلى صفحة الأخبار حيث يتم تحميل البيانات الصحيحة.
        onTap: () => context.go(AppRoutes.news),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image (conditional)
              if (showImages) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  child: Container(
                    width: 150,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 40),
                  ),
                ),
                const SizedBox(width: 20),
              ],

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge (conditional)
                    if (showCategories) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppConstants.islamicGreen.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          article['category'] as String,
                          style: const TextStyle(
                            color: AppConstants.islamicGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Title
                    Text(
                      article['title'] as String,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Excerpt (conditional)
                    if (showExcerpts) ...[
                      const SizedBox(height: 8),
                      Text(
                        article['excerpt'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Meta info
                    Row(
                      children: [
                        if (showDates) ...[
                          const Icon(Icons.access_time,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            article['date'] as String,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ],
                        if (showViewCounts && showDates)
                          const SizedBox(width: 20),
                        if (showViewCounts) ...[
                          const Icon(Icons.visibility,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${article['views']}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // MINISTER CARD (Database-Driven)
  // =====================================================
  Widget _buildMinisterCard(MinisterSectionSettings? settings) {
    // Default values if no settings
    final name = settings?.name ?? 'د. محمود الهباش';
    final position = settings?.position ?? 'وزير الأوقاف والشؤون الدينية';
    final message = settings?.message ??
        'نرحب بكم في موقع وزارة الأوقاف والشؤون الدينية الفلسطينية، حيث نعمل على خدمة ديننا الحنيف ومجتمعنا الفلسطيني.';
    final quote = settings?.quote ?? '';
    final showQuote = settings?.showQuote ?? false;
    final messageLink = settings?.messageLink ?? AppRoutes.minister;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
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

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppConstants.islamicGreen.withValues(alpha:0.1),
                  backgroundImage: settings?.imageUrl.isNotEmpty == true
                      ? NetworkImage(settings!.imageUrl)
                      : null,
                  child: settings?.imageUrl.isEmpty ?? true
                      ? const Icon(Icons.person,
                      size: 50, color: AppConstants.islamicGreen)
                      : null,
                ),
                const SizedBox(height: 16),

                // Name
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.islamicGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Position
                Text(
                  position,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppConstants.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Message
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),

                // Quote (conditional)
                if (showQuote && quote.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppConstants.islamicGreen.withValues(alpha:0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        right: BorderSide(
                          color: AppConstants.islamicGreen,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Text(
                      quote,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppConstants.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.go(messageLink),
                  child: const Text('اقرأ المزيد'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ANNOUNCEMENTS CARD (Database-Driven)
  // =====================================================
  Widget _buildAnnouncementsCard(AnnouncementsSectionSettings? settings) {
    final showCount = settings?.showCount ?? 2;
    final showPriorities = settings?.showPriorities ?? true;

    // TODO: Fetch actual announcements from database
    final announcements = _getSampleAnnouncements(showCount);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.campaign, color: AppConstants.islamicGreen),
                const SizedBox(width: 12),
                Text(
                  'إعلانات هامة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Announcements list
          ...announcements.map(
                (ann) => _buildAnnouncementItem(
              title: ann['title'],
              priority: ann['priority'],
              color: ann['color'],
              showPriority: showPriorities,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: TextButton(
                onPressed: () =>
                    context.go(AppRoutes.announcements),
                child: const Text('عرض جميع الإعلانات'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementItem({
    required String title,
    required String priority,
    required Color color,
    bool showPriority = true,
  }) {
    return ListTile(
      leading: showPriority
          ? Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          priority,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : null,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }

  // =====================================================
  // QUICK LINKS CARD (Static)
  // =====================================================
  Widget _buildQuickLinksCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.link, color: AppConstants.islamicGreen),
                const SizedBox(width: 12),
                Text(
                  'روابط سريعة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildQuickLinkItem(
              icon: Icons.mosque,
              title: 'دليل المساجد',
              route: AppRoutes.mosques),
          _buildQuickLinkItem(
              icon: Icons.computer,
              title: 'الخدمات الإلكترونية',
              route: AppRoutes.eservices),
          _buildQuickLinkItem(
              icon: Icons.construction,
              title: 'المشاريع',
              route: AppRoutes.projects),
          _buildQuickLinkItem(
              icon: Icons.contact_phone,
              title: 'اتصل بنا',
              route: AppRoutes.contact),
        ],
      ),
    );
  }

  Widget _buildQuickLinkItem({
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppConstants.islamicGreen.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppConstants.islamicGreen, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => context.go(route),
    );
  }

  // =====================================================
  // SERVICES SECTION (Static)
  // =====================================================
  Widget _buildServicesSection() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: WebContainer(
        child: Column(
          children: [
            Text(
              'خدماتنا',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.islamicGreen,
              ),
            ),
            const SizedBox(height: 40),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.2,
              children: [
                _buildServiceCard(
                    icon: Icons.mosque,
                    title: 'دليل المساجد',
                    route: AppRoutes.mosques),
                _buildServiceCard(
                    icon: Icons.computer,
                    title: 'الخدمات الإلكترونية',
                    route: AppRoutes.eservices),
                _buildServiceCard(
                    icon: Icons.event,
                    title: 'الأنشطة والفعاليات',
                    route: AppRoutes.activities),
                _buildServiceCard(
                    icon: Icons.construction,
                    title: 'المشاريع',
                    route: AppRoutes.projects),
                _buildServiceCard(
                    icon: Icons.article,
                    title: 'الأخبار',
                    route: AppRoutes.news),
                _buildServiceCard(
                    icon: Icons.campaign,
                    title: 'الإعلانات',
                    route: AppRoutes.announcements),
                _buildServiceCard(
                    icon: Icons.info,
                    title: 'عن الوزارة',
                    route: AppRoutes.about),
                _buildServiceCard(
                    icon: Icons.contact_phone,
                    title: 'اتصل بنا',
                    route: AppRoutes.contact),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required IconData icon,
    required String title,
    required String route,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppConstants.islamicGreen.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppConstants.islamicGreen, size: 30),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // HELPER METHODS
  // =====================================================

  /// Parse color from hex string
  Color _parseColor(String hexColor) {
    try {
      return Color(
          int.parse(hexColor.replaceFirst('#', '0xFF').replaceAll(' ', '')));
    } catch (e) {
      return AppConstants.islamicGreen; // Default
    }
  }

  /// Parse icon from string name
  IconData _parseIcon(String iconName) {
    final iconMap = {
      'mosque': Icons.mosque,
      'landscape': Icons.landscape,
      'people': Icons.people,
      'event': Icons.event,
      'building': Icons.business,
      'school': Icons.school,
      'book': Icons.book,
      'money': Icons.attach_money,
    };
    return iconMap[iconName.toLowerCase()] ?? Icons.star;
  }

  // =====================================================
  // SAMPLE DATA (TODO: Replace with actual DB fetch)
  // =====================================================

  List<Map<String, dynamic>> _getSampleNews(int count) {
    final allNews = [
      {
        'title': 'افتتاح مسجد جديد في مدينة رام الله',
        'excerpt':
        'تم افتتاح مسجد جديد في حي الطيرة برام الله بحضور معالي الوزير وجمع من المواطنين',
        'category': 'مساجد',
        'date': 'منذ ساعتين',
        'views': 150,
      },
      {
        'title': 'ندوة حول الوسطية في الإسلام',
        'excerpt':
        'تنظم الوزارة ندوة علمية حول موضوع الوسطية في الإسلام بمشاركة علماء من مختلف البلدان',
        'category': 'فعاليات',
        'date': 'منذ 5 ساعات',
        'views': 89,
      },
      {
        'title': 'دورة تدريبية لأئمة المساجد حول الخطابة',
        'excerpt':
        'تنطلق غداً دورة تدريبية متخصصة لأئمة المساجد حول فن الخطابة والإلقاء',
        'category': 'تعليم',
        'date': 'منذ يوم',
        'views': 67,
      },
    ];
    return allNews.take(count).toList();
  }

  List<Map<String, dynamic>> _getSampleAnnouncements(int count) {
    final allAnnouncements = [
      {
        'title': 'تغيير موعد صلاة الجمعة',
        'priority': 'عاجل',
        'color': AppConstants.error,
      },
      {
        'title': 'دورة تدريبية لأئمة المساجد',
        'priority': 'هام',
        'color': AppConstants.warning,
      },
      {
        'title': 'صيانة دورية للمساجد',
        'priority': 'عادي',
        'color': AppConstants.info,
      },
    ];
    return allAnnouncements.take(count).toList();
  }
}