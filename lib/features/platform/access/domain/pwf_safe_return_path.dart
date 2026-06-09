import 'pwf_access_reason.dart';

/// Normalizes return paths passed through auth/recovery/forbidden routes.
///
/// This deliberately accepts internal relative paths only. External URLs,
/// scheme/host values, backslashes, double-slash paths, and auth pages as final
/// destinations are rejected fail-closed.
class PwfSafeReturnPath {
  const PwfSafeReturnPath._();

  static String? normalize(String? raw) {
    final value = Uri.decodeComponent((raw ?? '').trim());
    if (value.isEmpty) return null;
    if (!value.startsWith('/')) return null;
    if (value.startsWith('//')) return null;
    if (value.contains(r'\')) return null;

    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    if (uri.hasScheme || uri.host.isNotEmpty) return null;

    final path = uri.path;
    if (path.isEmpty || !path.startsWith('/')) return null;
    const blockedTargets = <String>{
      '/login',
      '/admin/login',
      '/forgot-password',
      '/auth/recovery-callback',
      '/reset-password',
      '/forbidden',
    };
    if (blockedTargets.contains(path)) return null;

    final lowered = value.toLowerCase();
    const sensitiveMarkers = <String>[
      'access_token=',
      'refresh_token=',
      'token_hash=',
      'authorization=',
      'password=',
    ];
    for (final marker in sensitiveMarkers) {
      if (lowered.contains(marker)) return path;
    }

    return value;
  }

  static String fallback(String? raw, {String fallbackPath = '/'}) {
    return normalize(raw) ?? fallbackPath;
  }
}

/// Builder for canonical `/forbidden` URLs.
class PwfForbiddenRoute {
  const PwfForbiddenRoute._();

  static String build({
    PwfAccessReason reason = PwfAccessReason.unknown,
    String? reasonCode,
    String? from,
    String? unit,
  }) {
    final normalizedFrom = PwfSafeReturnPath.normalize(from);
    final query = <String, String>{
      'reason': reasonCode ?? reason.code,
      if (normalizedFrom != null) 'from': normalizedFrom,
      if ((unit ?? '').trim().isNotEmpty) 'unit': unit!.trim(),
    };
    final uri = Uri(path: '/forbidden', queryParameters: query);
    return uri.toString();
  }
}
