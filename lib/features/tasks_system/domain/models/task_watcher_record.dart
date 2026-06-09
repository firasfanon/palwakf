class TaskWatcherRecord {
  final String? id;
  final String taskId;
  final String userId;
  final String watchType;
  final DateTime? createdAt;

  const TaskWatcherRecord({
    this.id,
    required this.taskId,
    required this.userId,
    this.watchType = 'watcher',
    this.createdAt,
  });

  factory TaskWatcherRecord.fromJson(Map<String, dynamic> json) =>
      TaskWatcherRecord(
        id: json['id']?.toString(),
        taskId: json['task_id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        watchType: json['watch_type']?.toString() ?? 'watcher',
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null,
      );

  Map<String, dynamic> toInsertMap() => {
    'task_id': taskId,
    'user_id': userId,
    'watch_type': watchType,
  };
}
