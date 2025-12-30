import 'package:json_annotation/json_annotation.dart';

part 'waqf_land.g.dart';

enum LandType {
  @JsonValue('agricultural')
  agricultural,
  @JsonValue('residential')
  residential,
  @JsonValue('commercial')
  commercial,
  @JsonValue('industrial')
  industrial,
  @JsonValue('mixed')
  mixed,
  @JsonValue('vacant')
  vacant,
}

enum LandStatus {
  @JsonValue('registered')
  registered,
  @JsonValue('under_review')
  underReview,
  @JsonValue('disputed')
  disputed,
  @JsonValue('leased')
  leased,
  @JsonValue('occupied')
  occupied,
  @JsonValue('available')
  available,
}

enum OwnershipType {
  @JsonValue('waqf_khayri')
  waqfKhayri, // وقف خيري
  @JsonValue('waqf_ahli')
  waqfAhli, // وقف أهلي
  @JsonValue('waqf_mushtarak')
  waqfMushtarak, // وقف مشترك
}

@JsonSerializable()
class WaqfLand {
  final int id;
  final String referenceNumber;
  final String name;
  final String description;
  final LandType type;
  final LandStatus status;
  final OwnershipType ownershipType;
  final double area; // in square meters
  final String governorate;
  final String city;
  final String district;
  final String address;
  final LandLocation location;
  final LandDocumentation documentation;
  final String? currentUse;
  final bool isLeased;
  final LeasingInfo? leasingInfo;
  final double? estimatedValue;
  final String? beneficiary;
  final List<String> documents;
  final List<String> images;
  final Map<String, dynamic> metadata;
  final DateTime registrationDate;
  final DateTime? lastInspectionDate;
  final String registeredBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WaqfLand({
    required this.id,
    required this.referenceNumber,
    required this.name,
    this.description = '',
    required this.type,
    required this.status,
    required this.ownershipType,
    required this.area,
    required this.governorate,
    required this.city,
    required this.district,
    required this.address,
    required this.location,
    required this.documentation,
    this.currentUse,
    this.isLeased = false,
    this.leasingInfo,
    this.estimatedValue,
    this.beneficiary,
    this.documents = const [],
    this.images = const [],
    this.metadata = const {},
    required this.registrationDate,
    this.lastInspectionDate,
    required this.registeredBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WaqfLand.fromJson(Map<String, dynamic> json) =>
      _$WaqfLandFromJson(json);

  Map<String, dynamic> toJson() => _$WaqfLandToJson(this);

  WaqfLand copyWith({
    int? id,
    String? referenceNumber,
    String? name,
    String? description,
    LandType? type,
    LandStatus? status,
    OwnershipType? ownershipType,
    double? area,
    String? governorate,
    String? city,
    String? district,
    String? address,
    LandLocation? location,
    LandDocumentation? documentation,
    String? currentUse,
    bool? isLeased,
    LeasingInfo? leasingInfo,
    double? estimatedValue,
    String? beneficiary,
    List<String>? documents,
    List<String>? images,
    Map<String, dynamic>? metadata,
    DateTime? registrationDate,
    DateTime? lastInspectionDate,
    String? registeredBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WaqfLand(
      id: id ?? this.id,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      ownershipType: ownershipType ?? this.ownershipType,
      area: area ?? this.area,
      governorate: governorate ?? this.governorate,
      city: city ?? this.city,
      district: district ?? this.district,
      address: address ?? this.address,
      location: location ?? this.location,
      documentation: documentation ?? this.documentation,
      currentUse: currentUse ?? this.currentUse,
      isLeased: isLeased ?? this.isLeased,
      leasingInfo: leasingInfo ?? this.leasingInfo,
      estimatedValue: estimatedValue ?? this.estimatedValue,
      beneficiary: beneficiary ?? this.beneficiary,
      documents: documents ?? this.documents,
      images: images ?? this.images,
      metadata: metadata ?? this.metadata,
      registrationDate: registrationDate ?? this.registrationDate,
      lastInspectionDate: lastInspectionDate ?? this.lastInspectionDate,
      registeredBy: registeredBy ?? this.registeredBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@JsonSerializable()
class LandLocation {
  final double latitude;
  final double longitude;
  final String? coordinates; // GIS coordinates
  final List<MapPoint>? boundaries;

  const LandLocation({
    required this.latitude,
    required this.longitude,
    this.coordinates,
    this.boundaries,
  });

  factory LandLocation.fromJson(Map<String, dynamic> json) =>
      _$LandLocationFromJson(json);

  Map<String, dynamic> toJson() => _$LandLocationToJson(this);
}

@JsonSerializable()
class MapPoint {
  final double latitude;
  final double longitude;

  const MapPoint({
    required this.latitude,
    required this.longitude,
  });

  factory MapPoint.fromJson(Map<String, dynamic> json) =>
      _$MapPointFromJson(json);

  Map<String, dynamic> toJson() => _$MapPointToJson(this);
}

@JsonSerializable()
class LandDocumentation {
  final String? deedNumber;
  final String? basinNumber;
  final String? parcelNumber;
  final DateTime? deedDate;
  final String? registrationOffice;
  final bool hasOfficialDocuments;
  final List<String> documentTypes;

  const LandDocumentation({
    this.deedNumber,
    this.basinNumber,
    this.parcelNumber,
    this.deedDate,
    this.registrationOffice,
    this.hasOfficialDocuments = false,
    this.documentTypes = const [],
  });

  factory LandDocumentation.fromJson(Map<String, dynamic> json) =>
      _$LandDocumentationFromJson(json);

  Map<String, dynamic> toJson() => _$LandDocumentationToJson(this);
}

@JsonSerializable()
class LeasingInfo {
  final String lesseeNam;
  final String lesseeContact;
  final DateTime startDate;
  final DateTime endDate;
  final double monthlyRent;
  final String paymentStatus;
  final String contractNumber;

  const LeasingInfo({
    required this.lesseeNam,
    required this.lesseeContact,
    required this.startDate,
    required this.endDate,
    required this.monthlyRent,
    required this.paymentStatus,
    required this.contractNumber,
  });

  factory LeasingInfo.fromJson(Map<String, dynamic> json) =>
      _$LeasingInfoFromJson(json);

  Map<String, dynamic> toJson() => _$LeasingInfoToJson(this);
}

// Extensions
extension LandTypeExtension on LandType {
  String get displayName {
    switch (this) {
      case LandType.agricultural:
        return 'زراعي';
      case LandType.residential:
        return 'سكني';
      case LandType.commercial:
        return 'تجاري';
      case LandType.industrial:
        return 'صناعي';
      case LandType.mixed:
        return 'مختلط';
      case LandType.vacant:
        return 'شاغر';
    }
  }
}

extension LandStatusExtension on LandStatus {
  String get displayName {
    switch (this) {
      case LandStatus.registered:
        return 'مسجل';
      case LandStatus.underReview:
        return 'قيد المراجعة';
      case LandStatus.disputed:
        return 'متنازع عليه';
      case LandStatus.leased:
        return 'مؤجر';
      case LandStatus.occupied:
        return 'محتل';
      case LandStatus.available:
        return 'متاح';
    }
  }
}

extension OwnershipTypeExtension on OwnershipType {
  String get displayName {
    switch (this) {
      case OwnershipType.waqfKhayri:
        return 'وقف خيري';
      case OwnershipType.waqfAhli:
        return 'وقف أهلي';
      case OwnershipType.waqfMushtarak:
        return 'وقف مشترك';
    }
  }
}