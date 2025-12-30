// lib/presentation/screens/admin/systems/tasks/screens/tasks_management_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/core/services/task_service.dart';
import 'package:waqf/data/models/task.dart';
import 'package:waqf/presentation/screens/admin/systems/tasks/widgets/task_card.dart';

class TasksManagementScreen extends ConsumerStatefulWidget {
  const TasksManagementScreen({super.key});

  @override
  ConsumerState<TasksManagementScreen> createState() => _TasksManagementScreenState();
}

class _TasksManagementScreenState extends ConsumerState<TasksManagementScreen> {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await _taskService.getTasks();
      setState(() => _tasks = tasks);
    } catch (e) {
      print('Error loading tasks: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في تحميل المهام: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _refreshTasks() {
    _loadTasks();
  }

  // في tasks_management_screen.dart، عدل _navigateToTaskForm:
  void _navigateToTaskForm({String? taskId}) {
    // GoRouter: pass taskId through `extra` (route can read state.extra later)
    context.push('/admin/tasks/new', extra: taskId);
  }

  void _showTaskDetails(Task task) {
    context.push('/admin/tasks/${task.id}', extra: task.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المهام'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshTasks,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ شريط البحث
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن مهمة...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() => _searchQuery = '');
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // ✅ إحصائيات سريعة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem('إجمالي المهام', _tasks.length, Colors.blue),
                _buildStatItem('قيد التنفيذ',
                    _tasks.where((t) => t.status == TaskStatus.inProgress).length,
                    Colors.orange
                ),
                _buildStatItem('مكتملة',
                    _tasks.where((t) => t.status == TaskStatus.completed).length,
                    Colors.green
                ),
                _buildStatItem('متأخرة',
                    _tasks.where((t) => t.dueDate.isBefore(DateTime.now()) && t.status != TaskStatus.completed).length,
                    Colors.red
                ),
              ],
            ),
          ),

          // ✅ قائمة المهام
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.task_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد مهام',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
                : RefreshIndicator(
              onRefresh: _loadTasks,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TaskCard(
                      task: task,
                      onTap: () => _showTaskDetails(task),
                      onEdit: () => _navigateToTaskForm(taskId: task.id),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToTaskForm(),
        child: const Icon(Icons.add),
        tooltip: 'إضافة مهمة جديدة',
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}