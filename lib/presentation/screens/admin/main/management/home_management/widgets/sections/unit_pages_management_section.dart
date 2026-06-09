import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/core/access/access_provider.dart';
import 'package:waqf/core/admin_governance/page_manager_governance_contract.dart';
import 'package:waqf/presentation/providers/org_units_provider.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/pwf_unit_pages_execution_store.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/pwf_unit_pages_repository.dart';
import 'package:waqf/core/layout/pwf_global_layout_contract.dart';

class PwfUnitPagesManagementSection extends ConsumerStatefulWidget {
  const PwfUnitPagesManagementSection({super.key});

  @override
  ConsumerState<PwfUnitPagesManagementSection> createState() =>
      _PwfUnitPagesManagementSectionState();
}

class _PwfUnitPagesManagementSectionState
    extends ConsumerState<PwfUnitPagesManagementSection> {
  String _search = '';
  bool _showArchived = false;
  bool _publishedOnly = false;
  String? _selectedUnitId;
  String? _hydratedSignature;
  final Set<String> _savingUnitIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(orgUnitsListProvider);
    final accessAsync = ref.watch(accessProfileProvider);
    final rows = ref.watch(pwfUnitPagesExecutionStoreProvider);
    final persistedAsync = ref.watch(pwfUnitPagesPersistedContractsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: unitsAsync.when(
        data: (units) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            ref
                .read(pwfUnitPagesExecutionStoreProvider.notifier)
                .seedFromUnits(units);
          });

          persistedAsync.whenData((persistedRows) {
            final signature = persistedRows
                .map(
                  (row) =>
                      '${row.unitId}|${row.updatedAt?.millisecondsSinceEpoch ?? 0}|${row.allowedSections.join(',')}|${row.isPublished}|${row.isArchived}|${row.visibilityValue}',
                )
                .join('||');
            if (_hydratedSignature == signature) return;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final store = ref.read(
                pwfUnitPagesExecutionStoreProvider.notifier,
              );
              for (final row in persistedRows) {
                store.upsertByUnitId(row);
              }
              setState(() => _hydratedSignature = signature);
            });
          });

          final uniqueRows = _applyFilters(rows, units);
          PwfUnitPageExecutionRow? selected;
          if (_selectedUnitId == null) {
            selected = uniqueRows.isEmpty ? null : uniqueRows.first;
          } else {
            for (final row in uniqueRows) {
              if (row.unitId == _selectedUnitId) {
                selected = row;
                break;
              }
            }
          }
          final access = PwfAdminGovernanceContract.resolveAccessProfile(
            accessAsync.valueOrNull,
            scopeAr: selected == null
                ? 'وزارة / جميع الصفحات الديناميكية'
                : 'الوحدة: ${selected.unitNameAr}',
          );

          return LayoutBuilder(
            builder: (context, constraints) {
              final width =
                  constraints.hasBoundedWidth && constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : MediaQuery.sizeOf(context).width;
              final height =
                  constraints.hasBoundedHeight && constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : MediaQuery.sizeOf(context).height;
              final sidebar = _buildSidebar(
                context: context,
                rows: uniqueRows,
                access: access,
              );
              final mainPane = _buildMainPane(
                context: context,
                rows: uniqueRows,
                selected: selected,
                access: access,
              );

              if (width < 980) {
                return SizedBox(
                  height: height,
                  child: ListView(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 260),
                        child: sidebar,
                      ),
                      const Divider(height: 1),
                      ConstrainedBox(
                        constraints: BoxConstraints(minHeight: height * .72),
                        child: mainPane,
                      ),
                    ],
                  ),
                );
              }

              final sidebarWidth = width <= 1180
                  ? (width * .34).clamp(320.0, 390.0).toDouble()
                  : 430.0;
              return Row(
                children: [
                  SizedBox(width: sidebarWidth, child: sidebar),
                  const VerticalDivider(width: 1),
                  Expanded(child: mainPane),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }

  List<PwfUnitPageExecutionRow> _applyFilters(
    List<PwfUnitPageExecutionRow> rows,
    List<Map<String, dynamic>> units,
  ) {
    final unitIds = units
        .map((e) => (e['id'] ?? '').toString())
        .where((e) => e.isNotEmpty)
        .toSet();
    final normalizedQuery = _search.trim().toLowerCase();

    final filtered =
        rows
            .where((row) {
              if (!unitIds.contains(row.unitId)) return false;
              if (!_showArchived && row.isArchived) return false;
              if (_publishedOnly && !row.isPublished) return false;
              if (normalizedQuery.isEmpty) return true;
              return row.unitNameAr.toLowerCase().contains(normalizedQuery) ||
                  row.slug.toLowerCase().contains(normalizedQuery) ||
                  row.pageTitleAr.toLowerCase().contains(normalizedQuery);
            })
            .toList(growable: false)
          ..sort((a, b) {
            final order = a.displayOrder.compareTo(b.displayOrder);
            if (order != 0) return order;
            return a.unitNameAr.compareTo(b.unitNameAr);
          });

    if (_selectedUnitId != null &&
        filtered.every((row) => row.unitId != _selectedUnitId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(
          () =>
              _selectedUnitId = filtered.isEmpty ? null : filtered.first.unitId,
        );
      });
    }
    return filtered;
  }

  Widget _buildSidebar({
    required BuildContext context,
    required List<PwfUnitPageExecutionRow> rows,
    required PwfResolvedPageManagerAccess access,
  }) {
    final publishedCount = rows.where((e) => e.isPublished).length;
    final archivedCount = rows.where((e) => e.isArchived).length;
    final configuredCount = rows
        .where((e) => e.allowedSections.isNotEmpty)
        .length;
    final actorLabel = access.role.labelAr;

    return Container(
      color: const Color(0xFFF8FAFC),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Unit Pages — إغلاق تشغيلي',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'تم تحويل المرجع إلى Workspace حي داخل إدارة الصفحة الرئيسية: upsert by unit_id، تحرير allowedSections، CRUD ظاهر، وربط مباشر بصلاحيات مدير الصفحة الحالية.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF475569),
                height: 1.55,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StatCard(
                  label: 'الوحدات',
                  value: '${rows.length}',
                  icon: Icons.account_tree_outlined,
                ),
                _StatCard(
                  label: 'منشور',
                  value: '$publishedCount',
                  icon: Icons.public_outlined,
                  color: const Color(0xFF1D7A46),
                ),
                _StatCard(
                  label: 'مؤرشف',
                  value: '$archivedCount',
                  icon: Icons.archive_outlined,
                  color: const Color(0xFFB45309),
                ),
                _StatCard(
                  label: 'مضبوط الأقسام',
                  value: '$configuredCount',
                  icon: Icons.dashboard_customize_outlined,
                  color: const Color(0xFF0F4C81),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _PanelCard(
              title: 'صلاحيات مدير الصفحة الحالية',
              subtitle:
                  'الربط الآن أعمق من المرجع النظري: الشاشة تقرأ الدور الحالي وتحوّله إلى ملف صلاحيات تشغيلي.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _RoleChip(
                        label: access.role.labelAr,
                        color: access.role == PwfPageManagerRole.superuser
                            ? const Color(0xFF7C3AED)
                            : const Color(0xFF0F4C81),
                      ),
                      _RoleChip(
                        label: access.profile.scopeAr,
                        color: const Color(0xFF475569),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _BooleanMatrix(profile: access.profile),
                  const SizedBox(height: 10),
                  Text(
                    'أي حفظ أو أرشفة من هذه الشاشة يوسم حاليًا بالممثل التنفيذي: $actorLabel.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _PanelCard(
              title: 'محاور الإغلاق الحالية',
              subtitle: 'تمت مواءمة هذه الشاشة مع checklist المرجع الداخلي.',
              child: Column(
                children: PwfAdminGovernanceContract.unitPagesClosureChecklist
                    .map(
                      (item) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.check_circle_outline,
                          color: item.status.color,
                          size: 20,
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(item.description),
                        trailing: Text(
                          item.status.labelAr,
                          style: TextStyle(
                            color: item.status.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
            const SizedBox(height: 16),
            _PanelCard(
              title: 'تحقق الأوديت',
              subtitle: 'المطلوب التأكد منه عند كل ربط DB/RPC لاحق.',
              child: Column(
                children: PwfAdminGovernanceContract.auditVerificationItems
                    .map(
                      (item) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.fact_check_outlined,
                          color: item.status.color,
                          size: 20,
                        ),
                        title: Text(
                          item.domain,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(item.requiredFields.join(' • ')),
                        trailing: Text(
                          item.status.labelAr,
                          style: TextStyle(
                            color: item.status.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainPane({
    required BuildContext context,
    required List<PwfUnitPageExecutionRow> rows,
    required PwfUnitPageExecutionRow? selected,
    required PwfResolvedPageManagerAccess access,
  }) {
    final actorLabel = access.role.labelAr;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 320,
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'بحث باسم الوحدة أو slug أو عنوان الصفحة',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _search = value),
                ),
              ),
              FilterChip(
                selected: _publishedOnly,
                label: const Text('المنشور فقط'),
                onSelected: (value) => setState(() => _publishedOnly = value),
              ),
              FilterChip(
                selected: _showArchived,
                label: const Text('إظهار المؤرشف'),
                onSelected: (value) => setState(() => _showArchived = value),
              ),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(orgUnitsListProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('تحديث الوحدات'),
              ),
              FilledButton.icon(
                onPressed: selected == null
                    ? null
                    : () => _openEditDialog(context, selected, access),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('تحرير الصفحة المحددة'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 6,
                  child: _PanelCard(
                    title: 'قائمة صفحات الوحدات',
                    subtitle:
                        'الآن يوجد ربط موضعي فعلي مع public.site_pages + public.homepage_sections عبر Repository تنفيذي، مع بقاء خيار RPC السيادي مفتوحًا لاحقًا.',
                    child: rows.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'لا توجد وحدات متاحة لعرض صفحاتها بعد.',
                              ),
                            ),
                          )
                        : SizedBox(
                            height: MediaQuery.of(context).size.height - 260,
                            child: ListView.builder(
                              itemCount: rows.length,
                              itemBuilder: (context, index) {
                                final row = rows[index];
                                return _UnitPageRowCard(
                                  row: row,
                                  isSelected: selected?.unitId == row.unitId,
                                  onTap: () => setState(
                                    () => _selectedUnitId = row.unitId,
                                  ),
                                  onEdit: access.profile.canEdit
                                      ? () => _openEditDialog(
                                          context,
                                          row,
                                          access,
                                        )
                                      : null,
                                  onTogglePublish: access.profile.canPublish
                                      ? (value) {
                                          _persistRow(
                                            row.copyWith(
                                              isPublished: value,
                                              updatedAt: DateTime.now(),
                                              updatedByLabel: actorLabel,
                                            ),
                                            actorLabel: actorLabel,
                                            successMessage: value
                                                ? 'تم نشر صفحة الوحدة وحفظ العقد التشغيلي.'
                                                : 'تم إلغاء نشر صفحة الوحدة وحفظ العقد التشغيلي.',
                                          );
                                        }
                                      : null,
                                  onArchive: access.profile.canDelete
                                      ? () {
                                          _persistRow(
                                            row.copyWith(
                                              isArchived: !row.isArchived,
                                              updatedAt: DateTime.now(),
                                              updatedByLabel: actorLabel,
                                            ),
                                            actorLabel: actorLabel,
                                            successMessage: row.isArchived
                                                ? 'تم استرجاع صفحة الوحدة وحفظ العقد التشغيلي.'
                                                : 'تمت أرشفة صفحة الوحدة وحفظ العقد التشغيلي.',
                                          );
                                        }
                                      : null,
                                );
                              },
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 4,
                  child: selected == null
                      ? _PanelCard(
                          title: 'تفاصيل الصفحة',
                          subtitle:
                              'اختر صفحة وحدة من القائمة لعرض تفاصيلها وحالتها التشغيلية.',
                          child: const SizedBox(
                            height: 280,
                            child: Center(
                              child: Text('لم يتم اختيار صفحة بعد.'),
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          child: _UnitPageDetailCard(
                            row: selected,
                            access: access,
                            onEdit: access.profile.canEdit
                                ? () =>
                                      _openEditDialog(context, selected, access)
                                : null,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openEditDialog(
    BuildContext context,
    PwfUnitPageExecutionRow row,
    PwfResolvedPageManagerAccess access,
  ) async {
    final saved = await showDialog<PwfUnitPageExecutionRow>(
      context: context,
      builder: (_) =>
          _UnitPageEditDialog(initial: row, actorLabel: access.role.labelAr),
    );
    if (saved == null) return;
    await _persistRow(
      saved,
      actorLabel: access.role.labelAr,
      successMessage:
          'تم حفظ صفحة الوحدة وربط allowedSections بالمسار التشغيلي.',
    );
    if (mounted) {
      setState(() => _selectedUnitId = saved.unitId);
    }
  }

  PwfUnitPageExecutionRow? _findCurrentRow(String unitId) {
    try {
      return ref
          .read(pwfUnitPagesExecutionStoreProvider)
          .firstWhere((row) => row.unitId == unitId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistRow(
    PwfUnitPageExecutionRow draft, {
    required String actorLabel,
    required String successMessage,
  }) async {
    if (_savingUnitIds.contains(draft.unitId)) return;
    final previous = _findCurrentRow(draft.unitId);
    setState(() => _savingUnitIds.add(draft.unitId));
    ref.read(pwfUnitPagesExecutionStoreProvider.notifier).upsertByUnitId(draft);
    try {
      final saved = await ref
          .read(pwfUnitPagesRepositoryProvider)
          .saveContract(draft, actorLabel: actorLabel);
      ref
          .read(pwfUnitPagesExecutionStoreProvider.notifier)
          .upsertByUnitId(saved);
      ref.invalidate(pwfUnitPagesPersistedContractsProvider);
      ref.invalidate(homepageSectionsForUnitProvider(saved.slug));
      if (saved.slug == 'home') {
        ref.invalidate(allHomepageSectionsProvider);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } catch (error) {
      if (previous != null) {
        ref
            .read(pwfUnitPagesExecutionStoreProvider.notifier)
            .upsertByUnitId(previous);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر حفظ صفحة الوحدة: $error')));
    } finally {
      if (mounted) {
        setState(() => _savingUnitIds.remove(draft.unitId));
      } else {
        _savingUnitIds.remove(draft.unitId);
      }
    }
  }
}

class _UnitPageRowCard extends StatelessWidget {
  const _UnitPageRowCard({
    required this.row,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    required this.onTogglePublish,
    required this.onArchive,
  });

  final PwfUnitPageExecutionRow row;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final ValueChanged<bool>? onTogglePublish;
  final VoidCallback? onArchive;

  @override
  Widget build(BuildContext context) {
    final cardColor = isSelected ? const Color(0xFFE8F1FB) : Colors.white;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? const Color(0xFF0F4C81) : const Color(0xFFE2E8F0),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth.isFinite
                      ? constraints.maxWidth
                      : 320.0;
                  final compactHeader =
                      availableWidth <
                      PwfGlobalLayoutContract.compactBreakpoint;
                  final titleBlock = ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: compactHeader
                          ? availableWidth.clamp(96.0, 320.0).toDouble()
                          : (availableWidth - 132)
                                .clamp(140.0, 520.0)
                                .toDouble(),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          row.unitNameAr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          row.slug,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  );
                  final chips = Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _RoleChip(
                        label: row.visibility.labelAr,
                        color:
                            row.visibility == PwfUnitPageVisibilityMode.public
                            ? const Color(0xFF0F4C81)
                            : const Color(0xFF475569),
                      ),
                      _RoleChip(
                        label: row.isPublished ? 'منشور' : 'مسودة',
                        color: row.isPublished
                            ? const Color(0xFF1D7A46)
                            : const Color(0xFFB45309),
                      ),
                    ],
                  );

                  if (compactHeader) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [titleBlock, const SizedBox(height: 8), chips],
                    );
                  }

                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(child: titleBlock),
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 128),
                        child: chips,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              Text(
                row.pageTitleAr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: row.allowedSections
                    .take(5)
                    .map(
                      (key) => Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(
                          _sectionLabel(key),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 10),
              PwfSafeWrapRow(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('تحرير'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onArchive,
                    icon: Icon(
                      row.isArchived
                          ? Icons.unarchive_outlined
                          : Icons.archive_outlined,
                      size: 18,
                    ),
                    label: Text(row.isArchived ? 'استرجاع' : 'أرشفة'),
                  ),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 128),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('نشر'),
                          Switch(
                            value: row.isPublished,
                            onChanged: onTogglePublish,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnitPageDetailCard extends StatelessWidget {
  const _UnitPageDetailCard({
    required this.row,
    required this.access,
    this.onEdit,
  });

  final PwfUnitPageExecutionRow row;
  final PwfResolvedPageManagerAccess access;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final auditReady =
        row.updatedAt != null && row.updatedByLabel.trim().isNotEmpty;
    return _PanelCard(
      title: 'تفاصيل الصفحة المختارة',
      subtitle:
          'حسم allowedSections + تدقيق الحالة + ربط دور مدير الصفحة الحالي.',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PwfSafeWrapRow(
              spacing: 8,
              runSpacing: 8,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Text(
                    row.unitNameAr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('تحرير'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _DetailBadge(label: 'slug: ${row.slug}'),
                _DetailBadge(label: 'العرض: ${row.visibility.labelAr}'),
                _DetailBadge(
                  label: 'الحالة: ${row.isPublished ? 'منشور' : 'مسودة'}',
                ),
                _DetailBadge(label: 'الترتيب: ${row.displayOrder}'),
                _DetailBadge(label: 'الدور الحالي: ${access.role.labelAr}'),
              ],
            ),
            const SizedBox(height: 16),
            _DetailLine(label: 'عنوان عربي', value: row.pageTitleAr),
            _DetailLine(
              label: 'عنوان إنجليزي',
              value: row.pageTitleEn.isEmpty ? '—' : row.pageTitleEn,
            ),
            _DetailLine(
              label: 'آخر تحديث',
              value: row.updatedAt == null
                  ? 'لم يحفظ بعد'
                  : row.updatedAt.toString(),
            ),
            _DetailLine(
              label: 'آخر منفذ',
              value: row.updatedByLabel.isEmpty
                  ? 'غير محدد'
                  : row.updatedByLabel,
            ),
            const SizedBox(height: 16),
            Text(
              'allowedSections',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: row.allowedSections
                  .map((key) => Chip(label: Text(_sectionLabel(key))))
                  .toList(growable: false),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: auditReady
                    ? const Color(0xFFE8F6EE)
                    : const Color(0xFFFFF7E6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: auditReady
                      ? const Color(0xFFB7E4C7)
                      : const Color(0xFFF5D48C),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    auditReady
                        ? Icons.verified_outlined
                        : Icons.pending_actions_outlined,
                    color: auditReady
                        ? const Color(0xFF1D7A46)
                        : const Color(0xFFB45309),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      auditReady
                          ? 'هذه الصفحة تملك بصمة تنفيذ أولية صالحة للمراجعة: آخر منفذ + وقت تحديث + allowedSections مضبوطة.'
                          : 'هذه الصفحة ما تزال بحاجة حفظ/تحديث حتى تصبح صالحة للمراجعة من منظور الأوديت.',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnitPageEditDialog extends StatefulWidget {
  const _UnitPageEditDialog({required this.initial, required this.actorLabel});

  final PwfUnitPageExecutionRow initial;
  final String actorLabel;

  @override
  State<_UnitPageEditDialog> createState() => _UnitPageEditDialogState();
}

class _UnitPageEditDialogState extends State<_UnitPageEditDialog> {
  late final TextEditingController _titleAr;
  late final TextEditingController _titleEn;
  late final TextEditingController _displayOrder;
  late PwfUnitPageVisibilityMode _visibility;
  late bool _published;
  late final Set<String> _allowedSections;

  @override
  void initState() {
    super.initState();
    _titleAr = TextEditingController(text: widget.initial.pageTitleAr);
    _titleEn = TextEditingController(text: widget.initial.pageTitleEn);
    _displayOrder = TextEditingController(
      text: widget.initial.displayOrder.toString(),
    );
    _visibility = widget.initial.visibility;
    _published = widget.initial.isPublished;
    _allowedSections = widget.initial.allowedSections.toSet();
  }

  @override
  void dispose() {
    _titleAr.dispose();
    _titleEn.dispose();
    _displayOrder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('تحرير صفحة ${widget.initial.unitNameAr}'),
      content: SizedBox(
        width: 720,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleAr,
                decoration: const InputDecoration(
                  labelText: 'العنوان العربي',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _titleEn,
                decoration: const InputDecoration(
                  labelText: 'العنوان الإنجليزي',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<PwfUnitPageVisibilityMode>(
                      value: _visibility,
                      decoration: const InputDecoration(
                        labelText: 'مستوى الظهور',
                        border: OutlineInputBorder(),
                      ),
                      items: PwfUnitPageVisibilityMode.values
                          .map(
                            (mode) => DropdownMenuItem(
                              value: mode,
                              child: Text(mode.labelAr),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) => setState(
                        () => _visibility =
                            value ?? PwfUnitPageVisibilityMode.public,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _displayOrder,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'الترتيب',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _published,
                onChanged: (value) => setState(() => _published = value),
                title: const Text('منشورة'),
              ),
              const SizedBox(height: 8),
              Text(
                'allowedSections',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kPwfUnitPageAllowedSectionOptions
                    .map(
                      (item) => FilterChip(
                        selected: _allowedSections.contains(item.key),
                        label: Text(item.labelAr),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _allowedSections.add(item.key);
                            } else {
                              _allowedSections.remove(item.key);
                            }
                          });
                        },
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () {
            final order =
                int.tryParse(_displayOrder.text.trim()) ??
                widget.initial.displayOrder;
            Navigator.pop(
              context,
              widget.initial.copyWith(
                pageTitleAr: _titleAr.text.trim(),
                pageTitleEn: _titleEn.text.trim(),
                visibility: _visibility,
                allowedSections: _allowedSections.toList(growable: false),
                isPublished: _published,
                displayOrder: order,
                updatedAt: DateTime.now(),
                updatedByLabel: widget.actorLabel,
              ),
            );
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}

class _PanelCard extends StatelessWidget {
  const _PanelCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.color = const Color(0xFF0F4C81),
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 182,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _BooleanMatrix extends StatelessWidget {
  const _BooleanMatrix({required this.profile});

  final PwfPageManagerPermissionProfile profile;

  @override
  Widget build(BuildContext context) {
    final entries = <MapEntry<String, bool>>[
      MapEntry('عرض', profile.canView),
      MapEntry('تعديل', profile.canEdit),
      MapEntry('نشر', profile.canPublish),
      MapEntry('حذف/أرشفة', profile.canDelete),
      MapEntry('Audit', profile.canAudit),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: entries
          .map(
            (entry) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: (entry.value
                    ? const Color(0xFFE8F6EE)
                    : const Color(0xFFF8FAFC)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: entry.value
                      ? const Color(0xFFB7E4C7)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    entry.value
                        ? Icons.check_circle_outline
                        : Icons.remove_circle_outline,
                    size: 16,
                    color: entry.value
                        ? const Color(0xFF1D7A46)
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _DetailBadge extends StatelessWidget {
  const _DetailBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(height: 1.5))),
        ],
      ),
    );
  }
}

String _sectionLabel(String key) {
  for (final item in kPwfUnitPageAllowedSectionOptions) {
    if (item.key == key) return item.labelAr;
  }
  return key;
}
