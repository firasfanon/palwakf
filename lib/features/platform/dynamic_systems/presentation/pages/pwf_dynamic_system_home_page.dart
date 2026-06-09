import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/routing/app_routes.dart';
import '../../../../../core/access/access_profile.dart';
import '../../../../../core/access/access_provider.dart';
import '../../data/models/pwf_dynamic_system_models.dart';
import '../providers/pwf_dynamic_system_registry_providers.dart';
import '../widgets/pwf_system_module_scaffolds.dart';

/// Public/introductory shell for semi-independent systems.
///
/// Sensitive systems use this page as a public-safe entry only; operational
/// records remain behind RBAC-protected admin routes and system-specific schemas.
class PwfDynamicSystemHomePage extends ConsumerWidget {
  const PwfDynamicSystemHomePage({super.key, required this.systemKey});

  final String systemKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(dynamicSystemAdminCatalogProvider);
    final accessAsync = ref.watch(accessProfileProvider);

    return modulesAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const PwfSystemErrorState(
        title: 'تعذر تحميل تعريف النظام',
        message: 'تعذر قراءة سجل الأنظمة الديناميكي.',
      ),
      data: (modules) {
        final module = _findModule(modules, systemKey);
        if (module == null || module.publicRoutePath == null) {
          return const PwfSystemErrorState(
            title: 'الصفحة غير متاحة',
            message:
                'لا توجد صفحة تعريفية عامة لهذا النظام أو أن النظام غير مفعل.',
          );
        }

        return PwfSystemPublicScaffold(
          module: module,
          children: [
            PwfSystemSectionCard(
              icon: Icons.info_outline_rounded,
              title: 'تعريف النظام وحدوده',
              subtitle:
                  'هذه صفحة تعريفية لنظام شبه مستقل داخل PalWakf. الوصول الإداري والبيانات التشغيلية محكومان بالصلاحيات وسجل الأنظمة والعقود الحاكمة.',
              chips: [
                'system_key: ${module.systemKey}',
                'module_type: ${module.moduleType.value}',
                'public route: ${module.publicRoutePath ?? '-'}',
              ],
            ),
            const SizedBox(height: 16),
            _SystemAccessEntryCard(module: module, accessAsync: accessAsync),
          ],
        );
      },
    );
  }
}

PwfDynamicSystemModule? _findModule(
  List<PwfDynamicSystemModule> modules,
  String systemKey,
) {
  final normalized = AccessProfile.normalizeSystemKeyAlias(systemKey);
  for (final module in modules) {
    if (module.systemKey == systemKey ||
        module.systemKey == normalized ||
        AccessProfile.normalizeSystemKeyAlias(module.systemKey) == normalized) {
      return module;
    }
  }
  return null;
}

class _SystemAccessEntryCard extends StatelessWidget {
  const _SystemAccessEntryCard({
    required this.module,
    required this.accessAsync,
  });

  final PwfDynamicSystemModule module;
  final AsyncValue<AccessProfile?> accessAsync;

  @override
  Widget build(BuildContext context) {
    return accessAsync.when(
      loading: () => const PwfSystemSectionCard(
        icon: Icons.hourglass_top_rounded,
        title: 'جارٍ التحقق من الصلاحيات',
        subtitle: 'يتم تحميل ملف الوصول قبل عرض قرار التشغيل.',
        chips: ['access: loading'],
      ),
      error: (_, __) => const PwfSystemSectionCard(
        icon: Icons.error_outline_rounded,
        title: 'تعذر تحميل الصلاحيات',
        subtitle:
            'لم يتم حجب الصفحة العامة، لكن التشغيل الداخلي يتطلب تحققًا جديدًا.',
        chips: ['access: retry-required'],
      ),
      data: (profile) {
        final canOperate =
            profile?.canAccessSystemByAlias(module.systemKey) ?? false;
        final isRoot = profile?.hasPlatformRootAuthority ?? false;
        return PwfSystemSectionCard(
          icon: canOperate
              ? Icons.verified_user_rounded
              : Icons.lock_outline_rounded,
          title: canOperate ? 'صلاحية التشغيل متاحة' : 'لا توجد صلاحية تشغيل',
          subtitle: canOperate
              ? (isRoot
                    ? 'الحساب يملك صلاحية منصة عليا؛ يسمح له بالعبور التشغيلي قبل فحص صلاحيات النظام scoped.'
                    : 'الحساب يملك صلاحية تشغيل لهذا النظام وفق AccessProfile أو السجل الديناميكي.')
              : 'يمكن قراءة صفحة التعريف العامة، أما مركز التشغيل الداخلي فيحتاج صلاحية صريحة أو Superuser.',
          chips: [
            'access: ${canOperate ? 'allowed' : 'denied'}',
            if (isRoot) 'root: superuser',
            'admin: ${module.routeForShell()}',
          ],
          trailing: FilledButton.icon(
            onPressed: canOperate
                ? () => context.go(
                    module.routeForShell().isEmpty
                        ? AppRoutes.adminDynamicSystem(module.systemKey)
                        : module.routeForShell(),
                  )
                : null,
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('دخول مركز التشغيل'),
          ),
        );
      },
    );
  }
}
