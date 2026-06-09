import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waqf/data/repositories/homepage_repository.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';
import 'package:waqf/presentation/providers/org_units_provider.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/shared/shared_content_admin_ui.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/shared/shared_content_scope.dart';

class ScopedStatisticsManagementSection extends ConsumerStatefulWidget {
  const ScopedStatisticsManagementSection({super.key});

  @override
  ConsumerState<ScopedStatisticsManagementSection> createState() =>
      _ScopedStatisticsManagementSectionState();
}

class _ScopedStatisticsManagementSectionState
    extends ConsumerState<ScopedStatisticsManagementSection> {
  String _unitSlug = 'home';
  String _loadedKey = '';
  bool _enabled = true;
  bool _saving = false;
  bool _selectionMode = false;
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _selectedIndices = <int>{};
  List<_EditableCounter> _counters = const [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _hydrateIfNeeded(StatisticsSectionSettings? settings) {
    final source = settings ?? const StatisticsSectionSettings();
    final key = '$_unitSlug|${source.enabled}|${source.counters.length}';
    if (_loadedKey == key) return;
    _enabled = source.enabled;
    _counters = source.counters
        .map((raw) {
          final map = raw is Map<String, dynamic>
              ? raw
              : Map<String, dynamic>.from(raw as Map);
          return _EditableCounter(
            label: (map['label'] ?? map['label_ar'] ?? '').toString(),
            value: ((map['value'] as num?)?.toInt() ?? 0).toString(),
            icon: (map['icon'] ?? '').toString(),
          );
        })
        .toList(growable: true);
    if (_counters.isEmpty) {
      _counters = _defaultCounters()
          .map((e) => e.copyWith())
          .toList(growable: true);
    }
    _selectionMode = false;
    _selectedIndices.clear();
    _loadedKey = key;
  }

  List<_EditableCounter> _defaultCounters() => const [
    _EditableCounter(label: 'مسجد تحت الإشراف', value: '1850', icon: 'mosque'),
    _EditableCounter(label: 'إمام وخطيب وداعية', value: '3200', icon: 'users'),
    _EditableCounter(label: 'مركز تحفيظ وتعليم', value: '45', icon: 'school'),
    _EditableCounter(
      label: 'حافظ وحافظة للقرآن',
      value: '12500',
      icon: 'quran',
    ),
  ];

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final unitId = await ref.read(unitIdBySlugProvider(_unitSlug).future);
      final repository = ref.read(homepageRepositoryProvider);
      final settings = StatisticsSectionSettings(
        enabled: _enabled,
        counters: _counters
            .map(
              (e) => {
                'label': e.label,
                'value': int.tryParse(e.value) ?? 0,
                'icon': e.icon,
              },
            )
            .toList(growable: false),
      );
      await repository.upsertScopedStatisticsSection(
        settings,
        unitId: unitId,
        isActive: true,
      );
      ref.invalidate(scopedStatisticsSectionProvider(_unitSlug));
      ref.invalidate(homepageSectionsForUnitProvider(_unitSlug));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الإحصائيات لهذا النطاق')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر حفظ الإحصائيات: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<int> _visibleIndices() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return List<int>.generate(_counters.length, (index) => index);
    }
    final indices = <int>[];
    for (var i = 0; i < _counters.length; i++) {
      final row = _counters[i];
      final haystack = '${row.label} ${row.icon} ${row.value}'.toLowerCase();
      if (haystack.contains(query)) {
        indices.add(i);
      }
    }
    return indices;
  }

  int _totalValue() {
    var total = 0;
    for (final item in _counters) {
      total += int.tryParse(item.value) ?? 0;
    }
    return total;
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
      case 'zero_values':
        for (var i = 0; i < _counters.length; i++) {
          if ((int.tryParse(_counters[i].value) ?? 0) <= 0) {
            toDelete.add(i);
          }
        }
        break;
      case 'empty_labels':
        for (var i = 0; i < _counters.length; i++) {
          if (_counters[i].label.trim().isEmpty) {
            toDelete.add(i);
          }
        }
        break;
      case 'restore_defaults':
        final confirmed = await _confirmAction(
          title: 'استعادة الافتراضيات',
          body:
              'سيتم استبدال العدادات الحالية بالعدادات الافتراضية لهذا القسم. هل تريد المتابعة؟',
        );
        if (confirmed != true) return;
        setState(() {
          _counters = _defaultCounters()
              .map((e) => e.copyWith())
              .toList(growable: true);
          _selectedIndices.clear();
          _selectionMode = false;
        });
        return;
      default:
        return;
    }

    final unique = toDelete.toSet().toList()..sort();
    if (unique.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد عناصر مطابقة لعملية الحذف المطلوبة'),
        ),
      );
      return;
    }

    final confirmed = await _confirmAction(
      title: 'تأكيد الحذف',
      body:
          'سيتم حذف ${unique.length} عداد/عدادات من النموذج الحالي فقط. يمكنك حفظ التعديلات لاحقًا لتثبيتها. هل تريد المتابعة؟',
    );
    if (confirmed != true) return;

    setState(() {
      for (final index in unique.reversed) {
        _counters.removeAt(index);
      }
      _selectedIndices.clear();
      _selectionMode = false;
    });
  }

  Future<bool?> _confirmAction({required String title, required String body}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
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
  }

  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(orgUnitsListProvider);
    final statsAsync = ref.watch(scopedStatisticsSectionProvider(_unitSlug));

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

        return statsAsync.when(
          loading: () => const SharedAdminLoadingState(
            message: 'جاري تحميل إعدادات الإحصائيات...',
          ),
          error: (e, _) =>
              SharedAdminErrorState(message: 'تعذر تحميل الإحصائيات: $e'),
          data: (settings) {
            _hydrateIfNeeded(settings);
            final visibleIndices = _visibleIndices();
            final visibleItems = visibleIndices
                .map((i) => _counters[i])
                .toList(growable: false);
            final totalValue = _totalValue();

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
                            label: _unitSlug,
                            icon: Icons.tag,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'إدارة الإحصائيات',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ارفع نفس مستوى قسم الإحصائيات في الواجهة العامة عبر عدادات أوضح وقيم دقيقة بحسب home أو slug، مع إمكانية إعادة الترتيب والحذف الجماعي قبل الحفظ.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF4B5563),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final columns = width >= 1100 ? 4 : (width >= 720 ? 2 : 1);
                    const spacing = 12.0;
                    final cardWidth = columns == 1
                        ? width
                        : (width - ((columns - 1) * spacing)) / columns;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: SharedAdminStatCard(
                            label: 'إجمالي العدادات',
                            value: '${_counters.length}',
                            icon: Icons.bar_chart_rounded,
                            color: const Color(0xFF0B3A70),
                            helper: 'جميع العناصر الحالية داخل النموذج',
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: SharedAdminStatCard(
                            label: 'النتائج المعروضة',
                            value: '${visibleItems.length}',
                            icon: Icons.filter_alt_outlined,
                            color: const Color(0xFF2E7D32),
                            helper: 'بعد تطبيق البحث الحالي',
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: SharedAdminStatCard(
                            label: 'مجموع القيم',
                            value: '$totalValue',
                            icon: Icons.numbers,
                            color: const Color(0xFF8A5A00),
                            helper: 'مؤشر سريع لمحتوى القسم',
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: SharedAdminStatCard(
                            label: 'الحالة',
                            value: _enabled ? 'مفعّل' : 'معطّل',
                            icon: _enabled
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: _enabled
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFB22222),
                            helper: 'حالة القسم في الصفحة العامة',
                          ),
                        ),
                      ],
                    );
                  },
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
                          SizedBox(
                            width: 320,
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
                            width: 260,
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                labelText: 'بحث داخل العدادات',
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
                              _selectionMode ? 'إنهاء التحديد' : 'تحديد متعدد',
                            ),
                            selected: _selectionMode,
                            onSelected: (v) => setState(() {
                              _selectionMode = v;
                              if (!v) _selectedIndices.clear();
                            }),
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
                            label: const Text('حفظ الإحصائيات'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => setState(() {
                              _counters.add(const _EditableCounter());
                              _selectionMode = false;
                              _selectedIndices.clear();
                            }),
                            icon: const Icon(Icons.add_chart_outlined),
                            label: const Text('إضافة عداد'),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) =>
                                _handleDeleteAction(value, visibleIndices),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'selected',
                                child: Text('حذف المحدد'),
                              ),
                              const PopupMenuItem(
                                value: 'visible',
                                child: Text('حذف النتائج الحالية'),
                              ),
                              const PopupMenuItem(
                                value: 'zero_values',
                                child: Text('حذف القيم الصفرية'),
                              ),
                              const PopupMenuItem(
                                value: 'empty_labels',
                                child: Text('حذف العناوين الفارغة'),
                              ),
                              const PopupMenuDivider(),
                              const PopupMenuItem(
                                value: 'restore_defaults',
                                child: Text('استعادة الافتراضيات'),
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
                        message: sharedContentScopeHint(_unitSlug),
                        icon: Icons.tips_and_updates_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (visibleItems.isEmpty)
                  SharedAdminEmptyState(
                    title: 'لا توجد عدادات مطابقة',
                    message: _searchController.text.trim().isEmpty
                        ? 'ابدأ بإضافة عدادات جديدة أو استعد القيم الافتراضية ثم احفظ التغييرات.'
                        : 'لا توجد عناصر مطابقة لبحثك الحالي. جرّب تعديل عبارة البحث أو مسحها.',
                    icon: Icons.query_stats_outlined,
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
                          'معاينة سريعة للعدادات',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final columns = width >= 1000
                                ? 3
                                : (width >= 640 ? 2 : 1);
                            const spacing = 12.0;
                            final itemWidth = columns == 1
                                ? width
                                : (width - ((columns - 1) * spacing)) / columns;
                            return Wrap(
                              spacing: spacing,
                              runSpacing: spacing,
                              children: [
                                for (final row in visibleItems.take(6))
                                  SizedBox(
                                    width: itemWidth,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(
                                          color: const Color(0xFFE5E7EB),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              color: const Color(
                                                0xFF0B3A70,
                                              ).withValues(alpha: 0.08),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Icon(
                                              _resolveIcon(row.icon),
                                              color: const Color(0xFF0B3A70),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  row.value,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge
                                                      ?.copyWith(
                                                        color: const Color(
                                                          0xFF0B3A70,
                                                        ),
                                                        fontWeight:
                                                            FontWeight.w800,
                                                      ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  row.label.isEmpty
                                                      ? 'عداد بدون عنوان'
                                                      : row.label,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                ),
                                              ],
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
                  for (final index in visibleIndices) ...[
                    _CounterEditorCard(
                      counter: _counters[index],
                      selectionMode: _selectionMode,
                      selected: _selectedIndices.contains(index),
                      onSelectedChanged: (value) => setState(() {
                        if (value) {
                          _selectedIndices.add(index);
                        } else {
                          _selectedIndices.remove(index);
                        }
                      }),
                      onChanged: (value) => _counters[index] = value,
                      onMoveUp: index > 0
                          ? () => setState(() {
                              final current = _counters.removeAt(index);
                              _counters.insert(index - 1, current);
                              _selectedIndices.clear();
                            })
                          : null,
                      onMoveDown: index < _counters.length - 1
                          ? () => setState(() {
                              final current = _counters.removeAt(index);
                              _counters.insert(index + 1, current);
                              _selectedIndices.clear();
                            })
                          : null,
                      onDelete: () => setState(() {
                        _counters.removeAt(index);
                        _selectedIndices.clear();
                      }),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _CounterEditorCard extends StatelessWidget {
  const _CounterEditorCard({
    required this.counter,
    required this.selectionMode,
    required this.selected,
    required this.onSelectedChanged,
    required this.onChanged,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  final _EditableCounter counter;
  final bool selectionMode;
  final bool selected;
  final ValueChanged<bool> onSelectedChanged;
  final ValueChanged<_EditableCounter> onChanged;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
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
                label: counter.label.trim().isEmpty
                    ? 'عداد جديد'
                    : counter.label,
                icon: Icons.insights_outlined,
                soft: true,
              ),
              SharedAdminMetaChip(label: counter.value, icon: Icons.numbers),
              SharedAdminMetaChip(
                label: counter.icon.isEmpty ? 'chart-column' : counter.icon,
                icon: Icons.tag_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 320,
                child: TextFormField(
                  initialValue: counter.label,
                  decoration: const InputDecoration(
                    labelText: 'العنوان',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => onChanged(counter.copyWith(label: v)),
                ),
              ),
              SizedBox(
                width: 180,
                child: TextFormField(
                  initialValue: counter.value,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'القيمة',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => onChanged(counter.copyWith(value: v)),
                ),
              ),
              SizedBox(
                width: 220,
                child: TextFormField(
                  initialValue: counter.icon,
                  decoration: const InputDecoration(
                    labelText: 'أيقونة',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => onChanged(counter.copyWith(icon: v)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B3A70).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _resolveIcon(counter.icon),
                  color: const Color(0xFF0B3A70),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  counter.label.trim().isEmpty
                      ? 'سيظهر عنوان العداد هنا بعد الإدخال'
                      : counter.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ),
            ],
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
  }
}

class _EditableCounter {
  const _EditableCounter({
    this.label = '',
    this.value = '0',
    this.icon = 'chart-column',
  });

  final String label;
  final String value;
  final String icon;

  _EditableCounter copyWith({String? label, String? value, String? icon}) {
    return _EditableCounter(
      label: label ?? this.label,
      value: value ?? this.value,
      icon: icon ?? this.icon,
    );
  }
}

IconData _resolveIcon(String raw) {
  switch (raw.trim().toLowerCase()) {
    case 'mosque':
    case 'masjid':
      return Icons.mosque_outlined;
    case 'users':
    case 'people':
      return Icons.groups_2_outlined;
    case 'school':
      return Icons.school_outlined;
    case 'quran':
    case 'book':
      return Icons.menu_book_outlined;
    case 'landmark':
      return Icons.account_balance_outlined;
    default:
      return Icons.bar_chart_rounded;
  }
}
