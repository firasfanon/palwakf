import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waqf/app/rbac/system_key.dart';
import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/features/platform/home/presentation/widgets/sections/pwf_home_sections_renderer.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/pwf_homepage_sections_manager.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/admin_surface_management_layout.dart';

class SystemSurfacesManagementScreen extends ConsumerStatefulWidget {
  const SystemSurfacesManagementScreen({super.key});

  @override
  ConsumerState<SystemSurfacesManagementScreen> createState() =>
      _SystemSurfacesManagementScreenState();
}

class _SystemSurfacesManagementScreenState
    extends ConsumerState<SystemSurfacesManagementScreen> {
  String _selectedSlug = SystemKey.mustakshif.slug;
  String? _queuedSlug;

  List<SystemKey> get _systems => SystemKey.values
      .where((e) => e != SystemKey.site && e != SystemKey.platformAdmin)
      .toList(growable: false);

  void _queueLoad(
    String slug,
    PwfHomepageSectionsManager manager,
    PwfHomepageSectionsState state,
  ) {
    if (slug.isEmpty) return;
    if (state.unitSlug == slug) return;
    if (state.isLoading) return;
    if (_queuedSlug == slug) return;
    _queuedSlug = slug;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await manager.setUnitSlug(slug);
      if (_queuedSlug == slug) {
        _queuedSlug = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pwfHomepageSectionsManagerProvider);
    final manager = ref.read(pwfHomepageSectionsManagerProvider.notifier);
    final selectedSystem = _systems.firstWhere(
      (e) => e.slug == _selectedSlug,
      orElse: () => SystemKey.mustakshif,
    );
    _queueLoad(_selectedSlug, manager, state);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة واجهات الأنظمة'),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: state.isLoading
                  ? null
                  : () async => manager.setUnitSlug(_selectedSlug),
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
        body: PwfAdminSurfaceSplit(
          controlPanel: _buildLeftPanel(
            context,
            state,
            manager,
            selectedSystem,
          ),
          previewPanel: _buildPreviewPanel(context, state, selectedSystem),
        ),
      ),
    );
  }

  Widget _buildLeftPanel(
    BuildContext context,
    PwfHomepageSectionsState state,
    PwfHomepageSectionsManager manager,
    SystemKey selectedSystem,
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
            'واجهة النظام العامة',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'هذه الشاشة مخصصة لإدارة Hero وBody الخاص بالنظام داخل عقد المنصة، دون خلطها مع واجهات الوحدات أو الصفحة الرئيسية.',
            style: TextStyle(height: 1.55, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedSystem.slug,
            decoration: const InputDecoration(
              labelText: 'النظام الهدف',
              border: OutlineInputBorder(),
            ),
            items: _systems
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.slug,
                    child: Text(item.nameAr, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: (value) async {
              if (value == null || value == _selectedSlug) return;
              setState(() => _selectedSlug = value);
              await manager.setUnitSlug(value);
            },
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

  Widget _buildPreviewPanel(
    BuildContext context,
    PwfHomepageSectionsState state,
    SystemKey selectedSystem,
  ) {
    final waitingSync = state.unitSlug != _selectedSlug || state.isLoading;
    return PwfAdminSurfacePreviewFrame(
      title: 'معاينة واجهة النظام',
      subtitle: 'النظام: ${selectedSystem.nameAr}',
      badge: selectedSystem.slug,
      isLoading: waitingSync,
      dirty: state.isDirty,
      child: PwfHomeSectionsRenderer(
        unitSlug: _selectedSlug,
        sections: state.draft,
      ),
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
