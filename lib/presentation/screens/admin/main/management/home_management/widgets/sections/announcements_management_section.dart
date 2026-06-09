import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waqf/data/models/announcement.dart';
import 'package:waqf/presentation/providers/admin_announcements_provider.dart';
import 'package:waqf/presentation/providers/org_units_provider.dart';
import 'package:waqf/presentation/providers/supabase_providers.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';

import '../forms/announcement_form_dialog.dart';
import '../shared/shared_content_admin_ui.dart';
import '../shared/shared_content_scope.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

class AnnouncementsManagementSection extends ConsumerStatefulWidget {
  const AnnouncementsManagementSection({super.key});

  @override
  ConsumerState<AnnouncementsManagementSection> createState() =>
      _AnnouncementsManagementSectionState();
}

class _AnnouncementsManagementSectionState
    extends ConsumerState<AnnouncementsManagementSection> {
  String _unitSlug = 'home';
  bool _includeInactive = true;
  bool _selectionMode = false;
  final Set<int> _selectedIds = <int>{};
  late final TextEditingController _searchController;

  String get _search => _searchController.text.trim();

  AdminAnnouncementsQuery get _query => AdminAnnouncementsQuery(
    unitSlug: _unitSlug,
    includeInactive: _includeInactive,
    search: _search,
  );

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

  void _refresh() {
    ref.invalidate(adminAnnouncementsProvider(_query));
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

  void _selectAll(Iterable<Announcement> items) {
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

  Future<void> _openForm({
    required String unitId,
    Announcement? existing,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AnnouncementFormDialog(
        unitId: unitId,
        unitSlug: _unitSlug,
        existing: existing,
      ),
    );
    if (ok == true) {
      _refresh();
    }
  }

  Future<void> _delete(Announcement announcement) async {
    await _deleteMany(
      [announcement],
      title: 'حذف الإعلان',
      description: 'سيتم حذف إعلان واحد بعنوان "${announcement.title}".',
      successMessage: 'تم حذف الإعلان',
    );
  }

  Future<void> _deleteMany(
    List<Announcement> items, {
    required String title,
    required String description,
    required String successMessage,
  }) async {
    if (items.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد إعلانات مطابقة للحذف.')),
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
                'سيتم حذف السجلات نهائيًا من قاعدة البيانات.',
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
          .from(PwfDatabaseOwnerSurfaces.announcements)
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
    List<Announcement> items,
  ) async {
    final selectedItems = items
        .where((item) => _selectedIds.contains(item.id))
        .toList(growable: false);
    final now = DateTime.now();
    switch (action) {
      case 'selected':
        await _deleteMany(
          selectedItems,
          title: 'حذف المحدد',
          description: 'سيتم حذف الإعلانات التي حددتها من البطاقات الحالية.',
          successMessage: 'تم حذف الإعلانات المحددة',
        );
        return;
      case 'all_visible':
        await _deleteMany(
          items,
          title: 'حذف النتائج الحالية',
          description:
              'سيتم حذف كل الإعلانات الظاهرة الآن ضمن النطاق والبحث الحاليين.',
          successMessage: 'تم حذف الإعلانات الظاهرة',
        );
        return;
      case 'inactive_only':
        await _deleteMany(
          items.where((item) => !item.isActive).toList(growable: false),
          title: 'حذف غير النشط',
          description: 'سيتم حذف الإعلانات غير النشطة فقط من النتائج الحالية.',
          successMessage: 'تم حذف الإعلانات غير النشطة',
        );
        return;
      case 'expired_only':
        await _deleteMany(
          items
              .where(
                (item) =>
                    item.validUntil != null && item.validUntil!.isBefore(now),
              )
              .toList(growable: false),
          title: 'حذف منتهي الصلاحية',
          description:
              'سيتم حذف الإعلانات المنتهية الصلاحية فقط من النتائج الحالية.',
          successMessage: 'تم حذف الإعلانات المنتهية',
        );
        return;
    }
  }

  Future<void> _toggleActive(Announcement announcement, bool value) async {
    try {
      final supabase = ref.read(supabaseServiceProvider).client;
      await supabase
          .from(PwfDatabaseOwnerSurfaces.announcements)
          .update({
            'is_active': value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', announcement.id);
      _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(value ? 'تم تفعيل الإعلان' : 'تم إيقاف الإعلان'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر تحديث حالة الإعلان: $e')));
    }
  }

  void _showDetails(Announcement announcement) {
    showDialog<void>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(announcement.title),
          content: SizedBox(
            width: 760,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SharedAdminMetaChip(
                        label: announcement.priority.displayName,
                        icon: Icons.priority_high_outlined,
                        color: _priorityColor(announcement.priority),
                        soft: true,
                      ),
                      SharedAdminMetaChip(
                        label: announcement.isActive ? 'نشط' : 'غير نشط',
                        icon: announcement.isActive
                            ? Icons.check_circle_outline
                            : Icons.pause_circle_outline,
                        color: announcement.isActive
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF6B7280),
                        soft: true,
                      ),
                      SharedAdminMetaChip(
                        label: 'الجمهور: ${announcement.targetAudience}',
                        icon: Icons.people_alt_outlined,
                      ),
                      if (announcement.isFeatured)
                        const SharedAdminMetaChip(
                          label: 'مميز',
                          icon: Icons.star_outline,
                          color: Color(0xFFD4AF37),
                          soft: true,
                        ),
                      if (announcement.isPinned)
                        const SharedAdminMetaChip(
                          label: 'مثبت',
                          icon: Icons.push_pin_outlined,
                          color: Color(0xFF0B3A70),
                          soft: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _AnnouncementDetailRow(
                    label: 'تاريخ الإنشاء',
                    value: sharedAdminFormatDateTime(
                      announcement.publishAt ?? announcement.createdAt,
                    ),
                  ),
                  _AnnouncementDetailRow(
                    label: 'الصلاحية حتى',
                    value: sharedAdminFormatDate(announcement.validUntil),
                  ),
                  _AnnouncementDetailBlock(
                    label: 'المحتوى',
                    value: announcement.content,
                  ),
                  if ((announcement.imageUrl ?? '').trim().isNotEmpty)
                    _AnnouncementDetailBlock(
                      label: 'رابط الصورة',
                      value: announcement.imageUrl!,
                    ),
                  if ((announcement.attachmentUrl ?? '').trim().isNotEmpty)
                    _AnnouncementDetailBlock(
                      label: 'رابط المرفق',
                      value: announcement.attachmentUrl!,
                    ),
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

        final listAsync = ref.watch(adminAnnouncementsProvider(_query));

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
                final cardAspectRatio = width >= 900 ? 1.12 : 0.84;

                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    SharedAdminSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مساحة إدارة الإعلانات',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'إدارة الإعلانات والنشرات والتنويهات الرسمية مع معاينة مباشرة، وتفعيل سريع، ونطاق واضح بين الوزارة والوحدة.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: const Color(0xFF6B7280),
                                  height: 1.5,
                                ),
                          ),
                          const SizedBox(height: 16),
                          SharedHomepageCountControlCard(
                            key: ValueKey('ann-home-count-$_unitSlug'),
                            unitSlug: _unitSlug,
                            unitId: unitId,
                            primarySectionName: 'pwf_announcements',
                            aliases: const ['announcements'],
                            title: 'التحكم في عدد الإعلانات في الصفحة الرئيسية',
                            description:
                                'حدد عدد بطاقات الإعلانات التي تظهر في الصفحة الرئيسية لهذا النطاق، مع التحكم في زر عرض الكل.',
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
                                    labelText: 'بحث في العنوان أو المحتوى',
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
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Switch(
                                        value: _includeInactive,
                                        onChanged: (v) => setState(
                                          () => _includeInactive = v,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text(
                                          'إظهار غير النشط',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
                                      label: const Text('إضافة إعلان'),
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
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              SharedContentScopeBadge(slug: _unitSlug),
                              SizedBox(
                                width: width > 720 ? width - 220 : width,
                                child: SharedAdminSectionNotice(
                                  message: sharedContentScopeHint(_unitSlug),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    listAsync.when(
                      loading: () => const SharedAdminLoadingState(
                        message: 'جاري تحميل الإعلانات...',
                      ),
                      error: (e, _) => SharedAdminErrorState(
                        message: 'تعذر تحميل الإعلانات: $e',
                        onRetry: _refresh,
                      ),
                      data: (items) {
                        final visibleItems = items;
                        final selectedCount = visibleItems
                            .where((item) => _selectedIds.contains(item.id))
                            .length;
                        final activeCount = visibleItems
                            .where((item) => item.isActive)
                            .length;
                        final highlightedCount = visibleItems
                            .where((item) => item.isFeatured || item.isPinned)
                            .length;
                        final urgentCount = visibleItems
                            .where(
                              (item) =>
                                  item.priority == Priority.high ||
                                  item.priority == Priority.urgent ||
                                  item.priority == Priority.critical,
                            )
                            .length;
                        final expiredCount = visibleItems
                            .where(
                              (item) =>
                                  item.validUntil != null &&
                                  item.validUntil!.isBefore(DateTime.now()),
                            )
                            .length;

                        return Column(
                          children: [
                            if (visibleItems.isNotEmpty)
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
                                      onPressed: () => _selectAll(visibleItems),
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
                                            visibleItems,
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
                                          value: 'inactive_only',
                                          child: Text('حذف غير النشط فقط'),
                                        ),
                                        PopupMenuItem(
                                          value: 'expired_only',
                                          child: Text('حذف منتهي الصلاحية فقط'),
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
                            if (visibleItems.isNotEmpty)
                              const SizedBox(height: 16),
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
                                  label: 'إجمالي الإعلانات',
                                  value: visibleItems.length.toString(),
                                  icon: Icons.campaign_outlined,
                                  color: const Color(0xFF0B3A70),
                                ),
                                SharedAdminStatCard(
                                  label: 'نشط',
                                  value: activeCount.toString(),
                                  icon: Icons.check_circle_outline,
                                  color: const Color(0xFF2E7D32),
                                ),
                                SharedAdminStatCard(
                                  label: 'أولوية عالية فأكثر',
                                  value: urgentCount.toString(),
                                  icon: Icons.priority_high_outlined,
                                  color: const Color(0xFFB22222),
                                ),
                                SharedAdminStatCard(
                                  label: 'منتهي الصلاحية',
                                  value: expiredCount.toString(),
                                  icon: Icons.event_busy_outlined,
                                  color: const Color(0xFF7C3AED),
                                  helper: 'مميز/مثبت: $highlightedCount',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (visibleItems.isEmpty)
                              SharedAdminEmptyState(
                                title: 'لا توجد إعلانات في هذا النطاق',
                                message:
                                    'يمكنك بدء إضافة أول إعلان لهذا السياق، أو تغيير النطاق الحالي.',
                                icon: Icons.campaign_outlined,
                                action: FilledButton.icon(
                                  onPressed: () => _openForm(unitId: unitId),
                                  icon: const Icon(Icons.add),
                                  label: const Text('إضافة إعلان'),
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
                                itemCount: visibleItems.length,
                                itemBuilder: (context, index) {
                                  final announcement = visibleItems[index];
                                  return _AnnouncementCard(
                                    announcement: announcement,
                                    selectionMode: _selectionMode,
                                    isSelected: _selectedIds.contains(
                                      announcement.id,
                                    ),
                                    onSelectionChanged: (value) =>
                                        _setSelected(announcement.id, value),
                                    onView: () => _showDetails(announcement),
                                    onEdit: () => _openForm(
                                      unitId: unitId,
                                      existing: announcement,
                                    ),
                                    onDelete: () => _delete(announcement),
                                    onToggleActive: (value) =>
                                        _toggleActive(announcement, value),
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

class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.announcement,
    required this.selectionMode,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  final Announcement announcement;
  final bool selectionMode;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleActive;

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
                  announcement.title,
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
                  color: _priorityColor(
                    announcement.priority,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  announcement.priority.displayName,
                  style: TextStyle(
                    color: _priorityColor(announcement.priority),
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
                label: announcement.isActive ? 'نشط' : 'غير نشط',
                icon: announcement.isActive
                    ? Icons.check_circle_outline
                    : Icons.pause_circle_outline,
                color: announcement.isActive
                    ? const Color(0xFF2E7D32)
                    : const Color(0xFF6B7280),
                soft: true,
              ),
              SharedAdminMetaChip(
                label: 'الجمهور: ${announcement.targetAudience}',
                icon: Icons.people_alt_outlined,
              ),
              if (announcement.isFeatured)
                const SharedAdminMetaChip(
                  label: 'مميز',
                  icon: Icons.star_outline,
                  color: Color(0xFFD4AF37),
                  soft: true,
                ),
              if (announcement.isPinned)
                const SharedAdminMetaChip(
                  label: 'مثبت',
                  icon: Icons.push_pin_outlined,
                  color: Color(0xFF0B3A70),
                  soft: true,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              announcement.content,
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
              _AnnouncementFooterMeta(
                icon: Icons.schedule_outlined,
                value: sharedAdminFormatDateTime(
                  announcement.publishAt ?? announcement.createdAt,
                ),
              ),
              _AnnouncementFooterMeta(
                icon: Icons.event_available_outlined,
                value: sharedAdminFormatDate(announcement.validUntil),
              ),
              if (announcement.sortOrder != 0)
                _AnnouncementFooterMeta(
                  icon: Icons.sort,
                  value: 'ترتيب ${announcement.sortOrder}',
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      announcement.isActive ? 'مفعل' : 'موقوف',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: announcement.isActive,
                      onChanged: onToggleActive,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SharedAdminRecordActions(
                compact: true,
                onView: onView,
                onEdit: onEdit,
                onDelete: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Color _priorityColor(Priority priority) {
  switch (priority) {
    case Priority.critical:
      return const Color(0xFFB22222);
    case Priority.urgent:
      return const Color(0xFFC2410C);
    case Priority.high:
      return const Color(0xFFD97706);
    case Priority.medium:
      return const Color(0xFF0B3A70);
    case Priority.normal:
      return const Color(0xFF2563EB);
    case Priority.low:
      return const Color(0xFF2E7D32);
  }
}

class _AnnouncementFooterMeta extends StatelessWidget {
  const _AnnouncementFooterMeta({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6B7280)),
        const SizedBox(width: 6),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _AnnouncementDetailRow extends StatelessWidget {
  const _AnnouncementDetailRow({required this.label, required this.value});

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

class _AnnouncementDetailBlock extends StatelessWidget {
  const _AnnouncementDetailBlock({required this.label, required this.value});

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
