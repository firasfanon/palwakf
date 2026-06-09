import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../core/access/access_provider.dart';
import '../../../../core/enums/enums.dart';
import '../../application/task_form_notifier.dart';
import '../../domain/enums/task_link_type_enum.dart';
import '../../domain/enums/task_priority_enum.dart';
import '../../domain/enums/task_status_enum.dart';
import '../../domain/enums/task_type_enum.dart';
import '../../domain/models/task_reference_link.dart';

class TaskFormPage extends ConsumerStatefulWidget {
  final String? taskId;
  final bool adminScope;

  const TaskFormPage({super.key, this.taskId, this.adminScope = false});

  @override
  ConsumerState<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends ConsumerState<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _unitIdController;
  late final TextEditingController _assignedUserController;
  late final TextEditingController _assignedRoleController;
  late final TextEditingController _progressController;
  DateTime? _dueAt;
  DateTime? _startAt;
  DateTime? _followupAt;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _unitIdController = TextEditingController();
    _assignedUserController = TextEditingController();
    _assignedRoleController = TextEditingController();
    _progressController = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _unitIdController.dispose();
    _assignedUserController.dispose();
    _assignedRoleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(taskFormProvider(widget.taskId));
    final notifier = ref.read(taskFormProvider(widget.taskId).notifier);
    final profile = ref.watch(accessProfileProvider).valueOrNull;
    final canWriteTasks = profile?.canWriteSystem(SystemKey.tasks) ?? false;

    if (!state.isLoading &&
        _titleController.text.isEmpty &&
        state.task.title.isNotEmpty) {
      _titleController.text = state.task.title;
      _descriptionController.text = state.task.description ?? '';
      _unitIdController.text = state.task.unitId ?? '';
      _assignedUserController.text = state.task.assignedToUserId ?? '';
      _assignedRoleController.text = state.task.assignedToRole ?? '';
      _progressController.text = '${state.task.progressPercent}';
      _dueAt = state.task.dueAt;
      _startAt = state.task.startAt;
      _followupAt = state.task.followupAt;
    }

