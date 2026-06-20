import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/app/routing/unit_routes.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/data/models/media_gallery_item.dart';
import 'package:waqf/presentation/providers/friday_sermons_provider.dart';
import 'package:waqf/presentation/providers/unit_dashboard_preview_providers.dart';
import 'package:waqf/presentation/providers/theme_provider.dart';
import 'package:waqf/presentation/widgets/home/breaking_news_slider.dart';
import 'package:waqf/presentation/widgets/home/hero_slider.dart';
import 'package:waqf/presentation/widgets/home/media_gallery_section.dart';
import 'package:waqf/presentation/widgets/home/minister_word_section.dart';
import 'package:waqf/presentation/widgets/home/stats_section.dart';
import '../theme/pwf_home_tokens.dart';
import '../widgets/pwf_eservices_section.dart';
import '../widgets/pwf_important_links_section.dart';
import '../widgets/pwf_prayer_times_section.dart';

/// Web homepage adopting the new HTML visual identity.
///
/// This screen is intentionally built using isolated names (Pwf*) to avoid
/// clashes with existing home widgets/screens while we migrate the UI.
///
/// It reuses the current DB-driven sections (Hero, Breaking, Stats, Galleries,
/// Minister word, and preview providers) and wraps them with the new layout.
class PwfWebHomeScreen extends ConsumerWidget {
  final String unitSlug;
  final String? unitTitle;

