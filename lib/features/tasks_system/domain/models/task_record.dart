import '../enums/task_priority_enum.dart';
import '../enums/task_status_enum.dart';
import '../enums/task_type_enum.dart';

class TaskRecord {
  final String id;
  final String title;
  final String? description;
  final TasksTaskType taskType;
  final TasksTaskStatus status;
  final TasksTaskPriority priority;
  final String? unitId;
  final String? createdBy;
  final String? assignedToUserId;
  final String? assignedToRole;
  final DateTime? startAt;
  final DateTime? dueAt;
  final DateTime? completedAt;
  final DateTime? followupAt;
  final bool isFieldTask;
  final bool requiresApproval;
  final int progressPercent;
  final String? parentTaskId;
  final String? sourceSystem;
  final String? sourceRef;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isArchived;

  const TaskRecord({
    required this.id,
    required this.title,
    this.description,
    required this.taskType,
    required this.status,
    required this.priority,
    this.unitId,
    this.createdBy,
    this.assignedToUserId,
    this.assignedToRole,
    this.startAt,
    this.dueAt,
    this.completedAt,
    this.followupAt,
    this.isFieldTask = false,
    this.requiresApproval = false,
    this.progressPercent = 0,
    this.parentTaskId,
    this.sourceSystem,
    this.sourceRef,
    this.createdAt,
    this.updatedAt,
    this.isArchived = false,
  });

  factory TaskRecord.empty() => TaskRecord(
    id: '',
    title: '',
    taskType: TasksTaskType.other,
    status: TasksTaskStatus.newTask,
    priority: TasksTaskPriority.medium,
  );

  factory TaskRecord.fromJson(Map<String, dynamic> json) {
    return TaskRecord(
      id: json['id']?.toString() ?? '',
      title: (json['title_ar'] ?? json['title'] ?? '').toString(),
      description: (json['description_ar'] ?? json['description'])?.toString(),
      taskType: TasksTaskTypeX.fromDb(json['task_type'] ?? json['type']),
      status: TasksTaskStatusX.fromDb(json['status']),
      priority: TasksTaskPriorityX.fromDb(json['priority']),
      unitId: json['unit_id']?.toString(),
      createdBy: json['created_by']?.toString(),
      assignedToUserId: json['assigned_to_user_id']?.toString(),
      assignedToRole: json['assigned_to_role']?.toString(),
      startAt: _parseDate(json['start_at']),
      dueAt: _parseDate(json['due_at'] ?? json['due_date']),
      completedAt: _parseDate(json['completed_at'] ?? json['completion_date']),
      followupAt: _parseDate(json['followup_at'] ?? json['followup_deadline']),
      isFieldTask: json['is_field_task'] == true,
      requiresApproval: json['requires_approval'] == true,
      progressPercent: json['progress_percent'] is int
          ? json['progress_percent'] as int
          : (json['progress_percentage'] is int
                ? json['progress_percentage'] as int
                : int.tryParse(
                        '${json['progress_percent'] ?? json['progress_percentage'] ?? 0}',
                      ) ??
                      0),
      parentTaskId: json['parent_task_id']?.toString(),
      sourceSystem: json['source_system']?.toString(),
      sourceRef: json['source_ref']?.toString(),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      isArchived: json['is_archived'] == true,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'title': title,
      'title_ar': title,
      'description': description,
      'description_ar': description,
      'task_type': taskType.dbValue,
      'type': taskType.dbValue,
      'status': status.dbValue,
      'priority': priority.dbValue,
      'unit_id': unitId,
      'created_by': createdBy,
      'assigned_to_user_id': assignedToUserId,
      'assigned_to_role': assignedToRole,
      'start_at': startAt?.toIso8601String(),
      'due_at': dueAt?.toIso8601String(),
      'due_date': dueAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'followup_at': followupAt?.toIso8601String(),
      'is_field_task': isFieldTask,
      'requires_approval': requiresApproval,
      'progress_percent': progressPercent,
      'progress_percentage': progressPercent,
      'parent_task_id': parentTaskId,
      'source_system': sourceSystem,
      'source_ref': sourceRef,
      'is_archived': isArchived,
    }..removeWhere((key, value) => value == null);
  }

  TaskRecord copyWith({
    String? id,
    String? title,
    String? description,
    TasksTaskType? taskType,
    TasksTaskStatus? status,
    TasksTaskPriority? priority,
    String? unitId,
    String? createdBy,
    String? assignedToUserId,
    String? assignedToRole,
    DateTime? startAt,
    DateTime? dueAt,
    DateTime? completedAt,
    DateTime? followupAt,
    bool? isFieldTask,
    bool? requiresApproval,
    int? progressPercent,
    String? parentTaskId,
    String? sourceSystem,
    String? sourceRef,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
  }) {
    return TaskRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      taskType: taskType ?? this.taskType,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      unitId: unitId ?? this.unitId,
      createdBy: createdBy ?? this.createdBy,
      assignedToUserId: assignedToUserId ?? this.assignedToUserId,
      assignedToRole: assignedToRole ?? this.assignedToRole,
      startAt: startAt ?? this.startAt,
      dueAt: dueAt ?? this.dueAt,
      completedAt: completedAt ?? this.completedAt,
      followupAt: followupAt ?? this.followupAt,
      isFieldTask: isFieldTask ?? this.isFieldTask,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      progressPercent: progressPercent ?? this.progressPercent,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      sourceSystem: sourceSystem ?? this.sourceSystem,
      sourceRef: sourceRef ?? this.sourceRef,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
