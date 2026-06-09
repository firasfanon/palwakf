import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:waqf/data/models/friday_sermon.dart';
import 'package:waqf/data/models/media_gallery_item.dart';
import 'package:waqf/features/platform/home/presentation/screens/pwf_web_page_scaffold.dart';
import 'package:waqf/features/platform/home/presentation/theme/pwf_home_palette.dart';
import 'package:waqf/features/platform/home/presentation/widgets/pwf_hover_card.dart';
import 'package:waqf/features/platform/home/presentation/screens/pages/pwf_public_content_shared.dart';
import 'package:waqf/features/platform/home/presentation/widgets/pwf_section_container.dart';
import 'package:waqf/presentation/providers/friday_sermons_provider.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';
import 'package:waqf/presentation/providers/media_gallery_provider.dart';

class PwfMediaGalleryWebScreen extends ConsumerStatefulWidget {
  const PwfMediaGalleryWebScreen({super.key, required this.unitSlug});

  final String unitSlug;

  @override
  ConsumerState<PwfMediaGalleryWebScreen> createState() =>
      _PwfMediaGalleryWebScreenState();
}

enum _PwfMediaTab { photos, videos }

enum _PwfMediaSort { newest, featuredFirst, alphabetical }

class _PwfMediaGalleryWebScreenState
    extends ConsumerState<PwfMediaGalleryWebScreen> {
  final TextEditingController _search = TextEditingController();
  _PwfMediaTab _tab = _PwfMediaTab.photos;
  _PwfMediaSort _sort = _PwfMediaSort.newest;
  bool _featuredOnly = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeType = _tab == _PwfMediaTab.photos
        ? MediaType.photo
        : MediaType.video;
    final asyncItems = ref.watch(
      publicMediaGalleryBrowseProvider(
        PublicMediaGalleryBrowseQuery(
          unitSlug: widget.unitSlug,
          type: activeType,
          search: _search.text.trim(),
        ),
      ),
    );

    return PwfWebPageScaffold(
      unitSlug: widget.unitSlug,
      title: 'المعرض الإعلامي',
      showTitleSection: true,
      child: PwfSectionContainer(
        sectionKey: 'PwfMediaGalleryWebScreen',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PwfMediaHero(unitSlug: widget.unitSlug),
            const SizedBox(height: 18),
            _PwfMediaToolbar(
              searchController: _search,
              activeTab: _tab,
              featuredOnly: _featuredOnly,
              sort: _sort,
              onTabChanged: (value) => setState(() => _tab = value),
              onFeaturedChanged: (value) =>
                  setState(() => _featuredOnly = value),
              onSortChanged: (value) => setState(() => _sort = value),
              onSearchChanged: (_) => setState(() {}),
              onClearSearch: () {
                _search.clear();
                setState(() {});
              },
            ),
            const SizedBox(height: 18),
            asyncItems.when(
              data: (items) {
                final visibleItems = _filterAndSortItems(items);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PwfMediaStatsRow(
                      total: items.length,
                      featured: items.where((e) => e.isFeatured).length,
                      pinned: items.where((e) => e.isPinned).length,
                      visible: visibleItems.length,
                      isVideo: activeType == MediaType.video,
                    ),
                    const SizedBox(height: 18),
                    if (visibleItems.isEmpty)
                      const _PwfEmptyState(
                        message: 'لا توجد عناصر مطابقة للمرشحات الحالية.',
                      )
                    else
                      _PwfMediaGrid(
                        items: visibleItems,
                        isVideo: activeType == MediaType.video,
                      ),
                  ],
                );
              },
              loading: () => const _PwfLoadingState(),
              error: (e, _) =>
                  const _PwfEmptyState(message: 'تعذّر تحميل المعرض.'),
            ),
          ],
        ),
      ),
    );
  }

  List<MediaGalleryItem> _filterAndSortItems(List<MediaGalleryItem> items) {
    final filtered = items
        .where((item) {
          if (_featuredOnly && !item.isFeatured) return false;
          return true;
        })
        .toList(growable: true);

    switch (_sort) {
      case _PwfMediaSort.newest:
        filtered.sort((a, b) {
          final aDate =
              a.publishAt ??
              a.createdAt ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final bDate =
              b.publishAt ??
              b.createdAt ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final pinnedCompare = (b.isPinned ? 1 : 0).compareTo(
            a.isPinned ? 1 : 0,
          );
          if (pinnedCompare != 0) return pinnedCompare;
          final featuredCompare = (b.isFeatured ? 1 : 0).compareTo(
            a.isFeatured ? 1 : 0,
          );
          if (featuredCompare != 0) return featuredCompare;
          return bDate.compareTo(aDate);
        });
        break;
      case _PwfMediaSort.featuredFirst:
        filtered.sort((a, b) {
          final pinnedCompare = (b.isPinned ? 1 : 0).compareTo(
            a.isPinned ? 1 : 0,
          );
          if (pinnedCompare != 0) return pinnedCompare;
          final featuredCompare = (b.isFeatured ? 1 : 0).compareTo(
            a.isFeatured ? 1 : 0,
          );
          if (featuredCompare != 0) return featuredCompare;
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
        });
        break;
      case _PwfMediaSort.alphabetical:
        filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
    }

    return List<MediaGalleryItem>.unmodifiable(filtered);
  }
}

