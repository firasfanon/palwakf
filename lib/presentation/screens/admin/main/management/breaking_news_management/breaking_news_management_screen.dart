// lib/presentation/screens/admin/breaking_news_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/data/repositories/homepage_repository.dart';
import 'package:waqf/presentation/widgets/web/web_container.dart';
import 'package:waqf/presentation/widgets/web/web_sidebar.dart';


// =====================================================
// PROVIDERS
// =====================================================
final breakingNewsRepositoryProvider = Provider<HomepageRepository>((ref) {
  return HomepageRepository(Supabase.instance.client);
});

// Breaking News Notifier
class BreakingNewsNotifier extends AsyncNotifier<List<BreakingNewsItem>> {
  @override
  Future<List<BreakingNewsItem>> build() async {
    final repository = ref.watch(breakingNewsRepositoryProvider);
    return repository.fetchAllBreakingNews();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(breakingNewsRepositoryProvider);
      return repository.fetchAllBreakingNews();
    });
  }

  Future<void> addItem(BreakingNewsItem item) async {
    final repository = ref.read(breakingNewsRepositoryProvider);
    await repository.createBreakingNewsItem(item);
    await refresh();
  }

  Future<void> updateItem(BreakingNewsItem item) async {
    final repository = ref.read(breakingNewsRepositoryProvider);
    await repository.updateBreakingNewsItem(item);
    await refresh();
  }

  Future<void> deleteItem(String id) async {
    final repository = ref.read(breakingNewsRepositoryProvider);
    await repository.deleteBreakingNewsItem(id);
    await refresh();
  }

  Future<void> deleteItems(List<String> ids) async {
    final repository = ref.read(breakingNewsRepositoryProvider);
    for (final id in ids) {
      await repository.deleteBreakingNewsItem(id);
    }
    await refresh();
  }
}

final breakingNewsProvider =
AsyncNotifierProvider<BreakingNewsNotifier, List<BreakingNewsItem>>(() {
  return BreakingNewsNotifier();
});

// =====================================================
// BREAKING NEWS MANAGEMENT SCREEN
// =====================================================
class BreakingNewsManagementScreen extends ConsumerStatefulWidget {
  const BreakingNewsManagementScreen({super.key});

  @override
  ConsumerState<BreakingNewsManagementScreen> createState() =>
      _BreakingNewsManagementScreenState();
}

