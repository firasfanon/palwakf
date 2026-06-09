import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/access/access_profile.dart';
import '../../data/models/pwf_dynamic_system_models.dart';
import '../providers/pwf_dynamic_system_registry_providers.dart';
import '../widgets/pwf_system_module_scaffolds.dart';

class PwfDynamicSystemPage extends ConsumerWidget {
  const PwfDynamicSystemPage({
    super.key,
    required this.systemKey,
    this.sectionKey,
  });

  final String systemKey;
  final String? sectionKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modulesAsync = ref.watch(visibleDynamicAdminSystemsProvider);

    return modulesAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const PwfSystemErrorState(
        title: 'تعذر تحميل النظام الديناميكي',
        message:
            'تحقق من تثبيت platform.system_registry وRPC الخاصة بالسجل الديناميكي.',
      ),
      data: (modules) {
        final module = _findModule(modules, systemKey);
        if (module == null) {
          return const PwfSystemErrorState(
            title: 'النظام غير متاح',
            message: 'هذا النظام غير مسجل أو غير مصرح لحسابك الحالي.',
          );
        }

        final section = sectionKey == null
            ? null
            : _findSection(module.sections, sectionKey!);
        final visibleSections = module.sections
            .where((section) => section.isActive && section.showInDashboard)
            .toList(growable: false);

        return PwfSystemAdminScaffold(
          module: module,
          activeSection: section,
          children: [
            if (section != null)
              PwfSystemSectionCard(
                icon: section.icon,
                title: section.titleAr,
                subtitle: section.descriptionAr.isEmpty
                    ? 'قسم ديناميكي مسجل في platform.system_sections ويخضع لصلاحيات النظام.'
                    : section.descriptionAr,
                chips: [
                  'القسم: ${section.sectionKey}',
                  'النوع: ${section.sectionType}',
                  'الصلاحية: ${section.requiredPermissionKey}',
                ],
              )
            else
              PwfSystemDashboardScaffold(
                module: module,
                sections: visibleSections,
                emptyMessage:
                    'لم تُسجل أقسام مرئية بعد لهذا النظام، أو لا توجد أقسام مصرح بها للمستخدم الحالي.',
              ),
            if (section != null && module.sections.isNotEmpty) ...[
              const SizedBox(height: 18),
              PwfSystemSectionsGrid(module: module, sections: visibleSections),
            ],
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

PwfDynamicSystemSection? _findSection(
  List<PwfDynamicSystemSection> sections,
  String sectionKey,
) {
  for (final section in sections) {
    if (section.sectionKey == sectionKey) return section;
  }
  return null;
}
