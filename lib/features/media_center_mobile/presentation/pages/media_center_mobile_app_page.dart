
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqf/app/routing/app_routes.dart';

import '../../data/models/media_center_mobile_models.dart';
import '../providers/media_center_mobile_providers.dart';
import '../widgets/media_center_mobile_visual_contract.dart';

class MediaCenterMobileAppPage extends ConsumerStatefulWidget {
  const MediaCenterMobileAppPage({super.key});

  @override
  ConsumerState<MediaCenterMobileAppPage> createState() =>
      _MediaCenterMobileAppPageState();
}

class _MediaCenterMobileAppPageState
    extends ConsumerState<MediaCenterMobileAppPage> {
  MediaCenterMobileFamily _selectedFamily = MediaCenterMobileFamily.news;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(mediaCenterMobileSnapshotProvider);

    return MediaCenterMobileShell(
      title: 'المركز الإعلامي الرسمي',
      body: snapshot.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _MobileErrorState(
          message: error.toString(),
          onRetry: _refresh,
        ),
        data: (data) => RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: MediaCenterOfficialHero(
                  title: 'تطبيق المركز الإعلامي',
                  subtitle:
                      'قراءة رسمية من media_center عبر API edge فقط. وسائل التواصل تشارك الرابط الرسمي ولا تصبح المصدر الأصلي.',
                  icon: Icons.verified_outlined,
                  chips: [
                    MediaCenterContractChip(
                      label: _selectedFamily.labelAr,
                      icon: Icons.tune,
                      emphasis: true,
                    ),
                    MediaCenterContractChip(
                      label: '${data.totalCount} عنصر',
                      icon: Icons.storage_outlined,
                    ),
                    const MediaCenterContractChip(
                      label: 'API edge',
                      icon: Icons.hub_outlined,
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: _MobileSearchBox(
                  value: _query,
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              _MobileItemsList(
                items: _filter(data.itemsFor(_selectedFamily)),
                emptyLabel:
                    'لا توجد عناصر ضمن ${_selectedFamily.labelAr} حاليًا.',
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.mediaCenterMobilePublish),
        backgroundColor: MediaCenterMobileVisualContract.platformGold,
        foregroundColor: MediaCenterMobileVisualContract.platformDark,
        icon: const Icon(Icons.edit_note),
        label: const Text(
          'نشر رسمي',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      bottomNavigationBar: _MediaCenterBottomNavigation(
        selectedFamily: _selectedFamily,
        onChanged: (family) {
          setState(() {
            _selectedFamily = family;
            _query = '';
          });
        },
      ),
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(mediaCenterMobileSnapshotProvider);
    await ref.read(mediaCenterMobileSnapshotProvider.future);
  }

  List<MediaCenterMobileItem> _filter(List<MediaCenterMobileItem> items) {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return items;
    return items.where((item) {
      return item.title.toLowerCase().contains(normalized) ||
          item.summary.toLowerCase().contains(normalized) ||
          item.ownerName.toLowerCase().contains(normalized);
    }).toList(growable: false);
  }
}

class _MediaCenterBottomNavigation extends StatelessWidget {
  const _MediaCenterBottomNavigation({
    required this.selectedFamily,
    required this.onChanged,
  });

  final MediaCenterMobileFamily selectedFamily;
  final ValueChanged<MediaCenterMobileFamily> onChanged;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: Colors.white,
      indicatorColor: MediaCenterMobileVisualContract.platformGold
          .withOpacity(0.22),
      selectedIndex: MediaCenterMobileFamily.values.indexOf(selectedFamily),
      onDestinationSelected: (index) {
        onChanged(MediaCenterMobileFamily.values[index]);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.article_outlined),
          selectedIcon: Icon(
            Icons.article,
            color: MediaCenterMobileVisualContract.platformBlue,
          ),
          label: 'الأخبار',
        ),
        NavigationDestination(
          icon: Icon(Icons.campaign_outlined),
          selectedIcon: Icon(
            Icons.campaign,
            color: MediaCenterMobileVisualContract.platformBlue,
          ),
          label: 'الإعلانات',
        ),
        NavigationDestination(
          icon: Icon(Icons.event_available_outlined),
          selectedIcon: Icon(
            Icons.event_available,
            color: MediaCenterMobileVisualContract.platformBlue,
          ),
          label: 'الأنشطة',
        ),
      ],
    );
  }
}

class _MobileSearchBox extends StatelessWidget {
  const _MobileSearchBox({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        textDirection: TextDirection.rtl,
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: 'بحث سريع داخل المركز الإعلامي',
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}

class _MobileItemsList extends StatelessWidget {
  const _MobileItemsList({
    required this.items,
    required this.emptyLabel,
  });

  final List<MediaCenterMobileItem> items;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              emptyLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: MediaCenterMobileVisualContract.muted,
              ),
            ),
          ),
        ),
      );
    }

    return SliverList.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        return Padding(
          padding: EdgeInsets.fromLTRB(16, index == 0 ? 0 : 0, 16, 0),
          child: _MobileMediaCard(item: item),
        );
      },
    );
  }
}

