import '../domain/enums/task_priority_enum.dart';
import '../domain/enums/task_status_enum.dart';
import '../domain/enums/task_type_enum.dart';
import '../domain/models/task_record.dart';
import '../domain/models/task_reference_link.dart';

class TaskFormState {
  final bool isLoading;
  final bool isSaving;
  final TaskRecord task;
  final List<TaskReferenceLink> links;
  final String? error;
  final bool saveSuccess;

  const TaskFormState({
    this.isLoading = false,
    this.isSaving = false,
    required this.task,
    this.links = const [],
    this.error,
    this.saveSuccess = false,
  });

  factory TaskFormState.initial() => TaskFormState(task: TaskRecord.empty());

  TaskFormState copyWith({
    bool? isLoading,
    bool? isSaving,
    TaskRecord? task,
    List<TaskReferenceLink>? links,
    String? error,
    bool clearError = false,
    bool? saveSuccess,
  }) {
    return TaskFormState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      task: task ?? this.task,
      links: links ?? this.links,
      error: clearError ? null : (error ?? this.error),
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }

  TasksTaskType get taskType => task.taskType;
  TasksTaskStatus get status => task.status;
  TasksTaskPriority get priority => task.priority;
}
