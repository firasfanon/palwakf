import 'package:flutter_riverpod/flutter_riverpod.dart';

class PwfAllowedSectionOption {
  const PwfAllowedSectionOption({required this.key, required this.labelAr});

  final String key;
  final String labelAr;
}

const List<PwfAllowedSectionOption> kPwfUnitPageAllowedSectionOptions = [
  PwfAllowedSectionOption(key: 'pwf_quick_links_grid', labelAr: 'روابط سريعة'),
  PwfAllowedSectionOption(key: 'pwf_quick_services', labelAr: 'خدمات سريعة'),
  PwfAllowedSectionOption(
    key: 'pwf_eservices_portal',
    labelAr: 'بوابة الخدمات الإلكترونية',
  ),
  PwfAllowedSectionOption(key: 'pwf_stats_grid', labelAr: 'الإحصائيات'),
  PwfAllowedSectionOption(key: 'pwf_announcements', labelAr: 'الإعلانات'),
  PwfAllowedSectionOption(key: 'pwf_news', labelAr: 'الأخبار'),
  PwfAllowedSectionOption(key: 'pwf_media_gallery', labelAr: 'المعرض الإعلامي'),
  PwfAllowedSectionOption(key: 'pwf_activities', labelAr: 'الأنشطة'),
  PwfAllowedSectionOption(key: 'pwf_friday_sermons', labelAr: 'خطب الجمعة'),
  PwfAllowedSectionOption(
    key: 'pwf_feature_highlights',
    labelAr: 'البطاقات المميّزة',
  ),
  PwfAllowedSectionOption(
    key: 'pwf_mini_map_teaser',
    labelAr: 'الخريطة التمهيدية',
  ),
  PwfAllowedSectionOption(
    key: 'pwf_important_links',
    labelAr: 'الروابط المهمة',
  ),
];

enum PwfUnitPageVisibilityMode { public, internal, hidden }

extension PwfUnitPageVisibilityModeX on PwfUnitPageVisibilityMode {
  String get value {
    switch (this) {
      case PwfUnitPageVisibilityMode.public:
        return 'public';
      case PwfUnitPageVisibilityMode.internal:
        return 'internal';
      case PwfUnitPageVisibilityMode.hidden:
        return 'hidden';
    }
  }

  String get labelAr {
    switch (this) {
      case PwfUnitPageVisibilityMode.public:
        return 'عام';
      case PwfUnitPageVisibilityMode.internal:
        return 'داخلي';
      case PwfUnitPageVisibilityMode.hidden:
        return 'مخفي';
    }
  }

  static PwfUnitPageVisibilityMode fromValue(String value) {
    switch (value.trim().toLowerCase()) {
      case 'internal':
        return PwfUnitPageVisibilityMode.internal;
      case 'hidden':
        return PwfUnitPageVisibilityMode.hidden;
      case 'public':
      default:
        return PwfUnitPageVisibilityMode.public;
    }
  }
}

class PwfUnitPageExecutionRow {
  const PwfUnitPageExecutionRow({
    required this.unitId,
    required this.unitNameAr,
    required this.slug,
    required this.pageTitleAr,
    required this.pageTitleEn,
    required this.isPublished,
    required this.visibility,
    required this.allowedSections,
    required this.displayOrder,
    required this.updatedAt,
    required this.updatedByLabel,
    required this.isArchived,
  });

  final String unitId;
  final String unitNameAr;
  final String slug;
  final String pageTitleAr;
  final String pageTitleEn;
  final bool isPublished;
  final PwfUnitPageVisibilityMode visibility;
  final List<String> allowedSections;
  final int displayOrder;
  final DateTime? updatedAt;
  final String updatedByLabel;
  final bool isArchived;

  String get visibilityValue => visibility.value;

