import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/features/platform/access/application/pwf_auth_error_normalizer.dart';
import 'package:waqf/features/platform/access/domain/pwf_safe_return_path.dart';
import 'package:waqf/presentation/providers/auth_provider.dart';

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
  bool _obscurePassword = true;

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
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(PwfAuthErrorNormalizer.normalize(error)),
          backgroundColor: AppConstants.royalRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openPasswordRecovery() {
    final from = GoRouterState.of(context).uri.queryParameters['from'];
    final safeFrom = PwfSafeReturnPath.fallback(
      from,
      fallbackPath: AppRoutes.adminDashboard,
    );
    context.go(
      '${AppRoutes.forgotPassword}?from=${Uri.encodeComponent(safeFrom)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 920;
              final phone = constraints.maxWidth < 540;
              final form = _WebLoginCard(
                formKey: _formKey,
                identifierController: _identifierController,
                passwordController: _passwordController,
                obscurePassword: _obscurePassword,
                rememberMe: _rememberMe,
                isLoading: _isLoading,
                compact: compact,
                onTogglePassword: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                onRememberChanged: (value) =>
                    setState(() => _rememberMe = value ?? false),
                onLogin: _handleLogin,
                onForgotPassword: _openPasswordRecovery,
                onHome: () => context.go(AppRoutes.home),
              );

              if (compact) {
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    phone ? 14 : 22,
                    phone ? 14 : 22,
                    phone ? 14 : 22,
                    phone ? 22 : 30,
                  ),
                  child: Column(
                    children: [
                      _LoginBrandPanel(compact: true),
                      const SizedBox(height: 16),
                      form,
                    ],
                  ),
                );
              }

              return Row(
                children: [
                  const Expanded(flex: 5, child: _LoginBrandPanel()),
                  Expanded(
                    flex: 6,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(28),
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

class _LoginBrandPanel extends StatelessWidget {
  const _LoginBrandPanel({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: compact ? 210 : 620),
      decoration: BoxDecoration(
        color: const Color(0xFF0F4C81),
        borderRadius: compact ? BorderRadius.circular(28) : BorderRadius.zero,
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            top: compact ? -42 : -84,
            left: compact ? -32 : -76,
            child: _DecorativeOrb(
              size: compact ? 150 : 300,
              color: const Color(0xFFEAB308).withValues(alpha: 0.13),
            ),
          ),
          Positioned(
            bottom: compact ? -60 : -110,
            right: compact ? -40 : -80,
            child: _DecorativeOrb(
              size: compact ? 190 : 380,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Positioned(
            top: compact ? 28 : 58,
            right: compact ? 24 : 52,
            child: IconButton(
              tooltip: 'العودة للصفحة الرئيسية',
              onPressed: () => context.go(AppRoutes.home),
              style: IconButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.10),
              ),
              icon: const Icon(Icons.home_outlined),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 26 : 60,
                vertical: compact ? 30 : 54,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: compact ? 76 : 116,
                    height: compact ? 76 : 116,
                    padding: EdgeInsets.all(compact ? 11 : 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(compact ? 24 : 32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 26,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Image.asset(AppConstants.appLogo, fit: BoxFit.contain),
                  ),
                  SizedBox(height: compact ? 14 : 20),
                  Text(
                    'منصة الأوقاف الفلسطينية',
                    textAlign: TextAlign.center,
                    style: (compact
                            ? theme.textTheme.headlineSmall
                            : theme.textTheme.displaySmall)
                        ?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'وزارة الأوقاف والشؤون الدينية',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      fontSize: compact ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!compact) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'بوابة موحّدة للموظفين للوصول إلى مساحة العمل الخاصة بهم.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFDCEAF7),
                        fontSize: 16,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        _BrandPill(icon: Icons.language_rounded, label: 'واجهة عربية'),
                        _BrandPill(icon: Icons.devices_rounded, label: 'متوافقة مع الأجهزة'),
                        _BrandPill(icon: Icons.support_agent_rounded, label: 'دعم المنصة'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeOrb extends StatelessWidget {
  const _DecorativeOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _BrandPill extends StatelessWidget {
  const _BrandPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFEAB308)),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _WebLoginCard extends StatelessWidget {
  const _WebLoginCard({
    required this.formKey,
    required this.identifierController,
    required this.passwordController,
    required this.obscurePassword,
    required this.rememberMe,
    required this.isLoading,
    required this.compact,
    required this.onTogglePassword,
    required this.onRememberChanged,
    required this.onLogin,
    required this.onForgotPassword,
    required this.onHome,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController identifierController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool rememberMe;
  final bool isLoading;
  final bool compact;
  final VoidCallback onTogglePassword;
  final ValueChanged<bool?> onRememberChanged;
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 490),
      child: Container(
        padding: EdgeInsets.all(compact ? 22 : 34),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(compact ? 26 : 30),
          border: Border.all(color: const Color(0xFFE4EAF1)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F4C81).withValues(alpha: 0.08),
              blurRadius: 36,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.login_rounded, color: Color(0xFF0F4C81)),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'مرحبًا بك',
                style: TextStyle(
                  color: Color(0xFF12355A),
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'أدخل بيانات حسابك للمتابعة إلى مساحة العمل.',
                style: TextStyle(color: Color(0xFF64748B), height: 1.6),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: identifierController,
                autofocus: !compact,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                textDirection: TextDirection.ltr,
                autofillHints: const [AutofillHints.username, AutofillHints.email],
                decoration: _inputDecoration(
                  label: 'البريد الإلكتروني أو اسم المستخدم',
                  hint: 'name@example.com',
                  icon: Icons.person_outline_rounded,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'أدخل البريد الإلكتروني أو اسم المستخدم.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: passwordController,
                obscureText: obscurePassword,
                textDirection: TextDirection.ltr,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => onLogin(),
                decoration: _inputDecoration(
                  label: 'كلمة المرور',
                  hint: 'أدخل كلمة المرور',
                  icon: Icons.lock_outline_rounded,
                ).copyWith(
                  suffixIcon: IconButton(
                    tooltip: obscurePassword ? 'إظهار كلمة المرور' : 'إخفاء كلمة المرور',
                    onPressed: onTogglePassword,
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'أدخل كلمة المرور.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
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
              const SizedBox(height: 18),
              SizedBox(
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F4C81), Color(0xFF1C679F)],
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
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : onLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.arrow_back_rounded),
                    label: Text(
                      isLoading ? 'جارٍ التحقق...' : 'تسجيل الدخول',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 7),
                  Text(
                    'تعامل مع بيانات الدخول بسرية.',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: onHome,
                icon: const Icon(Icons.home_outlined),
                label: const Text('العودة للصفحة الرئيسية'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    const borderColor = Color(0xFFD8E1EB);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF0F4C81)),
      filled: true,
      fillColor: const Color(0xFFFBFCFE),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF0F4C81), width: 1.5),
      ),
    );
  }
}
