import 'package:json_annotation/json_annotation.dart';

part 'activity.g.dart';

enum ActivityCategory {
  @JsonValue('religious')
  religious,
  @JsonValue('educational')
  educational,
  @JsonValue('cultural')
  cultural,
  @JsonValue('social')
  social,
  @JsonValue('family')
  family,
  @JsonValue('training')
  training,
  @JsonValue('community')
  community,
}

enum ActivityType {
  @JsonValue('lecture')
  lecture,
  @JsonValue('seminar')
  seminar,
  @JsonValue('workshop')
  workshop,
  @JsonValue('competition')
  competition,
  @JsonValue('exhibition')
  exhibition,
  @JsonValue('course')
  course,
  @JsonValue('conference')
  conference,
  @JsonValue('ceremony')
  ceremony,
}

enum ActivityStatus {
  @JsonValue('upcoming')
  upcoming,
  @JsonValue('ongoing')
  ongoing,
  @JsonValue('completed')
  completed,
  @JsonValue('cancelled')
  cancelled,
  @JsonValue('postponed')
  postponed,
}

@JsonSerializable()
class Activity {
  final int id;
  final String title;
  final String description;
  final ActivityCategory category;
  final ActivityType type;
  final DateTime startDate;
  final DateTime? endDate;
  final String location;
  final String organizer;
  final int maxParticipants;
  final int currentParticipants;
  final ActivityStatus status;
  final String? imageUrl;
  final Map<String, dynamic> registrationInfo;
  final List<String> requirements;
  final ContactInfo contact;
  final bool requiresRegistration;
  final bool isFree;
  final double? price;
  final String? registrationUrl;
  final DateTime? registrationDeadline;
  final String governorate;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Activity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.startDate,
    this.endDate,
    required this.location,
    required this.organizer,
    this.maxParticipants = 0,
    this.currentParticipants = 0,
    required this.status,
    this.imageUrl,
    this.registrationInfo = const {},
    this.requirements = const [],
    required this.contact,
    this.requiresRegistration = false,
    this.isFree = true,
    this.price,
    this.registrationUrl,
    this.registrationDeadline,
    required this.governorate,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  Map<String, dynamic> toJson() => _$ActivityToJson(this);

  Activity copyWith({
    int? id,
    String? title,
    String? description,
    ActivityCategory? category,
    ActivityType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? organizer,
    int? maxParticipants,
    int? currentParticipants,
    ActivityStatus? status,
    String? imageUrl,
    Map<String, dynamic>? registrationInfo,
    List<String>? requirements,
    ContactInfo? contact,
    bool? requiresRegistration,
    bool? isFree,
    double? price,
    String? registrationUrl,
    DateTime? registrationDeadline,
    String? governorate,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Activity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      organizer: organizer ?? this.organizer,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      registrationInfo: registrationInfo ?? this.registrationInfo,
      requirements: requirements ?? this.requirements,
      contact: contact ?? this.contact,
      requiresRegistration: requiresRegistration ?? this.requiresRegistration,
      isFree: isFree ?? this.isFree,
      price: price ?? this.price,
      registrationUrl: registrationUrl ?? this.registrationUrl,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      governorate: governorate ?? this.governorate,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class ContactInfo {
  final String name;
  final String? phone;
  final String? email;
  final String? whatsapp;

  const ContactInfo({
    required this.name,
    this.phone,
    this.email,
    this.whatsapp,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) =>
      _$ContactInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ContactInfoToJson(this);

  ContactInfo copyWith({
    String? name,
    String? phone,
    String? email,
    String? whatsapp,
  }) {
    return ContactInfo(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      whatsapp: whatsapp ?? this.whatsapp,
    );
  }
}

// Extensions
extension ActivityCategoryExtension on ActivityCategory {
  String get displayName {
    switch (this) {
      case ActivityCategory.religious:
        return 'ديني';
      case ActivityCategory.educational:
        return 'تعليمي';
      case ActivityCategory.cultural:
        return 'ثقافي';
      case ActivityCategory.social:
        return 'اجتماعي';
      case ActivityCategory.family:
        return 'عائلي';
      case ActivityCategory.training:
        return 'تدريبي';
      case ActivityCategory.community:
        return 'مجتمعي';
    }
  }
}

extension ActivityTypeExtension on ActivityType {
  String get displayName {
    switch (this) {
      case ActivityType.lecture:
        return 'محاضرة';
      case ActivityType.seminar:
        return 'ندوة';
      case ActivityType.workshop:
        return 'ورشة عمل';
      case ActivityType.competition:
        return 'مسابقة';
      case ActivityType.exhibition:
        return 'معرض';
      case ActivityType.course:
        return 'دورة';
      case ActivityType.conference:
        return 'مؤتمر';
      case ActivityType.ceremony:
        return 'احتفال';
    }
  }
}

extension ActivityStatusExtension on ActivityStatus {
  String get displayName {
    switch (this) {
      case ActivityStatus.upcoming:
        return 'قادم';
      case ActivityStatus.ongoing:
        return 'جاري';
      case ActivityStatus.completed:
        return 'مكتمل';
      case ActivityStatus.cancelled:
        return 'ملغى';
      case ActivityStatus.postponed:
        return 'مؤجل';
    }
  }
}