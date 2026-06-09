import '../../domain/enums/task_priority_enum.dart';
import '../../domain/enums/task_status_enum.dart';
import '../../domain/models/task_attachment_record.dart';
import '../../domain/models/task_watcher_record.dart';
import '../../domain/models/task_notification_record.dart';
import '../../domain/models/task_event_record.dart';
import '../../domain/models/task_assignment_record.dart';
import '../../domain/models/task_comment_record.dart';
import '../../domain/models/task_followup_record.dart';
import '../../domain/models/task_record.dart';
import '../../domain/models/task_reference_link.dart';
import '../../domain/models/task_status_history_record.dart';
import '../services/tasks_system_remote_service.dart';

class TasksSystemRepository {
  TasksSystemRepository({TasksSystemRemoteService? remoteService})
    : _remoteService = remoteService ?? TasksSystemRemoteService();

  final TasksSystemRemoteService _remoteService;

  Future<List<TaskRecord>> listTasks({
    String? searchQuery,
    TasksTaskStatus? status,
    TasksTaskPriority? priority,
    String? unitId,
    String? assignedToUserId,
  }) {
    return _remoteService.listTasks(
      searchQuery: searchQuery,
      status: status?.dbValue,
      priority: priority?.dbValue,
      unitId: unitId,
      assignedToUserId: assignedToUserId,
    );
  }

  Future<TaskRecord?> getTask(String taskId) => _remoteService.getTask(taskId);
  Future<TaskRecord?> createTask(TaskRecord task) =>
      _remoteService.createTask(task);
  Future<TaskRecord?> updateTask(String taskId, Map<String, dynamic> updates) =>
      _remoteService.updateTask(taskId, updates);
  Future<bool> deleteTask(String taskId) => _remoteService.deleteTask(taskId);

  Future<List<TaskReferenceLink>> listLinks(String taskId) =>
      _remoteService.listLinks(taskId);
  Future<bool> replaceLinks(String taskId, List<TaskReferenceLink> links) =>
      _remoteService.replaceLinks(taskId, links);

  Future<List<TaskCommentRecord>> listComments(String taskId) =>
      _remoteService.listComments(taskId);
  Future<TaskCommentRecord?> addComment(TaskCommentRecord comment) =>
      _remoteService.addComment(comment);

  Future<List<TaskAttachmentRecord>> listAttachments(String taskId) =>
      _remoteService.listAttachments(taskId);
  Future<TaskAttachmentRecord?> addAttachment(
    TaskAttachmentRecord attachment,
  ) => _remoteService.addAttachment(attachment);

  Future<List<TaskFollowupRecord>> listFollowups(String taskId) =>
      _remoteService.listFollowups(taskId);
  Future<TaskFollowupRecord?> addFollowup(TaskFollowupRecord followup) =>
      _remoteService.addFollowup(followup);

  Future<List<TaskStatusHistoryRecord>> listStatusHistory(String taskId) =>
      _remoteService.listStatusHistory(taskId);
  Future<TaskStatusHistoryRecord?> addStatusHistory(
    TaskStatusHistoryRecord history,
  ) => _remoteService.addStatusHistory(history);

  Future<List<TaskAssignmentRecord>> listAssignments(String taskId) =>
      _remoteService.listAssignments(taskId);
  Future<TaskAssignmentRecord?> addAssignment(
    TaskAssignmentRecord assignment,
  ) => _remoteService.addAssignment(assignment);

  Future<List<TaskEventRecord>> listEvents(String taskId) =>
      _remoteService.listEvents(taskId);
  Future<TaskEventRecord?> addEvent(TaskEventRecord event) =>
      _remoteService.addEvent(event);

  Future<List<TaskWatcherRecord>> listWatchers(String taskId) =>
      _remoteService.listWatchers(taskId);
  Future<TaskWatcherRecord?> addWatcher(TaskWatcherRecord watcher) =>
      _remoteService.addWatcher(watcher);

  Future<List<TaskNotificationRecord>> listNotifications({
    String? taskId,
    String? userId,
  }) => _remoteService.listNotifications(taskId: taskId, userId: userId);
  Future<TaskNotificationRecord?> addNotification(
    TaskNotificationRecord notification,
  ) => _remoteService.addNotification(notification);
}
