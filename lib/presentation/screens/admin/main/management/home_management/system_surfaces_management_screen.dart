import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waqf/core/access/access_provider.dart';

import 'package:waqf/core/enums/system_key.dart';
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
    final accessProfile = ref.watch(accessProfileProvider).valueOrNull;
    final canManageSelectedSystem =
        accessProfile?.canManageSystem(selectedSystem) ?? false;
    final isSuperuser = accessProfile?.hasPlatformRootAuthority ?? false;
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
              onPressed: state.isDirty && !state.isSaving && canManageSelectedSystem
                  ? manager.save
                  : null,
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
            canManageSelectedSystem,
            isSuperuser,
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
    bool canManageSelectedSystem,
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
          const SizedBox(height: 12),
          _SystemSurfaceAuthorityNotice(
            isSuperuser: isSuperuser,
            canManage: canManageSelectedSystem,
            systemNameAr: selectedSystem.nameAr,
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
            canMutate: canManageSelectedSystem,
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

class _SystemSurfaceAuthorityNotice extends StatelessWidget {
  const _SystemSurfaceAuthorityNotice({
    required this.isSuperuser,
    required this.canManage,
    required this.systemNameAr,
  });

  final bool isSuperuser;
  final bool canManage;
  final String systemNameAr;

  @override
  Widget build(BuildContext context) {
    final text = isSuperuser
        ? 'تفويض Super User السيادي فعّال على واجهة $systemNameAr. التفعيل والترتيب والحفظ متاحان من هذه الشاشة؛ التنفيذ النهائي يبقى خاضعًا لعقد RPC الخاص بالنطاق عند وجوده.'
        : canManage
            ? 'لديك تفويض إدارة فعّال على واجهة $systemNameAr ضمن نطاقك الحالي.'
            : 'الوضع للقراءة فقط: لا توجد سلطة إدارة فعّالة لواجهة $systemNameAr.';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSuperuser
            ? const Color(0xFFF5F3FF)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSuperuser
              ? const Color(0xFFC4B5FD)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSuperuser ? Icons.admin_panel_settings_outlined : Icons.policy_outlined,
            color: isSuperuser ? const Color(0xFF6D28D9) : const Color(0xFF475569),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(height: 1.45))),
        ],
      ),
    );
  }
}

class _SectionsEditorList extends StatelessWidget {
  const _SectionsEditorList({
    required this.sections,
    required this.canMutate,
    required this.onToggle,
    required this.onReorder,
  });

  final List<HomepageSection> sections;
  final bool canMutate;
  final void Function(String key, bool value) onToggle;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 760,
      child: ReorderableListView.builder(
        buildDefaultDragHandles: false,
        itemCount: sections.length,
        onReorder: canMutate ? onReorder : (_, __) {},
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
              leading: canMutate
                  ? ReorderableDragStartListener(
                      index: index,
                      child: const Icon(Icons.drag_indicator),
                    )
                  : const Icon(Icons.lock_outline),
              trailing: Switch(
                value: item.isActive,
                onChanged: canMutate
                    ? (value) => onToggle(item.sectionName, value)
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