class _BreakingNewsManagementScreenState
    extends ConsumerState<BreakingNewsManagementScreen> {
  bool _showInactiveItems = true;
  String _sortBy = 'order';
  final Set<String> _selectedItems = {};
  bool _isMultiSelectMode = false;

  @override
  void dispose() {
    _selectedItems.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(breakingNewsProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      body: Row(
        children: [
          const WebSidebar(currentRoute: '/admin/breaking-news'),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: itemsAsync.when(
                    data: (items) => _buildContent(items),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => _buildError(error),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // TOP BAR
  // =====================================================
  Widget _buildTopBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            const Icon(Icons.campaign, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            const Text(
              'إدارة الأخبار العاجلة',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const Spacer(),

            // Show Inactive Toggle
            Row(
              children: [
                Checkbox(
                  value: _showInactiveItems,
                  onChanged: (v) =>
                      setState(() => _showInactiveItems = v ?? true),
                  activeColor: Colors.red,
                ),
                const Text('عرض المخفية'),
              ],
            ),
            const SizedBox(width: 16),

            // Sort Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'order', child: Text('الترتيب')),
                    DropdownMenuItem(value: 'created', child: Text('الأحدث')),
                    DropdownMenuItem(
                        value: 'priority', child: Text('الأولوية')),
                  ],
                  onChanged: (v) => setState(() => _sortBy = v!),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Multi-select Mode
            if (_isMultiSelectMode) ...[
              OutlinedButton.icon(
                onPressed: _handleBulkDelete,
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                label: Text('حذف (${_selectedItems.length})'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isMultiSelectMode = false;
                    _selectedItems.clear();
                  });
                },
                child: const Text('إلغاء'),
              ),
              const SizedBox(width: 16),
            ],

            // Add New Item Button
            ElevatedButton.icon(
              onPressed: _handleAddItem,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('إضافة خبر عاجل'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // CONTENT
  // =====================================================
  Widget _buildContent(List<BreakingNewsItem> allItems) {
    var items = allItems;
    if (!_showInactiveItems) {
      items = items.where((s) => s.isActive).toList();
    }

    // Sort items
    switch (_sortBy) {
      case 'created':
        items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'priority':
        items.sort((a, b) {
          final priorities = {'urgent': 0, 'high': 1, 'normal': 2};
          return (priorities[a.priority] ?? 2)
              .compareTo(priorities[b.priority] ?? 2);
        });
        break;
      case 'order':
      default:
        items.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    }

    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: WebContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsBar(allItems),
            const SizedBox(height: 24),
            _buildListView(items),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBar(List<BreakingNewsItem> allItems) {
    final activeCount = allItems.where((s) => s.isActive).length;
    final urgentCount = allItems.where((s) => s.priority == 'urgent').length;
    final expiredCount = allItems
        .where((s) =>
    s.expiresAt != null && s.expiresAt!.isBefore(DateTime.now()))
        .length;

    return Row(
      children: [
        _buildStatChip(
          icon: Icons.campaign,
          label: 'إجمالي الأخبار',
          value: allItems.length.toString(),
          color: Colors.red,
        ),
        const SizedBox(width: 16),
        _buildStatChip(
          icon: Icons.check_circle,
          label: 'نشطة',
          value: activeCount.toString(),
          color: AppConstants.success,
        ),
        const SizedBox(width: 16),
        _buildStatChip(
          icon: Icons.warning,
          label: 'عاجلة',
          value: urgentCount.toString(),
          color: Colors.orange,
        ),
        const SizedBox(width: 16),
        _buildStatChip(
          icon: Icons.schedule,
          label: 'منتهية',
          value: expiredCount.toString(),
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // LIST VIEW
  // =====================================================
  Widget _buildListView(List<BreakingNewsItem> items) {
    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return _buildItemCard(item, index);
      }).toList(),
    );
  }

  Widget _buildItemCard(BreakingNewsItem item, int index) {
    final isSelected = _selectedItems.contains(item.id);
    final isExpired =
        item.expiresAt != null && item.expiresAt!.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.red : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _handleItemClick(item),
        onLongPress: () => _handleLongPress(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Selection Checkbox
              if (_isMultiSelectMode)
                Checkbox(
                  value: isSelected,
                  onChanged: (v) => _toggleSelection(item.id),
                  activeColor: Colors.red,
                ),

              // Order
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${item.displayOrder}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getPriorityColor(item.priority),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getPriorityLabel(item.priority),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isExpired) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'منتهية',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.link != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'الرابط: ${item.link}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    if (item.expiresAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'ينتهي في: ${_formatDate(item.expiresAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isExpired ? Colors.red : Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: item.isActive
                      ? AppConstants.success.withValues(alpha:0.1)
                      : Colors.grey.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.isActive ? 'نشطة' : 'مخفية',
                  style: TextStyle(
                    color: item.isActive ? AppConstants.success : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Actions
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _handleEditItem(item),
                    tooltip: 'تعديل',
                    color: Colors.red,
                  ),
                  IconButton(
                    icon: Icon(
                      item.isActive ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () => _handleToggleActive(item),
                    tooltip: item.isActive ? 'إخفاء' : 'إظهار',
                    color: Colors.orange,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () => _handleDeleteItem(item),
                    tooltip: 'حذف',
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // EMPTY STATE
  // =====================================================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.campaign,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد أخبار عاجلة بعد',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإضافة خبر عاجل جديد',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _handleAddItem,
            icon: const Icon(Icons.add),
            label: const Text('إضافة خبر عاجل'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ERROR STATE
  // =====================================================
  Widget _buildError(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 100,
            color: Colors.red,
          ),
          const SizedBox(height: 24),
          const Text(
            'حدث خطأ في تحميل الأخبار',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => ref.read(breakingNewsProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ACTIONS
  // =====================================================
  void _handleItemClick(BreakingNewsItem item) {
    if (_isMultiSelectMode) {
      _toggleSelection(item.id);
    } else {
      _handleEditItem(item);
    }
  }

  void _handleLongPress(BreakingNewsItem item) {
    setState(() {
      _isMultiSelectMode = true;
      _selectedItems.add(item.id);
    });
  }

  void _toggleSelection(String itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
        if (_selectedItems.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedItems.add(itemId);
      }
    });
  }

  void _handleAddItem() {
    final parentContext = context;
    final messenger = ScaffoldMessenger.of(parentContext);

    showDialog(
      context: context,
      builder: (context) => _ItemFormDialog(
        onSave: (item) async {
          await ref.read(breakingNewsProvider.notifier).addItem(item);

          if (mounted) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('تمت إضافة الخبر بنجاح'),
                backgroundColor: AppConstants.success,
              ),
            );
          }
        },
      ),
    );
  }

  void _handleEditItem(BreakingNewsItem item) {
    final parentContext = context;
    final messenger = ScaffoldMessenger.of(parentContext);

    showDialog(
      context: context,
      builder: (context) => _ItemFormDialog(
        item: item,
        onSave: (updatedItem) async {
          await ref.read(breakingNewsProvider.notifier).updateItem(updatedItem);

          if (mounted) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('تم تحديث الخبر بنجاح'),
                backgroundColor: AppConstants.success,
              ),
            );
          }
        },
      ),
    );
  }

  void _handleToggleActive(BreakingNewsItem item) async {
    final messenger = ScaffoldMessenger.of(context);

    await ref.read(breakingNewsProvider.notifier).updateItem(
      item.copyWith(isActive: !item.isActive),
    );

    if (mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            item.isActive ? 'تم إخفاء الخبر' : 'تم إظهار الخبر',
          ),
          backgroundColor: AppConstants.info,
        ),
      );
    }
  }

  void _handleDeleteItem(BreakingNewsItem item) {
    final parentContext = context;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${item.text}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Capture messenger before async gap
              final messenger = ScaffoldMessenger.of(parentContext);

              await ref.read(breakingNewsProvider.notifier).deleteItem(item.id);

              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف الخبر بنجاح'),
                    backgroundColor: AppConstants.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _handleBulkDelete() {
    if (_selectedItems.isEmpty) return;

    final parentContext = context;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
          'هل أنت متأكد من حذف ${_selectedItems.length} خبر؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final messenger = ScaffoldMessenger.of(parentContext);

              await ref.read(breakingNewsProvider.notifier).deleteItems(
                _selectedItems.toList(),
              );

              if (mounted) {
                setState(() {
                  _selectedItems.clear();
                  _isMultiSelectMode = false;
                });

                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف الأخبار بنجاح'),
                    backgroundColor: AppConstants.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // HELPER METHODS
  // =====================================================
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'urgent':
        return 'عاجل';
      case 'high':
        return 'هام';
      default:
        return 'عادي';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.isNegative) return 'منتهي';
    if (diff.inDays > 0) return '${diff.inDays} يوم';
    if (diff.inHours > 0) return '${diff.inHours} ساعة';
    return '${diff.inMinutes} دقيقة';
  }
}

// =====================================================
// ITEM FORM DIALOG
// =====================================================
class _ItemFormDialog extends StatefulWidget {
  final BreakingNewsItem? item;
  final Function(BreakingNewsItem) onSave;

  const _ItemFormDialog({
    this.item,
    required this.onSave,
  });

  @override
  State<_ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<_ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _textController;
  late TextEditingController _linkController;
  late String _priority;
  late int _displayOrder;
  late bool _isActive;
  DateTime? _expiresAt;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _textController = TextEditingController(text: item?.text ?? '');
    _linkController = TextEditingController(text: item?.link ?? '');
    _priority = item?.priority ?? 'normal';
    _displayOrder = item?.displayOrder ?? 1;
    _isActive = item?.isActive ?? true;
    _expiresAt = item?.expiresAt;
  }

  @override
  void dispose() {
    _textController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEditing ? 'تعديل الخبر العاجل' : 'إضافة خبر عاجل جديد',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 24),

                // Text
                TextFormField(
                  controller: _textController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'نص الخبر',
                    hintText: 'أدخل نص الخبر العاجل',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'الحقل مطلوب' : null,
                ),
                const SizedBox(height: 16),

                // Link
                TextFormField(
                  controller: _linkController,
                  decoration: const InputDecoration(
                    labelText: 'الرابط (اختياري)',
                    hintText: '/news/123',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _priority,
                        decoration: const InputDecoration(
                          labelText: 'الأولوية',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'urgent', child: Text('عاجل')),
                          DropdownMenuItem(value: 'high', child: Text('هام')),
                          DropdownMenuItem(
                              value: 'normal', child: Text('عادي')),
                        ],
                        onChanged: (v) => setState(() => _priority = v!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _displayOrder,
                        decoration: const InputDecoration(
                          labelText: 'الترتيب',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(
                          20,
                              (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text('${i + 1}'),
                          ),
                        ),
                        onChanged: (v) => setState(() => _displayOrder = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Expires At
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _expiresAt ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _expiresAt = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'تاريخ الانتهاء (اختياري)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _expiresAt != null
                          ? '${_expiresAt!.year}-${_expiresAt!.month}-${_expiresAt!.day}'
                          : 'بدون تاريخ انتهاء',
                    ),
                  ),
                ),
                if (_expiresAt != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => setState(() => _expiresAt = null),
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('إلغاء تاريخ الانتهاء'),
                  ),
                ],
                const SizedBox(height: 16),

                CheckboxListTile(
                  title: const Text('نشط'),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v ?? true),
                  activeColor: Colors.red,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 32),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: Text(isEditing ? 'تحديث' : 'إضافة'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final item = BreakingNewsItem(
      id: widget.item?.id ?? '',
      text: _textController.text,
      link: _linkController.text.isEmpty ? null : _linkController.text,
      priority: _priority,
      displayOrder: _displayOrder,
      isActive: _isActive,
      expiresAt: _expiresAt,
      bgColor: '#DC2626',
      textColor: '#FFFFFF',
      createdAt: widget.item?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(item);
    Navigator.pop(context);
  }
}
