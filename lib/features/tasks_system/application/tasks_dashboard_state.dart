import '../domain/enums/task_priority_enum.dart';
import '../domain/enums/task_status_enum.dart';
import '../domain/enums/task_type_enum.dart';
import '../domain/models/task_record.dart';

class TasksDashboardState {
  final bool isLoading;
  final String searchQuery;
  final TasksTaskStatus? selectedStatus;
  final TasksTaskPriority? selectedPriority;
  final TasksTaskType? selectedType;
  final String? selectedSourceSystem;
  final bool onlyFieldTasks;
  final bool onlyRequiresApproval;
  final List<TaskRecord> tasks;
  final String? error;

  const TasksDashboardState({
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedStatus,
    this.selectedPriority,
    this.selectedType,
    this.selectedSourceSystem,
    this.onlyFieldTasks = false,
    this.onlyRequiresApproval = false,
    this.tasks = const [],
    this.error,
  });

  List<TaskRecord> get filteredTasks {
    return tasks
        .where((task) {
          if (selectedType != null && task.taskType != selectedType)
            return false;
          if (selectedSourceSystem != null &&
              selectedSourceSystem!.trim().isNotEmpty) {
            final source = (task.sourceSystem ?? '').trim().toLowerCase();
            final wanted = selectedSourceSystem!.trim().toLowerCase();
            if (!source.contains(wanted)) return false;
          }
          if (onlyFieldTasks && !task.isFieldTask) return false;
          if (onlyRequiresApproval && !task.requiresApproval) return false;
          return true;
        })
        .toList(growable: false);
  }

  List<String> get availableSourceSystems {
    final values =
        tasks
            .map((task) => (task.sourceSystem ?? '').trim())
            .where((value) => value.isNotEmpty)
            .toSet()
            .toList(growable: false)
          ..sort();
    return values;
  }

  int get overdueCount => tasks
      .where(
        (task) =>
            task.dueAt != null &&
            task.dueAt!.isBefore(DateTime.now()) &&
            task.status != TasksTaskStatus.completed &&
            task.status != TasksTaskStatus.closed,
      )
      .length;
  int get openCount => tasks
      .where(
        (task) =>
            task.status != TasksTaskStatus.completed &&
            task.status != TasksTaskStatus.closed &&
            task.status != TasksTaskStatus.cancelled,
      )
      .length;
  int get completedCount => tasks
      .where(
        (task) =>
            task.status == TasksTaskStatus.completed ||
            task.status == TasksTaskStatus.closed,
      )
      .length;
  int get fieldCount => tasks.where((task) => task.isFieldTask).length;
  int get reviewCount =>
      tasks.where((task) => task.status == TasksTaskStatus.needsReview).length;
  int get blockedCount =>
      tasks.where((task) => task.status == TasksTaskStatus.blocked).length;
  int get requiresApprovalCount =>
      tasks.where((task) => task.requiresApproval).length;
  int get caseLinkedCount => tasks.where((task) {
    final source = (task.sourceSystem ?? '').toLowerCase();
    return source.contains('case') || source.contains('legal');
  }).length;
  int get billingLinkedCount => tasks.where((task) {
    final source = (task.sourceSystem ?? '').toLowerCase();
    return source.contains('billing') ||
        source.contains('invoice') ||
        source.contains('lease');
  }).length;
  int get activeFilterCount {
    var count = 0;
    if (searchQuery.trim().isNotEmpty) count++;
    if (selectedStatus != null) count++;
    if (selectedPriority != null) count++;
    if (selectedType != null) count++;
    if (selectedSourceSystem != null && selectedSourceSystem!.trim().isNotEmpty)
      count++;
    if (onlyFieldTasks) count++;
    if (onlyRequiresApproval) count++;
    return count;
  }

  TasksDashboardState copyWith({
    bool? isLoading,
    String? searchQuery,
    TasksTaskStatus? selectedStatus,
    bool clearSelectedStatus = false,
    TasksTaskPriority? selectedPriority,
    bool clearSelectedPriority = false,
    TasksTaskType? selectedType,
    bool clearSelectedType = false,
    String? selectedSourceSystem,
    bool clearSelectedSourceSystem = false,
    bool? onlyFieldTasks,
    bool? onlyRequiresApproval,
    List<TaskRecord>? tasks,
    String? error,
    bool clearError = false,
  }) {
    return TasksDashboardState(
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: clearSelectedStatus
          ? null
          : (selectedStatus ?? this.selectedStatus),
      selectedPriority: clearSelectedPriority
          ? null
          : (selectedPriority ?? this.selectedPriority),
      selectedType: clearSelectedType
          ? null
          : (selectedType ?? this.selectedType),
      selectedSourceSystem: clearSelectedSourceSystem
          ? null
          : (selectedSourceSystem ?? this.selectedSourceSystem),
      onlyFieldTasks: onlyFieldTasks ?? this.onlyFieldTasks,
      onlyRequiresApproval: onlyRequiresApproval ?? this.onlyRequiresApproval,
      tasks: tasks ?? this.tasks,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
