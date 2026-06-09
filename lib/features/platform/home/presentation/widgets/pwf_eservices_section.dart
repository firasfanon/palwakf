import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/core/constants/app_constants.dart';
import '../theme/pwf_home_tokens.dart';
import 'pwf_hover_card.dart';
import 'shared/pwf_text_link_button.dart';

class PwfEServicesSection extends StatelessWidget {
  final String unitSlug;

  const PwfEServicesSection({super.key, required this.unitSlug});

  @override
  Widget build(BuildContext context) {
    // Reuse existing quick actions as a safe baseline (no new DB dependency).
    final items = AppConstants.quickActions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'بوابة الخدمات الإلكترونية',
                style: PwfHomeTokens.sectionTitleText(context),
              ),
            ),
            PwfTextLinkButton(
              label: 'عرض الكل',
              onPressed: () => context.go(AppRoutes.eservices),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, c) {
            final width = c.maxWidth;
            final crossAxisCount = width >= 1000 ? 4 : (width >= 720 ? 3 : 2);
            final itemWidth =
                (width - ((crossAxisCount - 1) * 12)) / crossAxisCount;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final item in items)
                  SizedBox(
                    width: itemWidth,
                    child: PwfHoverCard(
                      padding: const EdgeInsets.all(14),
                      onTap: () {
                        final route = (item['route'] as String?)?.trim();
                        if (route == null || route.isEmpty) {
                          context.go(AppRoutes.underConstruction);
                          return;
                        }
                        context.go(route);
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: PwfHomeTokens.primaryColor.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: PwfHomeTokens.primaryColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'خدمة إلكترونية',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: PwfHomeTokens.grayColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
