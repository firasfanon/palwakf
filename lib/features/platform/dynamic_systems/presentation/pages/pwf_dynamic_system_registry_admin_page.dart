import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/pwf_dynamic_system_models.dart';
import '../providers/pwf_dynamic_system_registry_providers.dart';

class PwfDynamicSystemRegistryAdminPage extends ConsumerStatefulWidget {
  const PwfDynamicSystemRegistryAdminPage({super.key});

  @override
  ConsumerState<PwfDynamicSystemRegistryAdminPage> createState() =>
      _PwfDynamicSystemRegistryAdminPageState();
}

class _PwfDynamicSystemRegistryAdminPageState
    extends ConsumerState<PwfDynamicSystemRegistryAdminPage> {
  final _systemKeyController = TextEditingController();
  final _nameArController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController(text: 'systems');
  final _iconController = TextEditingController(text: 'widgets');
  final _routeController = TextEditingController();

  final _sectionSystemKeyController = TextEditingController();
  final _sectionKeyController = TextEditingController();
  final _sectionTitleController = TextEditingController();
  final _sectionDescriptionController = TextEditingController();
  final _sectionPermissionController = TextEditingController(text: 'read');

  PwfDynamicModuleType _moduleType = PwfDynamicModuleType.generic;
  bool _requiresPermission = true;
  bool _showInDashboard = true;
  bool _showInSidebar = true;
  bool _savingSystem = false;
  bool _savingSection = false;

  @override
  void dispose() {
    _systemKeyController.dispose();
    _nameArController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _iconController.dispose();
    _routeController.dispose();
    _sectionSystemKeyController.dispose();
    _sectionKeyController.dispose();
    _sectionTitleController.dispose();
    _sectionDescriptionController.dispose();
    _sectionPermissionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(dynamicSystemAdminCatalogProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildHeader(),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 1100;
              if (compact) {
                return Column(
                  children: [
                    _buildSystemForm(),
                    const SizedBox(height: 16),
                    _buildSectionForm(),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildSystemForm()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSectionForm()),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          _buildCatalog(catalog),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F4C81), Color(0xFF0B1220)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سجل الأنظمة والأقسام الديناميكي',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'إضافة نظام أو خدمة أو قسم جديد من لوحة التحكم. يظهر تلقائيًا للسوبر يوزر وPlatform Admin، ثم يخضع للأدوار والصلاحيات الديناميكية.',
            style: TextStyle(color: Color(0xFFD7E3F6), height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemForm() {
    return _RegistryCard(
      title: 'إضافة / تحديث نظام أو خدمة',
      subtitle:
          'يحفظ في platform.system_registry. الأنظمة generic تظهر عبر /admin/systems/:systemKey.',
      child: Column(
        children: [
          _Field(
            controller: _systemKeyController,
            label: 'system_key',
            hint: 'training_center',
          ),
          _Field(
            controller: _nameArController,
            label: 'الاسم العربي',
            hint: 'مركز التدريب',
          ),
          _Field(
            controller: _descriptionController,
            label: 'الوصف',
            hint: 'نظام تدريبي ديناميكي داخل المنصة',
            maxLines: 2,
          ),
          Row(
            children: [
              Expanded(
                child: _Field(
                  controller: _categoryController,
                  label: 'category_key',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Field(controller: _iconController, label: 'icon_key'),
              ),
            ],
          ),
          _Field(
            controller: _routeController,
            label: 'admin_route_path اختياري',
            hint: '/admin/systems/training_center',
          ),
          DropdownButtonFormField<PwfDynamicModuleType>(
            value: _moduleType,
            decoration: const InputDecoration(labelText: 'نوع الموديول'),
            items: PwfDynamicModuleType.values
                .map(
                  (type) =>
                      DropdownMenuItem(value: type, child: Text(type.labelAr)),
                )
                .toList(growable: false),
            onChanged: (value) => setState(
              () => _moduleType = value ?? PwfDynamicModuleType.generic,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('يحتاج صلاحية'),
                selected: _requiresPermission,
                onSelected: (v) => setState(() => _requiresPermission = v),
              ),
              FilterChip(
                label: const Text('يظهر في Dashboard'),
                selected: _showInDashboard,
                onSelected: (v) => setState(() => _showInDashboard = v),
              ),
              FilterChip(
                label: const Text('يظهر في Sidebar'),
                selected: _showInSidebar,
                onSelected: (v) => setState(() => _showInSidebar = v),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _savingSystem ? null : _saveSystem,
              icon: _savingSystem
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_rounded),
              label: const Text('حفظ النظام'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionForm() {
    return _RegistryCard(
      title: 'إضافة / تحديث قسم داخل نظام',
      subtitle:
          'يحفظ في platform.system_sections. أي قسم جديد يظهر تلقائيًا داخل النظام إذا سمحت الصلاحيات.',
      child: Column(
        children: [
          _Field(
            controller: _sectionSystemKeyController,
            label: 'system_key',
            hint: 'training_center',
          ),
          _Field(
            controller: _sectionKeyController,
            label: 'section_key',
            hint: 'requests',
          ),
          _Field(
            controller: _sectionTitleController,
            label: 'عنوان القسم',
            hint: 'طلبات التدريب',
          ),
          _Field(
            controller: _sectionDescriptionController,
            label: 'الوصف',
            maxLines: 2,
          ),
          _Field(
            controller: _sectionPermissionController,
            label: 'required_permission_key',
            hint: 'read',
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _savingSection ? null : _saveSection,
              icon: _savingSection
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_box_rounded),
              label: const Text('حفظ القسم'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatalog(AsyncValue<List<PwfDynamicSystemModule>> catalog) {
    return catalog.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => const _RegistryCard(
        title: 'السجل غير مثبت بعد',
        subtitle:
            'شغّل SQL الخاص بـ N2.10 لإنشاء platform.system_registry و platform.system_sections وRPC wrappers.',
        child: SizedBox.shrink(),
      ),
      data: (systems) {
        if (systems.isEmpty) {
          return const _RegistryCard(
            title: 'لا توجد أنظمة ديناميكية بعد',
            subtitle: 'ابدأ بإضافة نظام جديد أو شغّل seed الافتراضي من SQL.',
            child: SizedBox.shrink(),
          );
        }
        return _RegistryCard(
          title: 'الأنظمة المسجلة',
          subtitle: 'تظهر هذه العناصر في السايدبار والداشبورد حسب الصلاحيات.',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final system in systems)
                Container(
                  width: 320,
                  padding: const EdgeInsets.all(14),
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
                          Icon(system.icon, color: const Color(0xFF0F4C81)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              system.nameAr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        system.systemKey,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          Chip(label: Text(system.moduleType.labelAr)),
                          Chip(label: Text('${system.sections.length} قسم')),
                          if (system.showInSidebar)
                            const Chip(label: Text('Sidebar')),
                          if (system.showInDashboard)
                            const Chip(label: Text('Dashboard')),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveSystem() async {
    final key = _systemKeyController.text.trim();
    final name = _nameArController.text.trim();
    if (key.isEmpty || name.isEmpty) {
      _showMessage('system_key والاسم العربي مطلوبان.', isError: true);
      return;
    }
    setState(() => _savingSystem = true);
    try {
      final route = _routeController.text.trim().isEmpty
          ? '/admin/systems/$key'
          : _routeController.text.trim();
      final system = PwfDynamicSystemModule(
        systemKey: key,
        nameAr: name,
        nameEn: null,
        descriptionAr: _descriptionController.text.trim(),
        categoryKey: _categoryController.text.trim().isEmpty
            ? 'systems'
            : _categoryController.text.trim(),
        moduleType: _moduleType,
        adminRoutePath: route,
        publicRoutePath: null,
        externalUrl: null,
        iconKey: _iconController.text.trim().isEmpty
            ? 'widgets'
            : _iconController.text.trim(),
        displayOrder: 100,
        isActive: true,
        showInDashboard: _showInDashboard,
        showInSidebar: _showInSidebar,
        requiresPermission: _requiresPermission,
        isSovereign: false,
        metadata: const <String, dynamic>{'source': 'admin_ui_n2_10'},
        sections: const <PwfDynamicSystemSection>[],
      );
      await ref
          .read(pwfDynamicSystemRegistryRepositoryProvider)
          .upsertSystem(system);
      ref.invalidate(dynamicSystemAdminCatalogProvider);
      ref.invalidate(visibleDynamicAdminSystemsProvider);
      _sectionSystemKeyController.text = key;
      _showMessage('تم حفظ النظام الديناميكي.');
    } catch (error) {
      _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _savingSystem = false);
    }
  }

  Future<void> _saveSection() async {
    final systemKey = _sectionSystemKeyController.text.trim();
    final sectionKey = _sectionKeyController.text.trim();
    final title = _sectionTitleController.text.trim();
    if (systemKey.isEmpty || sectionKey.isEmpty || title.isEmpty) {
      _showMessage(
        'system_key و section_key وعنوان القسم مطلوبة.',
        isError: true,
      );
      return;
    }
    setState(() => _savingSection = true);
    try {
      final section = PwfDynamicSystemSection(
        systemKey: systemKey,
        sectionKey: sectionKey,
        titleAr: title,
        descriptionAr: _sectionDescriptionController.text.trim(),
        routePath: '/admin/systems/$systemKey/sections/$sectionKey',
        sectionType: 'generic',
        iconKey: 'section',
        displayOrder: 100,
        isActive: true,
        showInDashboard: true,
        showInSidebar: true,
        requiredPermissionKey: _sectionPermissionController.text.trim().isEmpty
            ? 'read'
            : _sectionPermissionController.text.trim(),
        metadata: const <String, dynamic>{'source': 'admin_ui_n2_10'},
      );
      await ref
          .read(pwfDynamicSystemRegistryRepositoryProvider)
          .upsertSection(section);
      ref.invalidate(dynamicSystemAdminCatalogProvider);
      ref.invalidate(visibleDynamicAdminSystemsProvider);
      _showMessage('تم حفظ القسم الديناميكي.');
    } catch (error) {
      _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _savingSection = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFB22222)
            : const Color(0xFF0F4C81),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _RegistryCard extends StatelessWidget {
  const _RegistryCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF64748B), height: 1.5),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
