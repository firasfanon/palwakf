import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/media_gallery_item.dart';
import '../../providers/media_gallery_provider.dart';

class MediaGallerySection extends ConsumerWidget {
  final String unitSlug;
  final MediaType mediaType;
  final String title;
  final int previewLimit;

  const MediaGallerySection({
    super.key,
    required this.title,
    required this.mediaType,
    this.unitSlug = 'home',
    this.previewLimit = 8,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(
      unitMediaGalleryProvider(
        MediaGalleryQuery(
          unitSlug: unitSlug,
          type: mediaType,
          limit: previewLimit,
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          async.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, __) => _emptyState(mediaType),
            data: (items) {
              if (items.isEmpty) return _emptyState(mediaType);
              return SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    return _MediaCard(item: items[index]);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyState(MediaType t) {
    final icon = t == MediaType.photo
        ? Icons.photo_library_outlined
        : Icons.video_library_outlined;
    final label = t == MediaType.photo
        ? 'لا توجد صور حالياً'
        : 'لا توجد فيديوهات حالياً';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaCard extends StatelessWidget {
  final MediaGalleryItem item;
  const _MediaCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final thumb = (item.thumbnailUrl ?? '').trim();
    final image = thumb.isNotEmpty ? thumb : item.mediaUrl;

    return SizedBox(
      width: 220,
      child: Card(
        elevation: 1.5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: InkWell(
          onTap: () => _onTap(context),
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (image.trim().isNotEmpty)
                  Image.network(image, fit: BoxFit.cover)
                else
                  Container(
                    color: AppColors.surfaceVariant,
                    child: Icon(
                      item.mediaType == MediaType.photo
                          ? Icons.photo
                          : Icons.videocam,
                      color: AppColors.textSecondary,
                      size: 44,
                    ),
                  ),
                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                      colors: [
                        Colors.black.withValues(alpha: 0.65),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                if (item.mediaType == MediaType.video)
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.description.trim().isNotEmpty)
                        Text(
                          item.description,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onTap(BuildContext context) async {
    if (item.mediaType == MediaType.photo) {
      final url = item.mediaUrl.trim();
      if (url.isEmpty) return;
      await showDialog<void>(
        context: context,
        builder: (_) {
          return Dialog(
            insetPadding: const EdgeInsets.all(16),
            child: SizedBox(
              width: 900,
              height: 600,
              child: PhotoView(
                imageProvider: NetworkImage(url),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              ),
            ),
          );
        },
      );
      return;
    }

    // Video
    final url = (item.externalUrl ?? item.mediaUrl).trim();
    if (url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
