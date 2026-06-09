import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/routing/app_routes.dart';
import '../../../../../presentation/providers/auth_provider.dart';
import '../../application/pwf_auth_error_normalizer.dart';
import '../../application/pwf_password_recovery_controller.dart';
import '../../domain/pwf_safe_return_path.dart';

/// Platform-owned password recovery request page.
///
/// The response deliberately does not reveal whether an email exists.
class PwfForgotPasswordPage extends ConsumerStatefulWidget {
  const PwfForgotPasswordPage({super.key, this.from});

  final String? from;

  @override
  ConsumerState<PwfForgotPasswordPage> createState() =>
      _PwfForgotPasswordPageState();
}

class _PwfForgotPasswordPageState extends ConsumerState<PwfForgotPasswordPage> {
  static const String _configuredRecoveryOrigin =
      String.fromEnvironment('PWF_AUTH_REDIRECT_ORIGIN');

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;
  String? _message;
  bool _messageIsError = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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
    final callbackUrl = _buildRecoveryCallbackUrl(safeFrom);

    try {
      await ref.read(authStateProvider.notifier).resetPassword(
            _emailController.text.trim(),
            redirectTo: callbackUrl,
          );
      if (!mounted) return;
      setState(() {
        _message = PwfPasswordRecoveryController.nonEnumeratingSent;
        _messageIsError = false;
      });
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

  String _buildRecoveryCallbackUrl(String safeFrom) {
    final origin = _safeRecoveryOrigin();
    final callback = Uri(
      path: AppRoutes.recoveryCallback,
      queryParameters: {'from': safeFrom},
    ).toString();
    return '$origin/#$callback';
  }

  String _safeRecoveryOrigin() {
    final configured = _configuredRecoveryOrigin.trim();
    if (configured.isNotEmpty) {
      final parsed = Uri.tryParse(configured);
      if (parsed != null &&
          parsed.hasScheme &&
          parsed.hasAuthority &&
          (parsed.scheme == 'http' || parsed.scheme == 'https')) {
        return '${parsed.scheme}://${parsed.authority}';
      }
    }

    final base = Uri.base;
    return '${base.scheme}://${base.authority}';
  }

  @override
  Widget build(BuildContext context) {
    final safeFrom = PwfSafeReturnPath.fallback(
      widget.from,
      fallbackPath: AppRoutes.adminDashboard,
    );

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
                            Icons.lock_reset_rounded,
                            color: Color(0xFF0F4C81),
                            size: 54,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'استعادة كلمة المرور',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF0F4C81),
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'أدخل بريدك المؤسسي. سنعرض رسالة موحدة دون كشف ما إذا كان البريد مسجلًا أم لا.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 22),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            validator:
                                PwfPasswordRecoveryController.validateEmail,
                            onFieldSubmitted: (_) => _submit(),
                            decoration: const InputDecoration(
                              labelText: 'البريد الإلكتروني',
                              prefixIcon: Icon(Icons.email_outlined),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          if (_message != null) ...[
                            const SizedBox(height: 14),
                            _RecoveryMessage(
                              text: _message!,
                              isError: _messageIsError,
                            ),
                          ],
                          const SizedBox(height: 22),
                          SizedBox(
                            height: 54,
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting ? null : _submit,
                              icon: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.send_rounded),
                              label: const Text('إرسال رابط الاستعادة'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () {
                              context.go(
                                '${AppRoutes.login}?fresh=1&from=${Uri.encodeComponent(safeFrom)}',
                              );
                            },
                            icon: const Icon(Icons.login_rounded),
                            label: const Text('العودة إلى تسجيل الدخول'),
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

class _RecoveryMessage extends StatelessWidget {
  const _RecoveryMessage({required this.text, required this.isError});

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
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_outline,
            color: isError ? const Color(0xFFB91C1C) : const Color(0xFF047857),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color:
                    isError ? const Color(0xFF7F1D1D) : const Color(0xFF065F46),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
