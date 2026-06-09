// ignore_for_file: unused_element
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:waqf/app/routing/unit_routes.dart';
import 'package:waqf/data/models/activity.dart';
import 'package:waqf/data/models/media_gallery_item.dart';
import 'package:waqf/presentation/providers/media_gallery_provider.dart';
import 'package:waqf/presentation/providers/unit_dashboard_preview_providers.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';
import 'package:waqf/features/platform/public_runtime/presentation/widgets/pwf_public_image_fallback.dart';

import '../../theme/pwf_home_palette.dart';
import '../pwf_section_container.dart';
import '../shared/pwf_section_title.dart';
import 'pwf_content_display_settings.dart';

/// HTML-exact: "معرض الصور والفيديوهات" section.
///
/// - Tabs: Photos / Videos / Events
/// - Photos/Videos are DB-driven via `media_gallery_items` (unit-scoped).
/// - Events tab reuses upcoming activities preview as a best-effort match.
class PwfMediaGallerySection extends ConsumerStatefulWidget {
  const PwfMediaGallerySection({
    super.key,
    this.unitSlug = 'home',
    this.initialTab = 0,
    this.sectionSettings,
  });

  final String unitSlug;

  /// 0: photos, 1: videos, 2: events.
  final int initialTab;
  final Map<String, dynamic>? sectionSettings;

  @override
  ConsumerState<PwfMediaGallerySection> createState() =>
      _PwfMediaGallerySectionState();
}

