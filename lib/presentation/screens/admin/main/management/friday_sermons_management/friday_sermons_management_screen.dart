import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/data/models/friday_sermon.dart';
import 'package:waqf/presentation/widgets/admin/admin_layout.dart';

import '../../../../../../core/access/access_provider.dart';
import '../../../../../../core/enums/enums.dart';
import '../../../../../../core/utils/date_utils.dart';
import '../../../../../providers/friday_sermons_provider.dart';
import '../../../../../providers/unit_context_provider.dart';
import '../home_management/widgets/shared/shared_content_admin_ui.dart';

class FridaySermonsManagementScreen extends ConsumerStatefulWidget {
  const FridaySermonsManagementScreen({super.key});

  @override
  ConsumerState<FridaySermonsManagementScreen> createState() =>
      _FridaySermonsManagementScreenState();
}

class _FridaySermonsManagementScreenState
    extends ConsumerState<FridaySermonsManagementScreen> {
  late final TextEditingController _searchController;
  bool _selectionMode = false;
  final Set<String> _selectedIds = <String>{};

  String get _search => _searchController.text.trim().toLowerCase();

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
    ref.invalidate(adminFridaySermonsProvider);
    ref.invalidate(publicFridaySermonsProvider);
  }

  void _toggleSelectionMode() {
    setState(() {
      _selectionMode = !_selectionMode;
      if (!_selectionMode) {
        _selectedIds.clear();
      }
    });
  }

  void _setSelected(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _selectAll(Iterable<FridaySermon> items) {
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

  List<FridaySermon> _applySearch(List<FridaySermon> items) {
    if (_search.isEmpty) return items;
    return items
        .where((item) {
          final text = <String>[
            item.titleAr,
            item.titleEn ?? '',
            item.speakerName ?? '',
            item.mosqueName ?? '',
            item.summaryAr ?? '',
            item.contentAr ?? '',
          ].join(' ').toLowerCase();
          return text.contains(_search);
        })
        .toList(growable: false);
  }

  void _showDetails(FridaySermon sermon) {
    showDialog<void>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(sermon.titleAr.isEmpty ? 'خطبة الجمعة' : sermon.titleAr),
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
                        label: sermon.isPublished ? 'منشور' : 'غير منشور',
                        icon: sermon.isPublished
                            ? Icons.public_outlined
                            : Icons.visibility_off_outlined,
                        color: sermon.isPublished
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF6B7280),
                        soft: true,
                      ),
                      SharedAdminMetaChip(
                        label: AppDateUtils.formatArabicDate(sermon.sermonDate),
                        icon: Icons.calendar_today_outlined,
                      ),
                      if ((sermon.pdfUrl ?? '').trim().isNotEmpty)
                        const SharedAdminMetaChip(
                          label: 'PDF',
                          icon: Icons.picture_as_pdf_outlined,
                          color: Color(0xFFB22222),
                          soft: true,
                        ),
                      if ((sermon.audioUrl ?? '').trim().isNotEmpty)
                        const SharedAdminMetaChip(
                          label: 'صوت',
                          icon: Icons.audiotrack_outlined,
                          color: Color(0xFF0B3A70),
                          soft: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _FridayDetailRow(
                    label: 'الخطيب',
                    value: (sermon.speakerName ?? '').trim().isEmpty
                        ? '—'
                        : sermon.speakerName!,
                  ),
                  _FridayDetailRow(
                    label: 'المسجد',
                    value: (sermon.mosqueName ?? '').trim().isEmpty
                        ? '—'
                        : sermon.mosqueName!,
                  ),
                  if ((sermon.summaryAr ?? '').trim().isNotEmpty)
                    _FridayDetailBlock(
                      label: 'الملخص',
                      value: sermon.summaryAr!,
                    ),
                  if ((sermon.contentAr ?? '').trim().isNotEmpty)
                    _FridayDetailBlock(
                      label: 'نص الخطبة',
                      value: sermon.contentAr!,
                    ),
                  if ((sermon.pdfUrl ?? '').trim().isNotEmpty)
                    _FridayDetailBlock(
                      label: 'رابط PDF',
                      value: sermon.pdfUrl!,
                    ),
                  if ((sermon.audioUrl ?? '').trim().isNotEmpty)
                    _FridayDetailBlock(
                      label: 'رابط الصوت',
                      value: sermon.audioUrl!,
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

  Future<void> _togglePublished(FridaySermon sermon, bool value) async {
    await ref.read(fridaySermonsRepositoryProvider).update(sermon.id, {
      'is_published': value,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
    _refresh();
  }

  Future<void> _openDialog({FridaySermon? existing}) async {
    await showDialog(
      context: context,
      builder: (_) => _UpsertSermonDialog(existing: existing),
    );
    _refresh();
  }

  Future<void> _delete(FridaySermon sermon) async {
    await _deleteMany(
      [sermon],
      title: 'حذف الخطبة',
      description:
          'سيتم حذف خطبة واحدة بعنوان "${sermon.titleAr.isEmpty ? 'خطبة الجمعة' : sermon.titleAr}".',
      successMessage: 'تم حذف الخطبة',
    );
  }

  Future<void> _deleteMany(
    List<FridaySermon> items, {
    required String title,
    required String description,
    required String successMessage,
  }) async {
    if (items.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد خطب مطابقة للحذف.')),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => Directionality(
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
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('تأكيد الحذف'),
            ),
          ],
        ),
      ),
    );
    if (ok != true) return;

    try {
      final repo = ref.read(fridaySermonsRepositoryProvider);
      for (final item in items) {
        await repo.delete(item.id);
      }
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
    List<FridaySermon> items,
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
          description: 'سيتم حذف الخطب التي حددتها من البطاقات الحالية.',
          successMessage: 'تم حذف الخطب المحددة',
        );
        return;
      case 'all_visible':
        await _deleteMany(
          items,
          title: 'حذف النتائج الحالية',
          description: 'سيتم حذف كل الخطب الظاهرة حاليًا ضمن البحث الحالي.',
          successMessage: 'تم حذف الخطب الظاهرة',
        );
        return;
      case 'unpublished_only':
        await _deleteMany(
          items.where((item) => !item.isPublished).toList(growable: false),
          title: 'حذف غير المنشور',
          description: 'سيتم حذف الخطب غير المنشورة فقط من النتائج الحالية.',
          successMessage: 'تم حذف الخطب غير المنشورة',
        );
        return;
      case 'older_unpublished':
        await _deleteMany(
          items
              .where(
                (item) =>
                    !item.isPublished &&
                    item.sermonDate.isBefore(
                      now.subtract(const Duration(days: 60)),
                    ),
              )
              .toList(growable: false),
          title: 'حذف المسودات القديمة',
          description:
              'سيتم حذف الخطب غير المنشورة الأقدم من 60 يومًا من النتائج الحالية.',
          successMessage: 'تم حذف المسودات القديمة',
        );
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(accessProfileProvider);
    final sermonsAsync = ref.watch(adminFridaySermonsProvider);
    final homeUnitIdAsync = ref.watch(unitIdBySlugProvider('home'));

    return AdminLayout(
      currentRoute: AppRoutes.adminFridaySermons,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: profileAsync.when(
              data: (profile) {
                final canManage =
                    (profile?.isSuperuser == true) ||
                    (profile?.can(
                          SystemKey.platformAdmin,
                          Permission.manageSite,
                        ) ??
                        false);
                if (!canManage) {
                  return const SharedAdminErrorState(
                    message:
                        'غير مصرح لك بإدارة خُطب الجمعة. تحتاج صلاحية manageSite على platformAdmin.',
                  );
                }

                return sermonsAsync.when(
                  loading: () => const SharedAdminLoadingState(
                    message: 'جاري تحميل الخُطب...',
                  ),
                  error: (e, _) => SharedAdminErrorState(
                    message: e.toString(),
                    onRetry: _refresh,
                  ),
                  data: (items) {
                    final filtered = _applySearch(items);
                    final selectedCount = filtered
                        .where((item) => _selectedIds.contains(item.id))
                        .length;
                    final publishedCount = filtered
                        .where((item) => item.isPublished)
                        .length;
                    final withPdfCount = filtered
                        .where((item) => (item.pdfUrl ?? '').trim().isNotEmpty)
                        .length;
                    final withAudioCount = filtered
                        .where(
                          (item) => (item.audioUrl ?? '').trim().isNotEmpty,
                        )
                        .length;
                    final latest = filtered.isEmpty
                        ? null
                        : (filtered.toList()..sort(
                                (a, b) => b.sermonDate.compareTo(a.sermonDate),
                              ))
                              .first;
                    final width = MediaQuery.of(context).size.width;
                    final cardColumns = width >= 1350
                        ? 3
                        : width >= 900
                        ? 2
                        : 1;

                    return ListView(
                      children: [
                        SharedAdminSurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'إدارة خُطب الجمعة',
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'تم تطوير الصفحة من جدول بدائي إلى مساحة إدارة أوضح: بحث، مؤشرات، بطاقة للخطبة الأحدث، ومعاينة كاملة لكل خطبة قبل التحرير.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: const Color(0xFF6B7280),
                                                height: 1.5,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      FilledButton.icon(
                                        onPressed: () => _openDialog(),
                                        icon: const Icon(Icons.add),
                                        label: const Text('خطبة جديدة'),
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
                                ],
                              ),
                              const SizedBox(height: 16),
                              homeUnitIdAsync.when(
                                loading: () => const SharedAdminSectionNotice(
                                  message:
                                      'جاري تحميل إعدادات ظهور خطب الجمعة في الصفحة الرئيسية...',
                                  icon: Icons.tune_outlined,
                                ),
                                error: (e, _) => SharedAdminSectionNotice(
                                  message:
                                      'تعذر تحميل إعدادات ظهور خطب الجمعة: $e',
                                  icon: Icons.error_outline,
                                  color: const Color(0xFFB22222),
                                ),
                                data: (homeUnitId) => SharedHomepageCountControlCard(
                                  key: const ValueKey('friday-home-count-home'),
                                  unitSlug: 'home',
                                  unitId: homeUnitId,
                                  primarySectionName: 'pwf_friday_sermons',
                                  aliases: const <String>[],
                                  title:
                                      'التحكم في عدد الخطب الظاهرة في الصفحة الرئيسية',
                                  description:
                                      'حدد عدد بطاقات خطب الجمعة والنشرات الدينية التي تظهر في الصفحة الرئيسية، مع التحكم في زر عرض الكل.',
                                  defaultHomeLimit: 3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  labelText:
                                      'بحث في العنوان أو الخطيب أو المسجد أو الملخص',
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
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
                                  icon: const Icon(Icons.remove_done_outlined),
                                  label: const Text('إلغاء التحديد'),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) =>
                                      _handleBulkDeleteAction(value, filtered),
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
                                      value: 'unpublished_only',
                                      child: Text('حذف غير المنشور فقط'),
                                    ),
                                    PopupMenuItem(
                                      value: 'older_unpublished',
                                      child: Text(
                                        'حذف المسودات الأقدم من 60 يومًا',
                                      ),
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
                          childAspectRatio: width >= 900 ? 2.2 : 2.8,
                          children: [
                            SharedAdminStatCard(
                              label: 'إجمالي الخطب',
                              value: filtered.length.toString(),
                              icon: Icons.menu_book_outlined,
                              color: const Color(0xFF0B3A70),
                            ),
                            SharedAdminStatCard(
                              label: 'منشور',
                              value: publishedCount.toString(),
                              icon: Icons.public_outlined,
                              color: const Color(0xFF2E7D32),
                            ),
                            SharedAdminStatCard(
                              label: 'PDF',
                              value: withPdfCount.toString(),
                              icon: Icons.picture_as_pdf_outlined,
                              color: const Color(0xFFB22222),
                            ),
                            SharedAdminStatCard(
                              label: 'صوت',
                              value: withAudioCount.toString(),
                              icon: Icons.audiotrack_outlined,
                              color: const Color(0xFF7C3AED),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (latest != null) ...[
                          SharedAdminSurfaceCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'أحدث خطبة',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    SharedAdminMetaChip(
                                      label: AppDateUtils.formatArabicDate(
                                        latest.sermonDate,
                                      ),
                                      icon: Icons.calendar_today_outlined,
                                    ),
                                    if ((latest.speakerName ?? '')
                                        .trim()
                                        .isNotEmpty)
                                      SharedAdminMetaChip(
                                        label: latest.speakerName!,
                                        icon: Icons.record_voice_over_outlined,
                                      ),
                                    if ((latest.mosqueName ?? '')
                                        .trim()
                                        .isNotEmpty)
                                      SharedAdminMetaChip(
                                        label: latest.mosqueName!,
                                        icon: Icons.mosque_outlined,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  latest.titleAr.isEmpty
                                      ? 'خطبة الجمعة'
                                      : latest.titleAr,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                if ((latest.summaryAr ?? '')
                                    .trim()
                                    .isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    latest.summaryAr!,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(height: 1.5),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if (filtered.isEmpty)
                          const SharedAdminEmptyState(
                            title: 'لا توجد نتائج',
                            message:
                                'لا توجد خُطب مطابقة لبحثك الحالي أو لا توجد بيانات منشورة بعد.',
                            icon: Icons.menu_book_outlined,
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
                                  childAspectRatio: width >= 900 ? 1.18 : 0.96,
                                ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final sermon = filtered[index];
                              return _FridayAdminCard(
                                sermon: sermon,
                                selectionMode: _selectionMode,
                                isSelected: _selectedIds.contains(sermon.id),
                                onSelectionChanged: (value) =>
                                    _setSelected(sermon.id, value),
                                onView: () => _showDetails(sermon),
                                onEdit: () => _openDialog(existing: sermon),
                                onDelete: () => _delete(sermon),
                                onTogglePublished: (value) =>
                                    _togglePublished(sermon, value),
                              );
                            },
                          ),
                      ],
                    );
                  },
                );
              },
              loading: () => const SharedAdminLoadingState(
                message: 'جاري تحميل الصلاحيات...',
              ),
              error: (e, _) => SharedAdminErrorState(message: e.toString()),
            ),
          ),
        ),
      ),
    );
  }
}

class _FridayAdminCard extends StatelessWidget {
  const _FridayAdminCard({
    required this.sermon,
    required this.selectionMode,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePublished,
  });

  final FridaySermon sermon;
  final bool selectionMode;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onTogglePublished;

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
                  sermon.titleAr.isEmpty ? 'خطبة الجمعة' : sermon.titleAr,
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
                  color:
                      (sermon.isPublished
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF6B7280))
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  sermon.isPublished ? 'منشور' : 'غير منشور',
                  style: TextStyle(
                    color: sermon.isPublished
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFF6B7280),
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
                label: AppDateUtils.formatArabicDate(sermon.sermonDate),
                icon: Icons.calendar_today_outlined,
              ),
              if ((sermon.speakerName ?? '').trim().isNotEmpty)
                SharedAdminMetaChip(
                  label: sermon.speakerName!,
                  icon: Icons.record_voice_over_outlined,
                ),
              if ((sermon.mosqueName ?? '').trim().isNotEmpty)
                SharedAdminMetaChip(
                  label: sermon.mosqueName!,
                  icon: Icons.mosque_outlined,
                ),
              if ((sermon.pdfUrl ?? '').trim().isNotEmpty)
                const SharedAdminMetaChip(
                  label: 'PDF',
                  icon: Icons.picture_as_pdf_outlined,
                  color: Color(0xFFB22222),
                  soft: true,
                ),
              if ((sermon.audioUrl ?? '').trim().isNotEmpty)
                const SharedAdminMetaChip(
                  label: 'صوت',
                  icon: Icons.audiotrack_outlined,
                  color: Color(0xFF0B3A70),
                  soft: true,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              (sermon.summaryAr ?? '').trim().isNotEmpty
                  ? sermon.summaryAr!
                  : ((sermon.contentAr ?? '').trim().isNotEmpty
                        ? sermon.contentAr!
                        : 'لا يوجد ملخص مختصر لهذه الخطبة بعد.'),
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.55),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      sermon.isPublished ? 'منشور' : 'مسودة',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: sermon.isPublished,
                      onChanged: onTogglePublished,
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

