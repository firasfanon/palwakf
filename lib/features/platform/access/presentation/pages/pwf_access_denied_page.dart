import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/pwf_access_reason.dart';
import '../../domain/pwf_safe_return_path.dart';
import '../widgets/pwf_actor_context_strip.dart';

class PwfAccessDeniedPage extends StatelessWidget {
  const PwfAccessDeniedPage({
    super.key,
    this.reasonCode,
    this.fromPath,
    this.unitSlug,
  });

  final String? reasonCode;
  final String? fromPath;
  final String? unitSlug;

  @override
  Widget build(BuildContext context) {
    final uriReason = _queryValue('reason');
    final uriFrom = _queryValue('from');
    final uriUnit = _queryValue('unit');
    final reason = PwfAccessReason.fromCode(reasonCode ?? uriReason);
    final safeFrom = PwfSafeReturnPath.normalize(fromPath ?? uriFrom);
    final user = Supabase.instance.client.auth.currentUser;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 28,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.lock_outline_rounded,
                        size: 58,
                        color: Color(0xFFB22222),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'لا تملك صلاحية للوصول إلى هذه الصفحة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reason.arabicMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          height: 1.7,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 18),
                      PwfActorContextStrip(
                        email: user?.email ?? 'غير مسجل',
                        roleLabel: user == null ? 'anonymous' : 'authenticated',
                        unitLabel: unitSlug ?? uriUnit,
                        routeScope: safeFrom,
                        reasonCode: reason.code,
                        fromPath: safeFrom,
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.icon(
                            onPressed: () => context.go('/login'),
                            icon: const Icon(Icons.login_rounded),
                            label: const Text('تسجيل الدخول'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => context.go('/'),
                            icon: const Icon(Icons.home_outlined),
                            label: const Text('العودة للرئيسية'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'لا تعرض هذه الصفحة أي payload محمي أو tokens أو أخطاء تقنية خامة.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String? _queryValue(String key) {
    final uri = Uri.base;
    final direct = uri.queryParameters[key];
    if (direct != null) return direct;
    final fragment = uri.fragment;
    if (fragment.isEmpty) return null;
    final parsed = Uri.tryParse(
      fragment.startsWith('/') ? fragment : '/$fragment',
    );
    return parsed?.queryParameters[key];
  }
}
