import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/core/access/access_provider.dart';
import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/features/platform/home/presentation/widgets/sections/pwf_home_sections_renderer.dart';
import 'package:waqf/features/platform/unit_operations/domain/unit_operational_activation_contract.dart';
import 'package:waqf/features/platform/unit_operations/presentation/providers/unit_operational_activation_providers.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/pwf_homepage_sections_manager.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/pwf_unit_pages_repository.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/admin_surface_management_layout.dart';

/// Canonical editor for owner-runtime public compositions.
///
/// This screen is the only editable surface-composition route. The legacy unit
/// page execution route delegates here so a legacy publication marker cannot
/// diverge from the composition consumed by the public runtime.
class UnitSurfacesManagementScreen extends ConsumerStatefulWidget {
  const UnitSurfacesManagementScreen({super.key, this.initialUnitSlug});

  final String? initialUnitSlug;

  @override
  ConsumerState<UnitSurfacesManagementScreen> createState() =>
      _UnitSurfacesManagementScreenState();
}

class _UnitSurfacesManagementScreenState
    extends ConsumerState<UnitSurfacesManagementScreen> {
  String? _selectedSlug;
  String? _queuedSlug;

  @override
  void initState() {
    super.initState();
    final candidate = widget.initialUnitSlug?.trim().toLowerCase();
    _selectedSlug = candidate == null || candidate.isEmpty ? null : candidate;
  }

  void _queueCompositionLoad(
    String slug,
    PwfHomepageSectionsManager manager,
    PwfHomepageSectionsState state,
  ) {
    if (slug.isEmpty || state.unitSlug == slug || state.isLoading) return;
    if (_queuedSlug == slug) return;
    _queuedSlug = slug;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await manager.setUnitSlug(slug);
      if (_queuedSlug == slug) _queuedSlug = null;
    });
  }

  Future<void> _saveAndReconcile(PwfHomepageSectionsManager manager) async {
    await manager.save();
    if (!mounted) return;
    final latest = ref.read(pwfHomepageSectionsManagerProvider);
    if (latest.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر حفظ مسودة تركيب العرض: ${latest.error}')),
      );
      return;
    }

    final slug = latest.unitSlug.trim().isEmpty
        ? 'home'
        : latest.unitSlug.trim().toLowerCase();
    ref.invalidate(homepageSectionsForUnitProvider(slug));
    ref.invalidate(pwfUnitPagesPersistedContractsProvider);
    ref.invalidate(unitOperationalActivationStatesProvider);
    try {
      await ref.refresh(unitOperationalActivationStatesProvider.future);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم حفظ مسودة تركيب العرض. النشر العام خطوة مستقلة؛ استخدم «نشر التركيب للعامة» بعد مراجعة المعاينة.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حفظ المسودة، لكن تعذرت إعادة قراءة الجاهزية من Runtime: $error',
          ),
        ),
      );
    }
  }

  Future<void> _publishAndReconcile(PwfHomepageSectionsManager manager) async {
    final beforePublish = ref.read(pwfHomepageSectionsManagerProvider);
    if (beforePublish.isDirty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('احفظ مسودة تركيب العرض قبل طلب النشر العام.'),
        ),
      );
      return;
    }

    try {
      final receipt = await manager.publishRuntimeComposition();
      if (!mounted) return;

      final slug = ref.read(pwfHomepageSectionsManagerProvider).unitSlug
          .trim()
          .toLowerCase();
      ref.invalidate(homepageSectionsForUnitProvider(slug));
      ref.invalidate(pwfUnitPagesPersistedContractsProvider);
      ref.invalidate(unitOperationalActivationStatesProvider);

      try {
        final states = await ref.refresh(
          unitOperationalActivationStatesProvider.future,
        );
        final confirmed = states
            .where((state) => state.slug == slug)
            .cast<UnitOperationalActivationState?>()
            .firstWhere((state) => state != null, orElse: () => null);
        final runtimeConfirmed = confirmed != null &&
            confirmed.isSurfacePublished &&
            confirmed.activeSectionCount > 0;
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              runtimeConfirmed
                  ? 'تم نشر تركيب العرض للعامة وتأكيد Runtime بعد القراءة اللاحقة (${receipt.publishedEntryCount} قسمًا منشورًا).'
                  : 'تم استدعاء النشر، لكن قراءة Runtime لم تؤكد الظهور العام بعد. راجع بطاقة الجاهزية وNetwork.',
            ),
          ),
        );
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تنفيذ طلب النشر، لكن تعذر إثبات Runtime بالقراءة اللاحقة: $error',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر نشر تركيب العرض للعامة: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final compositionState = ref.watch(pwfHomepageSectionsManagerProvider);
    final manager = ref.read(pwfHomepageSectionsManagerProvider.notifier);
    final accessProfile = ref.watch(accessProfileProvider).valueOrNull;
    final isSuperuser = accessProfile?.hasPlatformRootAuthority ?? false;
    final activationStatesAsync = ref.watch(unitOperationalActivationStatesProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة واجهات الوحدات'),
          actions: [
            PwfAdminSurfaceAppBarActions(
              actions: [
                PwfAdminSurfaceAppBarAction(
                  label: 'تحديث القراءة التشغيلية',
                  icon: Icons.refresh,
                  onPressed: compositionState.isLoading
                      ? null
                      : () async {
                          if ((_selectedSlug ?? '').isNotEmpty) {
                            await manager.setUnitSlug(_selectedSlug!);
                          }
                          ref.invalidate(unitOperationalActivationStatesProvider);
                        },
                ),
                PwfAdminSurfaceAppBarAction(
                  label: 'تراجع',
                  icon: Icons.undo,
                  onPressed:
                      compositionState.isDirty && !compositionState.isSaving
                      ? manager.resetDraft
                      : null,
                ),
                PwfAdminSurfaceAppBarAction(
                  label: 'حفظ مسودة التركيب',
                  icon: Icons.save_outlined,
                  primary: true,
                  onPressed:
                      compositionState.isDirty && !compositionState.isSaving
                      ? () => _saveAndReconcile(manager)
                      : null,
                ),
                PwfAdminSurfaceAppBarAction(
                  label: 'نشر التركيب للعامة',
                  icon: Icons.publish_rounded,
                  primary: true,
                  onPressed: isSuperuser &&
                          !compositionState.isSaving &&
                          !compositionState.isLoading &&
                          !compositionState.isDirty &&
                          (_selectedSlug ?? '').isNotEmpty
                      ? () => _publishAndReconcile(manager)
                      : null,
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: activationStatesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('تعذر تحميل حالة واجهات الوحدات: $error'),
            ),
          ),
          data: (states) {
            final units = states
                .map(_UnitSurfaceTarget.fromActivationState)
                .toList(growable: false)
              ..sort((a, b) {
                final aHome = a.slug == 'home';
                final bHome = b.slug == 'home';
                if (aHome != bHome) return aHome ? -1 : 1;
                if (a.isPubliclyEligible != b.isPubliclyEligible) {
                  return a.isPubliclyEligible ? -1 : 1;
                }
                return a.label.compareTo(b.label);
              });

            if (units.isEmpty) {
              return const Center(child: Text('لا توجد وحدات قابلة للعرض.'));
            }

            final selectedTarget = _selectedSlug == null
                ? null
                : units.cast<_UnitSurfaceTarget?>().firstWhere(
                      (item) => item?.slug == _selectedSlug,
                      orElse: () => null,
                    );
            if (selectedTarget != null) {
              _queueCompositionLoad(
                selectedTarget.slug,
                manager,
                compositionState,
              );
            }

            if (selectedTarget == null) {
              return ListView(
                padding: PwfAdminSurfaceLayoutTokens.pagePadding,
                children: [
                  _buildSelectorCard(
                    context,
                    units,
                    null,
                    manager,
                    isSuperuser,
                  ),
                  const SizedBox(height: 12),
                  _buildEmptyCard(context),
                ],
              );
            }

            return PwfAdminSurfaceSplit(
              controlPanel: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSelectorCard(
                    context,
                    units,
                    selectedTarget,
                    manager,
                    isSuperuser,
                  ),
                  const SizedBox(height: 12),
                  _buildEditorCard(
                    context,
                    compositionState,
                    manager,
                    selectedTarget,
                  ),
                ],
              ),
              previewPanel: _buildPreviewCard(
                context,
                compositionState,
                selectedTarget,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSelectorCard(
    BuildContext context,
    List<_UnitSurfaceTarget> units,
    _UnitSurfaceTarget? selectedTarget,
    PwfHomepageSectionsManager manager,
    bool isSuperuser,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'إدارة واجهات الوحدات',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'هذه الشاشة هي المرجع التحريري لتركيب العرض العام. لا تعتبر علامة النشر القديمة دليلاً على الظهور العام؛ الجاهزية تقاس من قراءة Runtime بعد الحفظ.',
            style: TextStyle(height: 1.55, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 12),
          if (isSuperuser) const _UnitSurfaceSuperuserNotice(),
          if (isSuperuser) const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedTarget?.slug,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'الوزارة أو الوحدة الهدف',
              border: OutlineInputBorder(),
            ),
            selectedItemBuilder: (context) => units
                .map(
                  (item) => Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                )
                .toList(growable: false),
            items: units
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.slug,
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        '${item.label} — ${item.publicReadinessLabel}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(
                          color: item.isPubliclyEligible
                              ? const Color(0xFF1D7A46)
                              : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (value) async {
              if (value == null || value == _selectedSlug) return;
              setState(() => _selectedSlug = value);
              await manager.setUnitSlug(value);
            },
          ),
          if (selectedTarget != null) ...[
            const SizedBox(height: 12),
            _UnitSurfaceRuntimeStatus(target: selectedTarget),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => context.go(
                  '${AppRoutes.adminUnitOperationalActivation}?unit=${Uri.encodeComponent(selectedTarget.slug)}',
                ),
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('فتح حالة التفعيل والجاهزية'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.all(24),
      child: const Center(
        child: Text('اختر وحدة من القائمة لعرض تركيبها وحالة جاهزيتها العامة.'),
      ),
    );
  }

  Widget _buildEditorCard(
    BuildContext context,
    PwfHomepageSectionsState state,
    PwfHomepageSectionsManager manager,
    _UnitSurfaceTarget selectedTarget,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ترتيب وتفعيل الأقسام',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'الوحدة: ${selectedTarget.label} — الحفظ يكتب مسودة تركيب العرض المملوك للوحدة؛ النشر العام خطوة صريحة منفصلة ثم تُثبت بقراءة Runtime.',
            style: const TextStyle(color: Color(0xFF475569)),
          ),
          const SizedBox(height: 16),
          _SectionsEditorList(
            sections: state.draft,
            onToggle: manager.toggleActive,
            onReorder: manager.reorder,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(
    BuildContext context,
    PwfHomepageSectionsState state,
    _UnitSurfaceTarget selectedTarget,
  ) {
    final waitingSync = state.unitSlug != selectedTarget.slug || state.isLoading;
    return PwfAdminSurfacePreviewFrame(
      title: 'معاينة تركيب العرض',
      subtitle: 'الوحدة: ${selectedTarget.label}',
      badge: selectedTarget.slug,
      isLoading: waitingSync,
      dirty: state.isDirty,
      child: PwfHomeSectionsRenderer(
        unitSlug: selectedTarget.slug,
        sections: state.draft,
      ),
    );
  }
}

class _UnitSurfaceSuperuserNotice extends StatelessWidget {
  const _UnitSurfaceSuperuserNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4B5FD)),
      ),
      child: const Row(
        children: [
          Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF6D28D9)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'تفويض Super User السيادي فعّال. الحفظ يكتب مسودة، ثم يستطيع Super User نشر التركيب للعامة مباشرة دون اشتراط حساب مراجعة أو ناشر منفصل. بطاقة الجاهزية تقرأ Runtime بعد النشر.',
              style: TextStyle(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitSurfaceTarget {
  const _UnitSurfaceTarget({required this.activation});

  final UnitOperationalActivationState activation;

  String get id => activation.unitId;
  String get slug => activation.slug;
  String get label => activation.unitNameAr;
  bool get isPubliclyEligible => activation.isPubliclyEligible;
  String get publicReadinessLabel => activation.publicReadinessLabel;

  factory _UnitSurfaceTarget.fromActivationState(
    UnitOperationalActivationState state,
  ) {
    return _UnitSurfaceTarget(activation: state);
  }
}

class _UnitSurfaceRuntimeStatus extends StatelessWidget {
  const _UnitSurfaceRuntimeStatus({required this.target});

  final _UnitSurfaceTarget target;

  @override
  Widget build(BuildContext context) {
    final state = target.activation;
    final color = state.isPubliclyEligible
        ? const Color(0xFF1D7A46)
        : const Color(0xFFB45309);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .28)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Icon(
            state.isPubliclyEligible
                ? Icons.verified_rounded
                : Icons.pending_actions_rounded,
            color: color,
          ),
          Text(
            state.publicReadinessLabel,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
          _RuntimeChip(label: state.operationalLabel),
          _RuntimeChip(label: state.publicationLabel),
          _RuntimeChip(label: state.runtimeCompositionLabel),
        ],
      ),
    );
  }
}

class _RuntimeChip extends StatelessWidget {
  const _RuntimeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _SectionsEditorList extends StatelessWidget {
  const _SectionsEditorList({
    required this.sections,
    required this.onToggle,
    required this.onReorder,
  });

  final List<HomepageSection> sections;
  final void Function(String key, bool value) onToggle;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 760,
      child: ReorderableListView.builder(
        buildDefaultDragHandles: false,
        itemCount: sections.length,
        onReorder: onReorder,
        itemBuilder: (context, index) {
          final item = sections[index];
          return Card(
            key: ValueKey(item.sectionName),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                item.sectionName,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('الترتيب: ${item.displayOrder}'),
              leading: ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_indicator),
              ),
              trailing: Switch(
                value: item.isActive,
                onChanged: (value) => onToggle(item.sectionName, value),
              ),
            ),
          );
        },
      ),
    );
  }
}