class _FridayDetailRow extends StatelessWidget {
  const _FridayDetailRow({required this.label, required this.value});

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

class _FridayDetailBlock extends StatelessWidget {
  const _FridayDetailBlock({required this.label, required this.value});

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

class _UpsertSermonDialog extends ConsumerStatefulWidget {
  final FridaySermon? existing;
  const _UpsertSermonDialog({this.existing});

  @override
  ConsumerState<_UpsertSermonDialog> createState() =>
      _UpsertSermonDialogState();
}

class _UpsertSermonDialogState extends ConsumerState<_UpsertSermonDialog> {
  late final TextEditingController _titleAr;
  late final TextEditingController _speaker;
  late final TextEditingController _mosque;
  late final TextEditingController _summary;
  late final TextEditingController _content;
  late final TextEditingController _audioUrl;
  late final TextEditingController _pdfUrl;

  DateTime _date = DateTime.now();
  bool _published = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleAr = TextEditingController(text: e?.titleAr ?? '');
    _speaker = TextEditingController(text: e?.speakerName ?? '');
    _mosque = TextEditingController(text: e?.mosqueName ?? '');
    _summary = TextEditingController(text: e?.summaryAr ?? '');
    _content = TextEditingController(text: e?.contentAr ?? '');
    _audioUrl = TextEditingController(text: e?.audioUrl ?? '');
    _pdfUrl = TextEditingController(text: e?.pdfUrl ?? '');
    _date = e?.sermonDate ?? DateTime.now();
    _published = e?.isPublished ?? true;
  }

