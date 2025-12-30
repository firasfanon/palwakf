import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../data/models/news_article.dart';
import '../../../widgets/common/custom_app_bar.dart';

class MobileNewsDetailScreen extends ConsumerWidget {
  final NewsArticle? article;

  const MobileNewsDetailScreen({super.key, this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (article == null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'تفاصيل الخبر'),
        body: const Center(child: Text('لم يتم العثور على الخبر')),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: article!.category.displayName,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (article!.imageUrl != null)
              Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey[300],
                child: Image.network(
                  article!.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 80),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppConstants.islamicGreen.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      article!.category.displayName,
                      style: const TextStyle(
                        color: AppConstants.islamicGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(
                    article!.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Meta Info
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(article!.author, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(width: 16),
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        article!.publishedAt?.arabicFormat ?? '',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // Content
                  Text(
                    article!.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.8,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tags
                  if (article!.tags.isNotEmpty) ...[
                    const Text(
                      'الوسوم:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: article!.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: AppConstants.surfaceVariant,
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Share Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement share
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('مشاركة الخبر'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
