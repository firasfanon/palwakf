import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../app/routing/unit_routes.dart';
import '../../../providers/unit_context_provider.dart';
import '../../../widgets/web/web_public_page.dart';
import '../../../widgets/common/custom_app_bar.dart';

class UnitHomeScreen extends ConsumerWidget {
  final String unitSlug;

  const UnitHomeScreen({
    super.key,
    required this.unitSlug,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitAsync = ref.watch(orgUnitBySlugProvider(unitSlug));

    if (kIsWeb) {
      return WebPublicPage(
        title: unitSlug == 'home' ? 'وزارة الأوقاف والشؤون الدينية' : 'المديرية',
        subtitle: 'صفحة ديناميكية بحسب الوحدة المؤسسية',
        child: unitAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const Center(child: Text('تعذّر تحميل بيانات الوحدة')),
          data: (unit) {
            final nameAr = (unit?['name_ar'] ?? '').toString().trim();
            final title = nameAr.isNotEmpty ? nameAr : (unitSlug == 'home' ? 'وزارة الأوقاف والشؤون الدينية' : unitSlug);
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  children: [
                    _navCard(
                      context,
                      title: 'الأخبار',
                      subtitle: 'أخبار وإعلانات الوحدة',
                      icon: Icons.newspaper,
                      onTap: () => context.go(UnitRoutes.news(unitSlug)),
                    ),
                    _navCard(
                      context,
                      title: 'الإعلانات',
                      subtitle: 'التعاميم والقرارات',
                      icon: Icons.campaign,
                      onTap: () => context.go(UnitRoutes.announcements(unitSlug)),
                    ),
                    _navCard(
                      context,
                      title: 'الأنشطة',
                      subtitle: 'الفعاليات والمشاركات',
                      icon: Icons.event,
                      onTap: () => context.go(UnitRoutes.activities(unitSlug)),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: unitSlug == 'home' ? 'الوزارة' : 'المديرية',
        showSearchButton: true,
      ),
      body: unitAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('تعذّر تحميل بيانات الوحدة')),
        data: (unit) {
          final nameAr = (unit?['name_ar'] ?? '').toString().trim();
          final title = nameAr.isNotEmpty ? nameAr : (unitSlug == 'home' ? 'وزارة الأوقاف والشؤون الدينية' : unitSlug);
          return Directionality(
            textDirection: TextDirection.rtl,
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _mobileTile(context, 'الأخبار', Icons.newspaper, () => context.go(UnitRoutes.news(unitSlug))),
                _mobileTile(context, 'الإعلانات', Icons.campaign, () => context.go(UnitRoutes.announcements(unitSlug))),
                _mobileTile(context, 'الأنشطة', Icons.event, () => context.go(UnitRoutes.activities(unitSlug))),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _navCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 360,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusL)),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            child: Row(
              children: [
                Icon(icon, size: 34),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(subtitle, style: TextStyle(color: Colors.grey[700])),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_left),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mobileTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_left),
        onTap: onTap,
      ),
    );
  }
}