class _PwfMediaHero extends ConsumerWidget {
  const _PwfMediaHero({required this.unitSlug});

  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = ref.watch(orgUnitBySlugProvider(unitSlug)).valueOrNull;
    final scopeLabel = pwfResolveScopeLabel(unitSlug: unitSlug, unit: unit);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2C55), Color(0xFF1E3A8A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.perm_media_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'معرض الصور والفيديو',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'أرشيف مرئي موحّد لعرض صور وفيديوهات $scopeLabel مع إمكان البحث والتصفية داخل نفس الصفحة.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.white.withValues(alpha: 0.86),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _HeroHintChip(icon: Icons.search, label: 'بحث مباشر'),
              _HeroHintChip(
                icon: Icons.filter_alt_outlined,
                label: 'فلاتر مرنة',
              ),
              _HeroHintChip(
                icon: Icons.open_in_new_outlined,
                label: 'فتح الملف أو الرابط',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroHintChip extends StatelessWidget {
  const _HeroHintChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PwfMediaToolbar extends StatelessWidget {
  const _PwfMediaToolbar({
    required this.searchController,
    required this.activeTab,
    required this.featuredOnly,
    required this.sort,
    required this.onTabChanged,
    required this.onFeaturedChanged,
    required this.onSortChanged,
    required this.onSearchChanged,
    required this.onClearSearch,
  });

  final TextEditingController searchController;
  final _PwfMediaTab activeTab;
  final bool featuredOnly;
  final _PwfMediaSort sort;
  final ValueChanged<_PwfMediaTab> onTabChanged;
  final ValueChanged<bool> onFeaturedChanged;
  final ValueChanged<_PwfMediaSort> onSortChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _ToolbarTabChip(
                label: 'الصور',
                active: activeTab == _PwfMediaTab.photos,
                onTap: () => onTabChanged(_PwfMediaTab.photos),
              ),
              _ToolbarTabChip(
                label: 'الفيديو',
                active: activeTab == _PwfMediaTab.videos,
                onTap: () => onTabChanged(_PwfMediaTab.videos),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 14,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 360,
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: InputDecoration(
                    labelText: 'بحث داخل المعرض',
                    hintText: 'عنوان / وصف',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      onPressed: onClearSearch,
                      icon: const Icon(Icons.clear),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<_PwfMediaSort>(
                  value: sort,
                  decoration: const InputDecoration(
                    labelText: 'الترتيب',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: _PwfMediaSort.newest,
                      child: Text('الأحدث'),
                    ),
                    DropdownMenuItem(
                      value: _PwfMediaSort.featuredFirst,
                      child: Text('المميز أولًا'),
                    ),
                    DropdownMenuItem(
                      value: _PwfMediaSort.alphabetical,
                      child: Text('أبجديًا'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) onSortChanged(value);
                  },
                ),
              ),
              FilterChip(
                label: const Text('المميز فقط'),
                selected: featuredOnly,
                onSelected: onFeaturedChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToolbarTabChip extends StatelessWidget {
  const _ToolbarTabChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFFDBEAFE),
      labelStyle: TextStyle(
        color: active ? const Color(0xFF1D4ED8) : const Color(0xFF374151),
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _PwfMediaStatsRow extends StatelessWidget {
  const _PwfMediaStatsRow({
    required this.total,
    required this.featured,
    required this.pinned,
    required this.visible,
    required this.isVideo,
  });

  final int total;
  final int featured;
  final int pinned;
  final int visible;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    final items = [
      _PwfMiniStat(
        'الإجمالي',
        '$total',
        isVideo ? Icons.videocam_outlined : Icons.image_outlined,
      ),
      _PwfMiniStat('المميز', '$featured', Icons.star_border_rounded),
      _PwfMiniStat('المثبت', '$pinned', Icons.push_pin_outlined),
      _PwfMiniStat('بعد الفلترة', '$visible', Icons.filter_alt_outlined),
    ];

    return Wrap(spacing: 12, runSpacing: 12, children: items);
  }
}

class _PwfMiniStat extends StatelessWidget {
  const _PwfMiniStat(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0F2C55), size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PwfMediaGrid extends StatelessWidget {
  const _PwfMediaGrid({required this.items, required this.isVideo});

  final List<MediaGalleryItem> items;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final cols = w >= 1100 ? 3 : (w >= 760 ? 2 : 1);
        const spacing = 14.0;
        final cardW = (w - (spacing * (cols - 1))) / cols;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: cardW,
                child: _PwfMediaCard(item: item, isVideo: isVideo),
              ),
          ],
        );
      },
    );
  }
}

class _PwfMediaCard extends StatelessWidget {
  const _PwfMediaCard({required this.item, required this.isVideo});

  final MediaGalleryItem item;
  final bool isVideo;

  @override
  Widget build(BuildContext context) {
    final previewUrl = (item.thumbnailUrl ?? '').trim().isNotEmpty
        ? item.thumbnailUrl!
        : item.mediaUrl;
    final publishLabel = item.publishAt == null
        ? 'منشور'
        : 'نشر ${item.publishAt!.toLocal().toString().substring(0, 16)}';

    return PwfHoverCard(
      onTap: () => _showMediaDetails(context, item, isVideo),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      previewUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFE5E7EB),
                        child: Icon(
                          isVideo
                              ? Icons.ondemand_video_outlined
                              : Icons.image_outlined,
                          size: 40,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),
                ),
                if (isVideo)
                  const Positioned.fill(
                    child: Center(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Color(0x88000000),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (item.isPinned)
                        const _PwfBadge('مثبت', Color(0xFF7C3AED)),
                      if (item.isFeatured)
                        const _PwfBadge('مميز', Color(0xFFF59E0B)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F2C55),
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _MetaChip(publishLabel),
                if ((item.externalUrl ?? '').trim().isNotEmpty)
                  const _MetaChip('رابط خارجي'),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item.description.trim().isEmpty
                  ? 'لا يوجد وصف مضاف لهذا العنصر.'
                  : item.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.black.withValues(alpha: 0.72),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _showMediaDetails(context, item, isVideo),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('التفاصيل'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openMedia(item, isVideo),
                  icon: Icon(
                    isVideo
                        ? Icons.open_in_new_outlined
                        : Icons.fullscreen_outlined,
                    size: 18,
                  ),
                  label: Text(isVideo ? 'فتح الفيديو' : 'عرض الصورة'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMediaDetails(
    BuildContext context,
    MediaGalleryItem item,
    bool isVideo,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 760),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F2C55),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        (item.thumbnailUrl ?? '').trim().isNotEmpty
                            ? item.thumbnailUrl!
                            : item.mediaUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFE5E7EB),
                          child: Icon(
                            isVideo
                                ? Icons.videocam_outlined
                                : Icons.image_outlined,
                            size: 48,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (item.isPinned)
                        const _PwfBadge('مثبت', Color(0xFF7C3AED)),
                      if (item.isFeatured)
                        const _PwfBadge('مميز', Color(0xFFF59E0B)),
                      if (item.publishAt != null)
                        _PwfBadge(
                          item.publishAt!.toLocal().toString().substring(0, 16),
                          const Color(0xFF0F766E),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    item.description.trim().isEmpty
                        ? 'لا يوجد وصف مضاف لهذا العنصر.'
                        : item.description,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _openMedia(item, isVideo),
                        icon: Icon(
                          isVideo
                              ? Icons.play_circle_outline
                              : Icons.image_search_outlined,
                        ),
                        label: Text(isVideo ? 'فتح الفيديو' : 'فتح الصورة'),
                      ),
                      if ((item.externalUrl ?? '').trim().isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: () => _openUrl(item.externalUrl!),
                          icon: const Icon(Icons.link_outlined),
                          label: const Text('فتح الرابط الخارجي'),
                        ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(
                            ClipboardData(text: item.mediaUrl),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isVideo
                                      ? 'تم نسخ رابط الفيديو'
                                      : 'تم نسخ رابط الصورة',
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy_all_outlined),
                        label: Text(
                          isVideo ? 'نسخ رابط الفيديو' : 'نسخ رابط الصورة',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openMedia(MediaGalleryItem item, bool isVideo) async {
    final preferredUrl = (item.externalUrl ?? '').trim().isNotEmpty
        ? item.externalUrl!.trim()
        : item.mediaUrl.trim();
    await _openUrl(preferredUrl);
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }
}

class _PwfBadge extends StatelessWidget {
  const _PwfBadge(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF1D4ED8),
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class PwfFridaySermonsWebScreen extends ConsumerStatefulWidget {
  const PwfFridaySermonsWebScreen({super.key, required this.unitSlug});

  final String unitSlug;

  @override
  ConsumerState<PwfFridaySermonsWebScreen> createState() =>
      _PwfFridaySermonsWebScreenState();
}

class _PwfFridaySermonsWebScreenState
    extends ConsumerState<PwfFridaySermonsWebScreen> {
  String _query = '';
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(publicFridaySermonsProvider);
    final unit = ref.watch(orgUnitBySlugProvider(widget.unitSlug)).valueOrNull;
    final scopeLabel = pwfResolveScopeLabel(
      unitSlug: widget.unitSlug,
      unit: unit,
    );

    return PwfWebPageScaffold(
      unitSlug: widget.unitSlug,
      title: 'خطب الجمعة والنشرات',
      showTitleSection: true,
      child: PwfSectionContainer(
        sectionKey: 'PwfFridaySermonsWebScreen',
        child: async.when(
          data: (items) {
            final filtered = _applySermonFilters(items, context);
            if (filtered.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PwfPublicIntroCard(
                    title: 'خطب الجمعة والنشرات',
                    subtitle:
                        'أرشيف مرتب لخطب الجمعة والنشرات العامة، مع البحث واستعراض التفاصيل داخل الصفحة.',
                    icon: Icons.mic_external_on_outlined,
                    unitSlug: widget.unitSlug,
                    note:
                        'يعرض هذا الأرشيف محتوى $scopeLabel مع ملخصات وروابط الملفات المرفقة حيث تتوفر.',
                  ),
                  const SizedBox(height: 18),
                  PwfSearchBox(
                    hint: 'ابحث في عنوان الخطبة أو المسجد أو اسم الخطيب...',
                    initialValue: _query,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                  const SizedBox(height: 18),
                  const _PwfEmptyState(
                    message: 'لا توجد خطب مطابقة لمرشحات البحث الحالية.',
                  ),
                ],
              );
            }

            final selected = filtered.firstWhere(
              (item) => item.id == _selectedId,
              orElse: () => filtered.first,
            );
            final pdfCount = filtered
                .where((e) => (e.pdfUrl ?? '').trim().isNotEmpty)
                .length;
            final audioCount = filtered
                .where((e) => (e.audioUrl ?? '').trim().isNotEmpty)
                .length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PwfPublicIntroCard(
                  title: 'خطب الجمعة والنشرات',
                  subtitle:
                      'أرشيف مرتب لخطب الجمعة والنشرات العامة، مع البحث واستعراض التفاصيل داخل الصفحة.',
                  icon: Icons.mic_external_on_outlined,
                  unitSlug: widget.unitSlug,
                  note:
                      'يعرض هذا الأرشيف محتوى $scopeLabel مع ملخصات وروابط الملفات المرفقة حيث تتوفر.',
                ),
                const SizedBox(height: 18),
                PwfStatsWrap(
                  items: [
                    PwfStatItem(
                      label: 'إجمالي الخطب',
                      value: filtered.length,
                      icon: Icons.library_books_outlined,
                    ),
                    PwfStatItem(
                      label: 'المنشور',
                      value: filtered.where((e) => e.isPublished).length,
                      icon: Icons.public_outlined,
                      color: const Color(0xFF1D7A46),
                    ),
                    PwfStatItem(
                      label: 'مع PDF',
                      value: pdfCount,
                      icon: Icons.picture_as_pdf_outlined,
                      color: PwfHomePalette.royalRed,
                    ),
                    PwfStatItem(
                      label: 'مع صوت',
                      value: audioCount,
                      icon: Icons.audiotrack_outlined,
                      color: PwfHomePalette.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                PwfSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PwfDetailSectionTitle(
                        title: 'البحث داخل الأرشيف',
                        subtitle:
                            'ابحث بالعنوان أو الملخص أو المسجد أو الخطيب للوصول السريع إلى الخطبة المطلوبة.',
                      ),
                      const SizedBox(height: 12),
                      PwfSearchBox(
                        hint: 'ابحث في عنوان الخطبة أو المسجد أو اسم الخطيب...',
                        initialValue: _query,
                        onChanged: (value) => setState(() => _query = value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _PwfSermonDetailCard(
                  sermon: selected,
                  onCopyTitle: () async {
                    await Clipboard.setData(
                      ClipboardData(text: _sermonTitle(context, selected)),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ عنوان الخطبة')),
                      );
                    }
                  },
                  onCopyPdf: (selected.pdfUrl ?? '').trim().isEmpty
                      ? null
                      : () async {
                          await Clipboard.setData(
                            ClipboardData(text: selected.pdfUrl!),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم نسخ رابط ملف PDF'),
                              ),
                            );
                          }
                        },
                  onCopyAudio: (selected.audioUrl ?? '').trim().isEmpty
                      ? null
                      : () async {
                          await Clipboard.setData(
                            ClipboardData(text: selected.audioUrl!),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم نسخ رابط الملف الصوتي'),
                              ),
                            );
                          }
                        },
                ),
                const SizedBox(height: 18),
                PwfRelatedLinksCard(
                  title: 'الأرشيف المرتبط',
                  subtitle:
                      'اختر خطبة أخرى من القائمة لتظهر تفاصيلها في أعلى الصفحة.',
                  children: [
                    for (final s in filtered)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: InkWell(
                          onTap: () => setState(() => _selectedId = s.id),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: selected.id == s.id
                                  ? const Color(0xFFEFF6FF)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: selected.id == s.id
                                    ? const Color(0xFFBFDBFE)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.record_voice_over_outlined,
                                  color: PwfHomePalette.primary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _sermonTitle(context, s),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: PwfHomePalette.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _sermonSummary(context, s),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          height: 1.6,
                                          color: Colors.black.withValues(
                                            alpha: 0.65,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  pwfFormatArabicDate(s.sermonDate),
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: PwfHomePalette.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
          loading: () => const _PwfLoadingState(),
          error: (e, _) => const _PwfEmptyState(message: 'تعذّر تحميل الخطب.'),
        ),
      ),
    );
  }

  List<FridaySermon> _applySermonFilters(
    List<FridaySermon> items,
    BuildContext context,
  ) {
    final q = _query.trim().toLowerCase();
    final out = items
        .where((item) {
          if (q.isEmpty) return true;
          final haystack = [
            _sermonTitle(context, item),
            _sermonSummary(context, item),
            item.speakerName ?? '',
            item.mosqueName ?? '',
          ].join(' ').toLowerCase();
          return haystack.contains(q);
        })
        .toList(growable: true);
    out.sort((a, b) => b.sermonDate.compareTo(a.sermonDate));
    return out;
  }
}

class _PwfSermonDetailCard extends StatelessWidget {
  const _PwfSermonDetailCard({
    required this.sermon,
    required this.onCopyTitle,
    this.onCopyPdf,
    this.onCopyAudio,
  });

  final FridaySermon sermon;
  final VoidCallback onCopyTitle;
  final VoidCallback? onCopyPdf;
  final VoidCallback? onCopyAudio;

  @override
  Widget build(BuildContext context) {
    final content = (sermon.contentAr ?? '').trim();
    final summary = _sermonSummary(context, sermon);
    return PwfSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PwfDetailSectionTitle(
            title: _sermonTitle(context, sermon),
            subtitle: summary == '—' ? 'تفاصيل الخطبة المختارة.' : summary,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              PwfMetaBadge(
                label: pwfFormatArabicDate(sermon.sermonDate),
                icon: Icons.calendar_today_outlined,
                color: PwfHomePalette.textSecondary,
              ),
              if ((sermon.speakerName ?? '').trim().isNotEmpty)
                PwfMetaBadge(
                  label: sermon.speakerName!.trim(),
                  icon: Icons.person_outline,
                  color: PwfHomePalette.textSecondary,
                ),
              if ((sermon.mosqueName ?? '').trim().isNotEmpty)
                PwfMetaBadge(
                  label: sermon.mosqueName!.trim(),
                  icon: Icons.mosque_outlined,
                  color: PwfHomePalette.textSecondary,
                ),
              PwfMetaBadge(
                label: sermon.isPublished ? 'منشور' : 'غير منشور',
                icon: sermon.isPublished
                    ? Icons.public_outlined
                    : Icons.lock_outline,
                color: sermon.isPublished
                    ? const Color(0xFF1D7A46)
                    : PwfHomePalette.royalRed,
              ),
            ],
          ),
          const SizedBox(height: 16),
          PwfDetailInfoGrid(
            items: [
              if ((sermon.speakerName ?? '').trim().isNotEmpty)
                PwfDetailInfoItem(
                  label: 'الخطيب',
                  value: sermon.speakerName!.trim(),
                  icon: Icons.record_voice_over_outlined,
                ),
              if ((sermon.mosqueName ?? '').trim().isNotEmpty)
                PwfDetailInfoItem(
                  label: 'المسجد',
                  value: sermon.mosqueName!.trim(),
                  icon: Icons.location_city_outlined,
                ),
              if ((sermon.pdfUrl ?? '').trim().isNotEmpty)
                const PwfDetailInfoItem(
                  label: 'ملف PDF',
                  value: 'متوفر',
                  icon: Icons.picture_as_pdf_outlined,
                  color: PwfHomePalette.royalRed,
                ),
              if ((sermon.audioUrl ?? '').trim().isNotEmpty)
                const PwfDetailInfoItem(
                  label: 'ملف صوتي',
                  value: 'متوفر',
                  icon: Icons.audiotrack_outlined,
                  color: PwfHomePalette.secondary,
                ),
            ],
          ),
          const SizedBox(height: 16),
          PwfDetailActionsBar(
            title: 'إجراءات الخطبة',
            actions: [
              OutlinedButton.icon(
                onPressed: onCopyTitle,
                icon: const Icon(Icons.copy_all_outlined),
                label: const Text('نسخ العنوان'),
              ),
              if (onCopyPdf != null)
                OutlinedButton.icon(
                  onPressed: onCopyPdf,
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('نسخ رابط PDF'),
                ),
              if (onCopyAudio != null)
                OutlinedButton.icon(
                  onPressed: onCopyAudio,
                  icon: const Icon(Icons.audiotrack_outlined),
                  label: const Text('نسخ رابط الصوت'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (content.isNotEmpty) ...[
            const PwfDetailSectionTitle(title: 'النص أو المحتوى الكامل'),
            const SizedBox(height: 10),
            SelectableText(
              content,
              style: const TextStyle(
                fontSize: 15.5,
                height: 1.95,
                color: Color(0xFF1E293B),
              ),
            ),
          ] else ...[
            const PwfDetailSectionTitle(title: 'ملخص الخطبة'),
            const SizedBox(height: 10),
            SelectableText(
              summary,
              style: const TextStyle(
                fontSize: 15.5,
                height: 1.95,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ],
      ),
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