class _MobileMediaCard extends StatelessWidget {
  const _MobileMediaCard({required this.item});

  final MediaCenterMobileItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _showDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MediaThumb(item: item),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        MediaCenterSoftChip(
                          label: item.family.labelAr,
                          gold: true,
                        ),
                        if (item.hasAttachment)
                          const MediaCenterSoftChip(
                            label: 'مرفق محكوم',
                            icon: Icons.attach_file,
                          ),
                        if (item.isFallback)
                          const MediaCenterSoftChip(
                            label: 'Fallback محلي',
                            red: true,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: MediaCenterMobileVisualContract.text,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.summary,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: MediaCenterMobileVisualContract.muted,
                        fontSize: 12.5,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_outlined,
                          size: 15,
                          color: MediaCenterMobileVisualContract.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.publishedLabelAr,
                          style: const TextStyle(
                            color: MediaCenterMobileVisualContract.muted,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            item.ownerName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: MediaCenterMobileVisualContract.muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.72,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          builder: (context, controller) => ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  height: 1.35,
                  color: MediaCenterMobileVisualContract.text,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  MediaCenterSoftChip(label: item.family.labelAr, gold: true),
                  MediaCenterSoftChip(label: item.scopeLabel),
                  MediaCenterSoftChip(label: item.publishedLabelAr),
                  if (item.hasAttachment)
                    const MediaCenterSoftChip(
                      label: 'المرفق لا يصبح public تلقائيًا',
                      icon: Icons.verified_user_outlined,
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                item.body.isEmpty ? item.summary : item.body,
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 14,
                  height: 1.7,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'قرار المصدر',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: MediaCenterMobileVisualContract.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${item.family.apiEdgeSurface}\n'
                'owner schema: media_center\n'
                'public schema: API edge فقط',
                style: const TextStyle(
                  color: MediaCenterMobileVisualContract.muted,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MediaThumb extends StatelessWidget {
  const _MediaThumb({required this.item});

  final MediaCenterMobileItem item;

  @override
  Widget build(BuildContext context) {
    final url = item.imageUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 78,
        height: 78,
        color: const Color(0xFFE2E8F0),
        child: url == null || url.trim().isEmpty
            ? Icon(
                _iconFor(item.family),
                color: MediaCenterMobileVisualContract.platformBlue,
              )
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  _iconFor(item.family),
                  color: MediaCenterMobileVisualContract.platformBlue,
                ),
              ),
      ),
    );
  }

  IconData _iconFor(MediaCenterMobileFamily family) {
    switch (family) {
      case MediaCenterMobileFamily.news:
        return Icons.article_outlined;
      case MediaCenterMobileFamily.announcements:
        return Icons.campaign_outlined;
      case MediaCenterMobileFamily.activities:
        return Icons.event_available_outlined;
    }
  }
}

class _MobileErrorState extends StatelessWidget {
  const _MobileErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_outlined,
                  size: 44,
                  color: MediaCenterMobileVisualContract.royalRed,
                ),
                const SizedBox(height: 12),
                const Text(
                  'تعذر تحميل تطبيق المركز الإعلامي',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: MediaCenterMobileVisualContract.muted,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  style: MediaCenterMobileVisualContract.primaryButtonStyle(),
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
