import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../../app/routing/app_routes.dart';
import '../../../../../presentation/providers/auth_provider.dart';
import '../../application/pwf_auth_error_normalizer.dart';
import '../../application/pwf_browser_url_sanitizer.dart';
import '../../application/pwf_password_recovery_controller.dart';
import '../../domain/pwf_safe_return_path.dart';

/// Platform-owned callback for Supabase password recovery links.
///
/// Important for Flutter Web hash routing: Supabase appends `?code=...` to
/// the URL before the hash fragment when the redirect URL is shaped like
/// `http://host/#/auth/recovery-callback?...`. Therefore GoRouter sees only
/// `/auth/recovery-callback?...`, while the recovery code lives in
/// `Uri.base.queryParameters`. This page deliberately merges both locations.
///
/// Supabase Flutter may also auto-consume the recovery auth code during client
/// bootstrap before this route attempts an explicit exchange. In that case the
/// second explicit exchange can report that the code is invalid/used while a
/// recovery session is already present. This page treats that condition as a
/// successful callback and proceeds to the reset-password step.
class PwfRecoveryCallbackPage extends ConsumerStatefulWidget {
  const PwfRecoveryCallbackPage({super.key, required this.uri});

  final Uri uri;

  @override
  ConsumerState<PwfRecoveryCallbackPage> createState() =>
      _PwfRecoveryCallbackPageState();
}

class _PwfRecoveryCallbackPageState
    extends ConsumerState<PwfRecoveryCallbackPage> {
  String? _error;
  bool _handled = false;
  bool _clientObservedRecoverySession = false;
  StreamSubscription<supabase.AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = supabase.Supabase.instance.client.auth.onAuthStateChange
        .listen((authState) {
      if (authState.session != null &&
          (authState.event == supabase.AuthChangeEvent.passwordRecovery ||
              authState.event == supabase.AuthChangeEvent.signedIn ||
              authState.event == supabase.AuthChangeEvent.initialSession)) {
        _clientObservedRecoverySession = true;
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleCallback());
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleCallback() async {
    if (_handled) return;
    _handled = true;

    final safeFrom = PwfSafeReturnPath.fallback(
      _queryValue('from'),
      fallbackPath: AppRoutes.adminDashboard,
    );
    final code = _queryValue('code')?.trim();
    final error = _queryValue('error_description') ?? _queryValue('error');

    if ((error ?? '').trim().isNotEmpty) {
      setState(() {
        _error = PwfAuthErrorNormalizer.normalizeRecovery(error);
      });
      return;
    }

    // Supabase Flutter may have already exchanged the PKCE code during app
    // bootstrap. Give the client a short grace window before doing a second
    // explicit exchange.
    if (code != null &&
        code.isNotEmpty &&
        await _hasClientRecoverySessionAfterGrace()) {
      _goToResetPassword(safeFrom);
      return;
    }

    if (code == null || code.isEmpty) {
      setState(() {
        _error = PwfPasswordRecoveryController.missingCode;
      });
      return;
    }

    try {
      await ref.read(authStateProvider.notifier).exchangeRecoveryCode(code);
      if (!mounted) return;
      _goToResetPassword(safeFrom);
    } catch (e) {
      // If the explicit exchange failed because the client already consumed
      // the single-use auth code, do not block the user; continue only when a
      // session is present. Otherwise fail closed and request a new link.
      if (await _hasClientRecoverySessionAfterGrace()) {
        if (!mounted) return;
        _goToResetPassword(safeFrom);
        return;
      }
      if (!mounted) return;
      setState(() {
        _error = PwfAuthErrorNormalizer.normalizeRecovery(e);
      });
    }
  }

  Future<bool> _hasClientRecoverySessionAfterGrace() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (_clientObservedRecoverySession) return true;
    return supabase.Supabase.instance.client.auth.currentSession != null;
  }

  void _goToResetPassword(String safeFrom) {
    if (!mounted) return;
    final resetRoute =
        '${AppRoutes.resetPassword}?fresh=1&from=${Uri.encodeComponent(safeFrom)}';
    PwfBrowserUrlSanitizer.replaceWithHashRoute(resetRoute);
    context.go(resetRoute);
  }

  String? _queryValue(String key) {
    // 1) Normal GoRouter query: /auth/recovery-callback?from=...
    final local = widget.uri.queryParameters[key];
    if ((local ?? '').trim().isNotEmpty) return local;

    // 2) Browser URL query before hash: /?code=...#/auth/recovery-callback
    final base = Uri.base.queryParameters[key];
    if ((base ?? '').trim().isNotEmpty) return base;

    // 3) Defensive parser for fragments that may carry either a route query
    //    (`#/auth/recovery-callback?from=...`) or token/hash parameters.
    final fragment = Uri.base.fragment;
    if (fragment.trim().isNotEmpty) {
      if (fragment.startsWith('/')) {
        final parsedRoute = Uri.tryParse(fragment);
        final routeValue = parsedRoute?.queryParameters[key];
        if ((routeValue ?? '').trim().isNotEmpty) return routeValue;
      }

      final queryStart = fragment.indexOf('?');
      final fragmentQuery = queryStart >= 0
          ? fragment.substring(queryStart + 1)
          : fragment.startsWith('?')
              ? fragment.substring(1)
              : fragment;
      if (fragmentQuery.contains('=')) {
        try {
          final parsed = Uri.splitQueryString(fragmentQuery);
          final fromFragment = parsed[key];
          if ((fromFragment ?? '').trim().isNotEmpty) return fromFragment;
        } catch (_) {
          // Malformed fragments are ignored fail-closed.
        }
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _error == null
                          ? Icons.sync_lock_rounded
                          : Icons.error_outline_rounded,
                      size: 54,
                      color: _error == null
                          ? const Color(0xFF0F4C81)
                          : const Color(0xFFB91C1C),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error == null
                          ? 'اعتماد رابط الاستعادة'
                          : 'تعذر اعتماد رابط الاستعادة',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF0F4C81),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _error ?? PwfPasswordRecoveryController.exchangingCode,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        height: 1.7,
                      ),
                    ),
                    if (_error == null) ...[
                      const SizedBox(height: 20),
                      const CircularProgressIndicator(),
                    ] else ...[
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => context.go(AppRoutes.forgotPassword),
                        icon: const Icon(Icons.lock_reset_rounded),
                        label: const Text('طلب رابط جديد'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
