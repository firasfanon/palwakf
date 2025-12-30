import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/news_article.dart';
import '../../../core/extensions/datetime_extensions.dart';

class NewsListItem extends StatelessWidget {
  final NewsArticle article;
  final VoidCallback onTap;

  const NewsListItem({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article.imageUrl != null) _buildImage(),
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 8),
                  _buildTitle(),
                  const SizedBox(height: 8),
                  _buildExcerpt(),
                  const SizedBox(height: 12),
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppConstants.radiusM),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: AppColors.surfaceVariant,
          child: article.imageUrl != null
              ? Image.network(
            article.imageUrl!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder();
            },
          )
              : _buildImagePlaceholder(),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.image,
        size: 48,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppColors.islamicGreen.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            article.category.displayName,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.islamicGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (article.isFeatured) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.goldenYellow.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  size: 12,
                  color: AppColors.goldenYellow,
                ),
                const SizedBox(width: 4),
                Text(
                  'مميز',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.goldenYellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      article.title,
      style: AppTextStyles.titleMedium.copyWith(
        fontWeight: FontWeight.bold,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildExcerpt() {
    return Text(
      article.excerpt,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter() {
    final publishDate = article.publishedAt ?? article.createdAt;

    return Row(
      children: [
        Icon(
          Icons.person,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          article.author,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.access_time,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          publishDate.timeAgo,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Icon(
          Icons.visibility,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          article.viewCount.toString(),
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}