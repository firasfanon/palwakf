// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mosque.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Mosque _$MosqueFromJson(Map<String, dynamic> json) => Mosque(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      nameEn: json['nameEn'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: $enumDecode(_$MosqueTypeEnumMap, json['type']),
      status: $enumDecode(_$MosqueStatusEnumMap, json['status']),
      location:
          MosqueLocation.fromJson(json['location'] as Map<String, dynamic>),
      imam: json['imam'] as String,
      imamPhone: json['imamPhone'] as String?,
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,
      hasParkingSpace: json['hasParkingSpace'] as bool? ?? false,
      hasWheelchairAccess: json['hasWheelchairAccess'] as bool? ?? false,
      hasAirConditioning: json['hasAirConditioning'] as bool? ?? false,
      hasWuduArea: json['hasWuduArea'] as bool? ?? true,
      hasFemaleSection: json['hasFemaleSection'] as bool? ?? false,
      hasLibrary: json['hasLibrary'] as bool? ?? false,
      hasEducationCenter: json['hasEducationCenter'] as bool? ?? false,
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      programs: (json['programs'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      imageUrl: json['imageUrl'] as String?,
      gallery: (json['gallery'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      establishedDate: json['establishedDate'] == null
          ? null
          : DateTime.parse(json['establishedDate'] as String),
      architect: json['architect'] as String?,
      area: (json['area'] as num?)?.toDouble(),
      governorate: json['governorate'] as String,
      district: json['district'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MosqueToJson(Mosque instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameEn': instance.nameEn,
      'description': instance.description,
      'type': _$MosqueTypeEnumMap[instance.type]!,
      'status': _$MosqueStatusEnumMap[instance.status]!,
      'location': instance.location,
      'imam': instance.imam,
      'imamPhone': instance.imamPhone,
      'capacity': instance.capacity,
      'hasParkingSpace': instance.hasParkingSpace,
      'hasWheelchairAccess': instance.hasWheelchairAccess,
      'hasAirConditioning': instance.hasAirConditioning,
      'hasWuduArea': instance.hasWuduArea,
      'hasFemaleSection': instance.hasFemaleSection,
      'hasLibrary': instance.hasLibrary,
      'hasEducationCenter': instance.hasEducationCenter,
      'services': instance.services,
      'programs': instance.programs,
      'imageUrl': instance.imageUrl,
      'gallery': instance.gallery,
      'establishedDate': instance.establishedDate?.toIso8601String(),
      'architect': instance.architect,
      'area': instance.area,
      'governorate': instance.governorate,
      'district': instance.district,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$MosqueTypeEnumMap = {
  MosqueType.jamia: 'jamia',
  MosqueType.masjid: 'masjid',
  MosqueType.musalla: 'musalla',
  MosqueType.historical: 'historical',
};

const _$MosqueStatusEnumMap = {
  MosqueStatus.active: 'active',
  MosqueStatus.inactive: 'inactive',
  MosqueStatus.underConstruction: 'under_construction',
  MosqueStatus.underRenovation: 'under_renovation',
  MosqueStatus.closed: 'closed',
  MosqueStatus.historical: 'historical',
};

MosqueLocation _$MosqueLocationFromJson(Map<String, dynamic> json) =>
    MosqueLocation(
      address: json['address'] as String,
      addressEn: json['addressEn'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      nearbyLandmarks: json['nearbyLandmarks'] as String?,
    );

Map<String, dynamic> _$MosqueLocationToJson(MosqueLocation instance) =>
    <String, dynamic>{
      'address': instance.address,
      'addressEn': instance.addressEn,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'nearbyLandmarks': instance.nearbyLandmarks,
    };
