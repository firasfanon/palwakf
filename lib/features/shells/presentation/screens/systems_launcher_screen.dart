import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waqf/app/routing/app_routes.dart';

import 'package:waqf/core/access/access_provider.dart';
import 'package:waqf/core/enums/enums.dart';
import 'package:waqf/features/platform/home/presentation/providers/pwf_ui_prefs_provider.dart';
import 'package:waqf/features/platform/home/presentation/screens/pwf_web_page_scaffold.dart';
import 'package:waqf/features/platform/home/presentation/theme/pwf_theme_tokens.dart';

class SystemsLauncherScreen extends ConsumerWidget {
  const SystemsLauncherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeKey = ref.watch(pwfUiPrefsProvider.select((s) => s.themeKey));
    final PwfThemeTokensData t = PwfThemeTokens.forKey(themeKey);

    final profileAsync = ref.watch(accessProfileProvider);

    return PwfWebPageScaffold(
      unitSlug: 'home',
      title: 'الأنظمة',
      showTitleSection: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: profileAsync.when(
              data: (profile) {
                // Not signed in
                if (profile == null) {
                  return _Card(
                    t: t,
                    title: 'تحتاج لتسجيل الدخول',
                    subtitle: 'هذه الصفحة تتطلب حساب موظف معتمد في المنصة.',
                    actions: [
                      _PrimaryButton(
                        t: t,
                        label: 'تسجيل الدخول',
                        onTap: () => context.go('/login'),
                      ),
                    ],
                  );
                }

                final allowed = <_SystemItem>[
                  _SystemItem(SystemKey.awqafSystem),
                  _SystemItem(SystemKey.adminData),
                  _SystemItem(SystemKey.lands),
                  _SystemItem(SystemKey.mustakshif),
                  _SystemItem(SystemKey.cases),
                  _SystemItem(SystemKey.properties),
                  _SystemItem(SystemKey.mosques),
                  _SystemItem(SystemKey.tasks),
                  _SystemItem(SystemKey.billing),
                  _SystemItem(SystemKey.zakat),
                  _SystemItem(SystemKey.prayerTimes),
                  _SystemItem(SystemKey.quran),
                  _SystemItem(SystemKey.platformAdmin),
                ];

                final hasAnyAccess =
                    profile.isSuperuser ||
                    allowed.any((s) => profile.canAccessSystem(s.key));

                if (!hasAnyAccess) {
                  return _Card(
                    t: t,
                    title: 'لا تملك صلاحية للوصول',
                    subtitle:
                        'لا توجد أي أنظمة مفعّلة على حسابك. راجع مسؤول المنصة لإسناد نظام/صلاحية.',
                    actions: [
                      _SecondaryButton(
                        t: t,
                        label: 'العودة إلى تسجيل الدخول',
                        onTap: () => context.go('/login'),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'مرحبًا بك في بوابة الأنظمة',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: t.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'اختر النظام الذي تريد فتحه. الأنظمة غير المصرّح بها ستكون معطّلة.',
                      style: TextStyle(
                        fontSize: 13,
                        color: t.onSurface.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final item in allowed)
                          _SystemCard(
                            t: t,
                            item: item,
                            enabled:
                                profile.isSuperuser ||
                                profile.canAccessSystem(item.key),
                            onTap: () => _openSystem(context, item.key),
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _HintBox(
                      t: t,
                      text:
                          'ملاحظة سيادية: صلاحيات الأنظمة تُدار من المنصة عبر RBAC/RLS (admin_users + user_system_roles/permissions).',
                    ),
                  ],
                );
              },
              loading: () => _Card(
                t: t,
                title: 'جاري التحقق من الصلاحيات…',
                subtitle: 'يرجى الانتظار…',
                actions: const [],
                busy: true,
              ),
              error: (e, _) => _Card(
                t: t,
                title: 'تعذر تحميل الصلاحيات',
                subtitle: e.toString(),
                actions: [
                  _SecondaryButton(
                    t: t,
                    label: 'إعادة المحاولة',
                    onTap: () => ref.invalidate(accessProfileProvider),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openSystem(BuildContext context, SystemKey key) {
    final location = _locationForSystem(key);
    context.go(location);
  }

  String _locationForSystem(SystemKey key) {
    switch (key) {
      case SystemKey.awqafSystem:
        return AppRoutes.adminDynamicSystem('awqaf_system');
      case SystemKey.adminData:
        return AppRoutes.adminData;
      case SystemKey.lands:
        return AppRoutes.adminWaqfLands;
      case SystemKey.mustakshif:
        return AppRoutes.mustakshif;
      case SystemKey.cases:
        return AppRoutes.adminCases;
      case SystemKey.mosques:
        return AppRoutes.adminMosques;
      case SystemKey.platformAdmin:
        return AppRoutes.adminDashboard;
      case SystemKey.zakat:
        return AppRoutes.adminZakat;
      case SystemKey.prayerTimes:
        return AppRoutes.adminPrayerTimes;
      case SystemKey.quran:
        return AppRoutes.adminQuran;
      default:
        // Fallback for any future systems.
        return '/systems/${key.slug}';
    }
  }
}

class _SystemItem {
  final SystemKey key;
  const _SystemItem(this.key);

  String get title => key.nameAr;
  String get slug => key.slug;
}

class _SystemCard extends StatelessWidget {
  const _SystemCard({
    required this.t,
    required this.item,
    required this.enabled,
    required this.onTap,
  });

  final PwfThemeTokensData t;
  final _SystemItem item;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = enabled ? t.cardBg : t.cardBg.withValues(alpha: 0.55);
    final border = enabled
        ? t.cardBorder
        : t.cardBorder.withValues(alpha: 0.45);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 290,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 16,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: enabled
                    ? t.primary.withValues(alpha: 0.12)
                    : t.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: t.primary.withValues(alpha: enabled ? 0.35 : 0.18),
                ),
              ),
              child: Icon(
                Icons.apps_rounded,
                color: enabled ? t.primary : t.primary.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: enabled
                          ? t.onSurface
                          : t.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '/systems/${item.slug}',
                    style: TextStyle(
                      fontSize: 12,
                      color: enabled
                          ? t.onSurface.withValues(alpha: 0.65)
                          : t.onSurface.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: enabled
                  ? t.onSurface.withValues(alpha: 0.6)
                  : t.onSurface.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }
}

class _HintBox extends StatelessWidget {
  const _HintBox({required this.t, required this.text});

  final PwfThemeTokensData t;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.cardBorder),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: t.onSurface.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.t,
    required this.title,
    required this.subtitle,
    required this.actions,
    this.busy = false,
  });

  final PwfThemeTokensData t;
  final String title;
  final String subtitle;
  final List<Widget> actions;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: t.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (busy) ...[
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: t.primary,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: t.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13,
              color: t.onSurface.withValues(alpha: 0.75),
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(spacing: 10, runSpacing: 10, children: actions),
          ],
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.t,
    required this.label,
    required this.onTap,
  });
  final PwfThemeTokensData t;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: t.primaryButtonBg,
        foregroundColor: t.primaryButtonFg,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.t,
    required this.label,
    required this.onTap,
  });
  final PwfThemeTokensData t;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: t.onSurface,
        side: BorderSide(color: t.outlinedBorder),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}
