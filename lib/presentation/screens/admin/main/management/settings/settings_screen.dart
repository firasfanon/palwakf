import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waqf/presentation/widgets/admin/admin_panel_registry.dart';
import 'package:waqf/core/visual_identity/visual_identity_contract.dart';
import 'package:waqf/core/visual_identity/visual_identity_registry.dart';
import 'package:waqf/core/visual_identity/visual_identity_publish_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waqf/core/admin_governance/page_manager_governance_contract.dart';
import 'package:waqf/core/access/access_profile.dart';
import 'package:waqf/core/access/access_provider.dart';
import 'package:waqf/core/enums/enums.dart';

class _VisualIdentityDraftEntry {
  const _VisualIdentityDraftEntry({
    required this.id,
    required this.preset,
    required this.statusLabel,
    required this.note,
    required this.updatedAt,
  });

  final String id;
  final PwfVisualPreset preset;
  final String statusLabel;
  final String note;
  final DateTime updatedAt;

  _VisualIdentityDraftEntry copyWith({
    String? statusLabel,
    String? note,
    DateTime? updatedAt,
  }) {
    return _VisualIdentityDraftEntry(
      id: id,
      preset: preset,
      statusLabel: statusLabel ?? this.statusLabel,
      note: note ?? this.note,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

final _visualIdentitySelectedPresetProvider = StateProvider<String?>(
  (ref) => null,
);
final _visualIdentityDraftNoteProvider = StateProvider<String>((ref) => '');
final _visualIdentityDraftsProvider =
    StateProvider<Map<String, _VisualIdentityDraftEntry>>(
      (ref) => <String, _VisualIdentityDraftEntry>{},
    );
final _visualIdentityPublishApprovalProvider = StateProvider<bool>(
  (ref) => false,
);
final _visualIdentityContrastAcknowledgedProvider = StateProvider<bool>(
  (ref) => false,
);

final _visualIdentityPublishRepositoryProvider =
    Provider<PwfVisualIdentityPublishRepository>(
      (ref) => PwfVisualIdentityPublishRepository(Supabase.instance.client),
    );
final _visualIdentityPublishStateProvider =
    FutureProvider<PwfVisualIdentityPublishState>(
      (ref) => ref.read(_visualIdentityPublishRepositoryProvider).fetchState(),
    );

@immutable
class _VisualTokenDiffEntry {
  const _VisualTokenDiffEntry({
    required this.label,
    required this.candidate,
    required this.published,
  });

  final String label;
  final Color candidate;
  final Color published;

  bool get changed => candidate.value != published.value;
}

@immutable
class _VisualContrastCheck {
  const _VisualContrastCheck({
    required this.label,
    required this.ratio,
    required this.passes,
  });

  final String label;
  final double ratio;
  final bool passes;
}

double _visualChannelToLinear(int channel) {
  final srgb = channel / 255.0;
  return srgb <= 0.04045
      ? srgb / 12.92
      : pow((srgb + 0.055) / 1.055, 2.4).toDouble();
}

double _visualLuminance(Color color) {
  return (0.2126 * _visualChannelToLinear(color.red)) +
      (0.7152 * _visualChannelToLinear(color.green)) +
      (0.0722 * _visualChannelToLinear(color.blue));
}

double _visualContrastRatio(Color a, Color b) {
  final l1 = _visualLuminance(a);
  final l2 = _visualLuminance(b);
  final lighter = max(l1, l2);
  final darker = min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

List<_VisualTokenDiffEntry> _buildVisualTokenDiff(
  PwfVisualPreset candidate,
  PwfVisualPreset published,
) {
  return <_VisualTokenDiffEntry>[
    _VisualTokenDiffEntry(
      label: 'Primary',
      candidate: candidate.palette.primary,
      published: published.palette.primary,
    ),
    _VisualTokenDiffEntry(
      label: 'Hover',
      candidate: candidate.palette.primaryHover,
      published: published.palette.primaryHover,
    ),
    _VisualTokenDiffEntry(
      label: 'Gold',
      candidate: candidate.palette.secondary,
      published: published.palette.secondary,
    ),
    _VisualTokenDiffEntry(
      label: 'Royal Red',
      candidate: candidate.palette.royalRed,
      published: published.palette.royalRed,
    ),
    _VisualTokenDiffEntry(
      label: 'Background',
      candidate: candidate.palette.background,
      published: published.palette.background,
    ),
    _VisualTokenDiffEntry(
      label: 'Surface',
      candidate: candidate.palette.surface,
      published: published.palette.surface,
    ),
    _VisualTokenDiffEntry(
      label: 'Border',
      candidate: candidate.palette.border,
      published: published.palette.border,
    ),
    _VisualTokenDiffEntry(
      label: 'Text Primary',
      candidate: candidate.palette.textPrimary,
      published: published.palette.textPrimary,
    ),
    _VisualTokenDiffEntry(
      label: 'Text Secondary',
      candidate: candidate.palette.textSecondary,
      published: published.palette.textSecondary,
    ),
  ];
}

List<_VisualContrastCheck> _buildContrastChecks(PwfVisualPalette palette) {
  final onPrimary = _visualContrastRatio(Colors.white, palette.primary);
  final onSurface = _visualContrastRatio(palette.textPrimary, palette.surface);
  final onBackground = _visualContrastRatio(
    palette.textPrimary,
    palette.background,
  );
  return <_VisualContrastCheck>[
    _VisualContrastCheck(
      label: 'نص أبيض على اللون الأساسي',
      ratio: onPrimary,
      passes: onPrimary >= 4.5,
    ),
    _VisualContrastCheck(
      label: 'النص الأساسي على البطاقات',
      ratio: onSurface,
      passes: onSurface >= 4.5,
    ),
    _VisualContrastCheck(
      label: 'النص الأساسي على الخلفية',
      ratio: onBackground,
      passes: onBackground >= 4.5,
    ),
  ];
}

bool _canManageVisualIdentity(AccessProfile? profile) {
  if (profile == null) return false;
  if (profile.isSuperuser) return true;
  return profile.can(SystemKey.platformAdmin, Permission.manageSite) ||
      profile.can(SystemKey.platformAdmin, Permission.manageHome);
}

String _buildVisualIdentityDecisionSummary({
  required PwfVisualPreset candidatePreset,
  required PwfVisualPreset publishedPreset,
  required PwfVisualPreset defaultPreset,
  required List<_VisualTokenDiffEntry> diffEntries,
  required List<_VisualContrastCheck> checks,
  required String note,
  required PwfVisualIdentityPublishState publishState,
}) {
  final changed = diffEntries
      .where((e) => e.changed)
      .map((e) => e.label)
      .toList(growable: false);
  final warnings = checks
      .where((e) => !e.passes)
      .map((e) => '${e.label}: ${e.ratio.toStringAsFixed(2)}:1')
      .toList(growable: false);
  final historyCount = publishState
      .historyForContext(candidatePreset.context.key)
      .length;
  return '''# قرار الهوية البصرية — ${candidatePreset.context.labelAr}

- المرشح: ${candidatePreset.id}
- المنشور: ${publishedPreset.id}
- الافتراضي: ${defaultPreset.id}
- العائلة: ${candidatePreset.family.labelAr}
- الكثافة: ${candidatePreset.density.labelAr}
- عدد الإصدارات السابقة لهذا السياق: $historyCount
- الملاحظة: ${note.trim().isEmpty ? 'بدون ملاحظة' : note.trim()}

## التوكنز المتغيّرة
${changed.isEmpty ? '- لا توجد فروقات مؤثرة' : changed.map((e) => '- $e').join('\n')}

## فحص التباين
${checks.map((e) => '- ${e.label}: ${e.ratio.toStringAsFixed(2)}:1 ${e.passes ? 'PASS' : 'WARNING'}').join('\n')}

## التحذيرات
${warnings.isEmpty ? '- لا توجد تحذيرات حرجة' : warnings.map((e) => '- $e').join('\n')}

## المرجع
- ${PwfVisualIdentityRegistry.docsPath}
- يتم الاستهلاك عبر registry موحد في platform_home / unit_pages / system_pages / admin_internal
''';
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = AdminPanelRegistry.orderedGroups;
    final tabs = groups.map(_tabForGroup).toList(growable: false);

    return DefaultTabController(
      length: groups.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('بوابة إدارة المنصة'),
          bottom: TabBar(
            isScrollable: true,
            tabs: tabs
                .map(
                  (tab) => Tab(text: tab.label, icon: Icon(tab.icon, size: 18)),
                )
                .toList(growable: false),
          ),
        ),
        body: TabBarView(
          children: groups
              .map((group) => _GatewayTab(group: group))
              .toList(growable: false),
        ),
      ),
    );
  }

  AdminPanelTabItem _tabForGroup(AdminPanelGroup group) {
    for (final tab in AdminPanelRegistry.tabs) {
      if (tab.key == group.id) return tab;
    }

    return AdminPanelTabItem(
      key: group.id,
      label: group.title,
      icon: _fallbackIconForGroup(group.id),
    );
  }

  IconData _fallbackIconForGroup(String groupId) {
    switch (groupId) {
      case 'public_pages':
        return Icons.article_outlined;
      case 'platform_services':
        return Icons.miscellaneous_services_outlined;
      default:
        return Icons.folder_open_outlined;
    }
  }
}

class _GatewayTab extends StatelessWidget {
  const _GatewayTab({required this.group});

