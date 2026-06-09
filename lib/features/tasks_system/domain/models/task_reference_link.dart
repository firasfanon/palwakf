import '../enums/task_link_type_enum.dart';

class TaskReferenceLink {
  final String? id;
  final String taskId;
  final TaskLinkType linkType;
  final String referenceId;
  final String referenceSystem;
  final bool isPrimary;
  final String? displayLabel;
  final String? notes;
  final DateTime? createdAt;

  const TaskReferenceLink({
    this.id,
    required this.taskId,
    required this.linkType,
    required this.referenceId,
    required this.referenceSystem,
    this.isPrimary = false,
    this.displayLabel,
    this.notes,
    this.createdAt,
  });

  factory TaskReferenceLink.fromJson(Map<String, dynamic> json) {
    return TaskReferenceLink(
      id: json['id']?.toString(),
      taskId: json['task_id']?.toString() ?? '',
      linkType: TaskLinkTypeX.fromDb(json['link_type']),
      referenceId: json['reference_id']?.toString() ?? '',
      referenceSystem: json['reference_system']?.toString() ?? '',
      isPrimary: json['is_primary'] == true,
      displayLabel: json['display_label']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: _parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'task_id': taskId,
      'link_type': linkType.dbValue,
      'reference_id': referenceId,
      'reference_system': referenceSystem,
      'is_primary': isPrimary,
      'display_label': displayLabel,
      'notes': notes,
    };
  }

  TaskReferenceLink copyWith({
    String? id,
    String? taskId,
    TaskLinkType? linkType,
    String? referenceId,
    String? referenceSystem,
    bool? isPrimary,
    String? displayLabel,
    String? notes,
    DateTime? createdAt,
  }) {
    return TaskReferenceLink(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      linkType: linkType ?? this.linkType,
      referenceId: referenceId ?? this.referenceId,
      referenceSystem: referenceSystem ?? this.referenceSystem,
      isPrimary: isPrimary ?? this.isPrimary,
      displayLabel: displayLabel ?? this.displayLabel,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
