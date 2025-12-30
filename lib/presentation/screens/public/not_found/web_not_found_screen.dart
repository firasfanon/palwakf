import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routing/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../widgets/web/web_app_bar.dart';
import '../../../widgets/web/web_footer.dart';


class WebNotFoundScreen extends StatelessWidget {
  const WebNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WebAppBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildErrorSection(context),
            _buildSuggestionsSection(context),
            const WebFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorSection(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height *0.9,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppConstants.islamicGreen.withValues(alpha:0.05),
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 404 Number with Islamic decoration
              Stack(
                alignment: Alignment.center,
                children: [
                  // Background decoration
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppConstants.islamicGreen.withValues(alpha:0.1),
                          AppColors.goldenYellow.withValues(alpha:0.1),
                        ],
                      ),
                    ),
                  ),
                  // 404 Text
                  Text(
                    '404',
                    style: TextStyle(
                      fontSize: 120,
                      fontWeight: FontWeight.bold,
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            AppConstants.islamicGreen,
                            AppColors.goldenYellow,
                          ],
                        ).createShader(const Rect.fromLTWH(0, 0, 300, 120)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Error Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppConstants.islamicGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.islamicGreen.withValues(alpha:0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.search_off,
                  size: 50,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              // Main Message
              Text(
                'عذراً، الصفحة غير موجودة',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.islamicGreen,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Text(
                  'يبدو أن الصفحة التي تبحث عنها غير موجودة أو تم نقلها.\nيمكنك العودة للصفحة الرئيسية أو تصفح الروابط المفيدة أدناه.',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.sageGreen,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 48),

              // Action Buttons
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go(AppRoutes.home);
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('العودة للرئيسية'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.islamicGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.go(AppRoutes.contact);
                    },
                    icon: const Icon(Icons.contact_support),
                    label: const Text('اتصل بنا'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConstants.islamicGreen,
                      side: BorderSide(
                        color: AppConstants.islamicGreen,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsSection(BuildContext context) {
    final suggestions = [
      {
        'icon': Icons.mosque,
        'title': 'دليل المساجد',
        'description': 'تصفح دليل المساجد في فلسطين',
        'route': AppRoutes.mosques,
        'color': AppConstants.islamicGreen,
      },
      {
        'icon': Icons.article,
        'title': 'الأخبار',
        'description': 'آخر الأخبار والمستجدات',
        'route': AppRoutes.news,
        'color': AppColors.goldenYellow,
      },
      {
        'icon': Icons.event,
        'title': 'الفعاليات',
        'description': 'الفعاليات والأنشطة القادمة',
        'route': AppRoutes.activities,
        'color': AppColors.sageGreen,
      },
      {
        'icon': Icons.computer,
        'title': 'الخدمات الإلكترونية',
        'description': 'خدماتنا الإلكترونية المتنوعة',
        'route': AppRoutes.eservices,
        'color': Colors.blue,
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: AppColors.surfaceVariant,
      child: Column(
        children: [
          Text(
            'صفحات قد تهمك',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppConstants.islamicGreen,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'تصفح الأقسام الأكثر زيارة في موقعنا',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.sageGreen,
            ),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 1200
                  ? 4
                  : constraints.maxWidth > 800
                  ? 2
                  : 1;

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.1,
                ),
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final item = suggestions[index];
                  return _buildSuggestionCard(
                    context,
                    icon: item['icon'] as IconData,
                    title: item['title'] as String,
                    description: item['description'] as String,
                    route: item['route'] as String,
                    color: item['color'] as Color,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required String route,
        required Color color,
      }) {return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      color,
                      color.withValues(alpha:0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha:0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.sageGreen,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Icon(
                Icons.arrow_forward,
                color: color,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}