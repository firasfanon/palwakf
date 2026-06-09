import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/tasks_system_repository.dart';
import '../domain/models/task_comment_record.dart';
import '../domain/models/task_watcher_record.dart';
import '../domain/models/task_event_record.dart';
import '../domain/models/task_followup_record.dart';
import 'task_detail_state.dart';
import 'tasks_dashboard_notifier.dart';

final taskDetailProvider =
    StateNotifierProvider.family<TaskDetailNotifier, TaskDetailState, String>((
      ref,
      taskId,
    ) {
      final repository = ref.watch(tasksSystemRepositoryProvider);
      return TaskDetailNotifier(repository, taskId)..load();
    });

class TaskDetailNotifier extends StateNotifier<TaskDetailState> {
  TaskDetailNotifier(this._repository, this.taskId)
    : super(const TaskDetailState());

  final TasksSystemRepository _repository;
  final String taskId;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final task = await _repository.getTask(taskId);
      final links = await _repository.listLinks(taskId);
      final comments = await _repository.listComments(taskId);
      final attachments = await _repository.listAttachments(taskId);
      final followups = await _repository.listFollowups(taskId);
      final history = await _repository.listStatusHistory(taskId);
      final assignments = await _repository.listAssignments(taskId);
      final events = await _repository.listEvents(taskId);
      final watchers = await _repository.listWatchers(taskId);
      final notifications = await _repository.listNotifications(taskId: taskId);
      state = state.copyWith(
        isLoading: false,
        task: task,
        links: links,
        comments: comments,
        attachments: attachments,
        followups: followups,
        history: history,
        assignments: assignments,
        events: events,
        watchers: watchers,
        notifications: notifications,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addComment(String text) async {
    if (text.trim().isEmpty) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    await _repository.addComment(
      TaskCommentRecord(
        taskId: taskId,
        commentText: text.trim(),
        createdBy: userId,
      ),
    );
    await _repository.addEvent(
      TaskEventRecord(
        taskId: taskId,
        eventType: 'comment_added',
        actionType: 'add_comment',
        notes: text.trim(),
        actorUserId: userId,
      ),
    );
    await load();
  }

  Future<void> addFollowup({
    required String text,
    String? result,
    String? nextAction,
    DateTime? nextFollowupAt,
  }) async {
    if (text.trim().isEmpty) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    await _repository.addFollowup(
      TaskFollowupRecord(
        taskId: taskId,
        followupDate: DateTime.now(),
        followupText: text.trim(),
        followupResult: result,
        nextAction: nextAction,
        nextFollowupAt: nextFollowupAt,
        createdBy: userId,
      ),
    );
    await _repository.addEvent(
      TaskEventRecord(
        taskId: taskId,
        eventType: 'followup_added',
        actionType: 'add_followup',
        notes: text.trim(),
        actorUserId: userId,
        eventPayload: {
          'result': result,
          'next_action': nextAction,
          'next_followup_at': nextFollowupAt?.toIso8601String(),
        },
      ),
    );
    await load();
  }

  Future<void> watchCurrentTask() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    await _repository.addWatcher(
      TaskWatcherRecord(taskId: taskId, userId: userId),
    );
    await _repository.addEvent(
      TaskEventRecord(
        taskId: taskId,
        eventType: 'watcher_added',
        actionType: 'watch_task',
        notes: 'تمت إضافة مراقب على المهمة',
        actorUserId: userId,
      ),
    );
    await load();
  }
}