  const PwfWebHomeScreen({super.key, this.unitSlug = 'home', this.unitTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = (unitTitle ?? '').trim();
    final isHome = unitSlug == 'home';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: PwfHomeTokens.backgroundColor,
        body: Stack(
          children: [
            // Background ornaments are handled later (Flutter equivalent to the HTML patterns).
            SingleChildScrollView(
              child: Column(
                children: [
                  _TopBar(unitSlug: unitSlug),
                  _Header(unitSlug: unitSlug, unitTitle: title),
                  _NavBar(unitSlug: unitSlug),

                  // Hero + Breaking (DB-driven)
                  HeroSlider(unitSlug: unitSlug),
                  const SizedBox(height: 6),
                  BreakingNewsSlider(unitSlug: unitSlug),

                  _PageContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isHome && title.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            title,
                            style: PwfHomeTokens.sectionTitleText(
                              context,
                            ).copyWith(color: PwfHomeTokens.primaryColor),
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (isHome) ...[
                          const SizedBox(height: 6),
                          const _SectionTitle('كلمة الوزير'),
                          const SizedBox(height: 10),
                          const _Card(child: MinisterWordSection(maxLines: 4)),
                          const SizedBox(height: 18),
                        ],
                        const _SectionTitle('إحصائيات'),
                        const SizedBox(height: 10),
                        const _Card(child: StatsSection()),
                        const SizedBox(height: 18),
                        const _SectionTitle('بوابة الخدمات الإلكترونية'),
                        const SizedBox(height: 10),
                        _Card(child: PwfEServicesSection(unitSlug: unitSlug)),
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Expanded(
                              child: _Card(child: PwfPrayerTimesSection()),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _Card(child: PwfImportantLinksSection()),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _NewsAnnouncementsActivitiesRow(unitSlug: unitSlug),
                        const SizedBox(height: 18),
                        const _SectionTitle('معرض الوسائط'),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _Card(
                                child: MediaGallerySection(
                                  title: 'معرض الصور',
                                  unitSlug: unitSlug,
                                  mediaType: MediaType.photo,
                                  previewLimit: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _Card(
                                child: MediaGallerySection(
                                  title: 'معرض الفيديو',
                                  unitSlug: unitSlug,
                                  mediaType: MediaType.video,
                                  previewLimit: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const _SectionTitle('خطبة الجمعة'),
                        const SizedBox(height: 10),
                        _FridaySermonPreview(unitSlug: unitSlug),
                        const SizedBox(height: 26),
                      ],
                    ),
                  ),

                  const _Footer(),
                ],
              ),
            ),

            // Scroll-to-top button (HTML equivalent)
            Positioned(
              left: 16,
              bottom: 16,
              child: FloatingActionButton(
                heroTag: 'pwf_scroll_top',
                backgroundColor: PwfHomeTokens.primaryColor,
                onPressed: () {
                  Scrollable.ensureVisible(
                    context,
                    duration: const Duration(milliseconds: 300),
                    alignment: 0,
                  );
                },
                child: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageContainer extends StatelessWidget {
  final Widget child;

  const _PageContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: child,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PwfHomeTokens.cardBackgroundColor,
        borderRadius: BorderRadius.circular(PwfHomeTokens.radius),
        boxShadow: PwfHomeTokens.cardShadow,
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 22,
          decoration: BoxDecoration(
            color: PwfHomeTokens.secondaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(text, style: PwfHomeTokens.sectionTitleText(context)),
      ],
    );
  }
}

class _TopBar extends ConsumerWidget {
  final String unitSlug;

  const _TopBar({required this.unitSlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: PwfHomeTokens.primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 8,
              children: [
                Wrap(
                  spacing: 8,
                  children: [
                    _TopBarBtn(
                      label: 'تكبير الخط',
                      icon: Icons.text_fields,
                      onTap: () => ref
                          .read(fontSizeProvider.notifier)
                          .increaseFontSize(),
                    ),
                    _TopBarBtn(
                      label: 'تبديل التباين',
                      icon: Icons.visibility,
                      onTap: () {
                        // Placeholder: high contrast mode will be wired to a provider
                        // once the theme system is extended.
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('قيد الربط: التباين العالي'),
                          ),
                        );
                      },
                    ),
                    _TopBarBtn(
                      label: 'وضع القراءة',
                      icon: Icons.menu_book,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('قيد الربط: وضع القراءة'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                Wrap(
                  spacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _LangPill(current: 'العربية', other: 'English'),
                    TextButton.icon(
                      onPressed: () => context.go(AppRoutes.underConstruction),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: PwfHomeTokens.secondaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      icon: const Icon(Icons.support_agent, size: 18),
                      label: const Text('الشكاوى'),
                    ),
                    IconButton(
                      tooltip: 'تبديل الوضع',
                      onPressed: () =>
                          ref.read(themeModeProvider.notifier).toggleTheme(),
                      icon: const Icon(Icons.dark_mode, color: Colors.white),
                    ),
                    IconButton(
                      tooltip: 'إسلامي',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('قيد الربط: الثيم الإسلامي'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.mosque, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBarBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _TopBarBtn({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

class _LangPill extends StatelessWidget {
  final String current;
  final String other;

  const _LangPill({required this.current, required this.other});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangBtn(text: current, isActive: true),
          _LangBtn(text: other, isActive: false),
        ],
      ),
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String text;
  final bool isActive;

  const _LangBtn({required this.text, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String unitSlug;
  final String unitTitle;

  const _Header({required this.unitSlug, required this.unitTitle});

  @override
  Widget build(BuildContext context) {
    final title = unitSlug == 'home'
        ? 'وزارة الأوقاف والشؤون الدينية'
        : (unitTitle.isNotEmpty ? unitTitle : 'المديرية');

    return Container(
      color: PwfHomeTokens.cardBackgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 12,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      AppConstants.appLogo,
                      width: 46,
                      height: 46,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'دولة فلسطين',
                          style: TextStyle(
                            color: PwfHomeTokens.grayColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 320,
                      child: TextField(
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          hintText: 'بحث داخل المنصة...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: PwfHomeTokens.backgroundColor,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(
                              color: PwfHomeTokens.grayColor.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(999),
                            borderSide: BorderSide(
                              color: PwfHomeTokens.grayColor.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () => context.go(AppRoutes.login),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PwfHomeTokens.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      icon: const Icon(Icons.lock_outline, size: 18),
                      label: const Text('دخول الموظفين'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBar extends StatelessWidget {
  final String unitSlug;

  const _NavBar({required this.unitSlug});

  @override
  Widget build(BuildContext context) {
    final items = <_NavItem>[
      _NavItem(
        'الرئيسية',
        () => context.go(UnitRoutes.home(unitSlug)),
      ),
      _NavItem('الأخبار', () => context.go(UnitRoutes.news(unitSlug))),
      _NavItem(
        'الإعلانات',
        () => context.go(UnitRoutes.announcements(unitSlug)),
      ),
      _NavItem('الأنشطة', () => context.go(UnitRoutes.activities(unitSlug))),
      _NavItem('الخدمات', () => context.go(AppRoutes.services)),
      _NavItem('الخدمات الإلكترونية', () => context.go(AppRoutes.eservices)),
      _NavItem('اتصل بنا', () => context.go(AppRoutes.contact)),
    ];

    return Container(
      color: PwfHomeTokens.primaryColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                for (final item in items)
                  TextButton(
                    onPressed: item.onTap,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String title;
  final VoidCallback onTap;

  _NavItem(this.title, this.onTap);
}

class _NewsAnnouncementsActivitiesRow extends ConsumerWidget {
  final String unitSlug;

  const _NewsAnnouncementsActivitiesRow({required this.unitSlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(
      unitLatestNewsPreviewProvider(
        UnitPreviewParams(unitSlug: unitSlug, limit: 4),
      ),
    );
    final annAsync = ref.watch(
      unitLatestAnnouncementsPreviewProvider(
        UnitPreviewParams(unitSlug: unitSlug, limit: 4),
      ),
    );
    final actAsync = ref.watch(
      unitUpcomingActivitiesPreviewProvider(
        UnitPreviewParams(unitSlug: unitSlug, limit: 4),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _Card(
            child: _PreviewList(
              title: 'الأخبار',
              onViewAll: () => context.go(UnitRoutes.news(unitSlug)),
              asyncItems: newsAsync,
              itemBuilder: (item) {
                final a = item;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    a.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    a.excerpt,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () =>
                      context.go(UnitRoutes.newsDetail(unitSlug, a.publicDetailId)),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Card(
            child: _PreviewList(
              title: 'الإعلانات',
              onViewAll: () => context.go(UnitRoutes.announcements(unitSlug)),
              asyncItems: annAsync,
              itemBuilder: (item) {
                final a = item;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    a.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    a.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Card(
            child: _PreviewList(
              title: 'الأنشطة',
              onViewAll: () => context.go(UnitRoutes.activities(unitSlug)),
              asyncItems: actAsync,
              itemBuilder: (item) {
                final a = item;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    a.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    a.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewList<T> extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;
  final AsyncValue<List<T>> asyncItems;
  final Widget Function(T item) itemBuilder;

  const _PreviewList({
    required this.title,
    required this.onViewAll,
    required this.asyncItems,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return asyncItems.when(
      loading: () => const SizedBox(
        height: 140,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox(
        height: 140,
        child: Center(child: Text('تعذر التحميل')),
      ),
      data: (items) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton(onPressed: onViewAll, child: const Text('عرض الكل')),
              ],
            ),
            const Divider(height: 1),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('لا توجد عناصر'),
              )
            else
              ...items.take(4).map(itemBuilder),
          ],
        );
      },
    );
  }
}

class _FridaySermonPreview extends ConsumerWidget {
  final String unitSlug;

  const _FridaySermonPreview({required this.unitSlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(publicFridaySermonsProvider);

    return _Card(
      child: async.when(
        loading: () => const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const SizedBox(
          height: 120,
          child: Center(child: Text('تعذر تحميل الخطبة')),
        ),
        data: (items) {
          final latest = items.isNotEmpty ? items.first : null;
          if (latest == null) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('لا توجد خطب منشورة حاليًا'),
            );
          }
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.mic, color: AppConstants.royalRed),
            // FridaySermon model is bilingual; prefer Arabic for RTL web home.
            title: Text(latest.titleAr),
            subtitle: Text(
              latest.summaryAr ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: TextButton(
              onPressed: () => context.go(AppRoutes.fridaySermon),
              child: const Text('فتح'),
            ),
          );
        },
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: PwfHomeTokens.darkColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
            child: Wrap(
              spacing: 28,
              runSpacing: 18,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'وزارة الأوقاف والشؤون الدينية',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'العنوان: ${AppConstants.address.replaceAll("\\n", " - ")}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      'هاتف: ${AppConstants.phoneNumber}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      'بريد: ${AppConstants.email}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'روابط',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _FooterLink('عن الوزارة', AppRoutes.about),
                    _FooterLink('الخدمات', AppRoutes.services),
                    _FooterLink('اتصل بنا', AppRoutes.contact),
                    _FooterLink('قيد الإنشاء', AppRoutes.underConstruction),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final String route;

  const _FooterLink(this.label, this.route);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
        ),
      ),
    );
  }
}