  PwfUnitPageExecutionRow copyWith({
    String? unitId,
    String? unitNameAr,
    String? slug,
    String? pageTitleAr,
    String? pageTitleEn,
    bool? isPublished,
    PwfUnitPageVisibilityMode? visibility,
    List<String>? allowedSections,
    int? displayOrder,
    DateTime? updatedAt,
    String? updatedByLabel,
    bool? isArchived,
  }) {
    return PwfUnitPageExecutionRow(
      unitId: unitId ?? this.unitId,
      unitNameAr: unitNameAr ?? this.unitNameAr,
      slug: slug ?? this.slug,
      pageTitleAr: pageTitleAr ?? this.pageTitleAr,
      pageTitleEn: pageTitleEn ?? this.pageTitleEn,
      isPublished: isPublished ?? this.isPublished,
      visibility: visibility ?? this.visibility,
      allowedSections: allowedSections ?? this.allowedSections,
      displayOrder: displayOrder ?? this.displayOrder,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedByLabel: updatedByLabel ?? this.updatedByLabel,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}

class PwfUnitPagesExecutionStore
    extends StateNotifier<List<PwfUnitPageExecutionRow>> {
  PwfUnitPagesExecutionStore() : super(const []);

  void seedFromUnits(List<Map<String, dynamic>> units) {
    final currentByUnitId = {for (final row in state) row.unitId: row};
    var changed = false;
    final next = List<PwfUnitPageExecutionRow>.from(state);

    for (var i = 0; i < units.length; i++) {
      final row = units[i];
      final unitId = (row['id'] ?? '').toString().trim();
      if (unitId.isEmpty || currentByUnitId.containsKey(unitId)) continue;
      final slug = (row['slug'] ?? '').toString().trim();
      final unitNameAr = ((row['name_ar'] ?? row['name'] ?? row['slug']) ?? '')
          .toString()
          .trim();
      next.add(
        PwfUnitPageExecutionRow(
          unitId: unitId,
          unitNameAr: unitNameAr.isEmpty ? slug : unitNameAr,
          slug: slug,
          pageTitleAr: unitNameAr.isEmpty ? 'صفحة الوحدة' : unitNameAr,
          pageTitleEn: (row['name_en'] ?? slug).toString().trim(),
          isPublished: slug == 'home',
          visibility: PwfUnitPageVisibilityMode.public,
          allowedSections: const [
            'pwf_news',
            'pwf_announcements',
            'pwf_activities',
            'pwf_friday_sermons',
          ],
          displayOrder: i + 1,
          updatedAt: null,
          updatedByLabel: 'غير محدد',
          isArchived: false,
        ),
      );
      changed = true;
    }

    if (changed) {
      next.sort((a, b) {
        final order = a.displayOrder.compareTo(b.displayOrder);
        if (order != 0) return order;
        return a.unitNameAr.compareTo(b.unitNameAr);
      });
      state = List<PwfUnitPageExecutionRow>.unmodifiable(next);
    }
  }

  void upsertByUnitId(PwfUnitPageExecutionRow draft) {
    final next = List<PwfUnitPageExecutionRow>.from(state);
    final index = next.indexWhere((item) => item.unitId == draft.unitId);
    final normalized = draft.copyWith(
      allowedSections: _normalizeAllowedSections(draft.allowedSections),
      pageTitleAr: draft.pageTitleAr.trim().isEmpty
          ? draft.unitNameAr
          : draft.pageTitleAr.trim(),
      pageTitleEn: draft.pageTitleEn.trim(),
    );

    if (index >= 0) {
      next[index] = normalized;
    } else {
      next.add(normalized);
    }
    next.sort((a, b) {
      final order = a.displayOrder.compareTo(b.displayOrder);
      if (order != 0) return order;
      return a.unitNameAr.compareTo(b.unitNameAr);
    });
    state = List<PwfUnitPageExecutionRow>.unmodifiable(next);
  }

  void togglePublished({
    required String unitId,
    required bool isPublished,
    required String actorLabel,
  }) {
    final row = _find(unitId);
    if (row == null) return;
    upsertByUnitId(
      row.copyWith(
        isPublished: isPublished,
        updatedAt: DateTime.now(),
        updatedByLabel: actorLabel,
      ),
    );
  }

  void archiveByUnitId({
    required String unitId,
    required bool archived,
    required String actorLabel,
  }) {
    final row = _find(unitId);
    if (row == null) return;
    upsertByUnitId(
      row.copyWith(
        isArchived: archived,
        updatedAt: DateTime.now(),
        updatedByLabel: actorLabel,
      ),
    );
  }

  void replaceAllowedSections({
    required String unitId,
    required List<String> allowedSections,
    required String actorLabel,
  }) {
    final row = _find(unitId);
    if (row == null) return;
    upsertByUnitId(
      row.copyWith(
        allowedSections: _normalizeAllowedSections(allowedSections),
        updatedAt: DateTime.now(),
        updatedByLabel: actorLabel,
      ),
    );
  }

  PwfUnitPageExecutionRow? _find(String unitId) {
    try {
      return state.firstWhere((item) => item.unitId == unitId);
    } catch (_) {
      return null;
    }
  }

  List<String> _normalizeAllowedSections(List<String> values) {
    final seen = <String>{};
    final result = <String>[];
    for (final raw in values) {
      final key = raw.trim();
      if (key.isEmpty || seen.contains(key)) continue;
      seen.add(key);
      result.add(key);
    }
    return result;
  }
}

final pwfUnitPagesExecutionStoreProvider =
    StateNotifierProvider<
      PwfUnitPagesExecutionStore,
      List<PwfUnitPageExecutionRow>
    >((ref) => PwfUnitPagesExecutionStore());
