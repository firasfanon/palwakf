class TaskNotificationRecord {
  final String? id;
  final String? taskId;
  final String? userId;
  final String notificationType;
  final String title;
  final String? body;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  const TaskNotificationRecord({
    this.id,
    this.taskId,
    this.userId,
    this.notificationType = 'task_update',
    required this.title,
    this.body,
    this.isRead = false,
    this.readAt,
    this.createdAt,
  });

  factory TaskNotificationRecord.fromJson(Map<String, dynamic> json) =>
      TaskNotificationRecord(
        id: json['id']?.toString(),
        taskId: json['task_id']?.toString(),
        userId: json['user_id']?.toString(),
        notificationType:
            json['notification_type']?.toString() ?? 'task_update',
        title: json['title']?.toString() ?? '',
        body: json['body']?.toString(),
        isRead: json['is_read'] == true,
        readAt: json['read_at'] != null
            ? DateTime.tryParse(json['read_at'].toString())
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
      );

  Map<String, dynamic> toInsertMap() => {
    'task_id': taskId,
    'user_id': userId,
    'notification_type': notificationType,
    'title': title,
    'body': body,
    'is_read': isRead,
    'read_at': readAt?.toIso8601String(),
  };
}
