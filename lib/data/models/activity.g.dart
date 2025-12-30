// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Activity _$ActivityFromJson(Map<String, dynamic> json) => Activity(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      description: json['description'] as String,
      category: $enumDecode(_$ActivityCategoryEnumMap, json['category']),
      type: $enumDecode(_$ActivityTypeEnumMap, json['type']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      location: json['location'] as String,
      organizer: json['organizer'] as String,
      maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 0,
      currentParticipants: (json['currentParticipants'] as num?)?.toInt() ?? 0,
      status: $enumDecode(_$ActivityStatusEnumMap, json['status']),
      imageUrl: json['imageUrl'] as String?,
      registrationInfo:
          json['registrationInfo'] as Map<String, dynamic>? ?? const {},
      requirements: (json['requirements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      contact: ContactInfo.fromJson(json['contact'] as Map<String, dynamic>),
      requiresRegistration: json['requiresRegistration'] as bool? ?? false,
      isFree: json['isFree'] as bool? ?? true,
      price: (json['price'] as num?)?.toDouble(),
      registrationUrl: json['registrationUrl'] as String?,
      registrationDeadline: json['registrationDeadline'] == null
          ? null
          : DateTime.parse(json['registrationDeadline'] as String),
      governorate: json['governorate'] as String,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ActivityToJson(Activity instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'category': _$ActivityCategoryEnumMap[instance.category]!,
      'type': _$ActivityTypeEnumMap[instance.type]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'location': instance.location,
      'organizer': instance.organizer,
      'maxParticipants': instance.maxParticipants,
      'currentParticipants': instance.currentParticipants,
      'status': _$ActivityStatusEnumMap[instance.status]!,
      'imageUrl': instance.imageUrl,
      'registrationInfo': instance.registrationInfo,
      'requirements': instance.requirements,
      'contact': instance.contact,
      'requiresRegistration': instance.requiresRegistration,
      'isFree': instance.isFree,
      'price': instance.price,
      'registrationUrl': instance.registrationUrl,
      'registrationDeadline': instance.registrationDeadline?.toIso8601String(),
      'governorate': instance.governorate,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ActivityCategoryEnumMap = {
  ActivityCategory.religious: 'religious',
  ActivityCategory.educational: 'educational',
  ActivityCategory.cultural: 'cultural',
  ActivityCategory.social: 'social',
  ActivityCategory.family: 'family',
  ActivityCategory.training: 'training',
  ActivityCategory.community: 'community',
};

const _$ActivityTypeEnumMap = {
  ActivityType.lecture: 'lecture',
  ActivityType.seminar: 'seminar',
  ActivityType.workshop: 'workshop',
  ActivityType.competition: 'competition',
  ActivityType.exhibition: 'exhibition',
  ActivityType.course: 'course',
  ActivityType.conference: 'conference',
  ActivityType.ceremony: 'ceremony',
};

const _$ActivityStatusEnumMap = {
  ActivityStatus.upcoming: 'upcoming',
  ActivityStatus.ongoing: 'ongoing',
  ActivityStatus.completed: 'completed',
  ActivityStatus.cancelled: 'cancelled',
  ActivityStatus.postponed: 'postponed',
};

ContactInfo _$ContactInfoFromJson(Map<String, dynamic> json) => ContactInfo(
      name: json['name'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      whatsapp: json['whatsapp'] as String?,
    );

Map<String, dynamic> _$ContactInfoToJson(ContactInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'whatsapp': instance.whatsapp,
    };
