import 'pwf_browser_url_sanitizer_stub.dart'
    if (dart.library.html) 'pwf_browser_url_sanitizer_web.dart';

/// Sanitizes the browser URL for Flutter Web hash-routing recovery flows.
///
/// Supabase recovery links place `?code=...` before the hash route, for example:
/// `http://localhost:56395/?code=...#/auth/recovery-callback?...`.
/// GoRouter hash navigation can preserve that pre-hash query unless the browser
/// history entry is explicitly replaced. This helper removes one-time recovery
/// codes from the visible URL before navigating to reset/login/dashboard routes.
class PwfBrowserUrlSanitizer {
  const PwfBrowserUrlSanitizer._();

  static void replaceWithHashRoute(String route) {
    replaceBrowserUrlWithHashRoute(route);
  }
}
