import '../domain/models/task_watcher_record.dart';
import '../domain/models/task_notification_record.dart';
import '../domain/models/task_event_record.dart';
import '../domain/models/task_assignment_record.dart';
import '../domain/models/task_attachment_record.dart';
import '../domain/models/task_comment_record.dart';
import '../domain/models/task_followup_record.dart';
import '../domain/models/task_record.dart';
import '../domain/models/task_reference_link.dart';
import '../domain/models/task_status_history_record.dart';

class TaskDetailState {
  final bool isLoading;
  final TaskRecord? task;
  final List<TaskReferenceLink> links;
  final List<TaskCommentRecord> comments;
  final List<TaskAttachmentRecord> attachments;
  final List<TaskFollowupRecord> followups;
  final List<TaskStatusHistoryRecord> history;
  final List<TaskAssignmentRecord> assignments;
  final List<TaskEventRecord> events;
  final List<TaskWatcherRecord> watchers;
  final List<TaskNotificationRecord> notifications;
  final String? error;

  const TaskDetailState({
    this.isLoading = false,
    this.task,
    this.links = const [],
    this.comments = const [],
    this.attachments = const [],
    this.followups = const [],
    this.history = const [],
    this.assignments = const [],
    this.events = const [],
    this.watchers = const [],
    this.notifications = const [],
    this.error,
  });

  TaskDetailState copyWith({
    bool? isLoading,
    TaskRecord? task,
    bool clearTask = false,
    List<TaskReferenceLink>? links,
    List<TaskCommentRecord>? comments,
    List<TaskAttachmentRecord>? attachments,
    List<TaskFollowupRecord>? followups,
    List<TaskStatusHistoryRecord>? history,
    List<TaskAssignmentRecord>? assignments,
    List<TaskEventRecord>? events,
    List<TaskWatcherRecord>? watchers,
    List<TaskNotificationRecord>? notifications,
    String? error,
    bool clearError = false,
  }) {
    return TaskDetailState(
      isLoading: isLoading ?? this.isLoading,
      task: clearTask ? null : (task ?? this.task),
      links: links ?? this.links,
      comments: comments ?? this.comments,
      attachments: attachments ?? this.attachments,
      followups: followups ?? this.followups,
      history: history ?? this.history,
      assignments: assignments ?? this.assignments,
      events: events ?? this.events,
      watchers: watchers ?? this.watchers,
      notifications: notifications ?? this.notifications,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