  final AdminPanelGroup group;

  @override
  Widget build(BuildContext context) {
    final isSystemsTab = group.id == 'systems';
    final isPlatformTab = group.id == 'platform';

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          group.title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          group.subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
        const SizedBox(height: 20),
        if (isPlatformTab) ...[
          const _VisualIdentityExecutionCard(),
          const SizedBox(height: 20),
          const _AdminGovernanceExecutionCard(),
          const SizedBox(height: 20),
        ],
        _buildEntriesGrid(context),
        if (isSystemsTab) ...[
          const SizedBox(height: 20),
          _SystemsGovernanceOverviewCard(),
          const SizedBox(height: 16),
          _GovernedSystemsSection(
            title: 'النظام الإداري المرجعي الرئيسي',
            subtitle:
                'هذا الجزء يثبت أن awqaf_system هو العقل الإداري المرجعي للمنصة، وليس مجرد نظام فرعي عادي.',
            systems: AdminPanelRegistry.administrativeCoreSystems,
          ),
          const SizedBox(height: 16),
          _GovernedSystemsSection(
            title: 'الأنظمة شبه المستقلة المرتبطة بالمنصة',
            subtitle:
                'أنظمة مرتبطة بالعقد الحاكم للمنصة وقاعدة البيانات المشتركة، لكنها تحتفظ بوظيفتها التخصصية الخاصة.',
            systems: AdminPanelRegistry.connectedSystems,
          ),
        ],
      ],
    );
  }

  Widget _buildEntriesGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: group.items.length,
      itemBuilder: (context, index) {
        final item = group.items[index];
        return _GatewayCard(item: item);
      },
    );
  }
}

class _SystemsGovernanceOverviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final coreCount = AdminPanelRegistry.administrativeCoreSystems.length;
    final connectedCount = AdminPanelRegistry.connectedSystems.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0B3A70).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF0B3A70).withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'حوكمة الأنظمة المرتبطة بالمنصة',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'حوكمة الأنظمة المرتبطة بالمنصة.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF374151),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 12,
            backgroundColor: color,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GovernedSystemsSection extends StatelessWidget {
  const _GovernedSystemsSection({
    required this.title,
    required this.subtitle,
    required this.systems,
  });

  final String title;
  final String subtitle;
  final List<AdminGovernedSystem> systems;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          ...systems.map(
            (system) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _GovernedSystemTile(system: system),
            ),
          ),
        ],
      ),
    );
  }
}

