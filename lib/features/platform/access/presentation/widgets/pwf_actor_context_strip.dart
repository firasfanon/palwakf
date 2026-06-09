import 'package:flutter/material.dart';

import '../../domain/pwf_access_reason.dart';
import '../../domain/pwf_safe_return_path.dart';

class PwfActorContextStrip extends StatelessWidget {
  const PwfActorContextStrip({
    super.key,
    this.email,
    this.roleLabel,
    this.unitLabel,
    this.routeScope,
    this.reasonCode,
    this.fromPath,
    this.compact = false,
  });

  final String? email;
  final String? roleLabel;
  final String? unitLabel;
  final String? routeScope;
  final String? reasonCode;
  final String? fromPath;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final reason = PwfAccessReason.fromCode(reasonCode);
    final safeFrom = PwfSafeReturnPath.normalize(fromPath);
    final entries = <_ActorContextEntry>[
      _ActorContextEntry(Icons.account_circle_outlined, 'الحساب', email),
      _ActorContextEntry(
        Icons.admin_panel_settings_outlined,
        'الدور',
        roleLabel,
      ),
      _ActorContextEntry(Icons.apartment_outlined, 'الوحدة', unitLabel),
      _ActorContextEntry(Icons.route_outlined, 'النطاق', routeScope),
      _ActorContextEntry(
        Icons.info_outline_rounded,
        'سبب الرفض',
        reasonCode == null ? null : reason.arabicMessage,
      ),
      _ActorContextEntry(Icons.link_outlined, 'المسار', safeFrom),
    ].where((entry) => (entry.value ?? '').trim().isNotEmpty).toList();

    if (entries.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Wrap(
        alignment: WrapAlignment.start,
        runAlignment: WrapAlignment.start,
        spacing: 8,
        runSpacing: 8,
        children: entries.map((entry) => _ActorContextChip(entry)).toList(),
      ),
    );
  }
}

class _ActorContextEntry {
  const _ActorContextEntry(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String? value;
}

class _ActorContextChip extends StatelessWidget {
  const _ActorContextChip(this.entry);

  final _ActorContextEntry entry;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(entry.icon, size: 16, color: const Color(0xFF0F4C81)),
            const SizedBox(width: 6),
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${entry.label}: ',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    TextSpan(text: entry.value),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF334155), height: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
