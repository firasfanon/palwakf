import 'package:flutter/foundation.dart';

@immutable
class PwfFormerMinister {
  const PwfFormerMinister({
    required this.id,
    this.unitId,
    required this.fullNameAr,
    required this.fullNameEn,
    required this.notesAr,
    required this.notesEn,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.sortOrder = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String? unitId;
  final String fullNameAr;
  final String fullNameEn;
  final String notesAr;
  final String notesEn;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isCurrent;
  final int sortOrder;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PwfFormerMinister.fromMap(Map<String, dynamic> map) {
    DateTime? parseDate(dynamic value) {
      final text = (value ?? '').toString().trim();
      if (text.isEmpty) return null;
      return DateTime.tryParse(text);
    }

    final unitIdText = map['unit_id']?.toString().trim();

    return PwfFormerMinister(
      id: (map['id'] ?? '').toString(),
      unitId: unitIdText == null || unitIdText.isEmpty ? null : unitIdText,
      fullNameAr: (map['full_name_ar'] ?? '').toString(),
      fullNameEn: (map['full_name_en'] ?? '').toString(),
      notesAr: (map['notes_ar'] ?? '').toString(),
      notesEn: (map['notes_en'] ?? '').toString(),
      startDate: parseDate(map['start_date']),
      endDate: parseDate(map['end_date']),
      isCurrent: map['is_current'] == true,
      sortOrder: map['sort_order'] is int
          ? map['sort_order'] as int
          : int.tryParse('${map['sort_order'] ?? 0}') ?? 0,
      isActive: map['is_active'] != false,
      createdAt: parseDate(map['created_at']),
      updatedAt: parseDate(map['updated_at']),
    );
  }

  Map<String, dynamic> toPayload({String? scopedUnitId}) {
    String? dateOnly(DateTime? value) =>
        value == null ? null : value.toIso8601String().split('T').first;

    return {
      'unit_id': scopedUnitId ?? unitId,
      'full_name_ar': fullNameAr.trim(),
      'full_name_en': fullNameEn.trim(),
      'notes_ar': notesAr.trim(),
      'notes_en': notesEn.trim(),
      'start_date': dateOnly(startDate),
      'end_date': dateOnly(endDate),
      'is_current': isCurrent,
      'sort_order': sortOrder,
      'is_active': isActive,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  PwfFormerMinister copyWith({
    String? id,
    String? unitId,
    String? fullNameAr,
    String? fullNameEn,
    String? notesAr,
    String? notesEn,
    DateTime? startDate,
    bool clearStartDate = false,
    DateTime? endDate,
    bool clearEndDate = false,
    bool? isCurrent,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PwfFormerMinister(
      id: id ?? this.id,
      unitId: unitId ?? this.unitId,
      fullNameAr: fullNameAr ?? this.fullNameAr,
      fullNameEn: fullNameEn ?? this.fullNameEn,
      notesAr: notesAr ?? this.notesAr,
      notesEn: notesEn ?? this.notesEn,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      isCurrent: isCurrent ?? this.isCurrent,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
