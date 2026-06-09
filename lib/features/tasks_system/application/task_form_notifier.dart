import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/tasks_system_repository.dart';
import '../domain/enums/task_link_type_enum.dart';
import '../domain/enums/task_priority_enum.dart';
import '../domain/enums/task_status_enum.dart';
import '../domain/enums/task_type_enum.dart';
import '../domain/models/task_record.dart';
import '../domain/models/task_notification_record.dart';
import '../domain/models/task_event_record.dart';
import '../domain/models/task_assignment_record.dart';
import '../domain/models/task_reference_link.dart';
import '../domain/models/task_status_history_record.dart';
import 'task_form_state.dart';
import 'tasks_dashboard_notifier.dart';

final taskFormProvider =
    StateNotifierProvider.family<TaskFormNotifier, TaskFormState, String?>((
      ref,
      taskId,
    ) {
      final repository = ref.watch(tasksSystemRepositoryProvider);
      return TaskFormNotifier(repository, taskId)..load();
    });

class TaskFormNotifier extends StateNotifier<TaskFormState> {
  TaskFormNotifier(this._repository, this.taskId)
    : super(TaskFormState.initial());

  final TasksSystemRepository _repository;
  final String? taskId;

  bool get isEditMode => taskId != null && taskId!.isNotEmpty;

  Future<void> load() async {
    if (!isEditMode) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final task = await _repository.getTask(taskId!);
      final links = await _repository.listLinks(taskId!);
      if (task != null) {
        state = state.copyWith(isLoading: false, task: task, links: links);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'تعذر تحميل المتابعة المطلوبة',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void updateBasic({
    String? title,
    String? description,
    TasksTaskType? taskType,
    TasksTaskStatus? status,
    TasksTaskPriority? priority,
    DateTime? dueAt,
    DateTime? startAt,
    DateTime? followupAt,
    String? unitId,
    String? assignedToUserId,
    String? assignedToRole,
    bool? isFieldTask,
    bool? requiresApproval,
    int? progressPercent,
  }) {
    state = state.copyWith(
      task: state.task.copyWith(
        title: title,
        description: description,
        taskType: taskType,
        status: status,
        priority: priority,
        dueAt: dueAt,
        startAt: startAt,
        followupAt: followupAt,
        unitId: unitId,
        assignedToUserId: assignedToUserId,
        assignedToRole: assignedToRole,
        isFieldTask: isFieldTask,
        requiresApproval: requiresApproval,
        progressPercent: progressPercent,
      ),
      saveSuccess: false,
    );
  }

  void setLinks(List<TaskReferenceLink> links) {
    state = state.copyWith(links: links, saveSuccess: false);
  }

  void addEmptyLink() {
    final List<TaskReferenceLink> links = List<TaskReferenceLink>.from(
      state.links,
    );
    links.add(
      TaskReferenceLink(
        taskId: taskId ?? '',
        linkType: TaskLinkType.waqfAsset,
        referenceId: '',
        referenceSystem: TaskLinkType.waqfAsset.sourceSystem,
        isPrimary: links.isEmpty,
      ),
    );
    setLinks(links);
  }

  void updateLink(int index, TaskReferenceLink link) {
    final List<TaskReferenceLink> links = List<TaskReferenceLink>.from(
      state.links,
    );
    if (index < 0 || index >= links.length) return;
    links[index] = link;
    setLinks(links);
  }

  void removeLink(int index) {
    final List<TaskReferenceLink> links = List<TaskReferenceLink>.from(
      state.links,
    );
    if (index < 0 || index >= links.length) return;
    links.removeAt(index);
    if (links.isNotEmpty && !links.any((element) => element.isPrimary)) {
      links[0] = links[0].copyWith(isPrimary: true);
    }
    setLinks(links);
  }

  Future<String?> save() async {
    if (state.task.title.trim().isEmpty) {
      state = state.copyWith(error: 'عنوان المتابعة مطلوب');
      return null;
    }

    state = state.copyWith(
      isSaving: true,
      clearError: true,
      saveSuccess: false,
    );
    try {
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      final payload = state.task.copyWith(
        createdBy: state.task.createdBy ?? currentUserId,
      );
      TaskRecord? saved;
      final previousStatus = isEditMode
          ? state.task.status
          : TasksTaskStatus.newTask;

      if (isEditMode) {
        saved = await _repository.updateTask(taskId!, payload.toInsertMap());
      } else {
        saved = await _repository.createTask(payload);
      }

      if (saved == null) {
        state = state.copyWith(isSaving: false, error: 'فشل حفظ المتابعة');
        return null;
      }

      final normalizedLinks = state.links
          .where((link) => link.referenceId.trim().isNotEmpty)
          .map(
            (link) => link.copyWith(
              taskId: saved!.id,
              referenceSystem: link.referenceSystem.isEmpty
                  ? link.linkType.sourceSystem
                  : link.referenceSystem,
            ),
          )
          .toList();
      await _repository.replaceLinks(saved.id, normalizedLinks);

      if (payload.assignedToUserId != null || payload.assignedToRole != null) {
        await _repository.addAssignment(
          TaskAssignmentRecord(
            taskId: saved.id,
            assignedToUserId: payload.assignedToUserId,
            assignedToRole: payload.assignedToRole,
            assignedBy: currentUserId,
            notes: isEditMode
                ? 'تحديث/تأكيد الإسناد من نموذج المتابعة'
                : 'إسناد أولي عند إنشاء المتابعة',
          ),
        );
      }

      if (!isEditMode || previousStatus != payload.status) {
        await _repository.addStatusHistory(
          TaskStatusHistoryRecord(
            taskId: saved.id,
            oldStatus: previousStatus,
            newStatus: payload.status,
            changedBy: currentUserId,
            reason: isEditMode
                ? 'تحديث من نموذج المتابعة'
                : 'إنشاء متابعة جديدة',
          ),
        );
      }

      await _repository.addEvent(
        TaskEventRecord(
          taskId: saved.id,
          eventType: isEditMode ? 'task_updated' : 'task_created',
          actionType: isEditMode ? 'update_task' : 'create_task',
          notes: payload.title,
          actorUserId: currentUserId,
        ),
      );

      if (payload.assignedToUserId != null &&
          payload.assignedToUserId!.isNotEmpty) {
        await _repository.addNotification(
          TaskNotificationRecord(
            taskId: saved.id,
            userId: payload.assignedToUserId,
            notificationType: 'task_assignment',
            title: isEditMode
                ? 'تم تحديث مهمة مسندة إليك'
                : 'تم إسناد مهمة جديدة إليك',
            body: payload.title,
          ),
        );
      }

      state = state.copyWith(
        isSaving: false,
        task: saved,
        links: normalizedLinks,
        saveSuccess: true,
      );
      return saved.id;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return null;
    }
  }
}
