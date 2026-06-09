class TaskAssignmentRecord {
  final String? id;
  final String taskId;
  final String? assignedToUserId;
  final String? assignedToRole;
  final String? assignedBy;
  final DateTime? assignedAt;
  final DateTime? acceptedAt;
  final DateTime? releasedAt;
  final bool isActive;
  final String? notes;

  const TaskAssignmentRecord({
    this.id,
    required this.taskId,
    this.assignedToUserId,
    this.assignedToRole,
    this.assignedBy,
    this.assignedAt,
    this.acceptedAt,
    this.releasedAt,
    this.isActive = true,
    this.notes,
  });

  factory TaskAssignmentRecord.fromJson(Map<String, dynamic> json) =>
      TaskAssignmentRecord(
        id: json['id']?.toString(),
        taskId: json['task_id']?.toString() ?? '',
        assignedToUserId: json['assigned_to_user_id']?.toString(),
        assignedToRole: json['assigned_to_role']?.toString(),
        assignedBy: json['assigned_by']?.toString(),
        assignedAt: json['assigned_at'] != null
            ? DateTime.tryParse(json['assigned_at'].toString())
            : null,
        acceptedAt: json['accepted_at'] != null
            ? DateTime.tryParse(json['accepted_at'].toString())
            : null,
        releasedAt: json['released_at'] != null
            ? DateTime.tryParse(json['released_at'].toString())
            : null,
        isActive: json['is_active'] == true,
        notes: json['notes']?.toString(),
      );

  Map<String, dynamic> toInsertMap() => {
    'task_id': taskId,
    'assigned_to_user_id': assignedToUserId,
    'assigned_to_role': assignedToRole,
    'assigned_by': assignedBy,
    'assigned_at': assignedAt?.toIso8601String(),
    'accepted_at': acceptedAt?.toIso8601String(),
    'released_at': releasedAt?.toIso8601String(),
    'is_active': isActive,
    'notes': notes,
  };
}
