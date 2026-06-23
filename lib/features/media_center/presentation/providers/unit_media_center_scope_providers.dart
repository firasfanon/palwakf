import 'package:flutter_riverpod/flutter_riverpod.dart';

class UnitMediaCenterScope {
  final String unitId;
  final String unitSlug;
  final String unitNameAr;
  final bool isUniversalSuperAdmin;

  const UnitMediaCenterScope({
    required this.unitId,
    required this.unitSlug,
    required this.unitNameAr,
    this.isUniversalSuperAdmin = false,
  });
}

final unitMediaCenterScopeProvider =
    FutureProvider<UnitMediaCenterScope?>((ref) async {
  return null;
});
