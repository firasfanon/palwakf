import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/data/models/media_gallery_item.dart';
import 'package:waqf/presentation/providers/admin_media_gallery_provider.dart';
import 'package:waqf/presentation/providers/media_gallery_provider.dart';
import 'package:waqf/presentation/providers/org_units_provider.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';

import '../common/section_header.dart';
import '../forms/media_gallery_item_form_dialog.dart';
import '../shared/shared_content_admin_ui.dart';
import '../shared/shared_content_scope.dart';

class MediaGalleryManagementSection extends ConsumerStatefulWidget {
  const MediaGalleryManagementSection({
    super.key,
    this.initialType = MediaType.photo,
    this.allowTypeChange = true,
    this.headerTitle,
    this.headerDescription,
  });

  final MediaType initialType;
  final bool allowTypeChange;
  final String? headerTitle;
  final String? headerDescription;

  @override
  ConsumerState<MediaGalleryManagementSection> createState() =>
      _MediaGalleryManagementSectionState();
}

enum _MediaPublicationFilter { all, published, scheduled, inactive }

class _MediaGalleryManagementSectionState
    extends ConsumerState<MediaGalleryManagementSection> {
  String _unitSlug = 'home';
  late MediaType _type;
  bool _includeInactive = true;
  bool _selectionMode = false;
  bool _featuredOnly = false;
  bool _pinnedOnly = false;
  _MediaPublicationFilter _publicationFilter = _MediaPublicationFilter.all;
  final Set<String> _selectedIds = <String>{};
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  @override
  void didUpdateWidget(covariant MediaGalleryManagementSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.allowTypeChange &&
        oldWidget.initialType != widget.initialType) {
      _type = widget.initialType;
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(orgUnitsListProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        final content = _buildResponsiveContent(context, unitsAsync, compact);

        return Container(
          padding: EdgeInsets.all(compact ? 12 : 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigo.withValues(alpha: 0.05),
                Colors.indigo.withValues(alpha: 0.015),
              ],
            ),
            borderRadius: BorderRadius.circular(compact ? 14 : 16),
            border: Border.all(color: Colors.indigo.withValues(alpha: 0.18)),
          ),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: content,
          ),
        );
      },
    );
  }

  Widget _buildResponsiveContent(
    BuildContext context,
    AsyncValue<List<Map<String, dynamic>>> unitsAsync,
    bool compact,
  ) {
    final body = unitsAsync.when(
      data: (units) {
        final safeUnits = List<Map<String, dynamic>>.from(units);
        _ensureUnitSlugValid(safeUnits);
        return _buildMediaBody(context, safeUnits, compact: compact);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _buildError(e),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
      children: [
        _buildHeader(context),
        SizedBox(height: compact ? 12 : 16),
        body,
      ],
    );
  }

  Widget _buildMediaBody(
    BuildContext context,
    List<Map<String, dynamic>> safeUnits, {
    required bool compact,
  }) {
    final workspace = _buildWorkspace(safeUnits, compact: compact);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
      children: [
        _buildControls(context, safeUnits, compact: compact),
        const SizedBox(height: 12),
        SharedHomepageCountControlCard(
          key: ValueKey('media-home-count-$_unitSlug-${_type.name}'),
          unitSlug: _unitSlug,
          unitId: _resolveUnitId(safeUnits),
          primarySectionName: 'pwf_media_gallery_images',
          aliases: const ['pwf_media_gallery', 'pwf_media_gallery_videos'],
          title: 'التحكم في عدد بطاقات المعرض في الصفحة الرئيسية',
          description:
              'حدد عدد بطاقات الصور/الفيديو التي تظهر في المعرض الإعلامي على الصفحة الرئيسية ضمن النطاق الحالي، مع التحكم في زر عرض الكل.',
          defaultHomeLimit: 4,
        ),
        const SizedBox(height: 12),
        SharedContentScopeBadge(slug: _unitSlug),
        const SizedBox(height: 8),
        Text(
          sharedContentScopeHint(_unitSlug),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF4B5563),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 12),
        workspace,
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final defaultTitle = _type == MediaType.photo
        ? 'إدارة معرض الصور'
        : 'إدارة الفيديوهات';
    final defaultDescription = _type == MediaType.photo
        ? 'رفع الصور، تنظيمها، التحكم في نشرها، وتمكين الحذف الفردي والجماعي ضمن نفس طبقة الوسائط الموحدة.'
        : 'رفع الفيديو أو ربطه، تنظيم الأرشيف المرئي، وإدارة النشر والحذف من مساحة عمل موحدة.';

    final actions = Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: () => setState(() => _includeInactive = !_includeInactive),
          icon: Icon(
            _includeInactive ? Icons.visibility : Icons.visibility_off,
            size: 18,
            color: Colors.indigo,
          ),
          label: Text(_includeInactive ? 'يشمل المخفي' : 'المنشور فقط'),
        ),
        OutlinedButton.icon(
          onPressed: _toggleSelectionMode,
          icon: Icon(
            _selectionMode ? Icons.checklist_rtl : Icons.check_box_outlined,
            size: 18,
            color: Colors.indigo,
          ),
          label: Text(_selectionMode ? 'إنهاء التحديد' : 'تحديد متعدد'),
        ),
        PopupMenuButton<String>(
          tooltip: 'طرق الحذف',
          onSelected: _handleDeleteMode,
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'selected', child: Text('حذف المحدد')),
            PopupMenuItem(value: 'current', child: Text('حذف النتائج الحالية')),
            PopupMenuItem(value: 'inactive', child: Text('حذف المخفي')),
            PopupMenuItem(value: 'scheduled', child: Text('حذف المجدول')),
          ],
          child: OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.delete_sweep_outlined, size: 18),
            label: const Text('طرق الحذف'),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _handleQuickAdd(MediaType.photo),
          icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
          label: const Text('رفع صورة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _handleQuickAdd(MediaType.video),
          icon: const Icon(Icons.video_call_outlined, size: 20),
          label: const Text('رفع فيديو'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.royalRed,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: _type == MediaType.photo
              ? Icons.photo_library
              : Icons.ondemand_video,
          title: widget.headerTitle ?? defaultTitle,
          color: Colors.indigo,
          trailing: actions,
        ),
        if ((widget.headerDescription ?? defaultDescription)
            .trim()
            .isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.headerDescription ?? defaultDescription,
            style: const TextStyle(
              color: Color(0xFF4B5563),
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  void _ensureUnitSlugValid(List<Map<String, dynamic>> units) {
    final slugs = units.map((u) => (u['slug'] ?? '').toString()).toSet();
    if (!slugs.contains(_unitSlug)) {
      _unitSlug = slugs.contains('home')
          ? 'home'
          : (slugs.isNotEmpty ? slugs.first : 'home');
    }
  }

  String _resolveUnitId(List<Map<String, dynamic>> units) {
    for (final unit in units) {
      final slug = (unit['slug'] ?? '').toString();
      if (slug == _unitSlug) {
        return (unit['id'] ?? '').toString();
      }
    }
    return '';
  }

  Widget _buildControls(
    BuildContext context,
    List<Map<String, dynamic>> units, {
    required bool compact,
  }) {
    final unitItems = List<Map<String, dynamic>>.from(units);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final unitFieldWidth = compact ? availableWidth : 320.0;
        final typeFieldWidth = compact ? availableWidth : 240.0;
        final searchFieldWidth = compact ? availableWidth : 360.0;

        return Container(
          padding: EdgeInsets.all(compact ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: compact ? 10 : 16,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: unitFieldWidth,
                    child: DropdownButtonFormField<String>(
                      value: _unitSlug,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'الوحدة / الفرع',
                        border: OutlineInputBorder(),
                      ),
                      items: unitItems.map((u) {
                        final slug = (u['slug'] ?? '').toString();
                        final nameAr = (u['name_ar'] ?? slug).toString();
                        final code = (u['code'] ?? '').toString();
                        final isActive = (u['is_active'] as bool?) ?? true;
                        final base = code.isEmpty ? nameAr : '$nameAr — $code';
                        final label = isActive ? base : '$base (موقوف)';
                        return DropdownMenuItem<String>(
                          value: slug,
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      selectedItemBuilder: (context) => unitItems.map((u) {
                        final slug = (u['slug'] ?? '').toString();
                        final nameAr = (u['name_ar'] ?? slug).toString();
                        final code = (u['code'] ?? '').toString();
                        final isActive = (u['is_active'] as bool?) ?? true;
                        final base = code.isEmpty ? nameAr : '$nameAr — $code';
                        final label = isActive ? base : '$base (موقوف)';
                        return Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() {
                        _unitSlug = v ?? _unitSlug;
                        _clearSelection();
                      }),
                    ),
                  ),
                  if (widget.allowTypeChange)
                    SizedBox(
                      width: typeFieldWidth,
                      child: DropdownButtonFormField<MediaType>(
                        value: _type,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'نوع المعرض',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: MediaType.photo,
                            child: Text('صور'),
                          ),
                          DropdownMenuItem(
                            value: MediaType.video,
                            child: Text('فيديو'),
                          ),
                        ],
                        onChanged: (v) => setState(() {
                          _type = v ?? _type;
                          _clearSelection();
                        }),
                      ),
                    ),
                  SizedBox(
                    width: searchFieldWidth,
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        labelText: 'بحث داخل المعرض',
                        hintText: 'عنوان / وصف / رابط خارجي',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            _search.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _filterChip(
                    label: 'الكل',
                    active: _publicationFilter == _MediaPublicationFilter.all,
                    onTap: () => setState(
                      () => _publicationFilter = _MediaPublicationFilter.all,
                    ),
                  ),
                  _filterChip(
                    label: 'المنشور',
                    active:
                        _publicationFilter == _MediaPublicationFilter.published,
                    onTap: () => setState(
                      () => _publicationFilter =
                          _MediaPublicationFilter.published,
                    ),
                  ),
                  _filterChip(
                    label: 'المجدول',
                    active:
                        _publicationFilter == _MediaPublicationFilter.scheduled,
                    onTap: () => setState(
                      () => _publicationFilter =
                          _MediaPublicationFilter.scheduled,
                    ),
                  ),
                  _filterChip(
                    label: 'المخفي',
                    active:
                        _publicationFilter == _MediaPublicationFilter.inactive,
                    onTap: () => setState(
                      () =>
                          _publicationFilter = _MediaPublicationFilter.inactive,
                    ),
                  ),
                  FilterChip(
                    label: const Text('المميز فقط'),
                    selected: _featuredOnly,
                    onSelected: (v) => setState(() => _featuredOnly = v),
                  ),
                  FilterChip(
                    label: const Text('المثبت فقط'),
                    selected: _pinnedOnly,
                    onSelected: (v) => setState(() => _pinnedOnly = v),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _filterChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => onTap(),
      selectedColor: Colors.indigo.withValues(alpha: 0.16),
      labelStyle: TextStyle(
        color: active ? Colors.indigo.shade800 : const Color(0xFF374151),
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildWorkspace(
    List<Map<String, dynamic>> units, {
    required bool compact,
  }) {
    final query = AdminMediaGalleryQuery(
      unitSlug: _unitSlug,
      mediaType: _type,
      includeInactive: _includeInactive,
      search: _search.text.trim(),
    );

    final itemsAsync = ref.watch(adminMediaGalleryItemsProvider(query));
    return itemsAsync.when(
      data: (items) {
        final visibleItems = _applyLocalFilters(items);
        _selectedIds.removeWhere((id) => !visibleItems.any((e) => e.id == id));

        final list = visibleItems.isEmpty
            ? _buildEmpty()
            : _buildGalleryList(visibleItems, units, query, compact: compact);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
          children: [
            _buildStatsRow(items, visibleItems),
            const SizedBox(height: 12),
            _buildListSummary(visibleItems),
            const SizedBox(height: 12),
            list,
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(48.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => _buildError(e),
    );
  }

  Widget _buildGalleryList(
    List<MediaGalleryItem> visibleItems,
    List<Map<String, dynamic>> units,
    AdminMediaGalleryQuery query, {
    required bool compact,
  }) {
    if (compact) {
      return Column(
        children: visibleItems
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  height: 420,
                  width: double.infinity,
                  child: _buildCard(item, units, query),
                ),
              ),
            )
            .toList(growable: false),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount = 3;
        double childAspectRatio = 0.74;
        if (width < 760) {
          crossAxisCount = 1;
          childAspectRatio = 0.70;
        } else if (width < 1120) {
          crossAxisCount = 2;
          childAspectRatio = 0.72;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: visibleItems.length,
          itemBuilder: (ctx, i) => _buildCard(visibleItems[i], units, query),
        );
      },
    );
  }

  List<MediaGalleryItem> _applyLocalFilters(List<MediaGalleryItem> items) {
    return items
        .where((item) {
          if (_featuredOnly && !item.isFeatured) return false;
          if (_pinnedOnly && !item.isPinned) return false;
          switch (_publicationFilter) {
            case _MediaPublicationFilter.all:
              return true;
            case _MediaPublicationFilter.published:
              return item.isPublishedNow;
            case _MediaPublicationFilter.scheduled:
              return item.isActive &&
                  item.publishAt != null &&
                  item.publishAt!.isAfter(DateTime.now());
            case _MediaPublicationFilter.inactive:
              return !item.isActive;
          }
        })
        .toList(growable: false);
  }

  Widget _buildStatsRow(
    List<MediaGalleryItem> allItems,
    List<MediaGalleryItem> visibleItems,
  ) {
    final published = allItems.where((e) => e.isPublishedNow).length;
    final featured = allItems.where((e) => e.isFeatured).length;
    final scheduled = allItems
        .where(
          (e) =>
              e.isActive &&
              e.publishAt != null &&
              e.publishAt!.isAfter(DateTime.now()),
        )
        .length;
    final selected = _selectedIds.length;

    final stats = [
      _MediaStatData(
        'الإجمالي',
        '${allItems.length}',
        Icons.perm_media_outlined,
      ),
      _MediaStatData('الظاهر الآن', '$published', Icons.public_outlined),
      _MediaStatData('المميز', '$featured', Icons.star_outline_rounded),
      _MediaStatData('المجدول', '$scheduled', Icons.schedule_outlined),
      _MediaStatData(
        'نتائج الصفحة',
        '${visibleItems.length}',
        Icons.filter_alt_outlined,
      ),
      _MediaStatData('المحدد', '$selected', Icons.check_box_outlined),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: stats.map(_buildStatCard).toList(growable: false),
    );
  }

  Widget _buildStatCard(_MediaStatData stat) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(stat.icon, color: Colors.indigo, size: 20),
          const SizedBox(height: 10),
          Text(
            stat.value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListSummary(List<MediaGalleryItem> items) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _summaryChip(Icons.push_pin_rounded, 'المثبت أولًا'),
        _summaryChip(Icons.auto_awesome_rounded, 'المميز بعده'),
        _summaryChip(Icons.sort_rounded, 'ثم الترتيب اليدوي'),
        _summaryChip(Icons.schedule_rounded, 'ثم موعد النشر'),
        if (_selectionMode)
          _summaryChip(
            Icons.checklist_rtl,
            'وضع تحديد متعدد (${_selectedIds.length})',
          ),
        if (items.isNotEmpty)
          _summaryChip(
            _type == MediaType.photo
                ? Icons.photo_library
                : Icons.video_library,
            'النتائج الحالية ${items.length}',
          ),
      ],
    );
  }

  Widget _summaryChip(IconData icon, String label) {
    final maxWidth = MediaQuery.sizeOf(context).width < 520
        ? MediaQuery.sizeOf(context).width - 72
        : 280.0;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth.clamp(160.0, 280.0).toDouble(),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.indigo.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.indigo.withValues(alpha: 0.14)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.indigo),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    MediaGalleryItem item,
    List<Map<String, dynamic>> units,
    AdminMediaGalleryQuery query,
  ) {
    final thumb = (item.thumbnailUrl ?? '').trim().isNotEmpty
        ? item.thumbnailUrl!
        : item.mediaUrl;
    final isVideo = item.mediaType == MediaType.video;
    final publishLabel = item.publishAt == null
        ? 'فوري'
        : item.publishAt!.toLocal().toString().substring(0, 16);
    final isSelected = _selectedIds.contains(item.id);

    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? Colors.indigo : Colors.grey.shade200,
          width: isSelected ? 1.4 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (_selectionMode) {
            _toggleSelection(item.id);
            return;
          }
          _handleEdit(item, units);
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: thumb,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Icon(
                            isVideo
                                ? Icons.video_library_outlined
                                : Icons.image_outlined,
                            size: 42,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isVideo)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  if (_selectionMode)
                    Positioned(
                      left: 10,
                      top: 10,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (_) => _toggleSelection(item.id),
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
                        _statusBadge(
                          item.isActive ? 'نشط' : 'مخفي',
                          item.isActive ? AppConstants.success : Colors.grey,
                        ),
                        if (item.isPinned)
                          _statusBadge('مثبت', const Color(0xFF7C3AED)),
                        if (item.isFeatured)
                          _statusBadge('مميز', const Color(0xFFF59E0B)),
                        if (item.publishAt != null &&
                            item.publishAt!.isAfter(DateTime.now()))
                          _statusBadge('مجدول', const Color(0xFF0EA5E9)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _metaPill('ترتيب: ${item.displayOrder}'),
                        _metaPill('نشر: $publishLabel'),
                        if ((item.externalUrl ?? '').trim().isNotEmpty)
                          _metaPill('خارجي'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description.trim().isEmpty
                          ? (isVideo
                                ? 'فيديو مرتبط بالصفحة الديناميكية الحالية.'
                                : 'صورة مرتبطة بالصفحة الديناميكية الحالية.')
                          : item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700], height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Switch(
                          value: item.isActive,
                          onChanged: (v) => _handleToggleActive(item, v, query),
                          activeColor: Colors.indigo,
                        ),
                        IconButton(
                          tooltip: 'تعديل',
                          onPressed: () => _handleEdit(item, units),
                          icon: const Icon(Icons.edit_outlined, size: 20),
                        ),
                        IconButton(
                          tooltip: 'حذف',
                          onPressed: () => _handleDelete(item, query),
                          icon: Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaPill(String label) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 180),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.indigo.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.indigo[700], fontSize: 11),
        ),
      ),
    );
  }

  Widget _statusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    final noun = _type == MediaType.photo ? 'صور' : 'فيديوهات';
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _type == MediaType.photo
                  ? Icons.photo_library_outlined
                  : Icons.ondemand_video_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد عناصر في هذا المعرض',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أضف $noun وارفع الملفات مباشرة من نافذة الإضافة للوحدة أو للوزارة ضمن النطاق المحدد.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(Object e) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'حدث خطأ أثناء تحميل المعرض: $e',
              style: TextStyle(color: Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) {
        _selectedIds.clear();
      }
    });
  }

  void _clearSelection() {
    _selectedIds.clear();
    _selectionMode = false;
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _handleQuickAdd(MediaType type) async {
    final oldType = _type;
    setState(() => _type = type);
    await _handleAdd();
    if (mounted && !widget.allowTypeChange) {
      setState(() => _type = oldType);
    }
  }

  Future<void> _handleAdd() async {
    final units = await ref.read(orgUnitsListProvider.future);
    final unitRow = units.firstWhere(
      (u) => (u['slug'] ?? '').toString() == _unitSlug,
      orElse: () => units.first,
    );
    final unitId = (unitRow['id'] ?? '').toString();

    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => MediaGalleryItemFormDialog(
        units: units,
        initialUnitId: unitId,
        initialType: _type,
        onSubmit: (res) => _submitCreate(res),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _handleEdit(
    MediaGalleryItem item,
    List<Map<String, dynamic>> units,
  ) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => MediaGalleryItemFormDialog(
        item: item,
        units: units,
        initialUnitId: item.unitId,
        initialType: item.mediaType,
        onSubmit: (res) => _submitUpdate(item.id, res),
      ),
    );

    if (!mounted) return;
    setState(() {});
  }

  Future<void> _handleToggleActive(
    MediaGalleryItem item,
    bool value,
    AdminMediaGalleryQuery query,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(mediaGalleryRepositoryProvider);
    try {
      await repo.setActive(item.id, value);
      _invalidateMedia(itemUnitSlug: _unitSlug, query: query);
    } catch (e) {
      _showMediaGallerySnackBar(
        messenger,
        'فشل تحديث الحالة: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _handleDelete(
    MediaGalleryItem item,
    AdminMediaGalleryQuery query,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف "${item.title}" نهائيًا؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final repo = ref.read(mediaGalleryRepositoryProvider);
    try {
      await repo.deleteItem(item.id);
      _selectedIds.remove(item.id);
      _invalidateMedia(itemUnitSlug: _unitSlug, query: query);
      _showMediaGallerySnackBar(
        messenger,
        'تم الحذف بنجاح',
        backgroundColor: AppConstants.success,
      );
    } catch (e) {
      _showMediaGallerySnackBar(
        messenger,
        'فشل الحذف: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  void _showMediaGallerySnackBar(
    ScaffoldMessengerState messenger,
    String message, {
    Color? backgroundColor,
  }) {
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleDeleteMode(String mode) async {
    final messenger = ScaffoldMessenger.of(context);
    final query = AdminMediaGalleryQuery(
      unitSlug: _unitSlug,
      mediaType: _type,
      includeInactive: _includeInactive,
      search: _search.text.trim(),
    );
    final items = await ref.read(adminMediaGalleryItemsProvider(query).future);
    final filtered = _applyLocalFilters(items);

    List<MediaGalleryItem> targets;
    switch (mode) {
      case 'selected':
        targets = filtered
            .where((e) => _selectedIds.contains(e.id))
            .toList(growable: false);
        break;
      case 'inactive':
        targets = filtered.where((e) => !e.isActive).toList(growable: false);
        break;
      case 'scheduled':
        targets = filtered
            .where(
              (e) =>
                  e.isActive &&
                  e.publishAt != null &&
                  e.publishAt!.isAfter(DateTime.now()),
            )
            .toList(growable: false);
        break;
      case 'current':
      default:
        targets = filtered;
        break;
    }

    if (targets.isEmpty) {
      _showMediaGallerySnackBar(
        messenger,
        'لا توجد عناصر مطابقة لهذه العملية.',
      );
      return;
    }

    if (!mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف الجماعي'),
        content: Text('سيتم حذف ${targets.length} عنصرًا. هل تريد المتابعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final repo = ref.read(mediaGalleryRepositoryProvider);
      await repo.deleteItems(targets.map((e) => e.id));
      _selectedIds.removeWhere((id) => targets.any((e) => e.id == id));
      _invalidateMedia(itemUnitSlug: _unitSlug, query: query);
      _showMediaGallerySnackBar(
        messenger,
        'تم حذف ${targets.length} عنصرًا بنجاح',
        backgroundColor: AppConstants.success,
      );
    } catch (e) {
      _showMediaGallerySnackBar(
        messenger,
        'فشل الحذف الجماعي: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _submitCreate(MediaGalleryFormResult res) async {
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(mediaGalleryRepositoryProvider);
    try {
      await repo.createItem(
        unitId: res.unitId,
        mediaType: res.type,
        title: res.title,
        description: res.description,
        mediaUrl: res.mediaUrl,
        thumbnailUrl: res.thumbnailUrl,
        externalUrl: res.externalUrl,
        isActive: res.isActive,
        displayOrder: res.displayOrder,
        isFeatured: res.isFeatured,
        isPinned: res.isPinned,
        publishAt: res.publishAt,
      );
      final unitSlug = await _slugForUnitId(res.unitId);
      final query = AdminMediaGalleryQuery(
        unitSlug: unitSlug,
        mediaType: res.type,
        includeInactive: _includeInactive,
        search: _search.text.trim(),
      );
      _invalidateMedia(itemUnitSlug: unitSlug, query: query);

      _showMediaGallerySnackBar(
        messenger,
        'تمت الإضافة بنجاح',
        backgroundColor: AppConstants.success,
      );
    } catch (e) {
      _showMediaGallerySnackBar(
        messenger,
        'فشل الإضافة: $e',
        backgroundColor: Colors.red,
      );
      rethrow;
    }
  }

  Future<void> _submitUpdate(String id, MediaGalleryFormResult res) async {
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(mediaGalleryRepositoryProvider);
    try {
      await repo.updateItem(
        id,
        unitId: res.unitId,
        mediaType: res.type,
        title: res.title,
        description: res.description,
        mediaUrl: res.mediaUrl,
        thumbnailUrl: res.thumbnailUrl,
        externalUrl: res.externalUrl,
        isActive: res.isActive,
        displayOrder: res.displayOrder,
        isFeatured: res.isFeatured,
        isPinned: res.isPinned,
        publishAt: res.publishAt,
      );

      final unitSlug = await _slugForUnitId(res.unitId);
      final query = AdminMediaGalleryQuery(
        unitSlug: unitSlug,
        mediaType: res.type,
        includeInactive: _includeInactive,
        search: _search.text.trim(),
      );
      _invalidateMedia(itemUnitSlug: unitSlug, query: query);

      _showMediaGallerySnackBar(
        messenger,
        'تم التحديث بنجاح',
        backgroundColor: AppConstants.success,
      );
    } catch (e) {
      _showMediaGallerySnackBar(
        messenger,
        'فشل التحديث: $e',
        backgroundColor: Colors.red,
      );
      rethrow;
    }
  }

  void _invalidateMedia({
    required String itemUnitSlug,
    required AdminMediaGalleryQuery query,
  }) {
    ref.invalidate(adminMediaGalleryItemsProvider(query));
    ref.invalidate(unitPhotosProvider(itemUnitSlug));
    ref.invalidate(unitVideosProvider(itemUnitSlug));
    if (itemUnitSlug != _unitSlug) {
      ref.invalidate(unitPhotosProvider(_unitSlug));
      ref.invalidate(unitVideosProvider(_unitSlug));
    }
  }

  Future<String> _slugForUnitId(String unitId) async {
    final selectedId = await ref.read(unitIdBySlugProvider(_unitSlug).future);
    if (selectedId == unitId) return _unitSlug;

    final units = await ref.read(orgUnitsListProvider.future);
    final row = units.firstWhere(
      (u) => (u['id'] ?? '').toString() == unitId,
      orElse: () => const <String, dynamic>{},
    );
    final slug = (row['slug'] ?? '').toString();
    return slug.isEmpty ? _unitSlug : slug;
  }
}

class _MediaStatData {
  const _MediaStatData(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}
