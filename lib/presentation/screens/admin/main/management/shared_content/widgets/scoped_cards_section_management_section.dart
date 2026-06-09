import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';
import 'package:waqf/presentation/providers/org_units_provider.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/shared/shared_content_admin_ui.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/shared/shared_content_scope.dart';

class ScopedCardsSectionManagementSection extends ConsumerStatefulWidget {
  const ScopedCardsSectionManagementSection({
    super.key,
    required this.sectionName,
    required this.title,
    required this.description,
    required this.defaultTitle,
    required this.defaultSubtitle,
    required this.defaultItems,
    this.primaryButtonLabel = 'حفظ',
    this.showLinks = true,
    this.publicPreviewRoute,
  });

  final String sectionName;
  final String title;
  final String description;
  final String defaultTitle;
  final String defaultSubtitle;
  final List<ScopedCardEditableItem> defaultItems;
  final String primaryButtonLabel;
  final bool showLinks;
  final String? publicPreviewRoute;

  @override
  ConsumerState<ScopedCardsSectionManagementSection> createState() =>
      _ScopedCardsSectionManagementSectionState();
}

class _ScopedCardsSectionManagementSectionState
    extends ConsumerState<ScopedCardsSectionManagementSection> {
  String _unitSlug = 'home';
  String _loadedKey = '';
  bool _enabled = true;
  bool _saving = false;
  bool _selectionMode = false;
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _searchController;
  final Set<int> _selectedIndices = <int>{};
  List<ScopedCardEditableItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _subtitleController = TextEditingController();
    _searchController = TextEditingController()
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _hydrateIfNeeded(List<HomepageSection> sections) {
    HomepageSection? section;
    for (final row in sections) {
      if (row.sectionName.trim().toLowerCase() == widget.sectionName) {
        section = row;
        break;
      }
    }
    final settings = section == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(section.settings);
    final rawItems = settings['items'] is List
        ? List<dynamic>.from(settings['items'] as List)
        : const <dynamic>[];
    final key =
        '${widget.sectionName}|$_unitSlug|${section?.id ?? 'none'}|${rawItems.length}|${settings['updated_at'] ?? ''}';
    if (_loadedKey == key) return;

    _enabled = settings['enabled'] is bool ? settings['enabled'] as bool : true;
    _titleController.text = (settings['title'] ?? widget.defaultTitle)
        .toString();
    _subtitleController.text = (settings['subtitle'] ?? widget.defaultSubtitle)
        .toString();
    _items = rawItems
        .map(ScopedCardEditableItem.fromMap)
        .toList(growable: true);
    if (_items.isEmpty) {
      _items = widget.defaultItems
          .map((e) => e.copyWith())
          .toList(growable: true);
    }
    _selectedIndices.clear();
    _selectionMode = false;
    _loadedKey = key;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      String? unitId;
      try {
        unitId = await ref.read(unitIdBySlugProvider(_unitSlug).future);
      } catch (_) {
        unitId = null;
      }

      final repository = ref.read(homepageRepositoryProvider);
      final nowIso = DateTime.now().toUtc().toIso8601String();
      await repository.saveSectionsMeta([
        HomepageSection(
          id: '',
          sectionName: widget.sectionName,
          settings: {
            'enabled': _enabled,
            'title': _titleController.text.trim(),
            'subtitle': _subtitleController.text.trim(),
            'items': _items.map((e) => e.toJson()).toList(growable: false),
          },
          isActive: _enabled,
          displayOrder: 0,
          createdAt: nowIso,
          updatedAt: nowIso,
          updatedBy: null,
          unitId: unitId,
        ),
      ], unitId: unitId);
      ref.invalidate(homepageSectionsForUnitProvider(_unitSlug));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حفظ ${widget.title} لهذا النطاق')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر الحفظ: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<int> _visibleIndices() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty)
      return List<int>.generate(_items.length, (index) => index);
    final matches = <int>[];
    for (var i = 0; i < _items.length; i++) {
      final row = _items[i];
      final haystack =
          '${row.title} ${row.description} ${row.icon} ${row.linkLabel} ${row.route}'
              .toLowerCase();
      if (haystack.contains(query)) matches.add(i);
    }
    return matches;
  }

  Future<void> _handleDeleteAction(
    String action,
    List<int> visibleIndices,
  ) async {
    final toDelete = <int>[];
    switch (action) {
      case 'selected':
        toDelete.addAll(_selectedIndices);
        break;
      case 'visible':
        toDelete.addAll(visibleIndices);
        break;
      case 'disabled':
        for (var i = 0; i < _items.length; i++) {
          if (!_items[i].enabled) toDelete.add(i);
        }
        break;
      case 'empty':
        for (var i = 0; i < _items.length; i++) {
          if (_items[i].title.trim().isEmpty &&
              _items[i].description.trim().isEmpty) {
            toDelete.add(i);
          }
        }
        break;
      default:
        return;
    }

    final unique = toDelete.toSet().toList()..sort();
    if (unique.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد بطاقات مطابقة لعملية الحذف المطلوبة'),
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
          'سيتم حذف ${unique.length} بطاقة من النموذج الحالي فقط. يمكنك الحفظ لاحقًا لتثبيت التعديل. هل تريد المتابعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('متابعة'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() {
      for (final index in unique.reversed) {
        _items.removeAt(index);
      }
      _selectedIndices.clear();
      _selectionMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(orgUnitsListProvider);
    final sectionsAsync = ref.watch(homepageSectionsForUnitProvider(_unitSlug));

    return unitsAsync.when(
      loading: () =>
          const SharedAdminLoadingState(message: 'جاري تحميل الوحدات...'),
      error: (e, _) => SharedAdminErrorState(message: 'تعذر تحميل الوحدات: $e'),
      data: (units) {
        final options = buildSharedContentScopeOptions(units);
        final selectedScope = options.any((e) => e.slug == _unitSlug)
            ? options.firstWhere((e) => e.slug == _unitSlug)
            : (options.isNotEmpty
                  ? options.first
                  : const SharedContentScopeOption(
                      slug: 'home',
                      label: 'الوزارة / الصفحة الرئيسية',
                      isHome: true,
                    ));
        return sectionsAsync.when(
          loading: () => const SharedAdminLoadingState(
            message: 'جاري تحميل إعدادات القسم...',
          ),
          error: (e, _) =>
              SharedAdminErrorState(message: 'تعذر تحميل إعدادات القسم: $e'),
          data: (sections) {
            _hydrateIfNeeded(sections);
            final visibleIndices = _visibleIndices();
            final visibleItems = visibleIndices
                .map((i) => _items[i])
                .toList(growable: false);
            final enabledCount = _items.where((e) => e.enabled).length;
            final linkCount = _items
                .where((e) => e.route.trim().isNotEmpty)
                .length;

            return LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth.isFinite
                    ? constraints.maxWidth
                    : MediaQuery.of(context).size.width;
                final compact = maxWidth < 900;
                final statCols = maxWidth >= 1100
                    ? 4
                    : (maxWidth >= 720 ? 2 : 1);
                const statSpacing = 12.0;
                final statWidth = statCols == 1
                    ? maxWidth
                    : (maxWidth - ((statCols - 1) * statSpacing)) / statCols;

                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    SharedAdminSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              SharedContentScopeBadge(slug: _unitSlug),
                              SharedAdminMetaChip(
                                label: selectedScope.label,
                                icon: selectedScope.isHome
                                    ? Icons.public
                                    : Icons.account_tree_outlined,
                                soft: true,
                              ),
                              SharedAdminMetaChip(
                                label: widget.sectionName,
                                icon: Icons.view_module_outlined,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            widget.title,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.description,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: const Color(0xFF4B5563),
                                  height: 1.6,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: statSpacing,
                      runSpacing: statSpacing,
                      children: [
                        SizedBox(
                          width: statWidth,
                          child: SharedAdminStatCard(
                            label: 'إجمالي البطاقات',
                            value: '${_items.length}',
                            icon: Icons.grid_view_rounded,
                            color: const Color(0xFF0B3A70),
                            helper: 'كل العناصر في هذا القسم',
                          ),
                        ),
                        SizedBox(
                          width: statWidth,
                          child: SharedAdminStatCard(
                            label: 'البطاقات المفعّلة',
                            value: '$enabledCount',
                            icon: Icons.check_circle_outline,
                            color: const Color(0xFF2E7D32),
                            helper: 'الجاهزة للظهور في الواجهة العامة',
                          ),
                        ),
                        SizedBox(
                          width: statWidth,
                          child: SharedAdminStatCard(
                            label: 'البطاقات المرتبطة',
                            value: '$linkCount',
                            icon: Icons.link_outlined,
                            color: const Color(0xFF8A5A00),
                            helper: widget.showLinks
                                ? 'بطاقات تملك مسارًا أو رابطًا'
                                : 'لا يستخدم هذا القسم روابط مباشرة',
                          ),
                        ),
                        SizedBox(
                          width: statWidth,
                          child: SharedAdminStatCard(
                            label: 'الحالة',
                            value: _enabled ? 'مفعّل' : 'معطّل',
                            icon: _enabled
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: _enabled
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFB22222),
                            helper: 'حالة القسم على مستوى النطاق الحالي',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SharedAdminSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: compact ? maxWidth : 360,
                                  minWidth: math.min(maxWidth, 260),
                                ),
                                child: DropdownButtonFormField<String>(
                                  value: _unitSlug,
                                  decoration: const InputDecoration(
                                    labelText: 'النطاق',
                                    border: OutlineInputBorder(),
                                  ),
                                  isExpanded: true,
                                  items: options
                                      .map(
                                        (o) => DropdownMenuItem(
                                          value: o.slug,
                                          child: Text(
                                            '${o.label} — ${o.slug}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(growable: false),
                                  onChanged: (v) => setState(() {
                                    _unitSlug = v ?? _unitSlug;
                                    _loadedKey = '';
                                  }),
                                ),
                              ),
                              SizedBox(
                                width: compact ? maxWidth : 260,
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    labelText: 'بحث داخل البطاقات',
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: _searchController.text.isEmpty
                                        ? null
                                        : IconButton(
                                            onPressed: _searchController.clear,
                                            icon: const Icon(Icons.close),
                                          ),
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              FilterChip(
                                label: const Text('القسم مفعّل'),
                                selected: _enabled,
                                onSelected: (v) => setState(() => _enabled = v),
                              ),
                              FilterChip(
                                label: Text(
                                  _selectionMode
                                      ? 'إنهاء التحديد'
                                      : 'تحديد متعدد',
                                ),
                                selected: _selectionMode,
                                onSelected: (v) => setState(() {
                                  _selectionMode = v;
                                  if (!v) _selectedIndices.clear();
                                }),
                              ),
                              if (widget.publicPreviewRoute != null)
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      context.go(widget.publicPreviewRoute!),
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('معاينة عامة'),
                                ),
                              FilledButton.icon(
                                onPressed: _saving ? null : _save,
                                icon: _saving
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.save_outlined),
                                label: Text(widget.primaryButtonLabel),
                              ),
                              OutlinedButton.icon(
                                onPressed: () => setState(() {
                                  _items.add(const ScopedCardEditableItem());
                                  _selectedIndices.clear();
                                  _selectionMode = false;
                                }),
                                icon: const Icon(Icons.add_box_outlined),
                                label: const Text('إضافة بطاقة'),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) =>
                                    _handleDeleteAction(value, visibleIndices),
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: 'selected',
                                    child: Text('حذف المحدد'),
                                  ),
                                  PopupMenuItem(
                                    value: 'visible',
                                    child: Text('حذف النتائج الحالية'),
                                  ),
                                  PopupMenuItem(
                                    value: 'disabled',
                                    child: Text('حذف غير المفعّل'),
                                  ),
                                  PopupMenuItem(
                                    value: 'empty',
                                    child: Text('حذف الفارغ'),
                                  ),
                                ],
                                child: OutlinedButton.icon(
                                  onPressed: null,
                                  icon: const Icon(Icons.delete_sweep_outlined),
                                  label: const Text('طرق الحذف'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SharedAdminSectionNotice(
                            message:
                                '${sharedContentScopeHint(_unitSlug)}\nيمكنك هنا توحيد بطاقات ${widget.title} بين الصفحة الرئيسية home وصفحات الوحدات بحسب slug، مع إبقاء نفس معمارية CRUD الحالية دون توسيع خارجي.',
                            icon: Icons.lightbulb_outline,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SharedAdminSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إعدادات القسم العامة',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'عنوان القسم',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _subtitleController,
                            minLines: 2,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'الوصف المختصر',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (visibleItems.isEmpty)
                      SharedAdminEmptyState(
                        title: 'لا توجد بطاقات مطابقة',
                        message: _searchController.text.trim().isEmpty
                            ? 'ابدأ بإضافة بطاقات جديدة لهذا القسم أو غيّر النطاق الحالي.'
                            : 'لا توجد بطاقات مطابقة لعبارة البحث الحالية. جرّب تعديل البحث أو مسحه.',
                        icon: Icons.view_carousel_outlined,
                        action: OutlinedButton.icon(
                          onPressed: _searchController.clear,
                          icon: const Icon(Icons.filter_alt_off_outlined),
                          label: const Text('مسح البحث'),
                        ),
                      )
                    else ...[
                      SharedAdminSurfaceCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'معاينة البطاقات المفعّلة',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 12),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final width = constraints.maxWidth;
                                final cols = width >= 1100
                                    ? 3
                                    : (width >= 720 ? 2 : 1);
                                const spacing = 12.0;
                                final itemWidth = cols == 1
                                    ? width
                                    : (width - ((cols - 1) * spacing)) / cols;
                                return Wrap(
                                  spacing: spacing,
                                  runSpacing: spacing,
                                  children: [
                                    for (final item
                                        in visibleItems
                                            .where((e) => e.enabled)
                                            .take(6))
                                      SizedBox(
                                        width: itemWidth,
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            border: Border.all(
                                              color: const Color(0xFFE5E7EB),
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SharedAdminMetaChip(
                                                label: item.icon.isEmpty
                                                    ? 'icon'
                                                    : item.icon,
                                                icon: _iconForCard(item.icon),
                                                soft: true,
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                item.title.isEmpty
                                                    ? 'بطاقة بدون عنوان'
                                                    : item.title,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                    ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                item.description.isEmpty
                                                    ? 'أضف وصفًا مختصرًا لهذه البطاقة'
                                                    : item.description,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: const Color(
                                                        0xFF4B5563,
                                                      ),
                                                      height: 1.5,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, editorConstraints) {
                          final width = editorConstraints.maxWidth;
                          final cols = width >= 1200
                              ? 3
                              : (width >= 820 ? 2 : 1);
                          const spacing = 12.0;
                          final itemWidth = cols == 1
                              ? width
                              : (width - ((cols - 1) * spacing)) / cols;
                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: [
                              for (final index in visibleIndices)
                                SizedBox(
                                  width: itemWidth,
                                  child: _ScopedCardEditorCard(
                                    item: _items[index],
                                    showLinks: widget.showLinks,
                                    selectionMode: _selectionMode,
                                    selected: _selectedIndices.contains(index),
                                    onSelectedChanged: (value) => setState(() {
                                      if (value) {
                                        _selectedIndices.add(index);
                                      } else {
                                        _selectedIndices.remove(index);
                                      }
                                    }),
                                    onChanged: (value) => _items[index] = value,
                                    onMoveUp: index > 0
                                        ? () => setState(() {
                                            final current = _items.removeAt(
                                              index,
                                            );
                                            _items.insert(index - 1, current);
                                            _selectedIndices.clear();
                                          })
                                        : null,
                                    onMoveDown: index < _items.length - 1
                                        ? () => setState(() {
                                            final current = _items.removeAt(
                                              index,
                                            );
                                            _items.insert(index + 1, current);
                                            _selectedIndices.clear();
                                          })
                                        : null,
                                    onDelete: () => setState(() {
                                      _items.removeAt(index);
                                      _selectedIndices.clear();
                                    }),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ],
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ScopedCardEditorCard extends StatelessWidget {
  const _ScopedCardEditorCard({
    required this.item,
    required this.showLinks,
    required this.selectionMode,
    required this.selected,
    required this.onSelectedChanged,
    required this.onChanged,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  final ScopedCardEditableItem item;
  final bool showLinks;
  final bool selectionMode;
  final bool selected;
  final ValueChanged<bool> onSelectedChanged;
  final ValueChanged<ScopedCardEditableItem> onChanged;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;
        final compact = maxWidth < 860;
        final firstFieldWidth = compact
            ? maxWidth
            : math.min<double>(260, (maxWidth - 12) / 3);
        final secondFieldWidth = compact
            ? maxWidth
            : math.max<double>(280, maxWidth - firstFieldWidth - 12);
        final linkLabelWidth = compact
            ? maxWidth
            : math.min<double>(240, (maxWidth - 12) / 3);
        final routeWidth = compact
            ? maxWidth
            : math.max<double>(280, maxWidth - linkLabelWidth - 12);

        return SharedAdminSurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (selectionMode)
                    Checkbox(
                      value: selected,
                      onChanged: (value) => onSelectedChanged(value ?? false),
                    ),
                  SharedAdminMetaChip(
                    label: item.title.isEmpty ? 'بطاقة جديدة' : item.title,
                    icon: _iconForCard(item.icon),
                    soft: true,
                  ),
                  SharedAdminMetaChip(
                    label: item.enabled ? 'مفعّلة' : 'غير مفعّلة',
                    icon: item.enabled
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: item.enabled
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFB22222),
                    soft: true,
                  ),
                  if (showLinks)
                    SharedAdminMetaChip(
                      label: item.route.isEmpty ? 'بدون رابط' : item.route,
                      icon: Icons.link_outlined,
                    ),
                  if (showLinks && item.route.trim().isNotEmpty)
                    SharedAdminMetaChip(
                      label: item.route.trim().startsWith('/')
                          ? 'مسار داخلي'
                          : 'رابط خارجي/مؤجل',
                      icon: item.route.trim().startsWith('/')
                          ? Icons.alt_route_outlined
                          : Icons.public_outlined,
                      soft: true,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: firstFieldWidth,
                    child: TextFormField(
                      initialValue: item.icon,
                      decoration: const InputDecoration(
                        labelText: 'أيقونة',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => onChanged(item.copyWith(icon: v)),
                    ),
                  ),
                  SizedBox(
                    width: secondFieldWidth,
                    child: TextFormField(
                      initialValue: item.title,
                      decoration: const InputDecoration(
                        labelText: 'العنوان',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => onChanged(item.copyWith(title: v)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: item.description,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'الوصف',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => onChanged(item.copyWith(description: v)),
              ),
              if (showLinks) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: linkLabelWidth,
                      child: TextFormField(
                        initialValue: item.linkLabel,
                        decoration: const InputDecoration(
                          labelText: 'نص الرابط',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) =>
                            onChanged(item.copyWith(linkLabel: v)),
                      ),
                    ),
                    SizedBox(
                      width: routeWidth,
                      child: TextFormField(
                        initialValue: item.route,
                        decoration: const InputDecoration(
                          labelText: 'المسار أو الرابط',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (v) => onChanged(item.copyWith(route: v)),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              FilterChip(
                label: const Text('مفعّل'),
                selected: item.enabled,
                onSelected: (v) => onChanged(item.copyWith(enabled: v)),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton.icon(
                    onPressed: onMoveUp,
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text('أعلى'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onMoveDown,
                    icon: const Icon(Icons.arrow_downward),
                    label: const Text('أسفل'),
                  ),
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('حذف'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class ScopedCardEditableItem {
  const ScopedCardEditableItem({
    this.icon = '',
    this.title = '',
    this.description = '',
    this.linkLabel = '',
    this.route = '',
    this.enabled = true,
  });

  final String icon;
  final String title;
  final String description;
  final String linkLabel;
  final String route;
  final bool enabled;

  factory ScopedCardEditableItem.fromMap(dynamic raw) {
    final map = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw as Map);
    return ScopedCardEditableItem(
      icon: (map['icon'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      linkLabel: (map['link_label'] ?? '').toString(),
      route: (map['route'] ?? '').toString(),
      enabled: map['enabled'] is bool ? map['enabled'] as bool : true,
    );
  }

  Map<String, dynamic> toJson() => {
    'icon': icon,
    'title': title,
    'description': description,
    'link_label': linkLabel,
    'route': route,
    'enabled': enabled,
  };

  ScopedCardEditableItem copyWith({
    String? icon,
    String? title,
    String? description,
    String? linkLabel,
    String? route,
    bool? enabled,
  }) {
    return ScopedCardEditableItem(
      icon: icon ?? this.icon,
      title: title ?? this.title,
      description: description ?? this.description,
      linkLabel: linkLabel ?? this.linkLabel,
      route: route ?? this.route,
      enabled: enabled ?? this.enabled,
    );
  }
}

IconData _iconForCard(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'credit_card':
      return Icons.credit_card_outlined;
    case 'building':
      return Icons.apartment_outlined;
    case 'file_signature':
      return Icons.description_outlined;
    case 'dashboard':
      return Icons.dashboard_outlined;
    case 'search':
      return Icons.search_outlined;
    case 'verified':
      return Icons.verified_outlined;
    case 'map':
      return Icons.map_outlined;
    default:
      return Icons.widgets_outlined;
  }
}
