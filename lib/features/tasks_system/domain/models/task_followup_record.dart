class TaskFollowupRecord {
  final String? id;
  final String taskId;
  final DateTime followupDate;
  final String followupText;
  final String? followupResult;
  final String? nextAction;
  final DateTime? nextFollowupAt;
  final String? createdBy;
  final DateTime? createdAt;

  const TaskFollowupRecord({
    this.id,
    required this.taskId,
    required this.followupDate,
    required this.followupText,
    this.followupResult,
    this.nextAction,
    this.nextFollowupAt,
    this.createdBy,
    this.createdAt,
  });

  factory TaskFollowupRecord.fromJson(Map<String, dynamic> json) {
    return TaskFollowupRecord(
      id: json['id']?.toString(),
      taskId: json['task_id']?.toString() ?? '',
      followupDate: _parseDate(json['followup_date']) ?? DateTime.now(),
      followupText: json['followup_text']?.toString() ?? '',
      followupResult: json['followup_result']?.toString(),
      nextAction: json['next_action']?.toString(),
      nextFollowupAt: _parseDate(json['next_followup_at']),
      createdBy: json['created_by']?.toString(),
      createdAt: _parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'task_id': taskId,
      'followup_date': followupDate.toIso8601String(),
      'followup_text': followupText,
      'followup_result': followupResult,
      'next_action': nextAction,
      'next_followup_at': nextFollowupAt?.toIso8601String(),
      'created_by': createdBy,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
