import '../enums/task_status_enum.dart';

class TaskStatusHistoryRecord {
  final String? id;
  final String taskId;
  final TasksTaskStatus oldStatus;
  final TasksTaskStatus newStatus;
  final String? reason;
  final String? changedBy;
  final DateTime? changedAt;

  const TaskStatusHistoryRecord({
    this.id,
    required this.taskId,
    required this.oldStatus,
    required this.newStatus,
    this.reason,
    this.changedBy,
    this.changedAt,
  });

  factory TaskStatusHistoryRecord.fromJson(Map<String, dynamic> json) {
    return TaskStatusHistoryRecord(
      id: json['id']?.toString(),
      taskId: json['task_id']?.toString() ?? '',
      oldStatus: TasksTaskStatusX.fromDb(json['old_status']),
      newStatus: TasksTaskStatusX.fromDb(json['new_status']),
      reason: json['reason']?.toString(),
      changedBy: json['changed_by']?.toString(),
      changedAt: _parseDate(json['changed_at']),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'task_id': taskId,
      'old_status': oldStatus.dbValue,
      'new_status': newStatus.dbValue,
      'reason': reason,
      'changed_by': changedBy,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
