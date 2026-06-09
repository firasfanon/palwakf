import 'package:supabase_flutter/supabase_flutter.dart';

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
import 'package:waqf/core/database/pwf_database_owner_surfaces.dart';

class TasksSystemRemoteService {
  TasksSystemRemoteService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<List<TaskRecord>> listTasks({
    String? searchQuery,
    String? unitId,
    String? assignedToUserId,
    String? status,
    String? priority,
  }) async {
    try {
      var query = _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.tasks)
          .select();

      if (unitId != null && unitId.isNotEmpty) {
        query = query.eq('unit_id', unitId);
      }
      if (assignedToUserId != null && assignedToUserId.isNotEmpty) {
        query = query.eq('assigned_to_user_id', assignedToUserId);
      }
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }
      if (priority != null && priority.isNotEmpty) {
        query = query.eq('priority', priority);
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = '%${searchQuery.trim()}%';
        query = query.or(
          'title.ilike.$q,title_ar.ilike.$q,description.ilike.$q,description_ar.ilike.$q',
        );
      }

      final data = await query.order('created_at', ascending: false);
      return (data as List)
          .map(
            (item) =>
                TaskRecord.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<TaskRecord?> getTask(String taskId) async {
    try {
      final data = await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.tasks)
          .select()
          .eq('id', taskId)
          .maybeSingle();
      if (data == null) return null;
      return TaskRecord.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (_) {
      return null;
    }
  }

  Future<TaskRecord?> createTask(TaskRecord task) async {
    try {
      final data = await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.tasks)
          .insert(task.toInsertMap())
          .select()
          .single();
      return TaskRecord.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (_) {
      return null;
    }
  }

  Future<TaskRecord?> updateTask(
    String taskId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final data = await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.tasks)
          .update(updates)
          .eq('id', taskId)
          .select()
          .single();
      return TaskRecord.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (_) {
      return null;
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.tasks)
          .delete()
          .eq('id', taskId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<TaskReferenceLink>> listLinks(String taskId) async {
    try {
      final data = await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.taskLinks)
          .select()
          .eq('task_id', taskId)
          .order('is_primary', ascending: false);
      return (data as List)
          .map(
            (item) => TaskReferenceLink.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<bool> replaceLinks(
    String taskId,
    List<TaskReferenceLink> links,
  ) async {
    try {
      await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.taskLinks)
          .delete()
          .eq('task_id', taskId);
      if (links.isEmpty) return true;
      final payload = links
          .map((link) => link.copyWith(taskId: taskId).toInsertMap())
          .toList();
      await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.taskLinks)
          .insert(payload);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<TaskCommentRecord>> listComments(String taskId) async {
    try {
      final data = await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.taskComments)
          .select()
          .eq('task_id', taskId)
          .order('created_at', ascending: false);
      return (data as List)
          .map(
            (item) => TaskCommentRecord.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<TaskCommentRecord?> addComment(TaskCommentRecord comment) async {
    try {
      final data = await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.taskComments)
          .insert(comment.toInsertMap())
          .select()
          .single();
      return TaskCommentRecord.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (_) {
      return null;
    }
  }

  Future<List<TaskAttachmentRecord>> listAttachments(String taskId) async {
    try {
      final data = await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.taskAttachments)
          .select()
          .eq('task_id', taskId)
          .order('uploaded_at', ascending: false);
      return (data as List)
          .map(
            (item) => TaskAttachmentRecord.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<TaskAttachmentRecord?> addAttachment(
    TaskAttachmentRecord attachment,
  ) async {
    try {
      final data = await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.taskAttachments)
          .insert(attachment.toInsertMap())
          .select()
          .single();
      return TaskAttachmentRecord.fromJson(
        Map<String, dynamic>.from(data as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<TaskFollowupRecord>> listFollowups(String taskId) async {
    try {
      final data = await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.taskFollowups)
          .select()
          .eq('task_id', taskId)
          .order('followup_date', ascending: false);
      return (data as List)
          .map(
            (item) => TaskFollowupRecord.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<TaskFollowupRecord?> addFollowup(TaskFollowupRecord followup) async {
    try {
      final data = await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.taskFollowups)
          .insert(followup.toInsertMap())
          .select()
          .single();
      return TaskFollowupRecord.fromJson(
        Map<String, dynamic>.from(data as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<TaskStatusHistoryRecord>> listStatusHistory(String taskId) async {
    try {
      final data = await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.taskStatusHistory)
          .select()
          .eq('task_id', taskId)
          .order('changed_at', ascending: false);
      return (data as List)
          .map(
            (item) => TaskStatusHistoryRecord.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<TaskStatusHistoryRecord?> addStatusHistory(
    TaskStatusHistoryRecord history,
  ) async {
    try {
      final data = await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.taskStatusHistory)
          .insert(history.toInsertMap())
          .select()
          .single();
      return TaskStatusHistoryRecord.fromJson(
        Map<String, dynamic>.from(data as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<TaskAssignmentRecord>> listAssignments(String taskId) async {
    try {
      final data = await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.taskAssignments)
          .select()
          .eq('task_id', taskId)
          .order('assigned_at', ascending: false);
      return (data as List)
          .map(
            (item) => TaskAssignmentRecord.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<TaskAssignmentRecord?> addAssignment(
    TaskAssignmentRecord assignment,
  ) async {
    try {
      final data = await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.taskAssignments)
          .insert(assignment.toInsertMap())
          .select()
          .single();
      return TaskAssignmentRecord.fromJson(
        Map<String, dynamic>.from(data as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<TaskEventRecord>> listEvents(String taskId) async {
    try {
      final data = await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.taskEvents)
          .select()
          .eq('task_id', taskId)
          .order('created_at', ascending: false);
      return (data as List)
          .map(
            (item) => TaskEventRecord.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<TaskEventRecord?> addEvent(TaskEventRecord event) async {
    try {
      final data = await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.taskEvents)
          .insert(event.toInsertMap())
          .select()
          .single();
      return TaskEventRecord.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (_) {
      return null;
    }
  }

  Future<List<TaskWatcherRecord>> listWatchers(String taskId) async {
    try {
      final data = await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.taskWatchers)
          .select()
          .eq('task_id', taskId)
          .order('created_at', ascending: false);
      return (data as List)
          .map(
            (item) => TaskWatcherRecord.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<TaskWatcherRecord?> addWatcher(TaskWatcherRecord watcher) async {
    try {
      final data = await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.taskWatchers)
          .insert(watcher.toInsertMap())
          .select()
          .single();
      return TaskWatcherRecord.fromJson(Map<String, dynamic>.from(data as Map));
    } catch (_) {
      return null;
    }
  }

  Future<List<TaskNotificationRecord>> listNotifications({
    String? taskId,
    String? userId,
  }) async {
    try {
      var query = _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.taskNotifications)
          .select();
      if (taskId != null && taskId.isNotEmpty) {
        query = query.eq('task_id', taskId);
      }
      if (userId != null && userId.isNotEmpty) {
        query = query.eq('user_id', userId);
      }
      final data = await query.order('created_at', ascending: false);
      return (data as List)
          .map(
            (item) => TaskNotificationRecord.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<TaskNotificationRecord?> addNotification(
    TaskNotificationRecord notification,
  ) async {
    try {
      final data = await _client
          .schema('tasks')
          .from(PwfDatabaseOwnerSurfaces.taskNotifications)
          .insert(notification.toInsertMap())
          .select()
          .single();
      return TaskNotificationRecord.fromJson(
        Map<String, dynamic>.from(data as Map),
      );
    } catch (_) {
      return null;
    }
  }
}
