// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'waqf_land.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WaqfLand _$WaqfLandFromJson(Map<String, dynamic> json) => WaqfLand(
      id: (json['id'] as num).toInt(),
      referenceNumber: json['referenceNumber'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      type: $enumDecode(_$LandTypeEnumMap, json['type']),
      status: $enumDecode(_$LandStatusEnumMap, json['status']),
      ownershipType: $enumDecode(_$OwnershipTypeEnumMap, json['ownershipType']),
      area: (json['area'] as num).toDouble(),
      governorate: json['governorate'] as String,
      city: json['city'] as String,
      district: json['district'] as String,
      address: json['address'] as String,
      location: LandLocation.fromJson(json['location'] as Map<String, dynamic>),
      documentation: LandDocumentation.fromJson(
          json['documentation'] as Map<String, dynamic>),
      currentUse: json['currentUse'] as String?,
      isLeased: json['isLeased'] as bool? ?? false,
      leasingInfo: json['leasingInfo'] == null
          ? null
          : LeasingInfo.fromJson(json['leasingInfo'] as Map<String, dynamic>),
      estimatedValue: (json['estimatedValue'] as num?)?.toDouble(),
      beneficiary: json['beneficiary'] as String?,
      documents: (json['documents'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
      registrationDate: DateTime.parse(json['registrationDate'] as String),
      lastInspectionDate: json['lastInspectionDate'] == null
          ? null
          : DateTime.parse(json['lastInspectionDate'] as String),
      registeredBy: json['registeredBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$WaqfLandToJson(WaqfLand instance) => <String, dynamic>{
      'id': instance.id,
      'referenceNumber': instance.referenceNumber,
      'name': instance.name,
      'description': instance.description,
      'type': _$LandTypeEnumMap[instance.type]!,
      'status': _$LandStatusEnumMap[instance.status]!,
      'ownershipType': _$OwnershipTypeEnumMap[instance.ownershipType]!,
      'area': instance.area,
      'governorate': instance.governorate,
      'city': instance.city,
      'district': instance.district,
      'address': instance.address,
      'location': instance.location,
      'documentation': instance.documentation,
      'currentUse': instance.currentUse,
      'isLeased': instance.isLeased,
      'leasingInfo': instance.leasingInfo,
      'estimatedValue': instance.estimatedValue,
      'beneficiary': instance.beneficiary,
      'documents': instance.documents,
      'images': instance.images,
      'metadata': instance.metadata,
      'registrationDate': instance.registrationDate.toIso8601String(),
      'lastInspectionDate': instance.lastInspectionDate?.toIso8601String(),
      'registeredBy': instance.registeredBy,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$LandTypeEnumMap = {
  LandType.agricultural: 'agricultural',
  LandType.residential: 'residential',
  LandType.commercial: 'commercial',
  LandType.industrial: 'industrial',
  LandType.mixed: 'mixed',
  LandType.vacant: 'vacant',
};

const _$LandStatusEnumMap = {
  LandStatus.registered: 'registered',
  LandStatus.underReview: 'under_review',
  LandStatus.disputed: 'disputed',
  LandStatus.leased: 'leased',
  LandStatus.occupied: 'occupied',
  LandStatus.available: 'available',
};

const _$OwnershipTypeEnumMap = {
  OwnershipType.waqfKhayri: 'waqf_khayri',
  OwnershipType.waqfAhli: 'waqf_ahli',
  OwnershipType.waqfMushtarak: 'waqf_mushtarak',
};

LandLocation _$LandLocationFromJson(Map<String, dynamic> json) => LandLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      coordinates: json['coordinates'] as String?,
      boundaries: (json['boundaries'] as List<dynamic>?)
          ?.map((e) => MapPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LandLocationToJson(LandLocation instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'coordinates': instance.coordinates,
      'boundaries': instance.boundaries,
    };

MapPoint _$MapPointFromJson(Map<String, dynamic> json) => MapPoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$MapPointToJson(MapPoint instance) => <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

LandDocumentation _$LandDocumentationFromJson(Map<String, dynamic> json) =>
    LandDocumentation(
      deedNumber: json['deedNumber'] as String?,
      basinNumber: json['basinNumber'] as String?,
      parcelNumber: json['parcelNumber'] as String?,
      deedDate: json['deedDate'] == null
          ? null
          : DateTime.parse(json['deedDate'] as String),
      registrationOffice: json['registrationOffice'] as String?,
      hasOfficialDocuments: json['hasOfficialDocuments'] as bool? ?? false,
      documentTypes: (json['documentTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$LandDocumentationToJson(LandDocumentation instance) =>
    <String, dynamic>{
      'deedNumber': instance.deedNumber,
      'basinNumber': instance.basinNumber,
      'parcelNumber': instance.parcelNumber,
      'deedDate': instance.deedDate?.toIso8601String(),
      'registrationOffice': instance.registrationOffice,
      'hasOfficialDocuments': instance.hasOfficialDocuments,
      'documentTypes': instance.documentTypes,
    };

LeasingInfo _$LeasingInfoFromJson(Map<String, dynamic> json) => LeasingInfo(
      lesseeNam: json['lesseeNam'] as String,
      lesseeContact: json['lesseeContact'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      monthlyRent: (json['monthlyRent'] as num).toDouble(),
      paymentStatus: json['paymentStatus'] as String,
      contractNumber: json['contractNumber'] as String,
    );

Map<String, dynamic> _$LeasingInfoToJson(LeasingInfo instance) =>
    <String, dynamic>{
      'lesseeNam': instance.lesseeNam,
      'lesseeContact': instance.lesseeContact,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'monthlyRent': instance.monthlyRent,
      'paymentStatus': instance.paymentStatus,
      'contractNumber': instance.contractNumber,
    };
