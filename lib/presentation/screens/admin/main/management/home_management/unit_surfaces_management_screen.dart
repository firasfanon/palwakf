import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/features/platform/home/presentation/widgets/sections/pwf_home_sections_renderer.dart';
import 'package:waqf/presentation/providers/org_units_provider.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/pwf_homepage_sections_manager.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/admin_surface_management_layout.dart';

class UnitSurfacesManagementScreen extends ConsumerStatefulWidget {
  const UnitSurfacesManagementScreen({super.key});

  @override
  ConsumerState<UnitSurfacesManagementScreen> createState() =>
      _UnitSurfacesManagementScreenState();
}

class _UnitSurfacesManagementScreenState
    extends ConsumerState<UnitSurfacesManagementScreen> {
  String? _selectedSlug;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pwfHomepageSectionsManagerProvider);
    final manager = ref.read(pwfHomepageSectionsManagerProvider.notifier);
    final unitsAsync = ref.watch(orgUnitsListProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة واجهات الوحدات'),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: state.isLoading || (_selectedSlug ?? '').isEmpty
                  ? null
                  : () async => manager.setUnitSlug(_selectedSlug!),
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: 'تراجع',
              onPressed: state.isDirty && !state.isSaving
                  ? manager.resetDraft
                  : null,
              icon: const Icon(Icons.undo),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: state.isDirty && !state.isSaving ? manager.save : null,
              icon: state.isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('حفظ'),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: unitsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text(error.toString())),
          data: (rows) {
            final units =
                rows
                    .where((row) {
                      final slug = ((row['slug'] ?? '') as String)
                          .trim()
                          .toLowerCase();
                      final unitType = ((row['unit_type'] ?? '') as String)
                          .trim()
                          .toLowerCase();
                      return slug.isNotEmpty &&
                          slug != 'home' &&
                          unitType != 'system';
                    })
                    .map(_UnitSurfaceTarget.fromRow)
                    .toList()
                  ..sort((a, b) {
                    if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
                    return a.label.compareTo(b.label);
                  });

            if (units.isEmpty) {
              return const Center(child: Text('لا توجد وحدات متاحة حالياً.'));
            }

            final selectedTarget = _selectedSlug == null
                ? null
                : units.cast<_UnitSurfaceTarget?>().firstWhere(
                    (e) => e?.slug == _selectedSlug,
                    orElse: () => null,
                  );

            if (selectedTarget == null) {
              return ListView(
                padding: PwfAdminSurfaceLayoutTokens.pagePadding,
                children: [
                  _buildSelectorCard(context, units, selectedTarget, manager),
                  const SizedBox(height: 12),
                  _buildEmptyCard(context),
                ],
              );
            }

            return PwfAdminSurfaceSplit(
              controlPanel: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSelectorCard(context, units, selectedTarget, manager),
                  const SizedBox(height: 12),
                  _buildEditorCard(context, state, manager),
                ],
              ),
              previewPanel: _buildPreviewCard(context, state, selectedTarget),
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
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'اختر الوحدة أولاً، ثم عدّل أقسام واجهتها العامة ومعاينتها قبل الحفظ. هذه الشاشة منفصلة عن Unit Pages التشغيلية القديمة.',
            style: TextStyle(height: 1.55, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedTarget?.slug,
            decoration: const InputDecoration(
              labelText: 'الوحدة الهدف',
              border: OutlineInputBorder(),
            ),
            items: units
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.slug,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 360),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                          if (!item.isActive) ...[
                            const SizedBox(width: 8),
                            const Text(
                              'غير مفعلة',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Color(0xFFB45309),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) async {
              if (value == null || value == _selectedSlug) return;
              setState(() => _selectedSlug = value);
              await manager.setUnitSlug(value);
            },
          ),
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
        child: Text(
          'اختر وحدة من القائمة المنسدلة لعرض وتحرير أقسام واجهتها العامة.',
        ),
      ),
    );
  }

  Widget _buildEditorCard(
    BuildContext context,
    PwfHomepageSectionsState state,
    PwfHomepageSectionsManager manager,
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
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
    final waitingSync =
        state.unitSlug != selectedTarget.slug || state.isLoading;
    return PwfAdminSurfacePreviewFrame(
      title: 'معاينة واجهة الوحدة',
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

class _UnitSurfaceTarget {
  final String slug;
  final String label;
  final bool isActive;

  const _UnitSurfaceTarget({
    required this.slug,
    required this.label,
    required this.isActive,
  });

  factory _UnitSurfaceTarget.fromRow(Map<String, dynamic> row) {
    return _UnitSurfaceTarget(
      slug: (row['slug'] ?? '').toString().trim().toLowerCase(),
      label: (row['name_ar'] ?? row['name_en'] ?? row['slug'] ?? '').toString(),
      isActive: (row['is_active'] ?? true) == true,
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
