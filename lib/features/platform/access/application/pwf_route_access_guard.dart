import '../domain/pwf_access_reason.dart';
import '../domain/pwf_safe_return_path.dart';

/// Central helper for route-guard URLs.
///
/// This is intentionally tiny and dependency-light so it can be used by the
/// GoRouter configuration without importing system-specific widgets.
class PwfRouteAccessGuard {
  const PwfRouteAccessGuard._();

  static String loginLocationFor(String currentLocation) {
    final from = PwfSafeReturnPath.normalize(currentLocation) ?? '/';
    return '/login?from=${Uri.encodeComponent(from)}';
  }

  static String forbiddenLocation({
    required PwfAccessReason reason,
    required String currentLocation,
    String? unitSlug,
  }) {
    return PwfForbiddenRoute.build(
      reason: reason,
      from: currentLocation,
      unit: unitSlug,
    );
  }
}
