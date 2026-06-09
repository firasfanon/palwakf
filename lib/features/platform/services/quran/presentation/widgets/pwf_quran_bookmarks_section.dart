import 'package:flutter/material.dart';
import '../../domain/pwf_quran_models.dart';
import 'pwf_quran_hero.dart';

class PwfQuranKeysBookmarks {
  static const title = 'quran.bookmarks.title';
  static const empty = 'quran.bookmarks.empty';
  static const ayah = 'quran.bookmarks.ayah';
  static const remove = 'quran.bookmarks.remove';
}

class PwfQuranBookmarksSection extends StatelessWidget {
  const PwfQuranBookmarksSection({
    super.key,
    required this.bookmarks,
    required this.surahById,
    required this.onRemoveAt,
  });

  final List<PwfQuranBookmark> bookmarks;
  final PwfQuranSurah? Function(int id) surahById;
  final ValueChanged<int> onRemoveAt;

  @override
  Widget build(BuildContext context) {
    final title = PwfQuranTr.t(context, PwfQuranKeysBookmarks.title);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: PwfQuranPalette.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  const Icon(Icons.bookmark, color: PwfQuranPalette.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: PwfQuranPalette.primary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Scheherazade New',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (bookmarks.isEmpty)
              _EmptyState(
                text: PwfQuranTr.t(context, PwfQuranKeysBookmarks.empty),
              )
            else
              _Grid(
                bookmarks: bookmarks,
                surahById: surahById,
                onRemoveAt: onRemoveAt,
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: PwfQuranPalette.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withValues(alpha: 14)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.bookmark_border,
            size: 42,
            color: PwfQuranPalette.gray.withValues(alpha: 220),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: PwfQuranPalette.gray,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.bookmarks,
    required this.surahById,
    required this.onRemoveAt,
  });

  final List<PwfQuranBookmark> bookmarks;
  final PwfQuranSurah? Function(int id) surahById;
  final ValueChanged<int> onRemoveAt;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, c) {
        final w = c.maxWidth;
        final crossAxisCount = w < 576 ? 1 : (w < 992 ? 2 : 3);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.6,
          ),
          itemCount: bookmarks.length,
          itemBuilder: (ctx, i) {
            final b = bookmarks[i];
            final surah = surahById(b.surahId);
            if (surah == null) return const SizedBox.shrink();
            return _BookmarkCard(
              index: i,
              surah: surah,
              bookmark: b,
              onRemoveAt: onRemoveAt,
            );
          },
        );
      },
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  const _BookmarkCard({
    required this.index,
    required this.surah,
    required this.bookmark,
    required this.onRemoveAt,
  });

  final int index;
  final PwfQuranSurah surah;
  final PwfQuranBookmark bookmark;
  final ValueChanged<int> onRemoveAt;

  @override
  Widget build(BuildContext context) {
    final ayahLabel = PwfQuranTr.t(context, PwfQuranKeysBookmarks.ayah);
    final remove = PwfQuranTr.t(context, PwfQuranKeysBookmarks.remove);

    final preview = surah.ayahText.isNotEmpty ? surah.ayahText.first : '';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: PwfQuranPalette.accent.withValues(alpha: 12),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          right: BorderSide(
            color: PwfQuranPalette.gold.withValues(alpha: 255),
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                surah.name,
                style: const TextStyle(
                  color: PwfQuranPalette.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  preview,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PwfQuranPalette.text,
                    height: 1.5,
                    fontFamily: 'Scheherazade New',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$ayahLabel ${bookmark.ayahNo}',
                      style: const TextStyle(
                        color: PwfQuranPalette.gray,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: remove,
                    onPressed: () => onRemoveAt(index),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: PwfQuranPalette.royalRed,
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
}