class _GovernedSystemTile extends StatelessWidget {
  const _GovernedSystemTile({required this.system});

  final AdminGovernedSystem system;

  @override
  Widget build(BuildContext context) {
    final tierColor = system.tier == AdminGovernanceTier.administrativeCore
        ? const Color(0xFF0B3A70)
        : const Color(0xFF2E7D32);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tierColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tierColor.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(system.icon, color: tierColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      system.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      system.familyAr,
                      style: TextStyle(
                        color: tierColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  system.tier.labelAr,
                  style: TextStyle(
                    color: tierColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            system.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF374151),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            system.notesAr,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          if ((system.adminRoute ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => context.go(system.adminRoute!),
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: const Text('فتح المسار المرتبط'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GatewayCard extends StatelessWidget {
  const _GatewayCard({required this.item});

  final AdminPanelEntry item;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxHeight < 126 || constraints.maxWidth < 210;
        final padding = compact ? 12.0 : 16.0;
        final iconSize = compact ? 36.0 : 44.0;
        final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: compact ? 13.5 : null,
            );

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.go(item.route),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: iconSize,
                        height: iconSize,
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF1D4E89).withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          item.icon,
                          color: const Color(0xFF1D4E89),
                          size: compact ? 20 : 24,
                        ),
                      ),
                      const Spacer(),
                      if (item.badge != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: compact ? 7 : 8,
                            vertical: compact ? 3 : 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB22222),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.badge.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: compact ? 10 : 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: compact ? 8 : 12),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle,
                  ),
                  SizedBox(height: compact ? 3 : 6),
                  Flexible(
                    child: Text(
                      item.description,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6B7280),
                            height: compact ? 1.15 : 1.35,
                            fontSize: compact ? 11.5 : null,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}


class _VisualIdentityExecutionCard extends ConsumerWidget {
  const _VisualIdentityExecutionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presets = PwfVisualIdentityRegistry.defaults;
    final accessProfile = ref.watch(accessProfileProvider).valueOrNull;
    final families = PwfVisualFamily.values;
    final contexts = PwfVisualContext.values;
    if (!_canManageVisualIdentity(accessProfile)) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.30),
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'غير مصرح لك بإدارة الهوية البصرية',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8),
            Text(
              'تحتاج صلاحية manageSite أو manageHome على platformAdmin، أو أن تكون superuser.',
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F4C81).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF0F4C81).withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'مرجع الهوية البصرية التنفيذية',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'هذه المساحة أصبحت مرجع تنفيذ حي ومغلق وظيفيًا داخل لوحة التحكم: العائلات الثلاث، السياقات الأربعة، المعاينات الحية، المقارنة الثلاثية، سجل الإصدارات، وفحص التباين قبل النشر.',
            style: TextStyle(color: Color(0xFF374151), height: 1.6),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _VisualIdentityMetricCard(
                title: 'العائلات المعتمدة',
                value: families.length.toString(),
                icon: Icons.palette_outlined,
                accent: const Color(0xFF0F4C81),
              ),
              _VisualIdentityMetricCard(
                title: 'السياقات التشغيلية',
                value: contexts.length.toString(),
                icon: Icons.layers_outlined,
                accent: const Color(0xFF1F6B45),
              ),
              _VisualIdentityMetricCard(
                title: 'الـ Presets الحالية',
                value: presets.length.toString(),
                icon: Icons.style_outlined,
                accent: const Color(0xFF7A1F2B),
              ),
              _VisualIdentityMetricCard(
                title: 'ملف المرجع',
                value: 'docs/visual_identity',
                icon: Icons.description_outlined,
                accent: const Color(0xFFC9A227),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _VisualIdentityDraftWorkspace(),
          const SizedBox(height: 16),
          const _VisualIdentityConsumptionAuditCard(),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'ما أُغلق في هذه الدفعة',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Text(
                  '1) Workspace ناضج للمعاينة والمقارنة بين الافتراضي والمنشور والمرشح.',
                ),
                Text(
                  '2) سجل إصدارات فعلي مع الرجوع إلى إصدار محدد داخل نفس السياق.',
                ),
                Text('3) فحص تباين أولي وحوكمة نشر داخلية قبل الاعتماد.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'مصفوفة العائلات والسياقات الحالية',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: families.map((family) {
              final familyPresets = presets
                  .where((preset) => preset.family == family)
                  .toList();
              return _VisualFamilyContextCard(
                family: family,
                presets: familyPresets,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          SelectableText(
            'docs: ${PwfVisualIdentityRegistry.docsPath}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisualIdentityDraftWorkspace extends ConsumerWidget {
  const _VisualIdentityDraftWorkspace();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presets = PwfVisualIdentityRegistry.defaults;
    final selectedPresetId =
        ref.watch(_visualIdentitySelectedPresetProvider) ?? presets.first.id;
    final note = ref.watch(_visualIdentityDraftNoteProvider);
    final drafts = ref.watch(_visualIdentityDraftsProvider);
    final approvalChecked = ref.watch(_visualIdentityPublishApprovalProvider);
    final contrastAcknowledged = ref.watch(
      _visualIdentityContrastAcknowledgedProvider,
    );
    final selectedPreset = presets.firstWhere(
      (preset) => preset.id == selectedPresetId,
      orElse: () => presets.first,
    );
    final selectedDraft = drafts[selectedPreset.id];
    final publishStateAsync = ref.watch(_visualIdentityPublishStateProvider);
    final publishState = publishStateAsync.valueOrNull;
    if (publishState != null) {
      PwfVisualIdentityRegistry.applyPublishedMappings(
        publishState.publishedByContext,
      );
    }

    PwfVisualPreset publishedFor(PwfVisualContext contextKey) {
      final publishedPresetId =
          publishState?.publishedByContext[contextKey.key];
      return publishedPresetId == null
          ? PwfVisualIdentityRegistry.defaultForContext(contextKey)
          : (PwfVisualIdentityRegistry.presetById(publishedPresetId) ??
                PwfVisualIdentityRegistry.defaultForContext(contextKey));
    }

    final effectivePublishedPreset = publishedFor(selectedPreset.context);
    final defaultPreset = PwfVisualIdentityRegistry.defaults.firstWhere(
      (preset) => preset.context == selectedPreset.context,
      orElse: () =>
          PwfVisualIdentityRegistry.defaultForContext(selectedPreset.context),
    );
    final palette = selectedPreset.palette;
    final tokenDiff = _buildVisualTokenDiff(
      selectedPreset,
      effectivePublishedPreset,
    );
    final contrastChecks = _buildContrastChecks(selectedPreset.palette);
    final contrastPass = contrastChecks.every((entry) => entry.passes);
    final publishAllowed =
        approvalChecked && (contrastPass || contrastAcknowledged);
    final decisionSummary = _buildVisualIdentityDecisionSummary(
      candidatePreset: selectedPreset,
      publishedPreset: effectivePublishedPreset,
      defaultPreset: defaultPreset,
      diffEntries: tokenDiff,
      checks: contrastChecks,
      note: note,
      publishState: publishState ?? const PwfVisualIdentityPublishState.empty(),
    );

    void upsertDraft(String statusLabel) {
      final next = {...drafts};
      next[selectedPreset.id] = _VisualIdentityDraftEntry(
        id: selectedPreset.id,
        preset: selectedPreset,
        statusLabel: statusLabel,
        note: note.trim(),
        updatedAt: DateTime.now(),
      );
      ref.read(_visualIdentityDraftsProvider.notifier).state = next;
    }

    Future<void> publishCandidate() async {
      try {
        final next = await ref
            .read(_visualIdentityPublishRepositoryProvider)
            .publishPreset(
              preset: selectedPreset,
              note: note,
              actorLabel: 'بوابة إدارة المنصة',
            );
        PwfVisualIdentityRegistry.applyPublishedMappings(
          next.publishedByContext,
        );
        ref.invalidate(_visualIdentityPublishStateProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم النشر الفعلي للهوية البصرية')),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('تعذر النشر الفعلي: $error')));
        }
      }
    }

    Future<void> rollbackCurrentContext() async {
      try {
        final next = await ref
            .read(_visualIdentityPublishRepositoryProvider)
            .rollbackContext(
              context: selectedPreset.context,
              note: note,
              actorLabel: 'بوابة إدارة المنصة',
            );
        PwfVisualIdentityRegistry.applyPublishedMappings(
          next.publishedByContext,
        );
        ref.invalidate(_visualIdentityPublishStateProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم الرجوع الفعلي للسياق المنشور')),
          );
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('تعذر الرجوع الفعلي: $error')));
        }
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workspace الهوية البصرية السيادية',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'هذه المساحة تغلق الآن دورة الهوية البصرية: مسودة، مرشح، نشر فعلي، رجوع لإصدار محدد، مقارنة ثلاثية، فحص تباين، ومعاينة حية للسياقات الأربعة داخل نفس الصفحة.',
            style: TextStyle(color: Color(0xFF4B5563), height: 1.55),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 320,
                child: DropdownButtonFormField<String>(
                  value: selectedPreset.id,
                  decoration: const InputDecoration(
                    labelText: 'اختيار Preset',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: presets
                      .map(
                        (preset) => DropdownMenuItem<String>(
                          value: preset.id,
                          child: Text(
                            '${preset.family.labelAr} — ${preset.context.labelAr}',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref
                              .read(
                                _visualIdentitySelectedPresetProvider.notifier,
                              )
                              .state =
                          value;
                      ref
                              .read(
                                _visualIdentityPublishApprovalProvider.notifier,
                              )
                              .state =
                          false;
                      ref
                              .read(
                                _visualIdentityContrastAcknowledgedProvider
                                    .notifier,
                              )
                              .state =
                          false;
                    }
                  },
                ),
              ),
              SizedBox(
                width: 420,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'ملاحظة المسودة / قرار النشر',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  controller: TextEditingController(text: note)
                    ..selection = TextSelection.collapsed(offset: note.length),
                  onChanged: (value) =>
                      ref
                              .read(_visualIdentityDraftNoteProvider.notifier)
                              .state =
                          value,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _VisualIdentityMetricCard(
                  title: 'العائلة',
                  value: selectedPreset.family.labelAr,
                  icon: Icons.palette_outlined,
                  accent: palette.primary,
                ),
                _VisualIdentityMetricCard(
                  title: 'السياق',
                  value: selectedPreset.context.labelAr,
                  icon: Icons.layers_outlined,
                  accent: palette.secondary,
                ),
                _VisualIdentityMetricCard(
                  title: 'الكثافة',
                  value: selectedPreset.density.labelAr,
                  icon: Icons.view_compact_alt_outlined,
                  accent: palette.royalRed,
                ),
                _VisualIdentityMetricCard(
                  title: 'حالة المسودة',
                  value: selectedDraft?.statusLabel ?? 'لا توجد مسودة',
                  icon: Icons.rule_folder_outlined,
                  accent: palette.textPrimary,
                ),
                _VisualIdentityMetricCard(
                  title: 'المنشور فعليًا',
                  value: effectivePublishedPreset.family.labelAr,
                  icon: Icons.verified_outlined,
                  accent: effectivePublishedPreset.palette.primary,
                ),
                _VisualIdentityMetricCard(
                  title: 'الافتراضي المرجعي',
                  value: defaultPreset.family.labelAr,
                  icon: Icons.bookmark_outline,
                  accent: defaultPreset.palette.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _VisualIdentityRuntimePreviewGrid(
            selectedPreset: selectedPreset,
            publishState:
                publishState ?? const PwfVisualIdentityPublishState.empty(),
          ),
          const SizedBox(height: 12),
          _VisualIdentityComparisonCard(
            candidatePreset: selectedPreset,
            publishedPreset: effectivePublishedPreset,
            draft: selectedDraft,
          ),
          const SizedBox(height: 12),
          _VisualIdentityDiffBreakdownCard(
            candidatePreset: selectedPreset,
            publishedPreset: effectivePublishedPreset,
            diffEntries: tokenDiff,
          ),
          const SizedBox(height: 12),
          _VisualIdentityGovernanceCard(
            checks: contrastChecks,
            approvalChecked: approvalChecked,
            contrastAcknowledged: contrastAcknowledged,
            onApprovalChanged: (value) =>
                ref
                        .read(_visualIdentityPublishApprovalProvider.notifier)
                        .state =
                    value,
            onContrastAcknowledgedChanged: (value) =>
                ref
                        .read(
                          _visualIdentityContrastAcknowledgedProvider.notifier,
                        )
                        .state =
                    value,
          ),
          const SizedBox(height: 12),
          const _VisualIdentityDocsBridgeCard(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => upsertDraft('مسودة'),
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text('حفظ كمسودة'),
              ),
              OutlinedButton.icon(
                onPressed: () => upsertDraft('مرشح للنشر'),
                icon: const Icon(Icons.publish_outlined),
                label: const Text('رفع كمرشح للنشر'),
              ),
              FilledButton.icon(
                onPressed: publishAllowed ? publishCandidate : null,
                icon: const Icon(Icons.publish_outlined),
                label: const Text('نشر فعلي'),
              ),
              OutlinedButton.icon(
                onPressed: rollbackCurrentContext,
                icon: const Icon(Icons.restore_page_outlined),
                label: const Text('رجوع فعلي'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: selectedPreset.id),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم نسخ معرف الـ preset')),
                    );
                  }
                },
                icon: const Icon(Icons.copy_outlined),
                label: const Text('نسخ المعرّف'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: decisionSummary));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم نسخ تقرير قرار الهوية البصرية'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.article_outlined),
                label: const Text('نسخ تقرير القرار'),
              ),
              OutlinedButton.icon(
                onPressed: selectedDraft == null
                    ? null
                    : () {
                        final next = {...drafts};
                        next.remove(selectedPreset.id);
                        ref.read(_visualIdentityDraftsProvider.notifier).state =
                            next;
                      },
                icon: const Icon(Icons.restore_outlined),
                label: const Text('حذف المسودة المحلية'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          publishStateAsync.when(
            data: (publishedState) {
              final history = publishedState
                  .historyForContext(selectedPreset.context.key)
                  .reversed
                  .take(10)
                  .toList(growable: false);
              return _VisualIdentityHistoryCard(
                selectedPreset: selectedPreset,
                history: history,
                onRollbackToVersion: (presetId) async {
                  try {
                    final next = await ref
                        .read(_visualIdentityPublishRepositoryProvider)
                        .rollbackContextToPreset(
                          context: selectedPreset.context,
                          presetId: presetId,
                          note: note,
                          actorLabel: 'بوابة إدارة المنصة',
                        );
                    PwfVisualIdentityRegistry.applyPublishedMappings(
                      next.publishedByContext,
                    );
                    ref.invalidate(_visualIdentityPublishStateProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تم الرجوع إلى الإصدار المحدد لهذا السياق',
                          ),
                        ),
                      );
                    }
                  } catch (error) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تعذر الرجوع إلى الإصدار المحدد: $error',
                          ),
                        ),
                      );
                    }
                  }
                },
              );
            },
            loading: () => const LinearProgressIndicator(minHeight: 2),
            error: (_, __) => const Text(
              'تعذر تحميل سجل النشر الفعلي حاليًا.',
              style: TextStyle(color: Color(0xFFB22222)),
            ),
          ),
          const SizedBox(height: 12),
          if (drafts.isNotEmpty) ...[
            const Text(
              'المسودات الحالية',
              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: drafts.values.map((entry) {
                final entryPalette = entry.preset.palette;
                return Container(
                  width: 300,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: entryPalette.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: entryPalette.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${entry.preset.family.labelAr} — ${entry.preset.context.labelAr}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: entryPalette.primary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: entryPalette.primary.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              entry.statusLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: entryPalette.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.note.trim().isEmpty
                            ? 'لا توجد ملاحظة محفوظة.'
                            : entry.note,
                        style: const TextStyle(
                          color: Color(0xFF4B5563),
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'آخر تحديث: ${entry.updatedAt.toLocal()}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _IdentityColorDot extends StatelessWidget {
  const _IdentityColorDot(this.color);
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _VisualIdentityComparisonCard extends StatelessWidget {
  const _VisualIdentityComparisonCard({
    required this.candidatePreset,
    required this.publishedPreset,
    required this.draft,
  });

  final PwfVisualPreset candidatePreset;
  final PwfVisualPreset publishedPreset;
  final _VisualIdentityDraftEntry? draft;

  @override
  Widget build(BuildContext context) {
    final candidate = candidatePreset.palette;
    final published = publishedPreset.palette;
    final isSamePreset = candidatePreset.id == publishedPreset.id;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.compare_arrows_outlined, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'مقارنة المسودة/المرشح مع الحالة المنشورة',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSamePreset
                      ? const Color(0xFFECFDF3)
                      : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSamePreset
                        ? const Color(0xFFB7E4C7)
                        : const Color(0xFFF5D0A9),
                  ),
                ),
                child: Text(
                  isSamePreset
                      ? 'لا يوجد اختلاف فعلي'
                      : 'يوجد اختلاف قبل النشر',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSamePreset
                        ? const Color(0xFF1D7A46)
                        : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            draft == null
                ? 'أنت تقارن الـ preset المختار بالحالة المنشورة فعليًا لهذا السياق.'
                : 'أنت تقارن ${draft!.statusLabel} الحالية بالحالة المنشورة فعليًا قبل اتخاذ قرار النشر أو الرجوع.',
            style: const TextStyle(color: Color(0xFF4B5563), height: 1.5),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _VisualPresetComparisonPane(
                title: 'المرشح الحالي',
                preset: candidatePreset,
                badgeColor: candidate.primary,
                badgeLabel: draft?.statusLabel ?? 'المحدد الحالي',
              ),
              _VisualPresetComparisonPane(
                title: 'المنشور فعليًا',
                preset: publishedPreset,
                badgeColor: published.primary,
                badgeLabel: 'الحالة الفعلية',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VisualPresetComparisonPane extends StatelessWidget {
  const _VisualPresetComparisonPane({
    required this.title,
    required this.preset,
    required this.badgeColor,
    required this.badgeLabel,
  });

  final String title;
  final PwfVisualPreset preset;
  final Color badgeColor;
  final String badgeLabel;

  @override
  Widget build(BuildContext context) {
    final palette = preset.palette;
    return Container(
      width: 360,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: palette.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${preset.family.labelAr} — ${preset.context.labelAr}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: palette.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'الكثافة: ${preset.density.labelAr}',
            style: TextStyle(color: palette.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            preset.descriptionAr,
            style: TextStyle(color: palette.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ColorSwatchChip(label: 'Primary', color: palette.primary),
              _ColorSwatchChip(label: 'Hover', color: palette.primaryHover),
              _ColorSwatchChip(label: 'Gold', color: palette.secondary),
              _ColorSwatchChip(label: 'Red', color: palette.royalRed),
              _ColorSwatchChip(
                label: 'Surface',
                color: palette.surface,
                bordered: true,
              ),
              _ColorSwatchChip(
                label: 'BG',
                color: palette.background,
                bordered: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ColorSwatchChip extends StatelessWidget {
  const _ColorSwatchChip({
    required this.label,
    required this.color,
    this.bordered = false,
  });

  final String label;
  final Color color;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: bordered
              ? const Color(0xFFD1D5DB)
              : color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
              border: bordered
                  ? Border.all(color: const Color(0xFF9CA3AF))
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _VisualIdentityMetricCard extends StatelessWidget {
  const _VisualIdentityMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisualFamilyContextCard extends StatelessWidget {
  const _VisualFamilyContextCard({required this.family, required this.presets});

  final PwfVisualFamily family;
  final List<PwfVisualPreset> presets;

  @override
  Widget build(BuildContext context) {
    final palette = presets.isNotEmpty
        ? presets.first.palette
        : PwfVisualIdentityRegistry.defaultForContext(
            PwfVisualContext.platformHome,
          ).palette;

    return Container(
      width: 320,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  family.labelAr,
                  style: TextStyle(
                    color: palette.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IdentityColorDot(palette.primary),
                  const SizedBox(width: 6),
                  _IdentityColorDot(palette.secondary),
                  const SizedBox(width: 6),
                  _IdentityColorDot(palette.royalRed),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...PwfVisualContext.values.map((contextItem) {
            final exists = presets.any((item) => item.context == contextItem);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      contextItem.labelAr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (exists ? palette.primary : const Color(0xFF9CA3AF))
                              .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color:
                            (exists ? palette.primary : const Color(0xFF9CA3AF))
                                .withValues(alpha: 0.18),
                      ),
                    ),
                    child: Text(
                      exists ? 'مفعل' : 'غير مُعد',
                      style: TextStyle(
                        color: exists
                            ? palette.primary
                            : const Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _AdminGovernanceExecutionCard extends StatelessWidget {
  const _AdminGovernanceExecutionCard();

  @override
  Widget build(BuildContext context) {
    final closureItems = PwfAdminGovernanceContract.unitPagesClosureChecklist;
    final profiles = PwfAdminGovernanceContract.pageManagerProfiles;
    final audits = PwfAdminGovernanceContract.auditVerificationItems;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F6B45).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF1F6B45).withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'مرجع مدراء الصفحات + Unit Pages + Audit',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'أُدخل المرجع المدمج داخل docs/admin، وأصبح لدينا عقد تنفيذي أولي يحدد إغلاق Unit Pages، ومصفوفة صلاحيات مدراء الصفحات، ومحاور التحقق من الأوديت.',
            style: TextStyle(color: Color(0xFF374151), height: 1.6),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildInfoBadge(
                'مسار المرجع',
                'docs/admin',
                const Color(0xFF0F4C81),
              ),
              _buildInfoBadge(
                'صلاحيات تشغيلية',
                '${profiles.length}',
                const Color(0xFF7A1F2B),
              ),
              _buildInfoBadge(
                'محاور Audit',
                '${audits.length}',
                const Color(0xFF1F6B45),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'إغلاق Unit Pages',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ...closureItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildChecklistItem(
                context,
                title: item.title,
                description: item.description,
                status: item.status,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'مصفوفة مدراء الصفحات',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ...profiles.map(
            (profile) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildRoleCard(context, profile),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تحقق الأوديت',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ...audits.map(
            (audit) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildAuditCard(context, audit),
            ),
          ),
          const SizedBox(height: 12),
          SelectableText(
            'docs: ${PwfAdminGovernanceContract.mergedDocPath}',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(
    BuildContext context, {
    required String title,
    required String description,
    required PwfGovernanceStatus status,
  }) {
    final color = status.color;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.fact_check_outlined, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: color.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Text(
                        status.labelAr,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF374151),
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context,
    PwfPageManagerPermissionProfile profile,
  ) {
    final color = profile.role == PwfPageManagerRole.superuser
        ? const Color(0xFF7A1F2B)
        : const Color(0xFF0F4C81);
    Widget chip(String label, bool enabled) {
      final chipColor = enabled
          ? const Color(0xFF1D7A46)
          : const Color(0xFF9CA3AF);
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: chipColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: chipColor.withValues(alpha: 0.18)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: chipColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            profile.role.labelAr,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            profile.role.summaryAr,
            style: const TextStyle(color: Color(0xFF374151), height: 1.5),
          ),
          const SizedBox(height: 8),
          Text(
            'النطاق: ${profile.scopeAr}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              chip('عرض', profile.canView),
              chip('تعديل', profile.canEdit),
              chip('نشر', profile.canPublish),
              chip('حذف', profile.canDelete),
              chip('Audit', profile.canAudit),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuditCard(BuildContext context, PwfAuditVerificationItem audit) {
    final color = audit.status.color;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  audit.domain,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withValues(alpha: 0.18)),
                ),
                child: Text(
                  audit.status.labelAr,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: audit.requiredFields
                .map(
                  (field) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F4C81).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFF0F4C81).withValues(alpha: 0.14),
                      ),
                    ),
                    child: Text(
                      field,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          Text(
            audit.notes,
            style: const TextStyle(color: Color(0xFF374151), height: 1.55),
          ),
        ],
      ),
    );
  }
}

class _VisualIdentityRuntimePreviewGrid extends StatelessWidget {
  const _VisualIdentityRuntimePreviewGrid({
    required this.selectedPreset,
    required this.publishState,
  });

  final PwfVisualPreset selectedPreset;
  final PwfVisualIdentityPublishState publishState;

  @override
  Widget build(BuildContext context) {
    final contexts = PwfVisualContext.values;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.preview_outlined, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'معاينة حية للسياقات الأربعة',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'تعرض كل سياق مع الافتراضي والمنشور والمرشح الجاري إن كان السياق نفسه هو المختار حاليًا، حتى تصبح المراجعة أكثر واقعية قبل النشر.',
            style: TextStyle(color: Color(0xFF4B5563), height: 1.5),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: contexts.map((ctx) {
              final publishedPreset =
                  PwfVisualIdentityRegistry.resolvePublishedPreset(
                    context: ctx,
                    publishedByContext: publishState.publishedByContext,
                  );
              final defaultPreset = PwfVisualIdentityRegistry.defaultForContext(
                ctx,
              );
              final candidate = selectedPreset.context == ctx
                  ? selectedPreset
                  : publishedPreset;
              return Container(
                width: 340,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ctx.labelAr,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                        if (selectedPreset.context == ctx)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F0FE),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'مرشح نشط',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F4C81),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ColorSwatchChip(
                          label: 'مرشح',
                          color: candidate.palette.primary,
                          bordered: true,
                        ),
                        _ColorSwatchChip(
                          label: 'منشور',
                          color: publishedPreset.palette.primary,
                          bordered: true,
                        ),
                        _ColorSwatchChip(
                          label: 'افتراضي',
                          color: defaultPreset.palette.primary,
                          bordered: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'العائلة المرشحة/الفعالة: ${candidate.family.labelAr}',
                      style: const TextStyle(color: Color(0xFF4B5563)),
                    ),
                    const SizedBox(height: 8),
                    _VisualIdentityPreviewPane(
                      title: 'معاينة ${ctx.key}',
                      preset: candidate,
                      badge: selectedPreset.context == ctx ? 'مرشح' : 'فعّال',
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _VisualIdentityPreviewPane extends StatelessWidget {
  const _VisualIdentityPreviewPane({
    required this.title,
    required this.preset,
    required this.badge,
  });

  final String title;
  final PwfVisualPreset preset;
  final String badge;

  @override
  Widget build(BuildContext context) {
    final palette = preset.palette;
    return Container(
      width: 320,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: palette.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: palette.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${preset.family.labelAr} — ${preset.context.labelAr}',
            style: TextStyle(color: palette.textSecondary, fontSize: 12.5),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'عنوان رئيسي',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'نص وصفي قصير يوضح شكل المعاينة داخل هذا السياق.',
                  style: TextStyle(color: palette.textSecondary, height: 1.45),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {},
                      child: const Text('إجراء أساسي'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: palette.primary,
                        side: BorderSide(color: palette.border),
                      ),
                      onPressed: () {},
                      child: const Text('إجراء ثانوي'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.table_rows_outlined,
                        color: palette.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'بطاقة/جدول/نموذج تجريبي',
                          style: TextStyle(color: palette.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VisualIdentityDiffBreakdownCard extends StatelessWidget {
  const _VisualIdentityDiffBreakdownCard({
    required this.candidatePreset,
    required this.publishedPreset,
    required this.diffEntries,
  });

  final PwfVisualPreset candidatePreset;
  final PwfVisualPreset publishedPreset;
  final List<_VisualTokenDiffEntry> diffEntries;

  @override
  Widget build(BuildContext context) {
    final changed = diffEntries.where((e) => e.changed).toList(growable: false);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_mosaic_outlined, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Diff بصري أعمق قبل النشر',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: changed.isEmpty
                      ? const Color(0xFFECFDF3)
                      : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  changed.isEmpty
                      ? 'لا فروقات مؤثرة'
                      : '${changed.length} توكن متغيّر',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: changed.isEmpty
                        ? const Color(0xFF1D7A46)
                        : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'تُسقَط هذه الفروقات على عناصر مثل الأزرار والبطاقات والجداول والحوارات والنماذج داخل ${candidatePreset.context.labelAr}.',
            style: const TextStyle(color: Color(0xFF4B5563), height: 1.5),
          ),
          const SizedBox(height: 12),
          if (diffEntries.isEmpty)
            const Text('لا توجد فروقات متاحة.')
          else
            ...diffEntries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        entry.label,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    _ColorSwatchChip(
                      label: 'مرشح',
                      color: entry.candidate,
                      bordered: true,
                    ),
                    const SizedBox(width: 8),
                    _ColorSwatchChip(
                      label: 'منشور',
                      color: entry.published,
                      bordered: true,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: entry.changed
                            ? const Color(0xFFFFF7ED)
                            : const Color(0xFFECFDF3),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        entry.changed ? 'Changed' : 'Same',
                        style: TextStyle(
                          color: entry.changed
                              ? const Color(0xFFB45309)
                              : const Color(0xFF1D7A46),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _VisualIdentityGovernanceCard extends StatelessWidget {
  const _VisualIdentityGovernanceCard({
    required this.checks,
    required this.approvalChecked,
    required this.contrastAcknowledged,
    required this.onApprovalChanged,
    required this.onContrastAcknowledgedChanged,
  });

  final List<_VisualContrastCheck> checks;
  final bool approvalChecked;
  final bool contrastAcknowledged;
  final ValueChanged<bool> onApprovalChanged;
  final ValueChanged<bool> onContrastAcknowledgedChanged;

  @override
  Widget build(BuildContext context) {
    final hasWarnings = checks.any((e) => !e.passes);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.policy_outlined, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'الحوكمة المؤسسية قبل النشر',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'راجع نتائج التباين وأكّد المراجعة البصرية قبل اعتماد النشر. عند وجود تحذيرات تباين، يجب الإقرار بها صراحة.',
            style: TextStyle(color: Color(0xFF4B5563), height: 1.5),
          ),
          const SizedBox(height: 12),
          ...checks.map(
            (check) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: check.passes
                    ? const Color(0xFFECFDF3)
                    : const Color(0xFFFFF7ED),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    check.passes
                        ? Icons.check_circle_outline
                        : Icons.warning_amber_rounded,
                    color: check.passes
                        ? const Color(0xFF1D7A46)
                        : const Color(0xFFB45309),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${check.label} — ${check.ratio.toStringAsFixed(2)}:1',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
          CheckboxListTile(
            value: approvalChecked,
            onChanged: (v) => onApprovalChanged(v ?? false),
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'أقرّ أن المرشح تمت مراجعته بصريًا في السياقات الأساسية.',
            ),
          ),
          CheckboxListTile(
            value: contrastAcknowledged,
            onChanged: hasWarnings
                ? (v) => onContrastAcknowledgedChanged(v ?? false)
                : null,
            contentPadding: EdgeInsets.zero,
            title: Text(
              hasWarnings
                  ? 'أقرّ بوجود تحذيرات تباين وأوافق على النشر رغم ذلك.'
                  : 'لا توجد تحذيرات تباين تتطلب إقرارًا إضافيًا.',
            ),
          ),
        ],
      ),
    );
  }
}

class _VisualIdentityConsumptionAuditCard extends StatelessWidget {
  const _VisualIdentityConsumptionAuditCard();

  @override
  Widget build(BuildContext context) {
    const coverage = <Map<String, String>>[
      {'title': 'platform_home', 'desc': 'الصفحة العامة والـ home tokens'},
      {'title': 'unit_pages', 'desc': 'الصفحات الديناميكية للوحدات'},
      {'title': 'system_pages', 'desc': 'صفحات الأنظمة المتصلة بالمنصة'},
      {
        'title': 'admin_internal',
        'desc': 'لوحة التحكم الداخلية والعناصر المشتركة',
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.fact_check_outlined, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'تعميم استهلاك الـ registry والحوكمة البصرية',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'هذه البطاقة توضح السياقات التي يجب أن تستهلك نفس registry عمليًا، وتلفت النظر إلى المناطق التي يجب تدقيقها ضد أي ألوان hardcoded خارج التوكنز.',
            style: TextStyle(color: Color(0xFF4B5563), height: 1.5),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: coverage
                .map(
                  (entry) => Container(
                    width: 250,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry['title']!,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry['desc']!,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF3),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Registry-bound',
                            style: TextStyle(
                              color: Color(0xFF1D7A46),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text(
            'نقاط التدقيق العملية: Admin shell، dashboard، top bar، system headers، dialogs، forms، cards، والجداول التي ما زالت تستخدم ألوانًا محلية بدل التوكنز.',
            style: TextStyle(color: Color(0xFF4B5563), height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _VisualIdentityDocsBridgeCard extends StatelessWidget {
  const _VisualIdentityDocsBridgeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.source_outlined, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ربط الحوكمة البصرية بالوثائق',
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'المرجع التنفيذي المعتمد لهذه المساحة يجب أن يبقى مرتبطًا بالوثيقة المؤسسية داخل docs/visual_identity، حتى لا تتحول الإعدادات الإدارية إلى مسار منفصل عن التوثيق الحاكم.',
          ),
          SizedBox(height: 8),
          SelectableText(
            'docs/visual_identity/PALWAKF_VISUAL_IDENTITY_MASTER_MERGED_V1_1_AR.md',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _VisualIdentityHistoryCard extends StatelessWidget {
  const _VisualIdentityHistoryCard({
    required this.selectedPreset,
    required this.history,
    required this.onRollbackToVersion,
  });

  final PwfVisualPreset selectedPreset;
  final List<PwfVisualIdentityPublishHistoryEntry> history;
  final Future<void> Function(String presetId) onRollbackToVersion;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'سجل إصدارات ${selectedPreset.context.labelAr}',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (history.isEmpty)
            const Text('لا يوجد سجل إصدارات متاح لهذا السياق بعد.')
          else
            ...history.map(
              (entry) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.presetId,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${entry.action} — ${entry.actorLabel}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.note.trim().isEmpty
                                ? 'بدون ملاحظة'
                                : entry.note,
                            style: const TextStyle(color: Color(0xFF4B5563)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => onRollbackToVersion(entry.presetId),
                      icon: const Icon(Icons.restore_page_outlined),
                      label: const Text('الرجوع لهذا الإصدار'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
