class TaskAttachmentRecord {
  final String? id;
  final String taskId;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int? fileSize;
  final String? attachmentCategory;
  final String? uploadedBy;
  final DateTime? uploadedAt;

  const TaskAttachmentRecord({
    this.id,
    required this.taskId,
    required this.fileName,
    required this.fileUrl,
    this.fileType = 'file',
    this.fileSize,
    this.attachmentCategory,
    this.uploadedBy,
    this.uploadedAt,
  });

  factory TaskAttachmentRecord.fromJson(Map<String, dynamic> json) {
    return TaskAttachmentRecord(
      id: json['id']?.toString(),
      taskId: json['task_id']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      fileUrl: json['file_url']?.toString() ?? '',
      fileType: json['file_type']?.toString() ?? 'file',
      fileSize: json['file_size'] is int
          ? json['file_size'] as int
          : int.tryParse('${json['file_size']}'),
      attachmentCategory: json['attachment_category']?.toString(),
      uploadedBy: json['uploaded_by']?.toString(),
      uploadedAt: _parseDate(json['uploaded_at']),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'task_id': taskId,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size': fileSize,
      'attachment_category': attachmentCategory,
      'uploaded_by': uploadedBy,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
