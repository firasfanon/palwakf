import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../theme/pwf_home_tokens.dart';
import 'pwf_hover_card.dart';
import 'shared/pwf_text_link_button.dart';

class PwfImportantLinksSection extends StatelessWidget {
  const PwfImportantLinksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final links = <_LinkItem>[
      const _LinkItem(
        title: 'الموقع الرسمي للوزارة',
        kind: _LinkKind.external,
        value: AppConstants.website,
      ),
      const _LinkItem(
        title: 'فيسبوك الوزارة',
        kind: _LinkKind.external,
        value: AppConstants.facebookUrl,
      ),
      const _LinkItem(
        title: 'يوتيوب الوزارة',
        kind: _LinkKind.external,
        value: AppConstants.youtubeUrl,
      ),
      const _LinkItem(
        title: 'منصة الحج والعمرة',
        kind: _LinkKind.route,
        value: AppRoutes.underConstruction,
      ),
      const _LinkItem(
        title: 'القرآن الكريم',
        kind: _LinkKind.route,
        value: '/quran',
      ),
      const _LinkItem(
        title: 'الشكاوى',
        kind: _LinkKind.route,
        value: '/complaints',
      ),
      const _LinkItem(
        title: 'المساعد الذكي (Chat)',
        kind: _LinkKind.route,
        value: '/admin/chatbot',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'روابط مهمة',
                style: PwfHomeTokens.sectionTitleText(context),
              ),
            ),
            TextButton(
              onPressed: () => context.go(AppRoutes.underConstruction),
              child: const Text('المزيد'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 780;
            final crossAxisCount = isNarrow ? 1 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: isNarrow ? 4.6 : 4.2,
              ),
              itemCount: links.length,
              itemBuilder: (_, index) {
                final item = links[index];
                return PwfHoverCard(
                  onTap: () => _open(context, item),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: PwfHomeTokens.primaryColor.withValues(
                            alpha: 0.08,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _iconFor(item),
                          color: PwfHomeTokens.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      const Icon(Icons.chevron_left),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  IconData _iconFor(_LinkItem item) {
    if (item.kind == _LinkKind.external) return Icons.open_in_new;
    return Icons.link;
  }

  Future<void> _open(BuildContext context, _LinkItem item) async {
    if (item.kind == _LinkKind.route) {
      context.go(item.value);
      return;
    }
    // Default behavior is enough; avoid requiring extra enums/imports.
    final ok = await launchUrlString(item.value);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تعذر فتح الرابط')));
    }
  }
}

enum _LinkKind { external, route }

class _LinkItem {
  final String title;
  final _LinkKind kind;
  final String value;

  const _LinkItem({
    required this.title,
    required this.kind,
    required this.value,
  });
}
