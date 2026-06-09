// lib/presentation/screens/admin/web_login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/features/platform/access/application/pwf_auth_error_normalizer.dart';
import 'package:waqf/features/platform/access/domain/pwf_safe_return_path.dart';
import 'package:waqf/presentation/providers/auth_provider.dart';
import 'package:waqf/presentation/widgets/forms/custom_text_field.dart';

class WebLoginScreen extends ConsumerStatefulWidget {
  const WebLoginScreen({super.key});

  @override
  ConsumerState<WebLoginScreen> createState() => _WebLoginScreenState();
}

class _WebLoginScreenState extends ConsumerState<WebLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authStateProvider.notifier).login(
            _identifierController.text.trim(),
            _passwordController.text,
          );
      if (!mounted) return;
      final from = GoRouterState.of(context).uri.queryParameters['from'];
      final safeTarget = PwfSafeReturnPath.fallback(
        from,
        fallbackPath: AppRoutes.adminDashboard,
      );
      context.go(safeTarget);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(PwfAuthErrorNormalizer.normalize(e)),
            backgroundColor: AppConstants.royalRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 900;
              final veryCompact = constraints.maxWidth < 520;
              final form = _LoginForm(
                formKey: _formKey,
                identifierController: _identifierController,
                passwordController: _passwordController,
                rememberMe: _rememberMe,
                isLoading: _isLoading,
                compact: compact,
                onRememberChanged: (value) =>
                    setState(() => _rememberMe = value ?? false),
                onLogin: _handleLogin,
                onForgotPassword: () {
                  final from =
                      GoRouterState.of(context).uri.queryParameters['from'];
                  final safeFrom = PwfSafeReturnPath.fallback(
                    from,
                    fallbackPath: AppRoutes.adminDashboard,
                  );
                  context.go(
                    '${AppRoutes.forgotPassword}?from=${Uri.encodeComponent(safeFrom)}',
                  );
                },
              );
              final hero = _LoginHero(compact: compact, theme: theme);

              if (compact) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: veryCompact ? 12 : 18,
                    vertical: veryCompact ? 12 : 18,
                  ),
                  child: Column(
                    children: [
                      hero,
                      const SizedBox(height: 12),
                      form,
                    ],
                  ),
                );
              }

              return Row(
                children: [
                  Expanded(flex: 5, child: hero),
                  Expanded(
                    flex: 6,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: form,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero({required this.compact, required this.theme});

  final bool compact;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: compact ? 160 : 520),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1220), Color(0xFF0F4C81)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: compact ? BorderRadius.circular(28) : BorderRadius.zero,
      ),
      child: Stack(
        children: [
          Positioned(
            top: compact ? 18 : 60,
            right: compact ? 18 : 50,
            child: Container(
              width: compact ? 92 : 180,
              height: compact ? 92 : 180,
              decoration: BoxDecoration(
                color: const Color(0xFFEAB308).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: compact ? 14 : 70,
            left: compact ? 18 : 40,
            child: Container(
              width: compact ? 120 : 220,
              height: compact ? 120 : 220,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 18 : 54,
              vertical: compact ? 18 : 48,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: compact ? 72 : 112,
                  height: compact ? 72 : 112,
                  padding: EdgeInsets.all(compact ? 10 : 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(compact ? 22 : 28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: compact ? 14 : 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Image.asset(AppConstants.appLogo, fit: BoxFit.contain),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAB308).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFFEAB308).withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Text(
                    'نظام إداري سيادي - PalWakf',
                    style: TextStyle(
                      color: Color(0xFFEAB308),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'وزارة الأوقاف والشؤون الدينية',
                  textAlign: TextAlign.center,
                  style: (compact
                          ? theme.textTheme.headlineSmall
                          : theme.textTheme.displaySmall)
                      ?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.18,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 18),
                  const Text(
                    'وصول آمن إلى لوحة التحكم الإدارية مع دعم الهوية الموحدة، الصلاحيات، وحوكمة الأنظمة المتصلة بالمنصة.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 16,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _InfoChip(
                        icon: Icons.security_rounded,
                        label: 'تسجيل دخول آمن',
                      ),
                      _InfoChip(
                        icon: Icons.account_tree_outlined,
                        label: 'ربط وحدوي ومركزي',
                      ),
                      _InfoChip(
                        icon: Icons.verified_user_outlined,
                        label: 'RBAC / RLS',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.identifierController,
    required this.passwordController,
    required this.rememberMe,
    required this.isLoading,
    required this.compact,
    required this.onRememberChanged,
    required this.onLogin,
    required this.onForgotPassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController identifierController;
  final TextEditingController passwordController;
  final bool rememberMe;
  final bool isLoading;
  final bool compact;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Container(
        padding: EdgeInsets.all(compact ? 18 : 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(compact ? 24 : 28),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تسجيل الدخول الإداري',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compact ? 22 : 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F4C81),
                ),
              ),
              SizedBox(height: compact ? 8 : 10),
              Text(
                compact
                    ? 'أدخل بياناتك للوصول إلى لوحة التحكم.'
                    : 'أدخل بريدك الإلكتروني أو اسم المستخدم وكلمة المرور للوصول إلى لوحة التحكم. للحسابات الحساسة يوصى بتفعيل البريد الموثق والمصادقة متعددة العوامل.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6B7280), height: 1.6),
              ),
              SizedBox(height: compact ? 10 : 12),
              SizedBox(
                width: double.infinity,
                child: CustomTextField(
                  controller: identifierController,
                  label: 'البريد الإلكتروني أو اسم المستخدم',
                  hint: 'name@example.com أو bthadmin',
                  prefixIcon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'البريد الإلكتروني أو اسم المستخدم مطلوب';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: PasswordTextField(
                  controller: passwordController,
                  label: 'كلمة المرور',
                  hint: 'أدخل كلمة المرور',
                  onFieldSubmitted: (_) => onLogin(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'كلمة المرور مطلوبة';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: compact ? 10 : 18),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(value: rememberMe, onChanged: onRememberChanged),
                      const Text('تذكرني'),
                    ],
                  ),
                  TextButton(
                    onPressed: isLoading ? null : onForgotPassword,
                    child: const Text('نسيت كلمة المرور؟'),
                  ),
                ],
              ),
              SizedBox(height: compact ? 12 : 22),
              SizedBox(
                width: double.infinity,
                height: compact ? 50 : 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F4C81), Color(0xFFEAB308)],
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F4C81).withValues(alpha: 0.20),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'دخول آمن إلى لوحة التحكم',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.login_rounded, color: Colors.white),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: Color(0xFF0F4C81)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'لأغراض الإنتاج: الحسابات الإدارية يجب أن ترتبط ببريد حقيقي مؤكد، وسياسات جلسة محددة، ومصادقة إضافية للحسابات الحساسة.',
                          style:
                              TextStyle(height: 1.5, color: Color(0xFF475569)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () => context.go(AppRoutes.home),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('العودة للصفحة الرئيسية'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFEAB308)),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
