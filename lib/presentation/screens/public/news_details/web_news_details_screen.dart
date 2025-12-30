import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../data/models/news_article.dart';
import '../../../widgets/web/web_app_bar.dart';
import '../../../widgets/web/web_footer.dart';
import '../../../widgets/web/web_container.dart';

class WebNewsDetailScreen extends ConsumerWidget {
  final NewsArticle? article;

  const WebNewsDetailScreen({super.key, this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (article == null) {
      return Scaffold(
        appBar: const WebAppBar(),
        body: const Center(child: Text('لم يتم العثور على الخبر')),
      );
    }

    return Scaffold(
      appBar: const WebAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Image
            if (article!.imageUrl != null)
              Container(
                height: 400,
                width: double.infinity,
                color: Colors.grey[300],
                child: Image.network(
                  article!.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image, size: 100),
                ),
              ),

            const SizedBox(height: 40),

            // Content
            WebContainer(
              maxWidth: 800,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppConstants.islamicGreen.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        article!.category.displayName,
                        style: const TextStyle(
                          color: AppConstants.islamicGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title
                    Text(
                      article!.title,
                      style: Theme
                          .of(context)
                          .textTheme
                          .displaySmall
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Meta Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppConstants.islamicGreen
                              .withValues(alpha:0.1),
                          child: const Icon(
                            Icons.person,
                            color: AppConstants.islamicGreen,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article!.author,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              article!.publishedAt?.arabicFormat ?? '',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 14),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.share),
                          tooltip: 'مشاركة',
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.bookmark_border),
                          tooltip: 'حفظ',
                        ),
                      ],
                    ),

                    const Divider(height: 48),

                    // Content
                    Text(
                      article!.content,
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                        height: 2.0,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Tags
                    if (article!.tags.isNotEmpty) ...[
                      Text(
                        'الوسوم:',
                        style: Theme
                            .of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: article!.tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            backgroundColor: AppConstants.surfaceVariant,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 40),
                    ],

                    // Share Section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppConstants.surfaceVariant,
                        borderRadius: BorderRadius.circular(
                            AppConstants.radiusL),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'شارك هذا الخبر',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              _buildShareButton(Icons.facebook, 'Facebook'),
                              const SizedBox(width: 12),
                              _buildShareButton(Icons.share, 'Twitter'),
                              const SizedBox(width: 12),
                              _buildShareButton(Icons.link, 'Copy Link'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 60),
            const WebFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildShareButton(IconData icon, String label) {
    return Tooltip(
      message: label,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: AppConstants.borderLight),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          icon: Icon(icon),
          onPressed: () {},
        ),
      ),
    );
  }
}