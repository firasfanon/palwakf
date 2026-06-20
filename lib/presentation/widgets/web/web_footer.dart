// lib/presentation/widgets/web/web_footer.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../app/routing/app_routes.dart';
import 'web_container.dart';

/// Web Footer with sitemap and contact information.
///
/// Platform 12 closure note:
/// The footer is rendered inside the public shell and can be constrained by
/// browser DevTools. The layout must therefore never rely on a single fixed
/// horizontal row for legal/copyright actions.
class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  static const double _compactFooterBreakpoint = 760;
  static const double _stackedSectionsBreakpoint = 860;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppConstants.onSurface,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: WebContainer(
        child: Column(
          children: [
            _buildResponsiveFooterSections(context),
            const SizedBox(height: 40),
            const Divider(color: Colors.white24),
            const SizedBox(height: 20),
            _buildResponsiveCopyright(context),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveFooterSections(BuildContext context) {
    final sections = <Widget>[
      _buildFooterSection(
        context,
        title: 'عن الوزارة',
        items: [
          {'label': 'كلمة الوزير', 'route': AppRoutes.minister},
          {'label': 'الرؤية والرسالة', 'route': AppRoutes.visionMission},
          {'label': 'الهيكل التنظيمي', 'route': AppRoutes.structure},
          {'label': 'الوزراء السابقون', 'route': AppRoutes.formerMinisters},
        ],
      ),
      _buildFooterSection(
        context,
        title: 'الخدمات',
        items: [
          {'label': 'الخدمات الإلكترونية', 'route': AppRoutes.eservices},
          {'label': 'دليل المساجد', 'route': AppRoutes.mosques},
          {'label': 'الأنشطة والفعاليات', 'route': AppRoutes.activities},
          {'label': 'المشاريع', 'route': AppRoutes.projects},
        ],
      ),
      _buildFooterSection(
        context,
        title: 'الأخبار والإعلانات',
        items: [
          {'label': 'الأخبار', 'route': AppRoutes.news},
          {'label': 'الإعلانات', 'route': AppRoutes.announcements},
        ],
      ),
      _buildContactSection(context),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        if (maxWidth < _stackedSectionsBreakpoint) {
          final itemWidth = maxWidth < 560 ? maxWidth : (maxWidth - 24) / 2;
          return Wrap(
            spacing: 24,
            runSpacing: 32,
            alignment: WrapAlignment.start,
            children: sections
                .map((section) => SizedBox(width: itemWidth, child: section))
                .toList(growable: false),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: sections
              .map(
                (section) => Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 24),
                    child: section,
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  Widget _buildFooterSection(
    BuildContext context, {
    required String title,
    required List<Map<String, String>> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => context.go(item['route']!),
              child: Text(
                item['label']!,
                style: const TextStyle(color: Colors.white70, fontSize: 15),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'تواصل معنا',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildContactItem(Icons.location_on, 'رام الله - فلسطين'),
        const SizedBox(height: 12),
        _buildContactItem(Icons.phone, '+970-2-2406340'),
        const SizedBox(height: 12),
        _buildContactItem(Icons.email, 'info@awqaf.ps'),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildSocialIcon(Icons.facebook, 'https://facebook.com'),
            _buildSocialIcon(Icons.public, 'https://twitter.com'),
            _buildSocialIcon(Icons.video_library, 'https://youtube.com'),
          ],
        ),
      ],
    );
  }

  Widget _buildResponsiveCopyright(BuildContext context) {
    final copyright = Text(
      '© 2025 وزارة الأوقاف والشؤون الدينية الفلسطينية. جميع الحقوق محفوظة.',
      textAlign: TextAlign.center,
      softWrap: true,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.white70,
      ),
    );

    final policyActions = Wrap(
      spacing: 8,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        TextButton(
          onPressed: () {},
          child: const Text(
            'سياسة الخصوصية',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        TextButton(
          onPressed: () {},
          child: const Text(
            'شروط الاستخدام',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _compactFooterBreakpoint) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              copyright,
              const SizedBox(height: 12),
              policyActions,
            ],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: copyright),
            const SizedBox(width: 16),
            Flexible(child: policyActions),
          ],
        );
      },
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, String url) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white70, size: 20),
        onPressed: () {
          // Open URL.
        },
        padding: EdgeInsets.zero,
      ),
    );
  }
}
