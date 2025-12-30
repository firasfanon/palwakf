import 'package:json_annotation/json_annotation.dart';

part 'mosque.g.dart';

enum MosqueType {
  @JsonValue('jamia')
  jamia, // جامع (Friday mosque)
  @JsonValue('masjid')
  masjid, // مسجد (regular mosque)
  @JsonValue('musalla')
  musalla, // مصلى (prayer room)
  @JsonValue('historical')
  historical, // مسجد تاريخي
}

enum MosqueStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('under_construction')
  underConstruction,
  @JsonValue('under_renovation')
  underRenovation,
  @JsonValue('closed')
  closed,
  @JsonValue('historical')
  historical,
}

@JsonSerializable()
class Mosque {
  final int id;
  final String name;
  final String nameEn;
  final String description;
  final MosqueType type;
  final MosqueStatus status;
  final MosqueLocation location;
  final String imam;
  final String? imamPhone;
  final int capacity;
  final bool hasParkingSpace;
  final bool hasWheelchairAccess;
  final bool hasAirConditioning;
  final bool hasWuduArea;
  final bool hasFemaleSection;
  final bool hasLibrary;
  final bool hasEducationCenter;
  final List<String> services;
  final List<String> programs;
  final String? imageUrl;
  final List<String> gallery;
  final DateTime? establishedDate;
  final String? architect;
  final double? area;
  final String governorate;
  final String district;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Mosque({
    required this.id,
    required this.name,
    this.nameEn = '',
    this.description = '',
    required this.type,
    required this.status,
    required this.location,
    required this.imam,
    this.imamPhone,
    this.capacity = 0,
    this.hasParkingSpace = false,
    this.hasWheelchairAccess = false,
    this.hasAirConditioning = false,
    this.hasWuduArea = true,
    this.hasFemaleSection = false,
    this.hasLibrary = false,
    this.hasEducationCenter = false,
    this.services = const [],
    this.programs = const [],
    this.imageUrl,
    this.gallery = const [],
    this.establishedDate,
    this.architect,
    this.area,
    required this.governorate,
    required this.district,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Mosque.fromJson(Map<String, dynamic> json) =>
      _$MosqueFromJson(json);

  Map<String, dynamic> toJson() => _$MosqueToJson(this);

  Mosque copyWith({
    int? id,
    String? name,
    String? nameEn,
    String? description,
    MosqueType? type,
    MosqueStatus? status,
    MosqueLocation? location,
    String? imam,
    String? imamPhone,
    int? capacity,
    bool? hasParkingSpace,
    bool? hasWheelchairAccess,
    bool? hasAirConditioning,
    bool? hasWuduArea,
    bool? hasFemaleSection,
    bool? hasLibrary,
    bool? hasEducationCenter,
    List<String>? services,
    List<String>? programs,
    String? imageUrl,
    List<String>? gallery,
    DateTime? establishedDate,
    String? architect,
    double? area,
    String? governorate,
    String? district,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Mosque(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      location: location ?? this.location,
      imam: imam ?? this.imam,
      imamPhone: imamPhone ?? this.imamPhone,
      capacity: capacity ?? this.capacity,
      hasParkingSpace: hasParkingSpace ?? this.hasParkingSpace,
      hasWheelchairAccess: hasWheelchairAccess ?? this.hasWheelchairAccess,
      hasAirConditioning: hasAirConditioning ?? this.hasAirConditioning,
      hasWuduArea: hasWuduArea ?? this.hasWuduArea,
      hasFemaleSection: hasFemaleSection ?? this.hasFemaleSection,
      hasLibrary: hasLibrary ?? this.hasLibrary,
      hasEducationCenter: hasEducationCenter ?? this.hasEducationCenter,
      services: services ?? this.services,
      programs: programs ?? this.programs,
      imageUrl: imageUrl ?? this.imageUrl,
      gallery: gallery ?? this.gallery,
      establishedDate: establishedDate ?? this.establishedDate,
      architect: architect ?? this.architect,
      area: area ?? this.area,
      governorate: governorate ?? this.governorate,
      district: district ?? this.district,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class MosqueLocation {
  final String address;
  final String addressEn;
  final double latitude;
  final double longitude;
  final String? nearbyLandmarks;

  const MosqueLocation({
    required this.address,
    this.addressEn = '',
    required this.latitude,
    required this.longitude,
    this.nearbyLandmarks,
  });

  factory MosqueLocation.fromJson(Map<String, dynamic> json) =>
      _$MosqueLocationFromJson(json);

  Map<String, dynamic> toJson() => _$MosqueLocationToJson(this);

  MosqueLocation copyWith({
    String? address,
    String? addressEn,
    double? latitude,
    double? longitude,
    String? nearbyLandmarks,
  }) {
    return MosqueLocation(
      address: address ?? this.address,
      addressEn: addressEn ?? this.addressEn,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      nearbyLandmarks: nearbyLandmarks ?? this.nearbyLandmarks,
    );
  }
}

// Extensions for display names
extension MosqueTypeExtension on MosqueType {
  String get displayName {
    switch (this) {
      case MosqueType.jamia:
        return 'جامع';
      case MosqueType.masjid:
        return 'مسجد';
      case MosqueType.musalla:
        return 'مصلى';
      case MosqueType.historical:
        return 'مسجد تاريخي';
    }
  }

  String get displayNameEn {
    switch (this) {
      case MosqueType.jamia:
        return 'Jamia Mosque';
      case MosqueType.masjid:
        return 'Mosque';
      case MosqueType.musalla:
        return 'Prayer Room';
      case MosqueType.historical:
        return 'Historical Mosque';
    }
  }
}

extension MosqueStatusExtension on MosqueStatus {
  String get displayName {
    switch (this) {
      case MosqueStatus.active:
        return 'نشط';
      case MosqueStatus.underConstruction:
        return 'قيد الإنشاء';
      case MosqueStatus.underRenovation:
        return 'قيد الترميم';
      case MosqueStatus.closed:
        return 'مغلق';
      case MosqueStatus.historical:
        return 'تاريخي';
      case MosqueStatus.inactive:
        return 'غير نشط';
    }
  }

  String get displayNameEn {
    switch (this) {
      case MosqueStatus.active:
        return 'Active';
      case MosqueStatus.underConstruction:
        return 'Under Construction';
      case MosqueStatus.underRenovation:
        return 'Under Renovation';
      case MosqueStatus.closed:
        return 'Closed';
      case MosqueStatus.historical:
        return 'Historical';
      case MosqueStatus.inactive:
        return 'Not Active';
    }
  }
}