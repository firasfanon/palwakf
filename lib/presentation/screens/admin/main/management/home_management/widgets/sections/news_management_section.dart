import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waqf/data/models/news_article.dart';
import 'package:waqf/presentation/providers/admin_news_provider.dart';
import 'package:waqf/presentation/providers/org_units_provider.dart';
import 'package:waqf/presentation/providers/supabase_providers.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';

import '../forms/news_article_form_dialog.dart';
import '../shared/shared_content_admin_ui.dart';
import '../shared/shared_content_scope.dart';
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

class NewsManagementSection extends ConsumerStatefulWidget {
  const NewsManagementSection({super.key});

  @override
  ConsumerState<NewsManagementSection> createState() =>
      _NewsManagementSectionState();
}

class _NewsManagementSectionState extends ConsumerState<NewsManagementSection> {
  String _unitSlug = 'home';
  late final TextEditingController _searchController;
  bool _includeAllStatuses = true;
  bool _selectionMode = false;
  final Set<int> _selectedIds = <int>{};

  String get _search => _searchController.text.trim();

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

  AdminNewsQuery get _query => AdminNewsQuery(
    unitSlug: _unitSlug,
    includeAllStatuses: _includeAllStatuses,
    search: _search,
  );

  void _refresh() {
    ref.invalidate(adminNewsArticlesProvider(_query));
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

  void _selectAll(Iterable<NewsArticle> items) {
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
    NewsArticle? existing,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => NewsArticleFormDialog(
        unitId: unitId,
        unitSlug: _unitSlug,
        existing: existing,
      ),
    );
    if (ok == true) {
      _refresh();
    }
  }

  Future<void> _delete(NewsArticle article) async {
    await _deleteMany(
      [article],
      title: 'حذف الخبر',
      description: 'سيتم حذف خبر واحد بعنوان "${article.title}".',
      successMessage: 'تم حذف الخبر',
    );
  }

