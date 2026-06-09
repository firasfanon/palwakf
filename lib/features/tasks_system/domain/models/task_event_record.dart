class TaskEventRecord {
  final String? id;
  final String taskId;
  final String eventType;
  final String? actionType;
  final Map<String, dynamic>? eventPayload;
  final String? notes;
  final String? actorUserId;
  final DateTime? createdAt;

  const TaskEventRecord({
    this.id,
    required this.taskId,
    required this.eventType,
    this.actionType,
    this.eventPayload,
    this.notes,
    this.actorUserId,
    this.createdAt,
  });

  factory TaskEventRecord.fromJson(Map<String, dynamic> json) =>
      TaskEventRecord(
        id: json['id']?.toString(),
        taskId: json['task_id']?.toString() ?? '',
        eventType: json['event_type']?.toString() ?? 'event',
        actionType: json['action_type']?.toString(),
        eventPayload: json['event_payload'] is Map
            ? Map<String, dynamic>.from(json['event_payload'] as Map)
            : null,
        notes: json['notes']?.toString(),
        actorUserId: json['actor_user_id']?.toString(),
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
      );

  Map<String, dynamic> toInsertMap() => {
    'task_id': taskId,
    'event_type': eventType,
    'action_type': actionType,
    'event_payload': eventPayload,
    'notes': notes,
    'actor_user_id': actorUserId,
  };
}
