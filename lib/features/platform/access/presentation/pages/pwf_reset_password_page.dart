import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../app/routing/app_routes.dart';
import '../../../../../presentation/providers/auth_provider.dart';
import '../../application/pwf_auth_error_normalizer.dart';
import '../../application/pwf_browser_url_sanitizer.dart';
import '../../application/pwf_password_recovery_controller.dart';
import '../../domain/pwf_safe_return_path.dart';

/// Platform-owned page for setting a new password after a recovery callback.
class PwfResetPasswordPage extends ConsumerStatefulWidget {
  const PwfResetPasswordPage({super.key, this.from});

  final String? from;

  @override
  ConsumerState<PwfResetPasswordPage> createState() =>
      _PwfResetPasswordPageState();
}

class _PwfResetPasswordPageState extends ConsumerState<PwfResetPasswordPage> {
  bool _hasRecoverySession =
      Supabase.instance.client.auth.currentSession != null;
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscure = true;
  String? _message;
  bool _messageIsError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureRecoverySession(silent: true);
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _recoveryCodeFromUrl() {
    final base = Uri.base;
    final direct = base.queryParameters['code'];
    if (direct != null && direct.trim().isNotEmpty) return direct.trim();

    final fragment = base.fragment;
    final questionIndex = fragment.indexOf('?');
    if (questionIndex < 0 || questionIndex + 1 >= fragment.length) return null;
    try {
      final fragmentQuery = Uri.splitQueryString(
        fragment.substring(questionIndex + 1),
      );
      final fromFragment = fragmentQuery['code'];
      if (fromFragment != null && fromFragment.trim().isNotEmpty) {
        return fromFragment.trim();
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<bool> _ensureRecoverySession({bool silent = false}) async {
    final client = Supabase.instance.client;
    if (client.auth.currentSession != null) {
      if (mounted && !_hasRecoverySession) {
        setState(() => _hasRecoverySession = true);
      }
      return true;
    }

    final code = _recoveryCodeFromUrl();
    if (code == null || code.isEmpty) {
      if (!silent && mounted) {
        setState(() {
          _message = PwfPasswordRecoveryController.pkceVerifierMissing;
          _messageIsError = true;
          _hasRecoverySession = false;
        });
      }
      return false;
    }

    try {
      await client.auth.exchangeCodeForSession(code);
      final hasSession = client.auth.currentSession != null;
      if (mounted) {
        setState(() => _hasRecoverySession = hasSession);
      }
      return hasSession;
    } catch (_) {
      final hasSession = client.auth.currentSession != null;
      if (mounted) {
        setState(() => _hasRecoverySession = hasSession);
      }
      return hasSession;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _message = null;
      _messageIsError = false;
    });

    final safeFrom = PwfSafeReturnPath.fallback(
      widget.from,
      fallbackPath: AppRoutes.adminDashboard,
    );

    try {
      final hasSession = await _ensureRecoverySession();
      if (!hasSession) {
        throw StateError(PwfPasswordRecoveryController.pkceVerifierMissing);
      }
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordController.text),
      );
      await Supabase.instance.client.auth.signOut();
      ref.read(authStateProvider.notifier).clearLocalSession();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text(PwfPasswordRecoveryController.passwordUpdatedFreshLogin),
        ),
      );
      final loginRoute =
          '${AppRoutes.login}?fresh=1&from=${Uri.encodeComponent(safeFrom)}';
      PwfBrowserUrlSanitizer.replaceWithHashRoute(loginRoute);
      context.go(loginRoute);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _message = PwfAuthErrorNormalizer.normalizeRecovery(error);
        _messageIsError = true;
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(
                            Icons.password_rounded,
                            color: Color(0xFF0F4C81),
                            size: 54,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'تعيين كلمة مرور جديدة',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF0F4C81),
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'بعد تحديث كلمة المرور سيتم إجبار تسجيل دخول جديد، ثم تمريرك عبر RBAC ونطاق الوحدة قبل فتح أي نظام داخلي.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              height: 1.6,
                            ),
                          ),
                          if (!_hasRecoverySession) ...[
                            const SizedBox(height: 14),
                            const _ResetNotice(
                              text:
                                  'لا توجد جلسة استعادة نشطة. افتح رابط الاستعادة من البريد أو اطلب رابطًا جديدًا.',
                              isError: true,
                            ),
                          ],
                          const SizedBox(height: 22),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscure,
                            validator:
                                PwfPasswordRecoveryController.validatePassword,
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور الجديدة',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirmController,
                            obscureText: _obscure,
                            validator: (value) => PwfPasswordRecoveryController
                                .validateConfirmation(
                              value,
                              _passwordController.text,
                            ),
                            onFieldSubmitted: (_) => _submit(),
                            decoration: const InputDecoration(
                              labelText: 'تأكيد كلمة المرور',
                              prefixIcon: Icon(Icons.verified_user_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          if (_message != null) ...[
                            const SizedBox(height: 14),
                            _ResetNotice(
                              text: _message!,
                              isError: _messageIsError,
                            ),
                          ],
                          const SizedBox(height: 22),
                          SizedBox(
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting || !_hasRecoverySession
                                  ? null
                                  : _submit,
                              icon: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.save_rounded),
                              label: const Text('تحديث كلمة المرور'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () =>
                                context.go(AppRoutes.forgotPassword),
                            icon: const Icon(Icons.lock_reset_rounded),
                            label: const Text('طلب رابط استعادة جديد'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResetNotice extends StatelessWidget {
  const _ResetNotice({required this.text, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? const Color(0xFFFFF1F2) : const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isError ? const Color(0xFFFCA5A5) : const Color(0xFFA7F3D0),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isError ? const Color(0xFF7F1D1D) : const Color(0xFF065F46),
          height: 1.5,
        ),
      ),
    );
  }
}
