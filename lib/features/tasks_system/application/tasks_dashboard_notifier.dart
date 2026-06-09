import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/tasks_system_repository.dart';
import '../domain/enums/task_priority_enum.dart';
import '../domain/enums/task_status_enum.dart';
import '../domain/enums/task_type_enum.dart';
import 'tasks_dashboard_state.dart';

final tasksSystemRepositoryProvider = Provider<TasksSystemRepository>((ref) {
  return TasksSystemRepository();
});

final tasksDashboardProvider =
    StateNotifierProvider<TasksDashboardNotifier, TasksDashboardState>((ref) {
      final repository = ref.watch(tasksSystemRepositoryProvider);
      return TasksDashboardNotifier(repository)..load();
    });

class TasksDashboardNotifier extends StateNotifier<TasksDashboardState> {
  TasksDashboardNotifier(this._repository) : super(const TasksDashboardState());

  final TasksSystemRepository _repository;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tasks = await _repository.listTasks(
        searchQuery: state.searchQuery,
        status: state.selectedStatus,
        priority: state.selectedPriority,
      );
      state = state.copyWith(isLoading: false, tasks: tasks);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> setSearchQuery(String value) async {
    state = state.copyWith(searchQuery: value);
    await load();
  }

  Future<void> setStatus(TasksTaskStatus? status) async {
    state = state.copyWith(
      selectedStatus: status,
      clearSelectedStatus: status == null,
    );
    await load();
  }

  Future<void> setPriority(TasksTaskPriority? priority) async {
    state = state.copyWith(
      selectedPriority: priority,
      clearSelectedPriority: priority == null,
    );
    await load();
  }

  void setType(TasksTaskType? type) {
    state = state.copyWith(selectedType: type, clearSelectedType: type == null);
  }

  void setSourceSystem(String? sourceSystem) {
    state = state.copyWith(
      selectedSourceSystem: sourceSystem,
      clearSelectedSourceSystem:
          sourceSystem == null || sourceSystem.trim().isEmpty,
    );
  }

  void setOnlyFieldTasks(bool value) {
    state = state.copyWith(onlyFieldTasks: value);
  }

  void setOnlyRequiresApproval(bool value) {
    state = state.copyWith(onlyRequiresApproval: value);
  }

  Future<void> showAllTasks() async {
    state = state.copyWith(
      searchQuery: '',
      clearSelectedStatus: true,
      clearSelectedPriority: true,
      clearSelectedType: true,
      clearSelectedSourceSystem: true,
      onlyFieldTasks: false,
      onlyRequiresApproval: false,
    );
    await load();
  }

  void showFieldTasksOnly() {
    state = state.copyWith(onlyFieldTasks: true);
  }

  void showRequiresApprovalOnly() {
    state = state.copyWith(onlyRequiresApproval: true);
  }

  void filterBySourceSystem(String sourceSystem) {
    state = state.copyWith(selectedSourceSystem: sourceSystem);
  }

  Future<bool> deleteTask(String taskId) async {
    final success = await _repository.deleteTask(taskId);
    if (success) {
      await load();
    }
    return success;
  }
}
