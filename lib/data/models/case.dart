import 'package:json_annotation/json_annotation.dart';

part 'case.g.dart';

enum CaseType {
  @JsonValue('property_dispute')
  propertyDispute,
  @JsonValue('inheritance')
  inheritance,
  @JsonValue('lease_dispute')
  leaseDispute,
  @JsonValue('boundary_dispute')
  boundaryDispute,
  @JsonValue('waqf_violation')
  waqfViolation,
  @JsonValue('administrative')
  administrative,
  @JsonValue('other')
  other,
}

enum CaseStatus {
  @JsonValue('new')
  newCase,
  @JsonValue('under_review')
  underReview,
  @JsonValue('investigation')
  investigation,
  @JsonValue('pending_documents')
  pendingDocuments,
  @JsonValue('in_court')
  inCourt,
  @JsonValue('resolved')
  resolved,
  @JsonValue('closed')
  closed,
  @JsonValue('appealed')
  appealed,
}

enum CasePriority {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
  @JsonValue('critical')
  critical,
}

@JsonSerializable()
class Case {
  final int id;
  final String caseNumber;
  final String title;
  final String description;
  final CaseType type;
  final CaseStatus status;
  final CasePriority priority;
  final String governorate;
  final CaseParty plaintiff;
  final CaseParty? defendant;
  final String? relatedWaqfLandId;
  final List<String> attachedDocuments;
  final List<CaseNote> notes;
  final List<CaseActivity> activities;
  final DateTime filingDate;
  final DateTime? resolutionDate;
  final String? courtName;
  final String? judgmentNumber;
  final String? outcome;
  final String assignedTo;
  final int createdBy;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Case({
    required this.id,
    required this.caseNumber,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.priority,
    required this.governorate,
    required this.plaintiff,
    this.defendant,
    this.relatedWaqfLandId,
    this.attachedDocuments = const [],
    this.notes = const [],
    this.activities = const [],
    required this.filingDate,
    this.resolutionDate,
    this.courtName,
    this.judgmentNumber,
    this.outcome,
    required this.assignedTo,
    required this.createdBy,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory Case.fromJson(Map<String, dynamic> json) => _$CaseFromJson(json);

  Map<String, dynamic> toJson() => _$CaseToJson(this);

  Case copyWith({
    int? id,
    String? caseNumber,
    String? title,
    String? description,
    CaseType? type,
    CaseStatus? status,
    CasePriority? priority,
    String? governorate,
    CaseParty? plaintiff,
    CaseParty? defendant,
    String? relatedWaqfLandId,
    List<String>? attachedDocuments,
    List<CaseNote>? notes,
    List<CaseActivity>? activities,
    DateTime? filingDate,
    DateTime? resolutionDate,
    String? courtName,
    String? judgmentNumber,
    String? outcome,
    String? assignedTo,
    int? createdBy,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Case(
      id: id ?? this.id,
      caseNumber: caseNumber ?? this.caseNumber,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      governorate: governorate ?? this.governorate,
      plaintiff: plaintiff ?? this.plaintiff,
      defendant: defendant ?? this.defendant,
      relatedWaqfLandId: relatedWaqfLandId ?? this.relatedWaqfLandId,
      attachedDocuments: attachedDocuments ?? this.attachedDocuments,
      notes: notes ?? this.notes,
      activities: activities ?? this.activities,
      filingDate: filingDate ?? this.filingDate,
      resolutionDate: resolutionDate ?? this.resolutionDate,
      courtName: courtName ?? this.courtName,
      judgmentNumber: judgmentNumber ?? this.judgmentNumber,
      outcome: outcome ?? this.outcome,
      assignedTo: assignedTo ?? this.assignedTo,
      createdBy: createdBy ?? this.createdBy,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class CaseParty {
  final String name;
  final String idNumber;
  final String phoneNumber;
  final String? email;
  final String address;
  final String? legalRepresentative;

  const CaseParty({
    required this.name,
    required this.idNumber,
    required this.phoneNumber,
    this.email,
    required this.address,
    this.legalRepresentative,
  });

  factory CaseParty.fromJson(Map<String, dynamic> json) =>
      _$CasePartyFromJson(json);

  Map<String, dynamic> toJson() => _$CasePartyToJson(this);
}

@JsonSerializable()
class CaseNote {
  final int id;
  final String content;
  final String createdBy;
  final DateTime createdAt;
  final bool isInternal;

  const CaseNote({
    required this.id,
    required this.content,
    required this.createdBy,
    required this.createdAt,
    this.isInternal = false,
  });

  factory CaseNote.fromJson(Map<String, dynamic> json) =>
      _$CaseNoteFromJson(json);

  Map<String, dynamic> toJson() => _$CaseNoteToJson(this);
}

@JsonSerializable()
class CaseActivity {
  final int id;
  final String action;
  final String description;
  final String performedBy;
  final DateTime performedAt;
  final Map<String, dynamic> changes;

  const CaseActivity({
    required this.id,
    required this.action,
    required this.description,
    required this.performedBy,
    required this.performedAt,
    this.changes = const {},
  });

  factory CaseActivity.fromJson(Map<String, dynamic> json) =>
      _$CaseActivityFromJson(json);

  Map<String, dynamic> toJson() => _$CaseActivityToJson(this);
}

// Extensions
extension CaseTypeExtension on CaseType {
  String get displayName {
    switch (this) {
      case CaseType.propertyDispute:
        return 'نزاع ملكية';
      case CaseType.inheritance:
        return 'ميراث';
      case CaseType.leaseDispute:
        return 'نزاع إيجار';
      case CaseType.boundaryDispute:
        return 'نزاع حدود';
      case CaseType.waqfViolation:
        return 'انتهاك وقف';
      case CaseType.administrative:
        return 'إداري';
      case CaseType.other:
        return 'أخرى';
    }
  }
}

extension CaseStatusExtension on CaseStatus {
  String get displayName {
    switch (this) {
      case CaseStatus.newCase:
        return 'جديدة';
      case CaseStatus.underReview:
        return 'قيد المراجعة';
      case CaseStatus.investigation:
        return 'قيد التحقيق';
      case CaseStatus.pendingDocuments:
        return 'بانتظار الوثائق';
      case CaseStatus.inCourt:
        return 'في المحكمة';
      case CaseStatus.resolved:
        return 'محلولة';
      case CaseStatus.closed:
        return 'مغلقة';
      case CaseStatus.appealed:
        return 'مستأنفة';
    }
  }
}

extension CasePriorityExtension on CasePriority {
  String get displayName {
    switch (this) {
      case CasePriority.low:
        return 'منخفضة';
      case CasePriority.medium:
        return 'متوسطة';
      case CasePriority.high:
        return 'عالية';
      case CasePriority.urgent:
        return 'عاجلة';
      case CasePriority.critical:
        return 'حرجة';
    }
  }
}