  Future<void> _deleteMany(
    List<NewsArticle> items, {
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
                'هذه العملية تحذف السجلات نهائيًا من قاعدة البيانات.',
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
          .from(PwfDatabaseOwnerSurfaces.newsArticles)
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
    List<NewsArticle> items,
  ) async {
    final selectedItems = items
        .where((item) => _selectedIds.contains(item.id))
        .toList(growable: false);

    switch (action) {
      case 'selected':
        await _deleteMany(
          selectedItems,
          title: 'حذف العناصر المحددة',
          description:
              'سيتم حذف الأخبار التي حددتها يدويًا من البطاقات الحالية.',
          successMessage: 'تم حذف الأخبار المحددة',
        );
        return;
      case 'all_visible':
        await _deleteMany(
          items,
          title: 'حذف كل النتائج الحالية',
          description:
              'سيتم حذف كل الأخبار الظاهرة الآن ضمن النطاق والبحث الحاليين.',
          successMessage: 'تم حذف الأخبار الظاهرة',
        );
        return;
      case 'non_published':
        await _deleteMany(
          items
              .where((item) => item.status != PublishStatus.published)
              .toList(growable: false),
          title: 'حذف غير المنشور',
          description:
              'سيتم حذف المسودات والمجدول والمؤرشف فقط من النتائج الحالية.',
          successMessage: 'تم حذف الأخبار غير المنشورة',
        );
        return;
      case 'scheduled_only':
        await _deleteMany(
          items
              .where((item) => item.status == PublishStatus.scheduled)
              .toList(growable: false),
          title: 'حذف الأخبار المجدولة',
          description: 'سيتم حذف الأخبار المجدولة فقط من النتائج الحالية.',
          successMessage: 'تم حذف الأخبار المجدولة',
        );
        return;
    }
  }

  void _showDetails(NewsArticle article) {
    showDialog<void>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(article.title),
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
                        label: article.category.displayName,
                        icon: Icons.category_outlined,
                        soft: true,
                      ),
                      SharedAdminMetaChip(
                        label: article.status.displayName,
                        icon: Icons.public_outlined,
                        soft: true,
                      ),
                      if (article.isFeatured)
                        const SharedAdminMetaChip(
                          label: 'مميز',
                          icon: Icons.star_outline,
                          color: Color(0xFFD4AF37),
                          soft: true,
                        ),
                      if (article.isPinned)
                        const SharedAdminMetaChip(
                          label: 'مثبت',
                          icon: Icons.push_pin_outlined,
                          color: Color(0xFF0B3A70),
                          soft: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _DetailRow(label: 'العنوان', value: article.title),
                  _DetailRow(
                    label: 'الكاتب',
                    value: article.author.isEmpty ? '—' : article.author,
                  ),
                  _DetailRow(
                    label: 'تاريخ النشر',
                    value: sharedAdminFormatDateTime(
                      article.publishedAt ?? article.createdAt,
                    ),
                  ),
                  _DetailRow(
                    label: 'المشاهدات',
                    value: article.viewCount.toString(),
                  ),
                  if ((article.excerpt).trim().isNotEmpty)
                    _DetailBlock(label: 'المقتطف', value: article.excerpt),
                  _DetailBlock(label: 'المحتوى', value: article.content),
                  if ((article.imageUrl ?? '').trim().isNotEmpty)
                    _DetailBlock(
                      label: 'رابط الصورة',
                      value: article.imageUrl!,
                    ),
                  if ((article.attachmentUrl ?? '').trim().isNotEmpty)
                    _DetailBlock(
                      label: 'رابط المرفق',
                      value: article.attachmentUrl!,
                    ),
                  if (article.tags.isNotEmpty) ...[
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
                      children: article.tags
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

        final listAsync = ref.watch(adminNewsArticlesProvider(_query));

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
                final cardAspectRatio = width >= 900 ? 1.18 : 0.86;

                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    SharedAdminSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مساحة إدارة الأخبار',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'إدارة أخبار الوزارة والوحدات من نفس الصفحة، مع نطاق واضح لـ home و slug ومعاينة مباشرة لكل سجل قبل التحرير.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: const Color(0xFF6B7280),
                                  height: 1.5,
                                ),
                          ),
                          const SizedBox(height: 16),
                          SharedHomepageCountControlCard(
                            key: ValueKey('news-home-count-$_unitSlug'),
                            unitSlug: _unitSlug,
                            unitId: unitId,
                            primarySectionName: 'pwf_news_tabs',
                            aliases: const ['pwf_news'],
                            title: 'التحكم في عدد أخبار الصفحة الرئيسية',
                            description:
                                'حدد عدد بطاقات الأخبار التي تظهر في الصفحة الرئيسية ضمن النطاق الحالي، مع إمكانية إخفاء زر عرض الكل عند الحاجة.',
                            defaultHomeLimit: 5,
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
                                    labelText:
                                        'بحث في العنوان أو المقتطف أو المحتوى',
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
                                        value: _includeAllStatuses,
                                        onChanged: (v) => setState(
                                          () => _includeAllStatuses = v,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text(
                                          'عرض كل الحالات',
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
                                      label: const Text('إضافة خبر'),
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
                        message: 'جاري تحميل الأخبار...',
                      ),
                      error: (e, _) => SharedAdminErrorState(
                        message: 'تعذر تحميل الأخبار: $e',
                        onRetry: _refresh,
                      ),
                      data: (items) {
                        final visibleItems = items;
                        final selectedCount = visibleItems
                            .where((item) => _selectedIds.contains(item.id))
                            .length;
                        final publishedCount = visibleItems
                            .where(
                              (item) => item.status == PublishStatus.published,
                            )
                            .length;
                        final featuredCount = visibleItems
                            .where((item) => item.isFeatured)
                            .length;
                        final pinnedCount = visibleItems
                            .where((item) => item.isPinned)
                            .length;
                        final scheduledCount = visibleItems
                            .where(
                              (item) => item.status == PublishStatus.scheduled,
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
                                  crossAxisAlignment: WrapCrossAlignment.center,
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
                                          value: 'non_published',
                                          child: Text(
                                            'حذف غير المنشور من النتائج الحالية',
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'scheduled_only',
                                          child: Text('حذف المجدول فقط'),
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
                                  label: 'إجمالي الأخبار',
                                  value: visibleItems.length.toString(),
                                  icon: Icons.newspaper_outlined,
                                  color: const Color(0xFF0B3A70),
                                  helper: 'ضمن النطاق الحالي',
                                ),
                                SharedAdminStatCard(
                                  label: 'منشور',
                                  value: publishedCount.toString(),
                                  icon: Icons.public_outlined,
                                  color: const Color(0xFF2E7D32),
                                ),
                                SharedAdminStatCard(
                                  label: 'مميز / مثبت',
                                  value: '${featuredCount + pinnedCount}',
                                  icon: Icons.star_outline,
                                  color: const Color(0xFFD4AF37),
                                  helper:
                                      'مميز: $featuredCount • مثبت: $pinnedCount',
                                ),
                                SharedAdminStatCard(
                                  label: 'مجدول',
                                  value: scheduledCount.toString(),
                                  icon: Icons.schedule_outlined,
                                  color: const Color(0xFF7C3AED),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (visibleItems.isEmpty)
                              SharedAdminEmptyState(
                                title: 'لا توجد أخبار في هذا النطاق',
                                message:
                                    'يمكنك البدء بإضافة أول خبر لهذا السياق، أو تبديل النطاق إلى وزارة / وحدة أخرى.',
                                icon: Icons.feed_outlined,
                                action: FilledButton.icon(
                                  onPressed: () => _openForm(unitId: unitId),
                                  icon: const Icon(Icons.add),
                                  label: const Text('إضافة خبر'),
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
                                  final article = visibleItems[index];
                                  final preview =
                                      article.excerpt.trim().isNotEmpty
                                      ? article.excerpt.trim()
                                      : article.content.trim();
                                  return _NewsArticleCard(
                                    article: article,
                                    preview: preview,
                                    selectionMode: _selectionMode,
                                    isSelected: _selectedIds.contains(
                                      article.id,
                                    ),
                                    onSelectionChanged: (value) =>
                                        _setSelected(article.id, value),
                                    onView: () => _showDetails(article),
                                    onEdit: () => _openForm(
                                      unitId: unitId,
                                      existing: article,
                                    ),
                                    onDelete: () => _delete(article),
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

class _NewsArticleCard extends StatelessWidget {
  const _NewsArticleCard({
    required this.article,
    required this.preview,
    required this.selectionMode,
    required this.isSelected,
    required this.onSelectionChanged,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final NewsArticle article;
  final String preview;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'الكاتب: ${article.author.isEmpty ? 'غير محدد' : article.author}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              if (selectionMode)
                Checkbox(
                  value: isSelected,
                  onChanged: (value) => onSelectionChanged(value ?? false),
                ),
              if ((article.imageUrl ?? '').trim().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    article.imageUrl!,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _ThumbnailFallback(icon: Icons.image_outlined),
                  ),
                )
              else
                const _ThumbnailFallback(icon: Icons.newspaper_outlined),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SharedAdminMetaChip(
                label: article.category.displayName,
                icon: Icons.category_outlined,
              ),
              SharedAdminMetaChip(
                label: article.status.displayName,
                icon: Icons.public_outlined,
              ),
              if (article.isFeatured)
                const SharedAdminMetaChip(
                  label: 'مميز',
                  icon: Icons.star_outline,
                  color: Color(0xFFD4AF37),
                  soft: true,
                ),
              if (article.isPinned)
                const SharedAdminMetaChip(
                  label: 'مثبت',
                  icon: Icons.push_pin_outlined,
                  color: Color(0xFF0B3A70),
                  soft: true,
                ),
              if (article.attachmentUrl != null &&
                  article.attachmentUrl!.trim().isNotEmpty)
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
              preview.isEmpty
                  ? 'لا يوجد مقتطف أو محتوى مختصر لهذا الخبر.'
                  : preview,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF374151),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _FooterMeta(
                icon: Icons.calendar_today_outlined,
                value: sharedAdminFormatDate(
                  article.publishedAt ?? article.createdAt,
                ),
              ),
              _FooterMeta(
                icon: Icons.visibility_outlined,
                value: '${article.viewCount} مشاهدة',
              ),
              if (article.sortOrder != 0)
                _FooterMeta(
                  icon: Icons.sort,
                  value: 'ترتيب ${article.sortOrder}',
                ),
            ],
          ),
          const SizedBox(height: 14),
          SharedAdminRecordActions(
            compact: true,
            onView: onView,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ],
      ),
    );
  }
}

class _FooterMeta extends StatelessWidget {
  const _FooterMeta({required this.icon, required this.value});

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

class _ThumbnailFallback extends StatelessWidget {
  const _ThumbnailFallback({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Icon(icon, color: const Color(0xFF6B7280)),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF111827),
              ),
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

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({required this.label, required this.value});

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
