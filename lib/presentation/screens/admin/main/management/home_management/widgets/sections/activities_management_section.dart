import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waqf/data/models/activity.dart';
import 'package:waqf/presentation/providers/admin_activities_provider.dart';
import 'package:waqf/presentation/providers/org_units_provider.dart';
import 'package:waqf/presentation/providers/supabase_providers.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';

import '../forms/activity_form_dialog.dart';
import '../shared/shared_content_admin_ui.dart';
import '../shared/shared_content_scope.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

enum ActivitiesManagementMode { activities, events }

class ActivitiesManagementSection extends ConsumerStatefulWidget {
  const ActivitiesManagementSection({
    super.key,
    this.mode = ActivitiesManagementMode.activities,
  });

  final ActivitiesManagementMode mode;

  @override
  ConsumerState<ActivitiesManagementSection> createState() =>
      _ActivitiesManagementSectionState();
}

class _ActivitiesManagementSectionState
    extends ConsumerState<ActivitiesManagementSection> {
  String _unitSlug = 'home';
  late final TextEditingController _searchController;
  bool _selectionMode = false;
  final Set<int> _selectedIds = <int>{};
  ActivityStatus? _statusFilter;
  ActivityType? _typeFilter;

  bool get _isEventsMode => widget.mode == ActivitiesManagementMode.events;
  String get _search => _searchController.text.trim();

  static const _eventTypes = <ActivityType>{
    ActivityType.conference,
    ActivityType.exhibition,
    ActivityType.ceremony,
    ActivityType.seminar,
  };

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesMode(Activity item) {
    final isEventType = _eventTypes.contains(item.type);
    return _isEventsMode ? isEventType : !isEventType;
  }

  AdminActivitiesQuery get _query =>
      AdminActivitiesQuery(unitSlug: _unitSlug, search: _search);

  void _refresh() {
    ref.invalidate(adminActivitiesProvider(_query));
  }

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) {
        _selectedIds.clear();
      }
    });
  }

  void _setSelected(int id, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _selectAll(Iterable<Activity> items) {
    setState(() {
      _selectionMode = true;
      _selectedIds
        ..clear()
        ..addAll(items.map((item) => item.id));
    });
  }

  void _clearSelection() {
    setState(() => _selectedIds.clear());
  }

  Future<void> _openForm({required String unitId, Activity? existing}) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => ActivityFormDialog(
        unitId: unitId,
        unitSlug: _unitSlug,
        existing: existing,
        titleOverride: _isEventsMode ? 'إضافة فعالية' : 'إضافة نشاط',
        editTitleOverride: _isEventsMode ? 'تعديل فعالية' : 'تعديل نشاط',
        initialType: _isEventsMode ? ActivityType.conference : null,
      ),
    );
    if (ok == true) {
      _refresh();
    }
  }

  Future<void> _delete(Activity activity) async {
    await _deleteMany(
      [activity],
      title: _isEventsMode ? 'حذف الفعالية' : 'حذف النشاط',
      description: 'سيتم حذف سجل واحد بعنوان "${activity.title}".',
      successMessage: _isEventsMode ? 'تم حذف الفعالية' : 'تم حذف النشاط',
    );
  }

  Future<void> _deleteMany(
    List<Activity> items, {
    required String title,
    required String description,
    required String successMessage,
  }) async {
    if (items.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد عناصر مطابقة للحذف.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(description),
              const SizedBox(height: 12),
              Text(
                'عدد السجلات: ${items.length}',
                style: Theme.of(
                  ctx,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'الحذف هنا نهائي ويطبق على النتائج الحالية فقط.',
                style: Theme.of(
                  ctx,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFFB22222)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('تأكيد الحذف'),
            ),
          ],
        ),
      ),
    );
    if (confirm != true) return;

    try {
      final supabase = ref.read(supabaseServiceProvider).client;
      await supabase
          .from(PwfDatabaseOwnerSurfaces.activities)
          .delete()
          .inFilter('id', items.map((e) => e.id).toList());
      setState(() {
        _selectedIds.removeAll(items.map((e) => e.id));
        if (_selectedIds.isEmpty) {
          _selectionMode = false;
        }
      });
      _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$successMessage (${items.length})')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر الحذف: $e')));
    }
  }

  Future<void> _handleBulkDeleteAction(
    String action,
    List<Activity> items,
  ) async {
    final selectedItems = items
        .where((item) => _selectedIds.contains(item.id))
        .toList(growable: false);

    switch (action) {
      case 'selected':
        await _deleteMany(
          selectedItems,
          title: 'حذف المحدد',
          description:
              'سيتم حذف السجلات التي حددتها يدويًا من البطاقات الحالية.',
          successMessage: _isEventsMode
              ? 'تم حذف الفعاليات المحددة'
              : 'تم حذف الأنشطة المحددة',
        );
        return;
      case 'all_visible':
        await _deleteMany(
          items,
          title: 'حذف النتائج الحالية',
          description: 'سيتم حذف كل السجلات الظاهرة الآن ضمن الفلاتر الحالية.',
          successMessage: _isEventsMode
              ? 'تم حذف الفعاليات الظاهرة'
              : 'تم حذف الأنشطة الظاهرة',
        );
        return;
      case 'completed_only':
        await _deleteMany(
          items
              .where((item) => item.status == ActivityStatus.completed)
              .toList(growable: false),
          title: 'حذف المكتمل',
          description: 'سيتم حذف السجلات المكتملة فقط من النتائج الحالية.',
          successMessage: _isEventsMode
              ? 'تم حذف الفعاليات المكتملة'
              : 'تم حذف الأنشطة المكتملة',
        );
        return;
      case 'cancelled_only':
        await _deleteMany(
          items
              .where(
                (item) =>
                    item.status == ActivityStatus.cancelled ||
                    item.status == ActivityStatus.postponed,
              )
              .toList(growable: false),
          title: 'حذف الملغى أو المؤجل',
          description:
              'سيتم حذف السجلات الملغاة أو المؤجلة فقط من النتائج الحالية.',
          successMessage: _isEventsMode
              ? 'تم حذف الفعاليات الملغاة/المؤجلة'
              : 'تم حذف الأنشطة الملغاة/المؤجلة',
        );
        return;
    }
  }

  void _showDetails(Activity activity) {
    showDialog<void>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(activity.title),
          content: SizedBox(
            width: 780,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SharedAdminMetaChip(
                        label: activity.category.displayName,
                        icon: Icons.category_outlined,
                        soft: true,
                      ),
                      SharedAdminMetaChip(
                        label: activity.type.displayName,
                        icon: Icons.sell_outlined,
                        soft: true,
                      ),
                      SharedAdminMetaChip(
                        label: activity.status.displayName,
                        icon: Icons.flag_outlined,
                        soft: true,
                      ),
                      if (activity.isFeatured)
                        const SharedAdminMetaChip(
                          label: 'مميز',
                          icon: Icons.star_outline,
                          color: Color(0xFFD4AF37),
                          soft: true,
                        ),
                      if (activity.isPinned)
                        const SharedAdminMetaChip(
                          label: 'مثبت',
                          icon: Icons.push_pin_outlined,
                          color: Color(0xFF0B3A70),
                          soft: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ActivityDetailRow(
                    label: 'التاريخ',
                    value: _formatActivityDateRange(activity),
                  ),
                  _ActivityDetailRow(
                    label: 'المكان',
                    value: activity.location.isEmpty ? '—' : activity.location,
                  ),
                  _ActivityDetailRow(
                    label: 'المنظم',
                    value: activity.organizer.isEmpty
                        ? '—'
                        : activity.organizer,
                  ),
                  _ActivityDetailRow(
                    label: 'المحافظة',
                    value: activity.governorate.isEmpty
                        ? '—'
                        : activity.governorate,
                  ),
                  _ActivityDetailRow(
                    label: 'النشر',
                    value: sharedAdminFormatDateTime(
                      activity.publishAt ?? activity.createdAt,
                    ),
                  ),
                  _ActivityDetailBlock(
                    label: 'الوصف',
                    value: activity.description,
                  ),
                  if ((activity.imageUrl ?? '').trim().isNotEmpty)
                    _ActivityDetailBlock(
                      label: 'رابط الصورة',
                      value: activity.imageUrl!,
                    ),
                  if ((activity.attachmentUrl ?? '').trim().isNotEmpty)
                    _ActivityDetailBlock(
                      label: 'رابط المرفق',
                      value: activity.attachmentUrl!,
                    ),
                  if (activity.tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'الوسوم',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: activity.tags
                          .map(
                            (tag) => SharedAdminMetaChip(
                              label: tag,
                              icon: Icons.sell_outlined,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(orgUnitsListProvider);
    final unitIdAsync = ref.watch(unitIdBySlugProvider(_unitSlug));

    return unitsAsync.when(
      loading: () => const SharedAdminLoadingState(
        message: 'جاري تحميل نطاقات الإدارة...',
      ),
      error: (e, _) => SharedAdminErrorState(message: 'تعذر تحميل الوحدات: $e'),
      data: (units) {
        final options = buildSharedContentScopeOptions(units);
        final hasCurrent = options.any((o) => o.slug == _unitSlug);
        if (!hasCurrent) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _unitSlug = 'home');
          });
        }

        final listAsync = ref.watch(adminActivitiesProvider(_query));

        return unitIdAsync.when(
          loading: () =>
              const SharedAdminLoadingState(message: 'جاري تحديد النطاق...'),
          error: (e, _) =>
              SharedAdminErrorState(message: 'تعذر تحديد النطاق: $e'),
          data: (unitId) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final controlColumns = width >= 1280
                    ? 4
                    : width >= 980
                    ? 3
                    : width >= 700
                    ? 2
                    : 1;
                final spacing = 12.0;
                final fieldWidth = controlColumns == 1
                    ? width
                    : (width - ((controlColumns - 1) * spacing)) /
                          controlColumns;
                final cardColumns = width >= 1350
                    ? 3
                    : width >= 900
                    ? 2
                    : 1;
                final cardAspectRatio = width >= 900 ? 1.08 : 0.82;

                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    SharedAdminSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEventsMode
                                ? 'مساحة إدارة الفعاليات'
                                : 'مساحة إدارة الأنشطة',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _isEventsMode
                                ? 'إدارة الفعاليات من نفس جدول الأنشطة الحالي، مع فلترة واضحة لأنواع الفعاليات ومعاينة أدق قبل التحرير.'
                                : 'إدارة الأنشطة المشتركة بين الوزارة والوحدات مع فلاتر تشغيلية أوضح وبطاقات أغنى من العرض البدائي السابق.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: const Color(0xFF6B7280),
                                  height: 1.5,
                                ),
                          ),
                          const SizedBox(height: 16),
                          SharedHomepageCountControlCard(
                            key: ValueKey(
                              'activities-home-count-$_unitSlug-${widget.mode.name}',
                            ),
                            unitSlug: _unitSlug,
                            unitId: unitId,
                            primarySectionName: 'pwf_activities',
                            aliases: const <String>[],
                            title: _isEventsMode
                                ? 'التحكم في عدد الفعاليات في الصفحة الرئيسية'
                                : 'التحكم في عدد الأنشطة في الصفحة الرئيسية',
                            description: _isEventsMode
                                ? 'حدد عدد بطاقات الفعاليات الظاهرة في الصفحة الرئيسية ضمن النطاق الحالي، مع التحكم في زر عرض الكل.'
                                : 'حدد عدد بطاقات الأنشطة الظاهرة في الصفحة الرئيسية ضمن النطاق الحالي، مع التحكم في زر عرض الكل.',
                            defaultHomeLimit: 4,
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: fieldWidth,
                                child: DropdownButtonFormField<String>(
                                  value: hasCurrent ? _unitSlug : 'home',
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'نطاق الإدارة',
                                  ),
                                  items: options
                                      .map(
                                        (o) => DropdownMenuItem(
                                          value: o.slug,
                                          child: Text(
                                            o.label,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  selectedItemBuilder: (context) => options
                                      .map<Widget>(
                                        (o) => Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            o.label,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(growable: false),
                                  onChanged: (v) => setState(
                                    () => _unitSlug = v ?? _unitSlug,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: fieldWidth,
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    labelText: 'بحث في العنوان أو الوصف',
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: _search.isEmpty
                                        ? null
                                        : IconButton(
                                            tooltip: 'مسح',
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() {});
                                            },
                                            icon: const Icon(Icons.close),
                                          ),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                              SizedBox(
                                width: fieldWidth,
                                child: DropdownButtonFormField<ActivityStatus?>(
                                  value: _statusFilter,
                                  decoration: const InputDecoration(
                                    labelText: 'الحالة',
                                  ),
                                  items: [
                                    const DropdownMenuItem<ActivityStatus?>(
                                      value: null,
                                      child: Text('كل الحالات'),
                                    ),
                                    ...ActivityStatus.values.map(
                                      (status) =>
                                          DropdownMenuItem<ActivityStatus?>(
                                            value: status,
                                            child: Text(status.displayName),
                                          ),
                                    ),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => _statusFilter = v),
                                ),
                              ),
                              SizedBox(
                                width: fieldWidth,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    FilledButton.icon(
                                      onPressed: () =>
                                          _openForm(unitId: unitId),
                                      icon: const Icon(Icons.add),
                                      label: Text(
                                        _isEventsMode
                                            ? 'إضافة فعالية'
                                            : 'إضافة نشاط',
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: _toggleSelectionMode,
                                      icon: Icon(
                                        _selectionMode
                                            ? Icons.close_fullscreen_outlined
                                            : Icons.checklist_rtl_outlined,
                                      ),
                                      label: Text(
                                        _selectionMode
                                            ? 'إنهاء التحديد'
                                            : 'تحديد متعدد',
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: _refresh,
                                      icon: const Icon(Icons.refresh),
                                      label: const Text('تحديث'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              SizedBox(
                                width: fieldWidth,
                                child: DropdownButtonFormField<ActivityType?>(
                                  value: _typeFilter,
                                  decoration: const InputDecoration(
                                    labelText: 'النوع',
                                  ),
                                  items: [
                                    const DropdownMenuItem<ActivityType?>(
                                      value: null,
                                      child: Text('كل الأنواع'),
                                    ),
                                    ...(_isEventsMode
                                            ? ActivityType.values.where(
                                                (t) => _eventTypes.contains(t),
                                              )
                                            : ActivityType.values.where(
                                                (t) => !_eventTypes.contains(t),
                                              ))
                                        .map(
                                          (type) =>
                                              DropdownMenuItem<ActivityType?>(
                                                value: type,
                                                child: Text(type.displayName),
                                              ),
                                        ),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => _typeFilter = v),
                                ),
                              ),
                              SizedBox(
                                width: width > 720
                                    ? width - fieldWidth - 12
                                    : width,
                                child: SharedAdminSectionNotice(
                                  message: _isEventsMode
                                      ? 'في هذه المرحلة ما زالت الفعاليات تُدار من جدول الأنشطة نفسه، لذلك تم تحسين الفلاتر والمعاينة دون تغيير البنية السيادية الحالية.'
                                      : sharedContentScopeHint(_unitSlug),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SharedContentScopeBadge(slug: _unitSlug),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    listAsync.when(
                      loading: () => SharedAdminLoadingState(
                        message: _isEventsMode
                            ? 'جاري تحميل الفعاليات...'
                            : 'جاري تحميل الأنشطة...',
                      ),
                      error: (e, _) => SharedAdminErrorState(
                        message: 'تعذر تحميل المحتوى: $e',
                        onRetry: _refresh,
                      ),
                      data: (items) {
                        var filtered = items
                            .where(_matchesMode)
                            .toList(growable: false);
                        if (_statusFilter != null) {
                          filtered = filtered
                              .where((item) => item.status == _statusFilter)
                              .toList(growable: false);
                        }
                        if (_typeFilter != null) {
                          filtered = filtered
                              .where((item) => item.type == _typeFilter)
                              .toList(growable: false);
                        }

                        final selectedCount = filtered
                            .where((item) => _selectedIds.contains(item.id))
                            .length;
                        final upcomingCount = filtered
                            .where(
                              (item) => item.status == ActivityStatus.upcoming,
                            )
                            .length;
                        final completedCount = filtered
                            .where(
                              (item) => item.status == ActivityStatus.completed,
                            )
                            .length;
                        final featuredCount = filtered
                            .where((item) => item.isFeatured || item.isPinned)
                            .length;
                        final withMediaCount = filtered
                            .where(
                              (item) =>
                                  (item.imageUrl ?? '').isNotEmpty ||
                                  (item.attachmentUrl ?? '').isNotEmpty,
                            )
                            .length;

                        return Column(
                          children: [
                            if (filtered.isNotEmpty)
                              SharedAdminSurfaceCard(
                                padding: const EdgeInsets.all(16),
                                child: Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    SharedAdminMetaChip(
                                      label: _selectionMode
                                          ? 'وضع التحديد مفعل'
                                          : 'وضع الحذف السريع',
                                      icon: _selectionMode
                                          ? Icons.checklist_rtl_outlined
                                          : Icons.delete_sweep_outlined,
                                      color: _selectionMode
                                          ? const Color(0xFF0B3A70)
                                          : const Color(0xFF6B7280),
                                      soft: true,
                                    ),
                                    SharedAdminMetaChip(
                                      label: 'المحدد: $selectedCount',
                                      icon: Icons.select_all_outlined,
                                      color: const Color(0xFFD4AF37),
                                      soft: true,
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => _selectAll(filtered),
                                      icon: const Icon(Icons.done_all_outlined),
                                      label: const Text('تحديد كل النتائج'),
                                    ),
                                    TextButton.icon(
                                      onPressed: _selectedIds.isEmpty
                                          ? null
                                          : _clearSelection,
                                      icon: const Icon(
                                        Icons.remove_done_outlined,
                                      ),
                                      label: const Text('إلغاء التحديد'),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) =>
                                          _handleBulkDeleteAction(
                                            value,
                                            filtered,
                                          ),
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                          value: 'selected',
                                          child: Text('حذف المحدد فقط'),
                                        ),
                                        PopupMenuItem(
                                          value: 'all_visible',
                                          child: Text('حذف كل النتائج الحالية'),
                                        ),
                                        PopupMenuItem(
                                          value: 'completed_only',
                                          child: Text('حذف المكتمل فقط'),
                                        ),
                                        PopupMenuItem(
                                          value: 'cancelled_only',
                                          child: Text('حذف الملغى/المؤجل فقط'),
                                        ),
                                      ],
                                      child: FilledButton.tonalIcon(
                                        onPressed: null,
                                        icon: const Icon(
                                          Icons.delete_sweep_outlined,
                                        ),
                                        label: const Text('طرق الحذف'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (filtered.isNotEmpty) const SizedBox(height: 16),
                            GridView.count(
                              crossAxisCount: width >= 1280
                                  ? 4
                                  : width >= 900
                                  ? 2
                                  : 1,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: width >= 900 ? 1.75 : 2.15,
                              children: [
                                SharedAdminStatCard(
                                  label: _isEventsMode
                                      ? 'إجمالي الفعاليات'
                                      : 'إجمالي الأنشطة',
                                  value: filtered.length.toString(),
                                  icon: _isEventsMode
                                      ? Icons.celebration_outlined
                                      : Icons.event_note_outlined,
                                  color: const Color(0xFF0B3A70),
                                ),
                                SharedAdminStatCard(
                                  label: 'قادم',
                                  value: upcomingCount.toString(),
                                  icon: Icons.schedule_outlined,
                                  color: const Color(0xFFD97706),
                                ),
                                SharedAdminStatCard(
                                  label: 'مكتمل',
                                  value: completedCount.toString(),
                                  icon: Icons.task_alt_outlined,
                                  color: const Color(0xFF2E7D32),
                                ),
                                SharedAdminStatCard(
                                  label: 'مميز / بمرفقات',
                                  value: '${featuredCount + withMediaCount}',
                                  icon: Icons.attach_file_outlined,
                                  color: const Color(0xFF7C3AED),
                                  helper:
                                      'تمييز: $featuredCount • وسائط: $withMediaCount',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (filtered.isEmpty)
                              SharedAdminEmptyState(
                                title: _isEventsMode
                                    ? 'لا توجد فعاليات في هذا النطاق'
                                    : 'لا توجد أنشطة في هذا النطاق',
                                message:
                                    'يمكنك تعديل الفلاتر الحالية أو إضافة سجل جديد مباشرة من هذه الصفحة.',
                                icon: _isEventsMode
                                    ? Icons.celebration_outlined
                                    : Icons.event_note_outlined,
                                action: FilledButton.icon(
                                  onPressed: () => _openForm(unitId: unitId),
                                  icon: const Icon(Icons.add),
                                  label: Text(
                                    _isEventsMode
                                        ? 'إضافة فعالية'
                                        : 'إضافة نشاط',
                                  ),
                                ),
                              )
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: cardColumns,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: cardAspectRatio,
                                    ),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final activity = filtered[index];
                                  return _ActivityCard(
                                    activity: activity,
                                    isEventsMode: _isEventsMode,
                                    selectionMode: _selectionMode,
                                    isSelected: _selectedIds.contains(
                                      activity.id,
                                    ),
                                    onSelectionChanged: (value) =>
                                        _setSelected(activity.id, value),
                                    onView: () => _showDetails(activity),
                                    onEdit: () => _openForm(
                                      unitId: unitId,
                                      existing: activity,
                                    ),
                                    onDelete: () => _delete(activity),
                                  );
                                },
                              ),
                          ],
                        );
                      },
                    ),
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

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.activity,
    required this.isEventsMode,
    required this.selectionMode,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final Activity activity;
  final bool isEventsMode;
  final bool selectionMode;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SharedAdminSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  activity.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (selectionMode)
                Checkbox(
                  value: isSelected,
                  onChanged: (value) => onSelectionChanged(value ?? false),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _activityStatusColor(
                    activity.status,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  activity.status.displayName,
                  style: TextStyle(
                    color: _activityStatusColor(activity.status),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SharedAdminMetaChip(
                label: activity.category.displayName,
                icon: Icons.category_outlined,
              ),
              SharedAdminMetaChip(
                label: activity.type.displayName,
                icon: Icons.sell_outlined,
              ),
              if (activity.isFeatured)
                const SharedAdminMetaChip(
                  label: 'مميز',
                  icon: Icons.star_outline,
                  color: Color(0xFFD4AF37),
                  soft: true,
                ),
              if (activity.isPinned)
                const SharedAdminMetaChip(
                  label: 'مثبت',
                  icon: Icons.push_pin_outlined,
                  color: Color(0xFF0B3A70),
                  soft: true,
                ),
              if ((activity.attachmentUrl ?? '').trim().isNotEmpty)
                const SharedAdminMetaChip(
                  label: 'مرفق',
                  icon: Icons.attach_file,
                  color: Color(0xFF7C3AED),
                  soft: true,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              activity.description,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF374151),
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _ActivityFooterMeta(
                icon: Icons.calendar_today_outlined,
                value: _formatActivityDateRange(activity),
              ),
              if (activity.location.isNotEmpty)
                _ActivityFooterMeta(
                  icon: Icons.place_outlined,
                  value: activity.location,
                ),
              if (activity.organizer.isNotEmpty)
                _ActivityFooterMeta(
                  icon: Icons.business_outlined,
                  value: activity.organizer,
                ),
            ],
          ),
          const SizedBox(height: 14),
          SharedAdminRecordActions(
            compact: true,
            onView: onView,
            onEdit: onEdit,
            onDelete: onDelete,
            extra: isEventsMode
                ? const SharedAdminMetaChip(
                    label: 'فعالية',
                    icon: Icons.celebration_outlined,
                    color: Color(0xFF7C3AED),
                    soft: true,
                  )
                : const SharedAdminMetaChip(
                    label: 'نشاط',
                    icon: Icons.event_note_outlined,
                    color: Color(0xFF0B3A70),
                    soft: true,
                  ),
          ),
        ],
      ),
    );
  }
}

Color _activityStatusColor(ActivityStatus status) {
  switch (status) {
    case ActivityStatus.upcoming:
      return const Color(0xFFD97706);
    case ActivityStatus.ongoing:
      return const Color(0xFF0B3A70);
    case ActivityStatus.completed:
      return const Color(0xFF2E7D32);
    case ActivityStatus.cancelled:
      return const Color(0xFFB22222);
    case ActivityStatus.postponed:
      return const Color(0xFF7C3AED);
  }
}

String _formatActivityDateRange(Activity activity) {
  final start = sharedAdminFormatDate(activity.startDate);
  if (activity.endDate == null) return start;
  final end = sharedAdminFormatDate(activity.endDate);
  return '$start - $end';
}

class _ActivityFooterMeta extends StatelessWidget {
  const _ActivityFooterMeta({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6B7280)),
        const SizedBox(width: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 220),
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityDetailRow extends StatelessWidget {
  const _ActivityDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityDetailBlock extends StatelessWidget {
  const _ActivityDetailBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: SelectableText(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}
