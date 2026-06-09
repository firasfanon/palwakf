class TaskCommentRecord {
  final String? id;
  final String taskId;
  final String commentText;
  final String commentType;
  final bool isInternal;
  final String? createdBy;
  final DateTime? createdAt;

  const TaskCommentRecord({
    this.id,
    required this.taskId,
    required this.commentText,
    this.commentType = 'note',
    this.isInternal = true,
    this.createdBy,
    this.createdAt,
  });

  factory TaskCommentRecord.fromJson(Map<String, dynamic> json) {
    return TaskCommentRecord(
      id: json['id']?.toString(),
      taskId: json['task_id']?.toString() ?? '',
      commentText: json['comment_text']?.toString() ?? '',
      commentType: json['comment_type']?.toString() ?? 'note',
      isInternal: json['is_internal'] == true,
      createdBy: json['created_by']?.toString(),
      createdAt: _parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'task_id': taskId,
      'comment_text': commentText,
      'comment_type': commentType,
      'is_internal': isInternal,
      'created_by': createdBy,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
