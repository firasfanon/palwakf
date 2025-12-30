import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/access/access_provider.dart';
import '../../../../../../core/enums/enums.dart';
import '../../../../../providers/org_units_provider.dart';

class OrgUnitsManagementScreen extends ConsumerWidget {
  const OrgUnitsManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(accessProfileProvider);
    final listAsync = ref.watch(filteredOrgUnitsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('إدارة المؤسسات')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: profileAsync.when(
            data: (profile) {
              final canManage = profile?.can(SystemKey.platformAdmin, Permission.manageSite) ?? false;
              if (!canManage) {
                return const Center(
                  child: Text('غير مصرح لك. تحتاج صلاحية manageSite على platformAdmin.'),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      SizedBox(
                        width: 360,
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'بحث (اسم/كود/Slug)',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (v) => ref.read(orgUnitsSearchProvider.notifier).state = v,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => ref.invalidate(orgUnitsListProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('تحديث'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final units = listAsync.valueOrNull ?? const <Map<String, dynamic>>[];
                          await showDialog(
                            context: context,
                            builder: (_) => _OrgUnitDialog(
                              title: 'إضافة مؤسسة',
                              units: units,
                            ),
                          );
                          ref.invalidate(orgUnitsListProvider);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: listAsync.when(
                      data: (rows) {
                        if (rows.isEmpty) return const Center(child: Text('لا توجد مؤسسات.'));
                        return SingleChildScrollView(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('الاسم')),
                              DataColumn(label: Text('الكود')),
                              DataColumn(label: Text('Slug')),
                              DataColumn(label: Text('النوع')),
                              DataColumn(label: Text('نشط')),
                              DataColumn(label: Text('إجراء')),
                            ],
                            rows: rows.map((r) {
                              final id = (r['id'] ?? '').toString();
                              final name = (r['name_ar'] ?? '').toString();
                              final code = (r['code'] ?? '').toString();
                              final slug = (r['slug'] ?? '').toString();
                              final type = (r['unit_type'] ?? '').toString();
                              final active = (r['is_active'] == true);

                              return DataRow(
                                cells: [
                                  DataCell(Text(name)),
                                  DataCell(Text(code)),
                                  DataCell(Text(slug)),
                                  DataCell(Text(type)),
                                  DataCell(Icon(active ? Icons.check_circle : Icons.cancel, size: 18)),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          tooltip: 'تعديل',
                                          icon: const Icon(Icons.edit),
                                          onPressed: () async {
                                            final units = rows;
                                            await showDialog(
                                              context: context,
                                              builder: (_) => _OrgUnitDialog(
                                                title: 'تعديل مؤسسة',
                                                units: units,
                                                unitRow: r,
                                              ),
                                            );
                                            ref.invalidate(orgUnitsListProvider);
                                          },
                                        ),
                                        IconButton(
                                          tooltip: 'حذف',
                                          icon: const Icon(Icons.delete_outline),
                                          onPressed: () async {
                                            final ok = await showDialog<bool>(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text('تأكيد الحذف'),
                                                content: Text('هل تريد حذف المؤسسة: $name ؟'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
                                                  ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
                                                ],
                                              ),
                                            );
                                            if (ok == true) {
                                              await ref.read(orgUnitsRepositoryProvider).deleteUnit(id);
                                              ref.invalidate(orgUnitsListProvider);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text(e.toString())),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
          ),
        ),
      ),
    );
  }
}

class _OrgUnitDialog extends ConsumerStatefulWidget {
  final String title;
  final List<Map<String, dynamic>> units;
  final Map<String, dynamic>? unitRow;

  const _OrgUnitDialog({
    required this.title,
    required this.units,
    this.unitRow,
  });

  @override
  ConsumerState<_OrgUnitDialog> createState() => _OrgUnitDialogState();
}

class _OrgUnitDialogState extends ConsumerState<_OrgUnitDialog> {
  static const _unitTypes = <String>[
    'ministry',
    'general_admin',
    'directorate',
    'school',
    'university',
    'institute',
    'orphanage',
    'zakat_committee',
    'mosque',
    'other',
  ];

  late final TextEditingController _nameAr;
  late final TextEditingController _nameEn;
  late final TextEditingController _code;
  late final TextEditingController _slug;
  late final TextEditingController _sortOrder;

  String _unitType = 'other';
  String? _parentId;
  bool _isActive = true;
  bool _slugTouched = false;

  // Profile fields
  late final TextEditingController _siteTitle;
  late final TextEditingController _siteSubtitle;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _facebook;
  late final TextEditingController _x;
  late final TextEditingController _instagram;
  late final TextEditingController _youtube;
  late final TextEditingController _whatsapp;

  @override
  void initState() {
    super.initState();
    final u = widget.unitRow;
    final profile = (u?['org_unit_profiles'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};

    _nameAr = TextEditingController(text: (u?['name_ar'] ?? '').toString());
    _nameEn = TextEditingController(text: (u?['name_en'] ?? '').toString());
    _code = TextEditingController(text: (u?['code'] ?? '').toString());
    _slug = TextEditingController(text: (u?['slug'] ?? '').toString());
    _sortOrder = TextEditingController(text: (u?['sort_order'] ?? 0).toString());

    _unitType = (u?['unit_type'] ?? 'other').toString();
    if (!_unitTypes.contains(_unitType)) _unitType = 'other';

    _parentId = u?['parent_id']?.toString();
    _isActive = (u?['is_active'] == true) || u == null;

    _siteTitle = TextEditingController(text: (profile['site_title'] ?? '').toString());
    _siteSubtitle = TextEditingController(text: (profile['site_subtitle'] ?? '').toString());
    _email = TextEditingController(text: (profile['contact_email'] ?? '').toString());
    _phone = TextEditingController(text: (profile['contact_phone'] ?? '').toString());
    _address = TextEditingController(text: (profile['contact_address'] ?? '').toString());
    _facebook = TextEditingController(text: (profile['facebook_url'] ?? '').toString());
    _x = TextEditingController(text: (profile['x_url'] ?? '').toString());
    _instagram = TextEditingController(text: (profile['instagram_url'] ?? '').toString());
    _youtube = TextEditingController(text: (profile['youtube_url'] ?? '').toString());
    _whatsapp = TextEditingController(text: (profile['whatsapp_url'] ?? '').toString());
  }

  @override
  void dispose() {
    _nameAr.dispose();
    _nameEn.dispose();
    _code.dispose();
    _slug.dispose();
    _sortOrder.dispose();
    _siteTitle.dispose();
    _siteSubtitle.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _facebook.dispose();
    _x.dispose();
    _instagram.dispose();
    _youtube.dispose();
    _whatsapp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unitId = widget.unitRow?['id']?.toString();
    final parentOptions = widget.units.where((e) => (e['id']?.toString() ?? '') != (unitId ?? '')).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text(widget.title),
        content: SizedBox(
          width: 720,
          child: DefaultTabController(
            length: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'بيانات المؤسسة'),
                    Tab(text: 'التواصل والسوشيال'),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(child: _buildUnitForm(parentOptions)),
                      SingleChildScrollView(child: _buildProfileForm()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: _save,
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }


  String _normalizeCode(String input) {
    // Uppercase, no spaces, keep A-Z0-9_- only
    final up = input.toUpperCase().replaceAll(' ', '');
    return up.replaceAll(RegExp(r'[^A-Z0-9_-]'), '');
  }

  String _normalizeSlug(String input) {
    // lowercase, no spaces, keep a-z0-9_- only
    final low = input.toLowerCase().replaceAll(' ', '');
    return low.replaceAll(RegExp(r'[^a-z0-9_-]'), '');
  }

  void _setTextIfDifferent(TextEditingController c, String value) {
    if (c.text == value) return;
    c.value = c.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange.empty,
    );
  }

  Widget _buildUnitForm(List<Map<String, dynamic>> parentOptions) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nameAr,
                decoration: const InputDecoration(labelText: 'الاسم (عربي)', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _nameEn,
                decoration: const InputDecoration(labelText: 'الاسم (English)', border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _unitType,
                decoration: const InputDecoration(labelText: 'النوع', border: OutlineInputBorder()),
                items: _unitTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _unitType = v ?? _unitType),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String?>(
                value: _parentId,
                decoration: const InputDecoration(labelText: 'يتبع لـ (Parent)', border: OutlineInputBorder()),
                items: [
                  const DropdownMenuItem(value: null, child: Text('— بدون —')),
                  ...parentOptions.map((u) {
                    final id = u['id']?.toString();
                    final label = (u['name_ar'] ?? u['code'] ?? '').toString();
                    return DropdownMenuItem(value: id, child: Text(label));
                  }),
                ],
                onChanged: (v) => setState(() => _parentId = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _code,
                onChanged: (v) {
                  final norm = _normalizeCode(v);
                  if (norm != v) _setTextIfDifferent(_code, norm);
                  if (!_slugTouched) {
                    _setTextIfDifferent(_slug, _normalizeSlug(norm));
                  }
                },
                decoration: const InputDecoration(labelText: 'Code (مثل BTH)', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _slug,
                onChanged: (v) {
                  _slugTouched = true;
                  final norm = _normalizeSlug(v);
                  if (norm != v) _setTextIfDifferent(_slug, norm);
                },
                decoration: const InputDecoration(labelText: 'Slug (مثل bth)', border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _sortOrder,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Sort Order', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('نشط'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _siteTitle,
                decoration: const InputDecoration(labelText: 'عنوان الموقع', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _siteSubtitle,
                decoration: const InputDecoration(labelText: 'العنوان الفرعي', border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'البريد', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _phone,
                decoration: const InputDecoration(labelText: 'الهاتف', border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _address,
          maxLines: 2,
          decoration: const InputDecoration(labelText: 'العنوان', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _facebook,
                decoration: const InputDecoration(labelText: 'Facebook', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _x,
                decoration: const InputDecoration(labelText: 'X / Twitter', border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _instagram,
                decoration: const InputDecoration(labelText: 'Instagram', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _youtube,
                decoration: const InputDecoration(labelText: 'YouTube', border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _whatsapp,
          decoration: const InputDecoration(labelText: 'WhatsApp', border: OutlineInputBorder()),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final nameAr = _nameAr.text.trim();
    final code = _normalizeCode(_code.text.trim());
    _setTextIfDifferent(_code, code);
    final slug = _normalizeSlug(_slug.text.trim());
    _setTextIfDifferent(_slug, slug);

    if (nameAr.isEmpty || code.isEmpty || slug.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الاسم (عربي) والكود والـ Slug مطلوبة.')),
      );
      return;
    }

    final sort = int.tryParse(_sortOrder.text.trim()) ?? 0;

    final unit = <String, dynamic>{
      'unit_type': _unitType,
      'parent_id': _parentId,
      'code': code,
      'slug': slug,
      'name_ar': nameAr,
      'name_en': _nameEn.text.trim(),
      'is_active': _isActive,
      'sort_order': sort,
    };

    final profile = <String, dynamic>{
      'site_title': _siteTitle.text.trim(),
      'site_subtitle': _siteSubtitle.text.trim(),
      'contact_email': _email.text.trim().isEmpty ? null : _email.text.trim(),
      'contact_phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      'contact_address': _address.text.trim().isEmpty ? null : _address.text.trim(),
      'facebook_url': _facebook.text.trim().isEmpty ? null : _facebook.text.trim(),
      'x_url': _x.text.trim().isEmpty ? null : _x.text.trim(),
      'instagram_url': _instagram.text.trim().isEmpty ? null : _instagram.text.trim(),
      'youtube_url': _youtube.text.trim().isEmpty ? null : _youtube.text.trim(),
      'whatsapp_url': _whatsapp.text.trim().isEmpty ? null : _whatsapp.text.trim(),
    };

    try {
      final repo = ref.read(orgUnitsRepositoryProvider);
      final unitId = widget.unitRow?['id']?.toString();

      if (unitId == null || unitId.isEmpty) {
        await repo.createUnitWithProfile(unit: unit, profile: profile);
      } else {
        await repo.updateUnitWithProfile(unitId: unitId, unitPatch: unit, profilePatch: profile);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
