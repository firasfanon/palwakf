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
  final String? attachmentUrl;
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
  final bool isFeatured;
  final bool isPinned;
  final DateTime? publishAt;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? unitId;

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
    this.attachmentUrl,
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
    this.isFeatured = false,
    this.isPinned = false,
    this.publishAt,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.unitId,
  });

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  factory Activity.fromDb(Map<String, dynamic> row) {
    T? pick<T>(String camel, String snake) {
      final v = row[camel];
      if (v != null) return v as T;
      final s = row[snake];
      if (s != null) return s as T;
      return null;
    }

    DateTime? parseDt(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      return DateTime.tryParse(v.toString());
    }

    String pickStr(String camel, String snake, {String fallback = ''}) {
      return (pick<dynamic>(camel, snake) ?? fallback).toString();
    }

    int pickInt(String camel, String snake, {int fallback = 0}) {
      final v = pick<dynamic>(camel, snake);
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '') ?? fallback;
    }

    bool pickBool(String camel, String snake, {bool fallback = false}) {
      final v = pick<dynamic>(camel, snake);
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) {
        final s = v.toLowerCase().trim();
        if (s == 'true' || s == '1') return true;
        if (s == 'false' || s == '0') return false;
      }
      return fallback;
    }

    double? pickDouble(String camel, String snake) {
      final v = pick<dynamic>(camel, snake);
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    E enumByName<E extends Enum>(List<E> values, String raw, E fallback) {
      final key = raw.trim();
      return values.firstWhere((e) => e.name == key, orElse: () => fallback);
    }

    final id = pickInt('id', 'id');
    final title = pickStr('title', 'title');
    final description = pickStr('description', 'description');

    final categoryRaw = pickStr('category', 'category', fallback: 'religious');
    final typeRaw = pickStr('type', 'type', fallback: 'lecture');
    final statusRaw = pickStr('status', 'status', fallback: 'upcoming');

    final startDate =
        parseDt(pick<dynamic>('startDate', 'start_date')) ?? DateTime.now();
    final endDate = parseDt(pick<dynamic>('endDate', 'end_date'));

    final location = pickStr('location', 'location');
    final organizer = pickStr('organizer', 'organizer');
    final maxParticipants = pickInt('maxParticipants', 'max_participants');
    final currentParticipants = pickInt(
      'currentParticipants',
      'current_participants',
    );

    final registrationInfo =
        (pick<Map<String, dynamic>>('registrationInfo', 'registration_info') ??
        const <String, dynamic>{});
    final publishing = (registrationInfo['publishing'] is Map<String, dynamic>)
        ? registrationInfo['publishing'] as Map<String, dynamic>
        : <String, dynamic>{};
    final media = (registrationInfo['media'] is Map<String, dynamic>)
        ? registrationInfo['media'] as Map<String, dynamic>
        : <String, dynamic>{};

    final imageUrl =
        (pick<dynamic>('imageUrl', 'image_url') ??
                media['cover_image_url'] ??
                '')
            .toString()
            .trim();
    final attachmentUrl =
        (pick<dynamic>('attachmentUrl', 'attachment_url') ??
                media['attachment_url'] ??
                '')
            .toString()
            .trim();
    final requirements =
        (pick<List<dynamic>>('requirements', 'requirements') ??
                const <dynamic>[])
            .map((e) => e.toString())
            .toList();
    final contactMap =
        (pick<Map<String, dynamic>>('contact', 'contact') ??
        const <String, dynamic>{});

    final requiresRegistration = pickBool(
      'requiresRegistration',
      'requires_registration',
      fallback: false,
    );
    final isFree = pickBool('isFree', 'is_free', fallback: true);
    final price = pickDouble('price', 'price');
    final registrationUrl =
        (pick<dynamic>('registrationUrl', 'registration_url') ?? '')
            .toString()
            .trim();
    final registrationDeadline = parseDt(
      pick<dynamic>('registrationDeadline', 'registration_deadline'),
    );
    final governorate = pickStr('governorate', 'governorate');
    final tags = (pick<List<dynamic>>('tags', 'tags') ?? const <dynamic>[])
        .map((e) => e.toString())
        .toList();

    final createdAt =
        parseDt(pick<dynamic>('createdAt', 'created_at')) ?? DateTime.now();
    final updatedAt =
        parseDt(pick<dynamic>('updatedAt', 'updated_at')) ?? createdAt;
    final unitId = pick<dynamic>('unitId', 'unit_id')?.toString();

    final isFeatured = pickBool(
      'isFeatured',
      'is_featured',
      fallback: publishing['is_featured'] == true,
    );
    final isPinned = pickBool(
      'isPinned',
      'is_pinned',
      fallback: publishing['is_pinned'] == true,
    );
    final publishAt = parseDt(
      pick<dynamic>('publishAt', 'publish_at') ?? publishing['publish_at'],
    );
    final sortOrder = pickInt(
      'sortOrder',
      'sort_order',
      fallback: int.tryParse('${publishing['sort_order'] ?? 0}') ?? 0,
    );

    return Activity(
      id: id,
      title: title,
      description: description,
      category: enumByName(
        ActivityCategory.values,
        categoryRaw,
        ActivityCategory.religious,
      ),
      type: enumByName(ActivityType.values, typeRaw, ActivityType.lecture),
      startDate: startDate,
      endDate: endDate,
      location: location,
      organizer: organizer,
      maxParticipants: maxParticipants,
      currentParticipants: currentParticipants,
      status: enumByName(
        ActivityStatus.values,
        statusRaw,
        ActivityStatus.upcoming,
      ),
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
      attachmentUrl: attachmentUrl.isEmpty ? null : attachmentUrl,
      registrationInfo: registrationInfo,
      requirements: requirements,
      contact: ContactInfo.fromDb(contactMap),
      requiresRegistration: requiresRegistration,
      isFree: isFree,
      price: price,
      registrationUrl: registrationUrl.isEmpty ? null : registrationUrl,
      registrationDeadline: registrationDeadline,
      governorate: governorate,
      tags: tags,
      isFeatured: isFeatured,
      isPinned: isPinned,
      publishAt: publishAt,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
      unitId: unitId,
    );
  }

  Map<String, dynamic> toJson() => _$ActivityToJson(this);

  Map<String, dynamic> toDb({String? unitId}) {
    final mergedRegistrationInfo = <String, dynamic>{
      ...registrationInfo,
      'publishing': <String, dynamic>{
        ...((registrationInfo['publishing'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{}),
        'is_featured': isFeatured,
        'is_pinned': isPinned,
        'publish_at': publishAt?.toIso8601String(),
        'sort_order': sortOrder,
      },
      'media': <String, dynamic>{
        ...((registrationInfo['media'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{}),
        'cover_image_url': imageUrl,
        'attachment_url': attachmentUrl,
      },
    };

    return <String, dynamic>{
      if (unitId != null) 'unit_id': unitId,
      'title': title,
      'description': description,
      'category': category.name,
      'type': type.name,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'location': location,
      'organizer': organizer,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'status': status.name,
      'image_url': (imageUrl ?? '').trim().isEmpty ? null : imageUrl,
      'attachment_url': (attachmentUrl ?? '').trim().isEmpty
          ? null
          : attachmentUrl,
      'registration_info': mergedRegistrationInfo,
      'requirements': requirements,
      'contact': contact.toDb(),
      'requires_registration': requiresRegistration,
      'is_free': isFree,
      'price': price,
      'registration_url': (registrationUrl ?? '').trim().isEmpty
          ? null
          : registrationUrl,
      'registration_deadline': registrationDeadline?.toIso8601String(),
      'governorate': governorate,
      'tags': tags,
      'is_featured': isFeatured,
      'is_pinned': isPinned,
      'publish_at': publishAt?.toIso8601String(),
      'sort_order': sortOrder,
    };
  }

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
    String? attachmentUrl,
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
    bool? isFeatured,
    bool? isPinned,
    DateTime? publishAt,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? unitId,
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
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
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
      isFeatured: isFeatured ?? this.isFeatured,
      isPinned: isPinned ?? this.isPinned,
      publishAt: publishAt ?? this.publishAt,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      unitId: unitId ?? this.unitId,
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

  factory ContactInfo.fromDb(Map<String, dynamic> row) {
    String pickStr(String key) =>
        (row[key] ?? row[key.toLowerCase()] ?? '').toString();
    String? pickOpt(String key) {
      final v = row[key] ?? row[key.toLowerCase()];
      final s = v?.toString().trim();
      if (s == null || s.isEmpty) return null;
      return s;
    }

    return ContactInfo(
      name: pickStr('name'),
      phone: pickOpt('phone'),
      email: pickOpt('email'),
      whatsapp: pickOpt('whatsapp'),
    );
  }

  Map<String, dynamic> toJson() => _$ContactInfoToJson(this);

  Map<String, dynamic> toDb() {
    return <String, dynamic>{
      'name': name,
      'phone': phone,
      'email': email,
      'whatsapp': whatsapp,
    };
  }

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
