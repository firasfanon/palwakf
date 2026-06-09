import 'package:flutter/material.dart';

import 'package:waqf/features/platform/home/presentation/screens/pages/pwf_public_content_shared.dart';
import 'package:waqf/features/platform/home/presentation/theme/pwf_home_palette.dart';
import 'package:waqf/features/platform/home/presentation/widgets/pwf_section_container.dart';
import 'package:waqf/features/platform/public_runtime/domain/pwf_public_official_data_binding_contract.dart';

/// PWF-SIS shell for public interactive tools such as `/home/zakat` and
/// `/home/chat`.
///
/// The goal is not to hide missing official data. Instead, every tool page
/// displays the canonical route, the official source contract, the current data
/// readiness decision, and then renders the interactive tool in the same visual
/// rhythm as the main public pages.
class PwfPublicInteractiveToolShell extends StatelessWidget {
  const PwfPublicInteractiveToolShell({
    super.key,
    required this.unitSlug,
    required this.canonicalRoute,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.note,
    this.primaryAction,
    this.secondaryAction,
  });

  final String unitSlug;
  final String canonicalRoute;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final String? note;
  final Widget? primaryAction;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    final binding = PwfPublicOfficialDataBindingContract.byRoute(
      canonicalRoute,
    );

    return PwfSectionContainer(
      sectionKey: 'PwfPublicInteractiveToolShell_$canonicalRoute',
      verticalPadding: 36,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PwfPublicIntroCard(
            title: title,
            subtitle: subtitle,
            icon: icon,
            unitSlug: unitSlug,
            note:
                note ??
                'هذه صفحة أداة تفاعلية عامة ضمن /home/*. يتم عرض مصدر البيانات الرسمي وحالة الجاهزية صراحة قبل استخدام الأداة.',
          ),
          const SizedBox(height: 16),
          _OfficialSourceBanner(
            route: canonicalRoute,
            binding: binding,
            primaryAction: primaryAction,
            secondaryAction: secondaryAction,
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _OfficialSourceBanner extends StatelessWidget {
  const _OfficialSourceBanner({
    required this.route,
    this.binding,
    this.primaryAction,
    this.secondaryAction,
  });

  final String route;
  final PwfPublicOfficialDataBinding? binding;
  final Widget? primaryAction;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    final ready = binding?.canBeCertifiedComplete == true;
    final color = ready ? const Color(0xFF0F8A5F) : PwfHomePalette.royalRed;
    return PwfSurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              PwfMetaBadge(
                label: 'المسار الرسمي: $route',
                icon: Icons.route_outlined,
                color: PwfHomePalette.primary,
              ),
              PwfMetaBadge(
                label: ready ? 'مصدر رسمي مكتمل' : 'مصدر رسمي قيد الاستكمال',
                icon: ready ? Icons.verified_outlined : Icons.info_outline,
                color: color,
                backgroundColor: color.withValues(alpha: 0.08),
              ),
              if (binding != null)
                PwfMetaBadge(
                  label: binding!.rowEvidence,
                  icon: Icons.storage_outlined,
                  color: PwfHomePalette.secondary,
                  backgroundColor: PwfHomePalette.secondary.withValues(
                    alpha: 0.12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            binding == null
                ? 'لا يوجد عقد مصدر بيانات مسجل لهذا المسار بعد. لا تُعتمد الصفحة مكتملة حتى يضاف مصدر رسمي واضح.'
                : 'مصدر البيانات الرسمي: ${binding!.officialSource}. المالك: ${binding!.owner}. حالة الجاهزية: ${binding!.readiness}.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: PwfHomePalette.textSecondary,
              height: 1.7,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (primaryAction != null || secondaryAction != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (primaryAction != null) primaryAction!,
                if (secondaryAction != null) secondaryAction!,
              ],
            ),
          ],
        ],
      ),
    );
  }
}