  @override
  void dispose() {
    _titleAr.dispose();
    _speaker.dispose();
    _mosque.dispose();
    _summary.dispose();
    _content.dispose();
    _audioUrl.dispose();
    _pdfUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text(isEdit ? 'تعديل خطبة' : 'خطبة جديدة'),
        content: SizedBox(
          width: 720,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleAr,
                  decoration: const InputDecoration(
                    labelText: 'العنوان (عربي)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _speaker,
                        decoration: const InputDecoration(
                          labelText: 'الخطيب',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _mosque,
                        decoration: const InputDecoration(
                          labelText: 'المسجد',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _date = picked);
                          }
                        },
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          'التاريخ: ${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SwitchListTile(
                        value: _published,
                        onChanged: (v) => setState(() => _published = v),
                        title: const Text('منشور'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _summary,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'ملخص (عربي)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _content,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    labelText: 'نص الخطبة (عربي)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _audioUrl,
                        decoration: const InputDecoration(
                          labelText: 'رابط الصوت (اختياري)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _pdfUrl,
                        decoration: const InputDecoration(
                          labelText: 'رابط PDF (اختياري)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleAr.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('العنوان مطلوب')));
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(fridaySermonsRepositoryProvider);

      if (widget.existing == null) {
        final sermon = FridaySermon(
          id: '',
          titleAr: title,
          sermonDate: _date,
          speakerName: _speaker.text.trim().isEmpty
              ? null
              : _speaker.text.trim(),
          mosqueName: _mosque.text.trim().isEmpty ? null : _mosque.text.trim(),
          summaryAr: _summary.text.trim().isEmpty ? null : _summary.text.trim(),
          contentAr: _content.text.trim().isEmpty ? null : _content.text.trim(),
          audioUrl: _audioUrl.text.trim().isEmpty
              ? null
              : _audioUrl.text.trim(),
          pdfUrl: _pdfUrl.text.trim().isEmpty ? null : _pdfUrl.text.trim(),
          isPublished: _published,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repo.create(sermon);
      } else {
        await repo.update(
          widget.existing!.id,
          {
            'title_ar': title,
            'sermon_date': _date.toIso8601String().substring(0, 10),
            'speaker_name': _speaker.text.trim().isEmpty
                ? null
                : _speaker.text.trim(),
            'mosque_name': _mosque.text.trim().isEmpty
                ? null
                : _mosque.text.trim(),
            'summary_ar': _summary.text.trim().isEmpty
                ? null
                : _summary.text.trim(),
            'content_ar': _content.text.trim().isEmpty
                ? null
                : _content.text.trim(),
            'audio_url': _audioUrl.text.trim().isEmpty
                ? null
                : _audioUrl.text.trim(),
            'pdf_url': _pdfUrl.text.trim().isEmpty ? null : _pdfUrl.text.trim(),
            'is_published': _published,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          }..removeWhere((k, v) => v == null),
        );
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
