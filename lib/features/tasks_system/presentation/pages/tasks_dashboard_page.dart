import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../core/access/access_provider.dart';
import '../../../../core/enums/enums.dart';
import '../../application/tasks_dashboard_notifier.dart';
import '../../application/tasks_dashboard_state.dart';
import '../../domain/enums/task_priority_enum.dart';
import '../../domain/enums/task_status_enum.dart';
import '../../domain/enums/task_type_enum.dart';
import '../../domain/models/task_record.dart';
import '../widgets/task_priority_chip.dart';
import '../widgets/task_stat_card.dart';
import '../widgets/task_status_chip.dart';

class TasksDashboardPage extends ConsumerWidget {
  const TasksDashboardPage({super.key, this.adminScope = false});

  final bool adminScope;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(tasksDashboardProvider);
    final notifier = ref.read(tasksDashboardProvider.notifier);
    final profile = ref.watch(accessProfileProvider).valueOrNull;
    final canManageTasks = profile?.canManageSystem(SystemKey.tasks) ?? false;
    final canWriteTasks = profile?.canWriteSystem(SystemKey.tasks) ?? false;
    final canDeleteTasks =
        canManageTasks ||
        (profile?.can(SystemKey.tasks, Permission.delete) ?? false);
    final tasks = state.filteredTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام المهام والمتابعات'),
        actions: [
          IconButton(
            onPressed: notifier.load,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
          if (canWriteTasks)
            FilledButton.icon(
              onPressed: () => context.push(
                adminScope ? AppRoutes.adminTaskForm : AppRoutes.tasksNew,
              ),
              icon: const Icon(Icons.add),
              label: const Text('متابعة جديدة'),
            ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: notifier.load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeroCard(context, state),
            const SizedBox(height: 16),
            _buildServiceActions(context, state, notifier, canWriteTasks),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 260,
                  child: TaskStatCard(
                    title: 'المتابعات المفتوحة',
                    value: state.openCount,
                    icon: Icons.task_alt_outlined,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: TaskStatCard(
                    title: 'المكتملة/المغلقة',
                    value: state.completedCount,
                    icon: Icons.done_all,
                    color: Colors.green,
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: TaskStatCard(
                    title: 'المتأخرة',
                    value: state.overdueCount,
                    icon: Icons.warning_amber_rounded,
                    color: const Color(0xFFB22222),
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: TaskStatCard(
                    title: 'الميدانية',
                    value: state.fieldCount,
                    icon: Icons.map_outlined,
                    color: Colors.amber.shade800,
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: TaskStatCard(
                    title: 'بانتظار مراجعة',
                    value: state.reviewCount,
                    icon: Icons.rate_review_outlined,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: TaskStatCard(
                    title: 'المتعطلة',
                    value: state.blockedCount,
                    icon: Icons.block_outlined,
                    color: Colors.orange.shade800,
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: TaskStatCard(
                    title: 'تحتاج اعتماد',
                    value: state.requiresApprovalCount,
                    icon: Icons.approval_outlined,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(
                  width: 260,
                  child: TaskStatCard(
                    title: 'مرتبطة بالقضايا/الفوترة',
                    value: state.caseLinkedCount + state.billingLinkedCount,
                    icon: Icons.account_tree_outlined,
                    color: Colors.indigo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFiltersCard(state, notifier),
            const SizedBox(height: 16),
            if (state.activeFilterCount > 0)
              Card(
                color: Colors.blue.withValues(alpha: 0.06),
                child: ListTile(
                  leading: const Icon(Icons.filter_alt_outlined),
                  title: Text('الفلاتر النشطة: ${state.activeFilterCount}'),
                  subtitle: Text(
                    'عدد النتائج الحالية: ${tasks.length} من أصل ${state.tasks.length}',
                  ),
                  trailing: TextButton.icon(
                    onPressed: notifier.showAllTasks,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('مسح الكل'),
                  ),
                ),
              ),
            if (state.error != null)
              Card(
                color: Colors.red.withValues(alpha: 0.08),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: Color(0xFFB22222)),
                  ),
                ),
              ),
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (tasks.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 56, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('لا توجد متابعات ضمن الفلاتر الحالية'),
                    ],
                  ),
                ),
              )
            else ...[
              _buildListHeader(context, tasks.length, canWriteTasks),
              const SizedBox(height: 12),
              ...tasks.map(
                (task) => _TaskListCard(
                  task: task,
                  adminScope: adminScope,
                  canWriteTasks: canWriteTasks,
                  canDeleteTasks: canDeleteTasks,
                  onEdit: () => context.push(
                    adminScope
                        ? AppRoutes.adminTaskEdit(task.id)
                        : AppRoutes.taskEdit(task.id),
                  ),
                  onDelete: () async {
                    final ok =
                        await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('حذف المتابعة'),
                            content: const Text('هل تريد حذف هذه المتابعة؟'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('إلغاء'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('حذف'),
                              ),
                            ],
                          ),
                        ) ??
                        false;
                    if (ok) {
                      await notifier.deleteTask(task.id);
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, TasksDashboardState state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.surface,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مساحة تشغيل موحدة للمهام والمتابعات',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'تجمع بين المتابعات الميدانية والإدارية، وتسمح بتصفية السجل وربطه بالقضايا والفوترة والأصول دون الخروج من إطار المنصة.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.6),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text('إجمالي السجل: ${state.tasks.length}')),
                Chip(
                  label: Text('المعروض الآن: ${state.filteredTasks.length}'),
                ),
                Chip(label: Text('مرتبطة بالقضايا: ${state.caseLinkedCount}')),
                Chip(
                  label: Text('مرتبطة بالفوترة: ${state.billingLinkedCount}'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceActions(
    BuildContext context,
    TasksDashboardState state,
    TasksDashboardNotifier notifier,
    bool canWriteTasks,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الخدمات السريعة',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (canWriteTasks)
                  FilledButton.icon(
                    onPressed: () => context.push(
                      adminScope ? AppRoutes.adminTaskForm : AppRoutes.tasksNew,
                    ),
                    icon: const Icon(Icons.add_task),
                    label: const Text('إضافة متابعة'),
                  ),
                OutlinedButton.icon(
                  onPressed: notifier.showAllTasks,
                  icon: const Icon(Icons.list_alt_outlined),
                  label: const Text('كل المتابعات'),
                ),
                OutlinedButton.icon(
                  onPressed: notifier.showFieldTasksOnly,
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('المهام الميدانية'),
                ),
                OutlinedButton.icon(
                  onPressed: notifier.showRequiresApprovalOnly,
                  icon: const Icon(Icons.approval_outlined),
                  label: const Text('التي تحتاج اعتمادًا'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    final match = state.availableSourceSystems
                        .cast<String?>()
                        .firstWhere(
                          (system) =>
                              (system ?? '').toLowerCase().contains('case') ||
                              (system ?? '').toLowerCase().contains('legal'),
                          orElse: () => null,
                        );
                    if (match != null) notifier.setSourceSystem(match);
                  },
                  icon: const Icon(Icons.gavel_outlined),
                  label: const Text('مهام القضايا'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    final match = state.availableSourceSystems
                        .cast<String?>()
                        .firstWhere(
                          (system) =>
                              (system ?? '').toLowerCase().contains(
                                'billing',
                              ) ||
                              (system ?? '').toLowerCase().contains(
                                'invoice',
                              ) ||
                              (system ?? '').toLowerCase().contains('lease'),
                          orElse: () => null,
                        );
                    if (match != null) notifier.setSourceSystem(match);
                  },
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('مهام الفوترة'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersCard(
    TasksDashboardState state,
    TasksDashboardNotifier notifier,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 320,
              child: TextFormField(
                initialValue: state.searchQuery,
                decoration: const InputDecoration(
                  labelText: 'بحث في المتابعات',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onFieldSubmitted: notifier.setSearchQuery,
              ),
            ),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<TasksTaskStatus?>(
                value: state.selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'الحالة',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<TasksTaskStatus?>(
                    value: null,
                    child: Text('كل الحالات'),
                  ),
                  ...TasksTaskStatus.values.map(
                    (status) => DropdownMenuItem<TasksTaskStatus?>(
                      value: status,
                      child: Text(status.labelAr),
                    ),
                  ),
                ],
                onChanged: notifier.setStatus,
              ),
            ),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<TasksTaskPriority?>(
                value: state.selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'الأولوية',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<TasksTaskPriority?>(
                    value: null,
                    child: Text('كل الأولويات'),
                  ),
                  ...TasksTaskPriority.values.map(
                    (priority) => DropdownMenuItem<TasksTaskPriority?>(
                      value: priority,
                      child: Text(priority.labelAr),
                    ),
                  ),
                ],
                onChanged: notifier.setPriority,
              ),
            ),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<TasksTaskType?>(
                value: state.selectedType,
                decoration: const InputDecoration(
                  labelText: 'نوع المتابعة',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<TasksTaskType?>(
                    value: null,
                    child: Text('كل الأنواع'),
                  ),
                  ...TasksTaskType.values.map(
                    (type) => DropdownMenuItem<TasksTaskType?>(
                      value: type,
                      child: Text(type.labelAr),
                    ),
                  ),
                ],
                onChanged: notifier.setType,
              ),
            ),
            SizedBox(
              width: 220,
              child: DropdownButtonFormField<String?>(
                value: state.selectedSourceSystem,
                decoration: const InputDecoration(
                  labelText: 'النظام المصدر',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('كل الأنظمة'),
                  ),
                  ...state.availableSourceSystems.map(
                    (system) => DropdownMenuItem<String?>(
                      value: system,
                      child: Text(system),
                    ),
                  ),
                ],
                onChanged: notifier.setSourceSystem,
              ),
            ),
            FilterChip(
              label: const Text('ميدانية فقط'),
              selected: state.onlyFieldTasks,
              onSelected: notifier.setOnlyFieldTasks,
            ),
            FilterChip(
              label: const Text('تحتاج اعتمادًا'),
              selected: state.onlyRequiresApproval,
              onSelected: notifier.setOnlyRequiresApproval,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListHeader(BuildContext context, int count, bool canWriteTasks) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'سجل المتابعات ($count)',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (canWriteTasks)
          TextButton.icon(
            onPressed: () => context.push(
              adminScope ? AppRoutes.adminTaskForm : AppRoutes.tasksNew,
            ),
            icon: const Icon(Icons.add),
            label: const Text('إضافة متابعة'),
          ),
      ],
    );
  }
}

class _TaskListCard extends StatelessWidget {
  const _TaskListCard({
    required this.task,
    required this.adminScope,
    required this.canWriteTasks,
    required this.canDeleteTasks,
    required this.onEdit,
    required this.onDelete,
  });

  final TaskRecord task;
  final bool adminScope;
  final bool canWriteTasks;
  final bool canDeleteTasks;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: () => context.push(
          adminScope
              ? AppRoutes.adminTaskDetails(task.id)
              : AppRoutes.taskDetails(task.id),
        ),
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((task.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(task.description!),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TaskStatusChip(status: task.status),
                TaskPriorityChip(priority: task.priority),
                Chip(label: Text(task.taskType.labelAr)),
                if ((task.sourceSystem ?? '').trim().isNotEmpty)
                  Chip(label: Text('النظام: ${task.sourceSystem}')),
                if (task.requiresApproval)
                  const Chip(label: Text('تحتاج اعتمادًا')),
                if (task.isFieldTask) const Chip(label: Text('ميدانية')),
                if (task.dueAt != null)
                  Chip(
                    label: Text(
                      'الاستحقاق: ${task.dueAt!.toLocal().toString().split(' ').first}',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: (task.progressPercent.clamp(0, 100)) / 100,
              ),
            ),
            const SizedBox(height: 4),
            Text('نسبة الإنجاز: ${task.progressPercent}%'),
          ],
        ),
        trailing: (canWriteTasks || canDeleteTasks)
            ? PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    await onDelete();
                  }
                },
                itemBuilder: (context) => [
                  if (canWriteTasks)
                    const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                  if (canDeleteTasks)
                    const PopupMenuItem(value: 'delete', child: Text('حذف')),
                ],
              )
            : null,
      ),
    );
  }
}
