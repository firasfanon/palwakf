// lib/presentation/widgets/web/web_footer.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../app/routing/app_routes.dart';
import 'web_container.dart';

/// Web Footer with sitemap and contact information
class WebFooter extends StatelessWidget {
  const WebFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppConstants.onSurface,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 40),
      child: WebContainer(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // About Section
                Expanded(
                  child: _buildFooterSection(
                    context,
                    title: 'عن الوزارة',
                    items: [
                      {'label': 'كلمة الوزير', 'route': AppRoutes.minister},
                      {'label': 'الرؤية والرسالة', 'route': AppRoutes.visionMission},
                      {'label': 'الهيكل التنظيمي', 'route': AppRoutes.structure},
                      {'label': 'الوزراء السابقون', 'route': AppRoutes.formerMinisters},
                    ],
                  ),
                ),

                // Services Section
                Expanded(
                  child: _buildFooterSection(
                    context,
                    title: 'الخدمات',
                    items: [
                      {'label': 'الخدمات الإلكترونية', 'route': AppRoutes.eservices},
                      {'label': 'دليل المساجد', 'route': AppRoutes.mosques},
                      {'label': 'الأنشطة والفعاليات', 'route': AppRoutes.activities},
                      {'label': 'المشاريع', 'route': AppRoutes.projects},
                    ],
                  ),
                ),

                // News Section
                Expanded(
                  child: _buildFooterSection(
                    context,
                    title: 'الأخبار والإعلانات',
                    items: [
                      {'label': 'الأخبار', 'route': AppRoutes.news},
                      {'label': 'الإعلانات', 'route': AppRoutes.announcements},
                    ],
                  ),
                ),

                // Contact Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      Row(
                        children: [
                          _buildSocialIcon(Icons.facebook, 'https://facebook.com'),
                          const SizedBox(width: 12),
                          _buildSocialIcon(Icons.public, 'https://twitter.com'),
                          const SizedBox(width: 12),
                          _buildSocialIcon(Icons.video_library, 'https://youtube.com'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
            const Divider(color: Colors.white24),
            const SizedBox(height: 20),

            // Copyright
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '© 2025 وزارة الأوقاف والشؤون الدينية الفلسطينية. جميع الحقوق محفوظة.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'سياسة الخصوصية',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    const SizedBox(width: 20),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'شروط الاستخدام',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterSection(
      BuildContext context, {
        required String title,
        required List<Map<String, String>> items,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => context.go(item['route']!),
            child: Text(
              item['label']!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          ),
        )),
      ],
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
          // Open URL
        },
        padding: EdgeInsets.zero,
      ),
    );
  }
}