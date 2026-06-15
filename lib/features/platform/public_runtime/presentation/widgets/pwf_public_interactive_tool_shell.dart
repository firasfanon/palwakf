import 'package:flutter/material.dart';

import 'package:waqf/features/platform/home/presentation/screens/pages/pwf_public_content_shared.dart';
import 'package:waqf/features/platform/home/presentation/widgets/pwf_section_container.dart';

/// Public shell for interactive tools such as `/home/zakat` and `/home/chat`.
///
/// Public shell for interactive tools. Technical binding and readiness metadata
/// remain internal/operator documentation and are not rendered to visitors.
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
            note: null,
          ),
          if (primaryAction != null || secondaryAction != null) ...[
            const SizedBox(height: 14),
            _PublicActionsBar(
              primaryAction: primaryAction,
              secondaryAction: secondaryAction,
            ),
          ],
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _PublicActionsBar extends StatelessWidget {
  const _PublicActionsBar({
    this.primaryAction,
    this.secondaryAction,
  });

  final Widget? primaryAction;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    return PwfSurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.end,
        children: [
          if (primaryAction != null) primaryAction!,
          if (secondaryAction != null) secondaryAction!,
        ],
      ),
    );
  }
}