    if (state.saveSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final id = state.task.id;
        context.go(
          widget.adminScope
              ? AppRoutes.adminTaskDetails(id)
              : AppRoutes.taskDetails(id),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskId == null ? 'إنشاء متابعة' : 'تعديل المتابعة'),
        actions: [
          FilledButton.icon(
            onPressed: (!canWriteTasks || state.isSaving)
                ? null
                : () async {
                    if (!_formKey.currentState!.validate()) return;
                    notifier.updateBasic(
                      title: _titleController.text.trim(),
                      description: _descriptionController.text.trim(),
                      unitId: _unitIdController.text.trim().isEmpty
                          ? null
                          : _unitIdController.text.trim(),
                      assignedToUserId:
                          _assignedUserController.text.trim().isEmpty
                          ? null
                          : _assignedUserController.text.trim(),
                      assignedToRole:
                          _assignedRoleController.text.trim().isEmpty
                          ? null
                          : _assignedRoleController.text.trim(),
                      dueAt: _dueAt,
                      startAt: _startAt,
                      followupAt: _followupAt,
                      progressPercent:
                          int.tryParse(_progressController.text.trim()) ?? 0,
                    );
                    await notifier.save();
                  },
            icon: state.isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text('حفظ'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: AbsorbPointer(
                absorbing: !canWriteTasks,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (!canWriteTasks)
                      Card(
                        color: Colors.amber.withValues(alpha: 0.12),
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'لديك صلاحية عرض المتابعة فقط. الإنشاء والتعديل متاحان لمدير النظام أو من يملك صلاحية كتابة على tasks_system.',
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
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: 420,
                              child: TextFormField(
                                controller: _titleController,
                                decoration: const InputDecoration(
                                  labelText: 'عنوان المتابعة',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) =>
                                    (value == null || value.trim().isEmpty)
                                    ? 'العنوان مطلوب'
                                    : null,
                              ),
                            ),
                            SizedBox(
                              width: 320,
                              child: DropdownButtonFormField<TasksTaskType>(
                                value: state.task.taskType,
                                decoration: const InputDecoration(
                                  labelText: 'نوع المتابعة',
                                  border: OutlineInputBorder(),
                                ),
                                items: TasksTaskType.values
                                    .map(
                                      (type) => DropdownMenuItem(
                                        value: type,
                                        child: Text(type.labelAr),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    notifier.updateBasic(
                                      taskType: value,
                                      isFieldTask:
                                          value ==
                                              TasksTaskType.fieldInspection ||
                                          value == TasksTaskType.gisAudit ||
                                          value ==
                                              TasksTaskType
                                                  .gisCoordinatesUpload ||
                                          value ==
                                              TasksTaskType
                                                  .encroachmentFollowup,
                                    );
                                  }
                                },
                              ),
                            ),
                            SizedBox(
                              width: 220,
                              child: DropdownButtonFormField<TasksTaskStatus>(
                                value: state.task.status,
                                decoration: const InputDecoration(
                                  labelText: 'الحالة',
                                  border: OutlineInputBorder(),
                                ),
                                items: TasksTaskStatus.values
                                    .map(
                                      (status) => DropdownMenuItem(
                                        value: status,
                                        child: Text(status.labelAr),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) => value == null
                                    ? null
                                    : notifier.updateBasic(status: value),
                              ),
                            ),
                            SizedBox(
                              width: 220,
                              child: DropdownButtonFormField<TasksTaskPriority>(
                                value: state.task.priority,
                                decoration: const InputDecoration(
                                  labelText: 'الأولوية',
                                  border: OutlineInputBorder(),
                                ),
                                items: TasksTaskPriority.values
                                    .map(
                                      (priority) => DropdownMenuItem(
                                        value: priority,
                                        child: Text(priority.labelAr),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) => value == null
                                    ? null
                                    : notifier.updateBasic(priority: value),
                              ),
                            ),
                            SizedBox(
                              width: 320,
                              child: TextFormField(
                                controller: _unitIdController,
                                decoration: const InputDecoration(
                                  labelText: 'unit_id المرجعي',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 320,
                              child: TextFormField(
                                controller: _assignedUserController,
                                decoration: const InputDecoration(
                                  labelText: 'assigned_to_user_id',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 240,
                              child: TextFormField(
                                controller: _assignedRoleController,
                                decoration: const InputDecoration(
                                  labelText: 'الدور/المسمى',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 180,
                              child: TextFormField(
                                controller: _progressController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'نسبة التقدم',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            _DateField(
                              label: 'تاريخ البدء',
                              value: _startAt,
                              onChanged: (value) =>
                                  setState(() => _startAt = value),
                            ),
                            _DateField(
                              label: 'تاريخ الاستحقاق',
                              value: _dueAt,
                              onChanged: (value) =>
                                  setState(() => _dueAt = value),
                            ),
                            _DateField(
                              label: 'المتابعة القادمة',
                              value: _followupAt,
                              onChanged: (value) =>
                                  setState(() => _followupAt = value),
                            ),
                            SizedBox(
                              width: 860,
                              child: TextFormField(
                                controller: _descriptionController,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  labelText: 'وصف المتابعة',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SwitchListTile(
                              value: state.task.isFieldTask,
                              onChanged: (value) =>
                                  notifier.updateBasic(isFieldTask: value),
                              title: const Text('مهمة ميدانية'),
                            ),
                            SwitchListTile(
                              value: state.task.requiresApproval,
                              onChanged: (value) =>
                                  notifier.updateBasic(requiresApproval: value),
                              title: const Text('تحتاج اعتماد'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'الروابط المرجعية',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: notifier.addEmptyLink,
                                  icon: const Icon(Icons.add_link),
                                  label: const Text('إضافة رابط'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'الربط الداخلي يبقى عبر reference_id. الأصل الوقفي هو المحور الأساسي عند المتابعات الميدانية أو العقارية أو التشغيلية.',
                            ),
                            const SizedBox(height: 12),
                            if (state.links.isEmpty)
                              const Text('لا توجد روابط مرجعية حتى الآن.')
                            else
                              ...List.generate(
                                state.links.length,
                                (index) => _TaskLinkEditor(
                                  index: index,
                                  value: state.links[index],
                                  onChanged: (link) =>
                                      notifier.updateLink(index, link),
                                  onRemove: () => notifier.removeLink(index),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          onChanged(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          child: Text(
            value == null
                ? 'غير محدد'
                : value!.toLocal().toString().split(' ').first,
          ),
        ),
      ),
    );
  }
}

class _TaskLinkEditor extends StatefulWidget {
  final int index;
  final TaskReferenceLink value;
  final ValueChanged<TaskReferenceLink> onChanged;
  final VoidCallback onRemove;

  const _TaskLinkEditor({
    required this.index,
    required this.value,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_TaskLinkEditor> createState() => _TaskLinkEditorState();
}

class _TaskLinkEditorState extends State<_TaskLinkEditor> {
  late TextEditingController _referenceIdController;
  late TextEditingController _labelController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _referenceIdController = TextEditingController(
      text: widget.value.referenceId,
    );
    _labelController = TextEditingController(
      text: widget.value.displayLabel ?? '',
    );
    _notesController = TextEditingController(text: widget.value.notes ?? '');
  }

  @override
  void didUpdateWidget(covariant _TaskLinkEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value.referenceId != widget.value.referenceId) {
      _referenceIdController.text = widget.value.referenceId;
    }
    if (oldWidget.value.displayLabel != widget.value.displayLabel) {
      _labelController.text = widget.value.displayLabel ?? '';
    }
    if (oldWidget.value.notes != widget.value.notes) {
      _notesController.text = widget.value.notes ?? '';
    }
  }

  @override
  void dispose() {
    _referenceIdController.dispose();
    _labelController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<TaskLinkType>(
                value: widget.value.linkType,
                decoration: const InputDecoration(
                  labelText: 'نوع الربط',
                  border: OutlineInputBorder(),
                ),
                items: TaskLinkType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.labelAr),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  widget.onChanged(
                    widget.value.copyWith(
                      linkType: value,
                      referenceSystem: value.sourceSystem,
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: 220,
              child: TextFormField(
                controller: _referenceIdController,
                decoration: const InputDecoration(
                  labelText: 'reference_id',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) =>
                    widget.onChanged(widget.value.copyWith(referenceId: value)),
              ),
            ),
            SizedBox(
              width: 260,
              child: TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'وصف/عنوان مرئي',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => widget.onChanged(
                  widget.value.copyWith(displayLabel: value),
                ),
              ),
            ),
            SizedBox(
              width: 240,
              child: TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات الربط',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) =>
                    widget.onChanged(widget.value.copyWith(notes: value)),
              ),
            ),
            SizedBox(
              width: 180,
              child: CheckboxListTile(
                value: widget.value.isPrimary,
                contentPadding: EdgeInsets.zero,
                title: const Text('مرجع أساسي'),
                onChanged: (value) => widget.onChanged(
                  widget.value.copyWith(isPrimary: value ?? false),
                ),
              ),
            ),
            IconButton(
              onPressed: widget.onRemove,
              icon: const Icon(Icons.delete_outline),
              tooltip: 'إزالة',
            ),
          ],
        ),
      ),
    );
  }
}
