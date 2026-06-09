import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waqf/data/models/friday_sermon.dart';
import 'package:waqf/data/models/media_gallery_item.dart';
import 'package:waqf/features/platform/home/presentation/screens/pwf_web_page_scaffold.dart';
import 'package:waqf/features/platform/home/presentation/theme/pwf_home_palette.dart';
import 'package:waqf/features/platform/home/presentation/widgets/pwf_hover_card.dart';
import 'package:waqf/features/platform/home/presentation/widgets/pwf_section_container.dart';
import 'package:waqf/presentation/providers/friday_sermons_provider.dart';
import 'package:waqf/presentation/providers/media_gallery_provider.dart';

class PwfMediaGalleryWebScreen extends ConsumerWidget {
  const PwfMediaGalleryWebScreen({super.key, required this.unitSlug});

  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(unitPhotosProvider(unitSlug));
    final videosAsync = ref.watch(unitVideosProvider(unitSlug));

    return PwfWebPageScaffold(
      unitSlug: unitSlug,
      title: 'المعرض الإعلامي',
      showTitleSection: true,
      child: PwfSectionContainer(
        sectionKey: 'PwfMediaGalleryWebScreen',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _PwfSubTitle('الصور'),
            const SizedBox(height: 10),
            photosAsync.when(
              data: (items) => _PwfMediaGrid(items: items),
              loading: () => const _PwfLoadingState(),
              error: (e, _) =>
                  const _PwfEmptyState(message: 'تعذّر تحميل الصور.'),
            ),
            const SizedBox(height: 22),
            const _PwfSubTitle('الفيديو'),
            const SizedBox(height: 10),
            videosAsync.when(
              data: (items) => _PwfMediaGrid(items: items),
              loading: () => const _PwfLoadingState(),
              error: (e, _) =>
                  const _PwfEmptyState(message: 'تعذّر تحميل الفيديو.'),
            ),
          ],
        ),
      ),
    );
  }
}

class PwfFridaySermonsWebScreen extends ConsumerWidget {
  const PwfFridaySermonsWebScreen({super.key, required this.unitSlug});

  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Current provider is public; unit scoping can be added later without breaking.
    final async = ref.watch(publicFridaySermonsProvider);

    return PwfWebPageScaffold(
      unitSlug: unitSlug,
      title: 'خطب الجمعة والنشرات',
      showTitleSection: true,
      child: PwfSectionContainer(
        sectionKey: 'PwfFridaySermonsWebScreen',
        child: async.when(
          data: (items) {
            if (items.isEmpty) {
              return const _PwfEmptyState(message: 'لا توجد خطب متاحة حالياً.');
            }
            return _PwfSermonsList(items: items);
          },
          loading: () => const _PwfLoadingState(),
          error: (e, _) => const _PwfEmptyState(message: 'تعذّر تحميل الخطب.'),
        ),
      ),
    );
  }
}

class _PwfSubTitle extends StatelessWidget {
  const _PwfSubTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: Color(0xFF0F2C55),
      ),
    );
  }
}

class _PwfMediaGrid extends StatelessWidget {
  const _PwfMediaGrid({required this.items});
  final List<MediaGalleryItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _PwfEmptyState(message: 'لا توجد عناصر.');
    }

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final cols = w >= 1100 ? 4 : (w >= 720 ? 3 : 2);
        const spacing = 12.0;
        final cardW = (w - (spacing * (cols - 1))) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: cardW,
                child: PwfHoverCard(
                  onTap: () {
                    // For now, avoid launching or routing from here.
                    // Can be enhanced later (lightbox / external url).
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 9,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: item.thumbnailUrl?.isNotEmpty == true
                                ? Image.network(
                                    item.thumbnailUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: const Color(0xFFE9ECF5),
                                    child: const Center(
                                      child: Icon(
                                        Icons.image,
                                        size: 28,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F2C55),
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PwfSermonsList extends StatelessWidget {
  const _PwfSermonsList({required this.items});

  final List<FridaySermon> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final s in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PwfHoverCard(
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _sermonTitle(context, s),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F2C55),
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _sermonSummary(context, s),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Colors.black.withValues(alpha: 0.70),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

String _sermonTitle(BuildContext context, FridaySermon s) {
  final isAr =
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
  final t = isAr
      ? s.titleAr
      : ((s.titleEn?.trim().isNotEmpty == true)
            ? s.titleEn!.trim()
            : s.titleAr);
  return t.trim().isNotEmpty ? t.trim() : s.titleAr;
}

String _sermonSummary(BuildContext context, FridaySermon s) {
  final isAr =
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar';
  final v = isAr
      ? ((s.summaryAr?.trim().isNotEmpty == true) ? s.summaryAr!.trim() : '')
      : ((s.summaryEn?.trim().isNotEmpty == true)
            ? s.summaryEn!.trim()
            : (s.summaryAr?.trim() ?? ''));
  return v.trim().isNotEmpty ? v.trim() : '—';
}

class _PwfLoadingState extends StatelessWidget {
  const _PwfLoadingState();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 26),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _PwfEmptyState extends StatelessWidget {
  const _PwfEmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.65),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