class _PwfMediaGallerySectionState
    extends ConsumerState<PwfMediaGallerySection> {
  late _GalleryTab _tab;

  @override
  void initState() {
    super.initState();
    final idx = widget.initialTab;
    if (idx == 1) {
      _tab = _GalleryTab.videos;
    } else if (idx == 2) {
      _tab = _GalleryTab.events;
    } else {
      _tab = _GalleryTab.photos;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sectionsAsync = ref.watch(
      homepageSectionsForUnitProvider(widget.unitSlug),
    );
    final resolvedSettings =
        (widget.sectionSettings != null && widget.sectionSettings!.isNotEmpty)
        ? widget.sectionSettings
        : sectionsAsync.maybeWhen(
            data: (sections) => PwfContentDisplaySettings.pickSectionSettings(
              sections,
              aliases: const [
                'pwf_media_gallery_images',
                'pwf_media_gallery',
                'pwf_media_gallery_videos',
              ],
            ),
            orElse: () => null,
          );
    final display = PwfContentDisplaySettings.fromMap(
      resolvedSettings,
      defaultHomeLimit: 4,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 40),
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PwfHomePalette.primary.withValues(alpha: 0.05),
            PwfHomePalette.secondary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: PwfSectionContainer(
        sectionKey: 'PwfMediaGallerySection',
        child: Column(
          children: [
            const PwfSectionTitle(
              title: 'معرض الصور والفيديوهات',
              subtitle:
                  'معرض مرئي يوثق أنشطة وفعاليات ومشاريع وزارة الأوقاف والشؤون الدينية',
            ),
            const SizedBox(height: 30),
            _GalleryTabs(
              active: _tab,
              onChanged: (t) => setState(() => _tab = t),
            ),
            const SizedBox(height: 30),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: switch (_tab) {
                _GalleryTab.photos => _PhotosGrid(
                  unitSlug: widget.unitSlug,
                  limit: display.homeLimit,
                  key: const ValueKey('photos'),
                ),
                _GalleryTab.videos => _VideosGrid(
                  unitSlug: widget.unitSlug,
                  limit: display.homeLimit,
                  key: const ValueKey('videos'),
                ),
                _GalleryTab.events => _EventsGrid(
                  unitSlug: widget.unitSlug,
                  limit: display.homeLimit,
                  key: const ValueKey('events'),
                ),
              },
            ),
            if (display.showViewAll) ...[
              const SizedBox(height: 30),
              Center(
                child: _PrimaryButton(
                  icon: Icons.photo_library_outlined,
                  label: 'عرض المزيد من الصور والفيديوهات',
                  onTap: () => context.go(UnitRoutes.media(widget.unitSlug)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _GalleryTab { photos, videos, events }

class _GalleryTabs extends StatelessWidget {
  const _GalleryTabs({required this.active, required this.onChanged});

  final _GalleryTab active;
  final ValueChanged<_GalleryTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: PwfHomePalette.gray.withValues(alpha: 0.3)),
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 30,
        runSpacing: 8,
        children: [
          _TabBtn(
            label: 'الصور',
            active: active == _GalleryTab.photos,
            onTap: () => onChanged(_GalleryTab.photos),
          ),
          _TabBtn(
            label: 'الفيديوهات',
            active: active == _GalleryTab.videos,
            onTap: () => onChanged(_GalleryTab.videos),
          ),
          _TabBtn(
            label: 'الفعاليات',
            active: active == _GalleryTab.events,
            onTap: () => onChanged(_GalleryTab.events),
          ),
        ],
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  const _TabBtn({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: active ? PwfHomePalette.primary : PwfHomePalette.gray,
              ),
            ),
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 3,
              width: 70,
              decoration: BoxDecoration(
                color: active ? PwfHomePalette.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotosGrid extends ConsumerWidget {
  const _PhotosGrid({super.key, required this.unitSlug, required this.limit});

  final String unitSlug;
  final int limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(
      unitMediaGalleryProvider(
        MediaGalleryQuery(
          unitSlug: unitSlug,
          type: MediaType.photo,
          limit: limit,
        ),
      ),
    );

    final items = asyncItems.maybeWhen(
      data: (v) {
        final safe = v.where((e) => e.isPublishedNow).toList(growable: true);
        safe.sort(_compareMediaItems);
        return List<MediaGalleryItem>.unmodifiable(safe);
      },
      orElse: () => const <MediaGalleryItem>[],
    );

    if (asyncItems.isLoading) {
      return const _GalleryLoading();
    }
    if (items.isEmpty) {
      return _GalleryEmptyState(
        icon: Icons.photo_library_outlined,
        title: unitSlug == 'home'
            ? 'لا توجد صور منشورة حاليًا'
            : 'لا توجد صور منشورة لهذه الوحدة حاليًا',
        subtitle: unitSlug == 'home'
            ? 'سيظهر المعرض هنا بعد نشر صور الوزارة من لوحة التحكم.'
            : 'سيظهر معرض الصور هنا بعد نشر صور هذه الوحدة من لوحة التحكم.',
      );
    }

    final cards = items
        .take(limit)
        .map<_GalleryCardData>((e) => _GalleryCardData.fromMedia(e))
        .toList(growable: false);

    return _GalleryGrid(
      cards: cards,
      onTap: (c) {
        if (c.isVideo) {
          final target = c.externalUrl ?? c.fullMediaUrl;
          if (target != null && target.trim().isNotEmpty) {
            launchUrlString(target);
            return;
          }
          context.go(UnitRoutes.media(unitSlug));
          return;
        }
        if (c.fullMediaUrl != null) {
          showDialog(
            context: context,
            builder: (_) => _ImageDialog(url: c.fullMediaUrl!),
          );
          return;
        }
        context.go(UnitRoutes.media(unitSlug));
      },
    );
  }
}

class _VideosGrid extends ConsumerWidget {
  const _VideosGrid({super.key, required this.unitSlug, required this.limit});

  final String unitSlug;
  final int limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncItems = ref.watch(
      unitMediaGalleryProvider(
        MediaGalleryQuery(
          unitSlug: unitSlug,
          type: MediaType.video,
          limit: limit,
        ),
      ),
    );
    final items = asyncItems.maybeWhen(
      data: (v) {
        final safe = v.where((e) => e.isPublishedNow).toList(growable: true);
        safe.sort(_compareMediaItems);
        return List<MediaGalleryItem>.unmodifiable(safe);
      },
      orElse: () => const <MediaGalleryItem>[],
    );

    if (asyncItems.isLoading) {
      return const _GalleryLoading();
    }
    if (items.isEmpty) {
      return _GalleryEmptyState(
        icon: Icons.ondemand_video_outlined,
        title: unitSlug == 'home'
            ? 'لا توجد فيديوهات منشورة حاليًا'
            : 'لا توجد فيديوهات منشورة لهذه الوحدة حاليًا',
        subtitle: unitSlug == 'home'
            ? 'ستظهر الفيديوهات هنا بعد نشرها من لوحة التحكم.'
            : 'ستظهر فيديوهات هذه الوحدة هنا بعد نشرها من لوحة التحكم.',
      );
    }

    final cards = items
        .take(limit)
        .map<_GalleryCardData>((e) => _GalleryCardData.fromMedia(e))
        .toList(growable: false);

    return _GalleryGrid(
      cards: cards,
      onTap: (c) {
        final link = c.externalUrl ?? c.fullMediaUrl;
        if (link == null || link.trim().isEmpty) {
          context.go(UnitRoutes.media(unitSlug));
          return;
        }
        launchUrlString(link);
      },
    );
  }
}

int _compareMediaItems(MediaGalleryItem a, MediaGalleryItem b) {
  int boolRank(bool v) => v ? 1 : 0;

  final pinnedDiff = boolRank(b.isPinned) - boolRank(a.isPinned);
  if (pinnedDiff != 0) return pinnedDiff;

  final featuredDiff = boolRank(b.isFeatured) - boolRank(a.isFeatured);
  if (featuredDiff != 0) return featuredDiff;

  final orderDiff = a.displayOrder.compareTo(b.displayOrder);
  if (orderDiff != 0) return orderDiff;

  final publishA = a.publishAt;
  final publishB = b.publishAt;
  if (publishA != null && publishB != null) {
    final publishDiff = publishB.compareTo(publishA);
    if (publishDiff != 0) return publishDiff;
  } else if (publishA != null || publishB != null) {
    return publishB == null ? 1 : -1;
  }

  final createdA = a.createdAt;
  final createdB = b.createdAt;
  if (createdA != null && createdB != null) {
    final createdDiff = createdB.compareTo(createdA);
    if (createdDiff != 0) return createdDiff;
  } else if (createdA != null || createdB != null) {
    return createdB == null ? 1 : -1;
  }

  return a.title.compareTo(b.title);
}

class _EventsGrid extends ConsumerWidget {
  const _EventsGrid({super.key, required this.unitSlug, required this.limit});

  final String unitSlug;
  final int limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncEvents = ref.watch(
      unitUpcomingActivitiesPreviewProvider(
        UnitPreviewParams(unitSlug: unitSlug, limit: limit),
      ),
    );

    final items = asyncEvents.maybeWhen(
      data: (v) => v,
      orElse: () => const <Activity>[],
    );

    final cards = items.isNotEmpty
        ? items
              .take(limit)
              .map<_GalleryCardData>((a) => _GalleryCardData.fromActivity(a))
              .toList(growable: false)
        : _demoEvents;

    return _GalleryGrid(
      cards: cards,
      onTap: (_) => context.go(UnitRoutes.activities(unitSlug)),
    );
  }
}

class _GalleryGrid extends StatelessWidget {
  const _GalleryGrid({required this.cards, required this.onTap});

  final List<_GalleryCardData> cards;
  final void Function(_GalleryCardData) onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        int count = 4;
        if (w < 520) {
          count = 1;
        } else if (w < 860) {
          count = 2;
        } else if (w < 1100) {
          count = 3;
        }

        final spacing = w < 520 ? 16.0 : 25.0;
        final aspectRatio = w < 360
            ? 0.50
            : w < 520
            ? 0.58
            : w < 860
            ? 0.66
            : w < 1100
            ? 0.74
            : 0.78;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
          ),
          itemCount: cards.length,
          itemBuilder: (_, i) =>
              _GalleryCard(data: cards[i], onTap: () => onTap(cards[i])),
        );
      },
    );
  }
}

class _GalleryLoading extends StatelessWidget {
  const _GalleryLoading();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 260,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _GalleryEmptyState extends StatelessWidget {
  const _GalleryEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: PwfHomeRadii.br8,
        border: Border.all(color: PwfHomePalette.gray.withValues(alpha: 0.16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 52,
            color: PwfHomePalette.primary.withValues(alpha: 0.75),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: PwfHomePalette.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 14,
              height: 1.6,
              color: PwfHomePalette.gray,
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryStatusBadge extends StatelessWidget {
  const _GalleryStatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.24),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlinePriorityChip extends StatelessWidget {
  const _InlinePriorityChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: PwfHomePalette.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: PwfHomePalette.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: PwfHomePalette.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryCard extends StatefulWidget {
  const _GalleryCard({required this.data, required this.onTap});

  final _GalleryCardData data;
  final VoidCallback onTap;

  @override
  State<_GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<_GalleryCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 320.0;
        final compact = cardWidth < 240;
        final bodyPadding = compact ? 14.0 : 20.0;
        final titleFontSize = compact ? 15.0 : 18.0;
        final descriptionMaxLines = compact ? 1 : 2;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: InkWell(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: _hover
                  ? (Matrix4.identity()..translate(0.0, -10.0))
                  : null,
              decoration: BoxDecoration(
                color: PwfHomePalette.cardBg,
                borderRadius: PwfHomeRadii.br8,
                boxShadow: _hover
                    ? PwfHomeShadows.cardHover
                    : PwfHomeShadows.card,
                border: Border.all(
                  color: PwfHomePalette.gray.withValues(alpha: 0.18),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        PwfPublicImage(
                          imageUrl: widget.data.imageUrl,
                          fit: BoxFit.cover,
                          fallbackColor: PwfHomePalette.primary.withValues(
                            alpha: 0.08,
                          ),
                        ),
                        if (widget.data.isVideo)
                          Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                color: PwfHomePalette.secondary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        Positioned(
                          top: 14,
                          left: 14,
                          right: 14,
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (widget.data.isPinned)
                                const _GalleryStatusBadge(
                                  label: 'مثبت',
                                  color: Color(0xFF7C3AED),
                                  icon: Icons.push_pin_rounded,
                                ),
                              if (widget.data.isFeatured)
                                const _GalleryStatusBadge(
                                  label: 'مميز',
                                  color: Color(0xFFF59E0B),
                                  icon: Icons.auto_awesome_rounded,
                                ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: bodyPadding,
                              vertical: compact ? 12 : 15,
                            ),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color.fromRGBO(0, 0, 0, 0.8),
                                ],
                              ),
                            ),
                            child: Text(
                              widget.data.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(bodyPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _MetaRow(
                                icon: Icons.calendar_today_outlined,
                                text: widget.data.metaLeft,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _MetaRow(
                                icon: Icons.local_offer_outlined,
                                text: widget.data.metaRight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.data.description,
                          maxLines: descriptionMaxLines,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: compact ? 13 : 14,
                            color: PwfHomePalette.gray,
                            height: 1.5,
                          ),
                        ),
                        if (widget.data.isPinned || widget.data.isFeatured) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (widget.data.isPinned)
                                const _InlinePriorityChip(
                                  label: 'مثبت',
                                  icon: Icons.push_pin_rounded,
                                ),
                              if (widget.data.isFeatured)
                                const _InlinePriorityChip(
                                  label: 'مميز',
                                  icon: Icons.auto_awesome_rounded,
                                ),
                            ],
                          ),
                        ],
                        if (widget.data.isVideo &&
                            widget.data.durationLabel != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 14,
                                color: PwfHomePalette.gray,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  widget.data.durationLabel!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.cairo(
                                    fontSize: 12,
                                    color: PwfHomePalette.gray,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: PwfHomePalette.primary.withValues(alpha: 0.8),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(fontSize: 12, color: PwfHomePalette.gray),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatefulWidget {
  const _PrimaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<_PrimaryButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final mediaWidth = MediaQuery.sizeOf(context).width;
        final maxButtonWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : mediaWidth - 32;
        final compact = maxButtonWidth < 280;
        final constrainedMaxWidth = maxButtonWidth
            .clamp(120.0, 420.0)
            .toDouble();

        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constrainedMaxWidth),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hover = true),
            onExit: (_) => setState(() => _hover = false),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                transform: _hover
                    ? (Matrix4.identity()..translate(0.0, -3.0))
                    : null,
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 18 : 30,
                  vertical: compact ? 10 : 12,
                ),
                decoration: BoxDecoration(
                  color: PwfHomePalette.primary,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: _hover
                      ? PwfHomeShadows.cardHover
                      : PwfHomeShadows.card,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Icon(
                      widget.icon,
                      color: Colors.white,
                      size: compact ? 16 : 18,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: compact ? 13 : 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ImageDialog extends StatelessWidget {
  const _ImageDialog({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              child: PwfPublicImage(imageUrl: url, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryCardData {
  final String title;
  final String description;
  final String imageUrl;
  final String metaLeft;
  final String metaRight;
  final bool isVideo;
  final bool isFeatured;
  final bool isPinned;
  final String? durationLabel;
  final String? fullMediaUrl;
  final String? externalUrl;

  const _GalleryCardData({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.metaLeft,
    required this.metaRight,
    required this.isVideo,
    this.isFeatured = false,
    this.isPinned = false,
    this.durationLabel,
    this.fullMediaUrl,
    this.externalUrl,
  });

  static _GalleryCardData fromMedia(MediaGalleryItem item) {
    final dt = item.createdAt;
    final dateLabel = dt == null ? '—' : _fmtDate(dt);
    return _GalleryCardData(
      title: item.title,
      description: item.description,
      imageUrl: (item.thumbnailUrl ?? item.mediaUrl).trim().isEmpty
          ? _fallbackImage
          : (item.thumbnailUrl ?? item.mediaUrl),
      metaLeft: dateLabel,
      metaRight: item.mediaType == MediaType.video ? 'فيديو' : 'صور',
      isVideo: item.mediaType == MediaType.video,
      isFeatured: item.isFeatured,
      isPinned: item.isPinned,
      durationLabel: item.mediaType == MediaType.video ? '—' : null,
      fullMediaUrl: item.mediaUrl,
      externalUrl: item.externalUrl,
    );
  }

  static _GalleryCardData fromActivity(Activity a) {
    return _GalleryCardData(
      title: a.title,
      description: a.description,
      imageUrl: (a.imageUrl ?? '').trim().isEmpty
          ? _fallbackImage
          : a.imageUrl!,
      metaLeft: _fmtDate(a.startDate),
      metaRight: _activityTypeAr(a.type),
      isVideo: false,
    );
  }
}

String _fmtDate(DateTime d) {
  // Keep it simple and local-friendly: 15 مايو 2023
  const months = <int, String>{
    1: 'يناير',
    2: 'فبراير',
    3: 'مارس',
    4: 'أبريل',
    5: 'مايو',
    6: 'يونيو',
    7: 'يوليو',
    8: 'أغسطس',
    9: 'سبتمبر',
    10: 'أكتوبر',
    11: 'نوفمبر',
    12: 'ديسمبر',
  };
  return '${d.day} ${months[d.month] ?? ''} ${d.year}';
}

String _activityTypeAr(ActivityType t) {
  switch (t) {
    case ActivityType.conference:
      return 'مؤتمرات';
    case ActivityType.exhibition:
      return 'معارض';
    case ActivityType.ceremony:
      return 'تكريم';
    case ActivityType.seminar:
      return 'ندوات';
    case ActivityType.workshop:
      return 'ورش عمل';
    case ActivityType.course:
      return 'دورات';
    case ActivityType.competition:
      return 'مسابقات';
    case ActivityType.lecture:
      return 'محاضرات';
  }
}

const String _fallbackImage = 'assets/images/hero_banner.png';

const List<_GalleryCardData> _demoPhotos = <_GalleryCardData>[
  _GalleryCardData(
    title: 'افتتاح مسجد جديد في غزة',
    description: 'افتتاح مسجد الرحمن في منطقة الشجاعية بحضور رسمي وشعبي',
    imageUrl:
        'https://images.unsplash.com/photo-1587614382346-4ec70e388b28?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    metaLeft: '15 مايو 2023',
    metaRight: 'مساجد',
    isVideo: false,
  ),
  _GalleryCardData(
    title: 'ترميم مسجد الأقصى المبارك',
    description:
        'أعمال ترميم وصيانة في المسجد الأقصى المبارك بالتعاون مع جهات دولية',
    imageUrl:
        'https://images.unsplash.com/photo-1542810634-71277d95dcbb?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    metaLeft: '13 مايو 2023',
    metaRight: 'ترميم',
    isVideo: false,
  ),
  _GalleryCardData(
    title: 'مؤتمر الأوقاف الإسلامي',
    description: 'مؤتمر سنوي يناقش دور الأوقاف في التنمية المستدامة',
    imageUrl:
        'https://images.unsplash.com/photo-1566008885218-90abf9200ddb?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    metaLeft: '11 مايو 2023',
    metaRight: 'مؤتمرات',
    isVideo: false,
  ),
  _GalleryCardData(
    title: 'مشروع وقف شمسي جديد',
    description:
        'تركيب ألواح شمسية في مسجد عمر بن الخطاب لترشيد استهلاك الكهرباء',
    imageUrl:
        'https://images.unsplash.com/photo-1509391366360-2e959784a276?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    metaLeft: '9 مايو 2023',
    metaRight: 'مشاريع',
    isVideo: false,
  ),
];

const List<_GalleryCardData> _demoVideos = <_GalleryCardData>[
  _GalleryCardData(
    title: 'جولة في مشروع ترميم مسجد النصر',
    description:
        'جولة ميدانية توضح مراحل العمل في ترميم مسجد النصر في مدينة غزة',
    imageUrl:
        'https://images.unsplash.com/photo-1545235617-9465d2a55698?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    metaLeft: '14 مايو 2023',
    metaRight: 'ترميم',
    isVideo: true,
    durationLabel: '3:45',
  ),
  _GalleryCardData(
    title: 'كلمة الوزير حول أهمية الوقف',
    description:
        'كلمة معالي الوزير في مؤتمر الأوقاف السنوي حول أهمية الوقف في المجتمع',
    imageUrl:
        'https://images.unsplash.com/photo-1566008885218-90abf9200ddb?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    metaLeft: '12 مايو 2023',
    metaRight: 'خطابات',
    isVideo: true,
    durationLabel: '5:20',
  ),
  _GalleryCardData(
    title: 'تقرير عن مشاريع الأوقاف 2023',
    description:
        'تقرير مصور يستعرض أبرز مشاريع وإنجازات الوزارة خلال العام 2023',
    imageUrl:
        'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    metaLeft: '10 مايو 2023',
    metaRight: 'تقارير',
    isVideo: true,
    durationLabel: '7:15',
  ),
  _GalleryCardData(
    title: 'مقابلة حول خدمات الوزارة الإلكترونية',
    description:
        'مقابلة تلفزيونية حول الخدمات الإلكترونية الجديدة التي تقدمها الوزارة',
    imageUrl:
        'https://images.unsplash.com/photo-1545235617-9465d2a55698?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    metaLeft: '8 مايو 2023',
    metaRight: 'مقابلات',
    isVideo: true,
    durationLabel: '4:30',
  ),
];

const List<_GalleryCardData> _demoEvents = <_GalleryCardData>[
  _GalleryCardData(
    title: 'مؤتمر الأوقاف والتنمية',
    description: 'مؤتمر علمي حول دور الأوقاف في تنمية المجتمع',
    imageUrl:
        'https://images.unsplash.com/photo-1587614382346-4ec70e388b28?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    metaLeft: '15 مايو 2023',
    metaRight: 'مؤتمرات',
    isVideo: false,
  ),
  _GalleryCardData(
    title: 'افتتاح مسجد جديد',
    description: 'حفل افتتاح مسجد السلام في محافظة رام الله',
    imageUrl:
        'https://images.unsplash.com/photo-1519735777090-ec97162dc266?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    metaLeft: '13 مايو 2023',
    metaRight: 'افتتاحات',
    isVideo: false,
  ),
  _GalleryCardData(
    title: 'معرض التراث الإسلامي',
    description: 'معرض التراث الإسلامي الفلسطيني في مدينة الخليل',
    imageUrl:
        'https://images.unsplash.com/photo-1545235617-9465d2a55698?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    metaLeft: '11 مايو 2023',
    metaRight: 'معارض',
    isVideo: false,
  ),
  _GalleryCardData(
    title: 'حفل تكريم المتبرعين',
    description: 'حفل تكريم المتبرعين لمشاريع الأوقاف في فلسطين',
    imageUrl:
        'https://images.unsplash.com/photo-1565992441121-4367c2967103?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    metaLeft: '9 مايو 2023',
    metaRight: 'تكريم',
    isVideo: false,
  ),
];
