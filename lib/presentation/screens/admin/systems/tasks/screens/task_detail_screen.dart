// lib/presentation/screens/admin/systems/tasks/screens/task_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/core/services/task_service.dart';
import 'package:waqf/data/models/task.dart';
import 'package:waqf/app/routing/app_routes.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  final TaskService _taskService = TaskService();
  Task? _task;
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadTaskDetails();
  }

  Future<void> _loadTaskDetails() async {
    try {
      final task = await _taskService.getTaskById(widget.taskId);
      setState(() {
        _task = task;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ خطأ في تحميل تفاصيل المهمة: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في تحميل المهمة: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه المهمة؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isDeleting = true);

      final success = await _taskService.deleteTask(widget.taskId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم حذف المهمة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );

        // العودة للقائمة بعد تأخير
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ فشل في حذف المهمة'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() => _isDeleting = false);
    }
  }

  void _navigateToEdit() {
    context.push(AppRoutes.adminTaskForm, extra: widget.taskId,).then((_) {
      // إعادة تحميل البيانات بعد التعديل
      _loadTaskDetails();
    });
  }

  void _updateTaskStatus(TaskStatus newStatus) async {
    try {
      final updates = {
        'status': newStatus.toString().split('.').last,
        'status_date': DateTime.now().toIso8601String(),
      };

      if (newStatus == TaskStatus.completed) {
        updates['completion_date'] = DateTime.now().toIso8601String();
        updates['progress_percentage'] = 100;
      }

      final updatedTask = await _taskService.updateTask(widget.taskId, updates);

      if (updatedTask != null && mounted) {
        setState(() => _task = updatedTask);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم تغيير الحالة إلى: ${newStatus.statusDisplayName}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ خطأ في تحديث حالة المهمة: $e');
    }
  }

  Widget _buildStatusButton(TaskStatus status, Color color) {
    return ElevatedButton(
      onPressed: _task?.status != status ? () => _updateTaskStatus(status) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(120, 40),
      ),
      child: Text(status.statusDisplayName),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('تحميل...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل المهمة')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'المهمة غير موجودة',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'قد تكون المهمة قد تم حذفها',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final task = _task!;

    return Scaffold(
      appBar: AppBar(
        title: Text(task.displayTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEdit,
            tooltip: 'تعديل',
          ),
          IconButton(
            icon: _isDeleting
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.delete),
            onPressed: _isDeleting ? null : _deleteTask,
            tooltip: 'حذف',
            color: Colors.red,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ بطاقة المهمة الرئيسية
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            task.displayTitle,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(task.status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            task.status.statusDisplayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (task.displayDescription.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'الوصف:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(task.displayDescription),
                          const SizedBox(height: 16),
                        ],
                      ),

                    // ✅ معلومات سريعة
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildInfoChip(
                          'النوع: ${task.typeDisplayName}',
                          _getTypeColor(task.type),
                          Icons.category,
                        ),
                        _buildInfoChip(
                          'الأولوية: ${task.priority.priorityDisplayName}',
                          _getPriorityColor(task.priority),
                          Icons.flag,
                        ),
                        _buildInfoChip(
                          'تاريخ الاستحقاق: ${_formatDate(task.dueDate)}',
                          Colors.blueGrey,
                          Icons.calendar_today,
                        ),
                        if (task.completionDate != null)
                          _buildInfoChip(
                            'تاريخ الإنجاز: ${_formatDate(task.completionDate!)}',
                            Colors.green,
                            Icons.check_circle,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ حالة المهمة - أزرار تغيير الحالة
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تغيير حالة المهمة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStatusButton(TaskStatus.newTask, Colors.blue),
                        _buildStatusButton(TaskStatus.inProgress, Colors.orange),
                        _buildStatusButton(TaskStatus.underAction, Colors.red),
                        _buildStatusButton(TaskStatus.completed, Colors.green),
                        _buildStatusButton(TaskStatus.cancelled, Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ معلومات التقدم
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'التقدم',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (task.progressPercentage ?? 0) / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              (task.progressPercentage ?? 0) >= 100
                                  ? Colors.green
                                  : Colors.blue,
                            ),
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${task.progressPercentage ?? 0}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 12,
                      children: [
                        _buildProgressInfo(
                          'المدة',
                          '${task.durationMinutes ?? 60} دقيقة',
                          Icons.timer,
                        ),
                        _buildProgressInfo(
                          'الساعات المقدرة',
                          '${task.estimatedHours ?? 0}',
                          Icons.access_time,
                        ),
                        _buildProgressInfo(
                          'الساعات الفعلية',
                          '${task.actualHours ?? 0}',
                          Icons.timer,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ معلومات الربط
            if (task.isLinkedToCase || task.isLinkedToWaqfLand)
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'الكيانات المرتبطة',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (task.isLinkedToCase)
                        ListTile(
                          leading: const Icon(Icons.gavel, color: Colors.blue),
                          title: const Text('قضية مرتبطة'),
                          subtitle: Text(task.caseReferenceNumber ?? 'رقم ${task.caseId}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: التنقل إلى تفاصيل القضية
                            print('انتقال إلى القضية: ${task.caseId}');
                          },
                        ),

                      if (task.isLinkedToWaqfLand)
                        ListTile(
                          leading: const Icon(Icons.landscape, color: Colors.green),
                          title: const Text('أرض وقفية مرتبطة'),
                          subtitle: Text(task.waqfLandRegistryId ?? 'رقم ${task.waqfLandId}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: التنقل إلى تفاصيل الأرض الوقفية
                            print('انتقال إلى الأرض الوقفية: ${task.waqfLandId}');
                          },
                        ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ✅ معلومات إضافية
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'معلومات إضافية',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildInfoRow('نوع الكيان', task.entityTypeDisplayName),
                    _buildInfoRow('إنشئت بواسطة', task.createdBy ?? 'غير معروف'),
                    _buildInfoRow('تاريخ الإنشاء', task.createdAt != null
                        ? _formatDateTime(task.createdAt!)
                        : 'غير معروف'),
                    _buildInfoRow('آخر تحديث', task.updatedAt != null
                        ? _formatDateTime(task.updatedAt!)
                        : 'غير معروف'),

                    if (task.requiresApproval == true)
                      _buildInfoRow('تحتاج موافقة', 'نعم', Colors.orange),

                    if (task.followupRequired == true && task.followupDeadline != null)
                      _buildInfoRow('موعد المتابعة', _formatDate(task.followupDeadline!), Colors.red),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ✅ أزرار إجراءات
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _navigateToEdit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue,
                    ),
                    icon: const Icon(Icons.edit, size: 20),
                    label: const Text('تعديل المهمة'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isDeleting ? null : _deleteTask,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.red,
                    ),
                    icon: _isDeleting
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.delete, size: 20),
                    label: Text(_isDeleting ? 'جاري الحذف...' : 'حذف المهمة'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 76)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.newTask:
        return Colors.blue;
      case TaskStatus.inProgress:
        return Colors.orange;
      case TaskStatus.underAction:
        return Colors.red;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.cancelled:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.purple;
    }
  }

  Color _getTypeColor(TaskType type) {
    switch (type) {
      case TaskType.courtVisit:
        return Colors.purple;
      case TaskType.siteInspection:
        return Colors.green;
      case TaskType.documentFollowup:
        return Colors.blue;
      case TaskType.meeting:
        return Colors.orange;
      case TaskType.administrative:
        return Colors.grey;
      case TaskType.other:
        return Colors.brown;
    }
  }
}