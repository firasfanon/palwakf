// lib/data/models/task.dart
import 'package:json_annotation/json_annotation.dart';
import 'case.dart';
import 'waqf_land.dart';

part 'task.g.dart';

// ✅ Enums متوافقة مع قاعدة البيانات المحدثة
enum TaskType {
  @JsonValue('court_visit')
  courtVisit,
  @JsonValue('site_inspection')
  siteInspection,
  @JsonValue('document_followup')
  documentFollowup,
  @JsonValue('meeting')
  meeting,
  @JsonValue('administrative')
  administrative,
  @JsonValue('other')
  other,
}

enum TaskStatus {
  @JsonValue('new')
  newTask,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('under_action')
  underAction,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
}

enum TaskPriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}

// ✅ من قاعدة البيانات المحدثة
enum RelatedEntityType {
  @JsonValue('case')
  caseEntity,
  @JsonValue('waqf_land')
  waqfLand,
  @JsonValue('both')
  both,
  @JsonValue('none')
  none,
}

enum SiteInspectionType {
  @JsonValue('initial')
  initial,
  @JsonValue('followup')
  followup,
  @JsonValue('routine')
  routine,
  @JsonValue('emergency')
  emergency,
}

@JsonSerializable()
class Task {
  final String id;
  final String title;
  final String? description;

  // ✅ الحقول العربية
  final String? titleAr;
  final String? descriptionAr;

  // ✅ معلومات أساسية
  final TaskType type;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime dueDate;
  final DateTime? completionDate;

  // ✅ ربط مع الأنظمة الحالية
  final int? caseId;
  final String? caseReferenceNumber;
  final Case? linkedCase;

  final int? waqfLandId;
  final String? waqfLandRegistryId;
  final WaqfLand? linkedWaqfLand;

  final RelatedEntityType relatedEntityType;

  // ✅ معلومات الزيارة القضائية
  final String? courtName;
  final String? courtNameAr;
  final String? judgeName;
  final String? judgeNameAr;
  final DateTime? courtHearingDate;
  final String? courtHearingTime;
  final String? visitPurpose;
  final String? visitPurposeAr;

  // ✅ معلومات الزيارة الميدانية
  final SiteInspectionType? siteInspectionType;
  final String? boundaryVerificationStatus;
  final String? encroachmentDetails;
  final String? encroachmentDetailsAr;
  final String? preservationStatus;

  // ✅ معلومات إدارية
  final int? durationMinutes;
  final bool? requiresApproval;
  final int? progressPercentage;
  final List<String>? assignedTo;
  final double? estimatedHours;
  final double? actualHours;

  // ✅ متابعة
  final bool? followupRequired;
  final DateTime? followupDeadline;

  // ✅ معلومات نظامية
  final String? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.titleAr,
    this.descriptionAr,
    required this.type,
    required this.status,
    required this.priority,
    required this.dueDate,
    this.completionDate,
    this.caseId,
    this.caseReferenceNumber,
    this.linkedCase,
    this.waqfLandId,
    this.waqfLandRegistryId,
    this.linkedWaqfLand,
    required this.relatedEntityType,
    this.courtName,
    this.courtNameAr,
    this.judgeName,
    this.judgeNameAr,
    this.courtHearingDate,
    this.courtHearingTime,
    this.visitPurpose,
    this.visitPurposeAr,
    this.siteInspectionType,
    this.boundaryVerificationStatus,
    this.encroachmentDetails,
    this.encroachmentDetailsAr,
    this.preservationStatus,
    this.durationMinutes,
    this.requiresApproval,
    this.progressPercentage,
    this.assignedTo,
    this.estimatedHours,
    this.actualHours,
    this.followupRequired,
    this.followupDeadline,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(this);

  // ✅ Helper Methods
  bool get isLinkedToCase => caseId != null;
  bool get isLinkedToWaqfLand => waqfLandId != null;

  String get displayTitle => titleAr ?? title;
  String get displayDescription => descriptionAr ?? description ?? '';

  String get typeDisplayName {
    switch (type) {
      case TaskType.courtVisit:
        return 'زيارة قضائية';
      case TaskType.siteInspection:
        return 'تفتيش ميداني';
      case TaskType.documentFollowup:
        return 'متابعة وثائق';
      case TaskType.meeting:
        return 'اجتماع';
      case TaskType.administrative:
        return 'إداري';
      case TaskType.other:
        return 'أخرى';
    }
  }

  String get entityTypeDisplayName {
    switch (relatedEntityType) {
      case RelatedEntityType.caseEntity:
        return 'قضية';
      case RelatedEntityType.waqfLand:
        return 'أرض وقفية';
      case RelatedEntityType.both:
        return 'قضية وأرض وقفية';
      case RelatedEntityType.none:
        return 'غير مرتبط';
    }
  }

  String get inspectionTypeDisplayName {
    switch (siteInspectionType) {
      case SiteInspectionType.initial:
        return 'زيارة أولية';
      case SiteInspectionType.followup:
        return 'متابعة';
      case SiteInspectionType.routine:
        return 'روتينية';
      case SiteInspectionType.emergency:
        return 'طارئة';
      default:
        return 'غير محدد';
    }
  }
}

// ✅ Extensions للـ Enums
extension TaskStatusExtension on TaskStatus {
  String get statusDisplayName {
    switch (this) {
      case TaskStatus.newTask:
        return 'جديدة';
      case TaskStatus.inProgress:
        return 'قيد التنفيذ';
      case TaskStatus.underAction:
        return 'تحت الإجراء';
      case TaskStatus.completed:
        return 'مكتملة';
      case TaskStatus.cancelled:
        return 'ملغاة';
    }
  }
}

extension TaskPriorityExtension on TaskPriority {
  String get priorityDisplayName {
    switch (this) {
      case TaskPriority.low:
        return 'منخفضة';
      case TaskPriority.medium:
        return 'متوسطة';
      case TaskPriority.high:
        return 'عالية';
      case TaskPriority.urgent:
        return 'عاجلة';
    }
  }
}

// ⭐ الجديد: إضافة لهذين الـ Extensions
extension TaskTypeExtension on TaskType {
  String get typeDisplayName {
    switch (this) {
      case TaskType.courtVisit:
        return 'زيارة قضائية';
      case TaskType.siteInspection:
        return 'تفتيش ميداني';
      case TaskType.documentFollowup:
        return 'متابعة وثائق';
      case TaskType.meeting:
        return 'اجتماع';
      case TaskType.administrative:
        return 'إداري';
      case TaskType.other:
        return 'أخرى';
    }
  }
}

extension RelatedEntityTypeExtension on RelatedEntityType {
  String get displayName {
    switch (this) {
      case RelatedEntityType.caseEntity:
        return 'قضية';
      case RelatedEntityType.waqfLand:
        return 'أرض وقفية';
      case RelatedEntityType.both:
        return 'قضية وأرض وقفية';
      case RelatedEntityType.none:
        return 'غير مرتبط';
    }
  }
}