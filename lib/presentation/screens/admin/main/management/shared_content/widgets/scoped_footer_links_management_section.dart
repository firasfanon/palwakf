import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waqf/data/models/footer_settings.dart';
import 'package:waqf/presentation/providers/footer_settings_provider.dart';
import 'package:waqf/presentation/providers/org_units_provider.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/shared/shared_content_admin_ui.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/shared/shared_content_scope.dart';

class ScopedFooterLinksManagementSection extends ConsumerStatefulWidget {
  const ScopedFooterLinksManagementSection({
    super.key,
    required this.mode,
    required this.title,
    required this.description,
  });

  final ScopedFooterLinksMode mode;
  final String title;
  final String description;

  @override
  ConsumerState<ScopedFooterLinksManagementSection> createState() =>
      _ScopedFooterLinksManagementSectionState();
}

enum ScopedFooterLinksMode { quickLinks, services }

enum _LinksFilter { all, enabledOnly, disabledOnly }

class _ScopedFooterLinksManagementSectionState
    extends ConsumerState<ScopedFooterLinksManagementSection> {
  String _unitSlug = 'home';
  String _loadedKey = '';
  bool _saving = false;
  String _query = '';
  _LinksFilter _filter = _LinksFilter.all;
  List<_EditableFooterLink> _links = const [];

  List<FooterLink> get _currentLinks => _links
      .map(
        (e) => FooterLink(label: e.label, route: e.route, enabled: e.enabled),
      )
      .toList(growable: false);

  void _hydrateIfNeeded(FooterSettings settings) {
    final source = widget.mode == ScopedFooterLinksMode.quickLinks
        ? settings.quickLinks
        : settings.servicesLinks;
    final key =
        '${widget.mode.name}|${settings.id}|$_unitSlug|${source.length}';
    if (_loadedKey == key) return;
    _links = source
        .map(
          (e) => _EditableFooterLink(
            label: e.label,
            route: e.route,
            enabled: e.enabled,
          ),
        )
        .toList(growable: true);
    if (_links.isEmpty) {
      _links = [const _EditableFooterLink()];
    }
    _loadedKey = key;
  }

  Future<void> _save(FooterSettings settings) async {
    setState(() => _saving = true);
    try {
      final unitId = await ref.read(unitIdBySlugProvider(_unitSlug).future);
      final repository = ref.read(footerRepositoryProvider);
      final next = widget.mode == ScopedFooterLinksMode.quickLinks
          ? settings.copyWith(quickLinks: _currentLinks)
          : settings.copyWith(servicesLinks: _currentLinks);
      await repository.saveFooterSettingsForUnit(next, unitId: unitId);
      ref.invalidate(editableFooterSettingsProvider(_unitSlug));
      ref.invalidate(publicFooterSettingsProvider(_unitSlug));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حفظ ${widget.title} لهذا النطاق')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر الحفظ: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _duplicateLink(int index) {
    final item = _links[index];
    setState(() {
      _links.insert(index + 1, item.copyWith());
    });
  }

  List<_EditableFooterLink> _filteredLinks() {
    final q = _query.trim().toLowerCase();
    return _links
        .where((row) {
          if (_filter == _LinksFilter.enabledOnly && !row.enabled) return false;
          if (_filter == _LinksFilter.disabledOnly && row.enabled) return false;
          if (q.isEmpty) return true;
          return row.label.toLowerCase().contains(q) ||
              row.route.toLowerCase().contains(q);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(orgUnitsListProvider);
    final settingsAsync = ref.watch(editableFooterSettingsProvider(_unitSlug));

    return unitsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('تعذر تحميل الوحدات: $e')),
      data: (units) {
        final options = buildSharedContentScopeOptions(units)
            .map((o) => _ScopeOption(slug: o.slug, label: o.label))
            .toList(growable: false);
        if (!options.any((o) => o.slug == _unitSlug)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _unitSlug = 'home');
          });
        }

        final selectedScope = options.firstWhere(
          (o) => o.slug == _unitSlug,
          orElse: () => const _ScopeOption(
            slug: 'home',
            label: 'الوزارة / الصفحة الرئيسية',
          ),
        );

        return settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('تعذر تحميل الإعدادات: $e')),
          data: (settings) {
            _hydrateIfNeeded(settings);
            final filteredLinks = _filteredLinks();
            final enabledCount = _links.where((e) => e.enabled).length;
            final externalCount = _links
                .where((e) => e.route.trim().startsWith('http'))
                .length;
            final localCount = _links
                .where(
                  (e) =>
                      e.route.trim().isNotEmpty &&
                      !e.route.trim().startsWith('http'),
                )
                .length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SharedAdminSectionNotice(
                  message:
                      '${widget.description} يتم الآن عرض اسم النطاق المختار بالعربية قدر الإمكان، ويُستخدم نفس المحتوى لاحقًا داخل الصفحة الرئيسية والواجهة العامة.',
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SharedAdminStatCard(
                      label: 'إجمالي الروابط',
                      value: '${_links.length}',
                      icon: Icons.link_outlined,
                      color: const Color(0xFF0B3A70),
                    ),
                    SharedAdminStatCard(
                      label: 'المفعّلة',
                      value: '$enabledCount',
                      icon: Icons.check_circle_outline,
                      color: const Color(0xFF1D7A46),
                    ),
                    SharedAdminStatCard(
                      label: 'داخلية',
                      value: '$localCount',
                      icon: Icons.route_outlined,
                      color: const Color(0xFF946200),
                    ),
                    SharedAdminStatCard(
                      label: 'خارجية',
                      value: '$externalCount',
                      icon: Icons.open_in_new_outlined,
                      color: const Color(0xFFB22222),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SharedAdminSurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: 320,
                            child: DropdownButtonFormField<String>(
                              value: _unitSlug,
                              decoration: const InputDecoration(
                                labelText: 'النطاق',
                                border: OutlineInputBorder(),
                              ),
                              items: options
                                  .map(
                                    (o) => DropdownMenuItem(
                                      value: o.slug,
                                      child: Text('${o.label} — ${o.slug}'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() {
                                _unitSlug = v ?? _unitSlug;
                                _loadedKey = '';
                              }),
                            ),
                          ),
                          SizedBox(
                            width: 260,
                            child: TextFormField(
                              initialValue: _query,
                              decoration: const InputDecoration(
                                labelText: 'بحث داخل الروابط',
                                hintText: 'عنوان أو مسار',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.search),
                              ),
                              onChanged: (v) => setState(() => _query = v),
                            ),
                          ),
                          SegmentedButton<_LinksFilter>(
                            segments: const [
                              ButtonSegment(
                                value: _LinksFilter.all,
                                label: Text('الكل'),
                              ),
                              ButtonSegment(
                                value: _LinksFilter.enabledOnly,
                                label: Text('المفعّل'),
                              ),
                              ButtonSegment(
                                value: _LinksFilter.disabledOnly,
                                label: Text('المعطّل'),
                              ),
                            ],
                            selected: {_filter},
                            onSelectionChanged: (v) =>
                                setState(() => _filter = v.first),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          SharedAdminMetaChip(
                            label: selectedScope.label,
                            icon: Icons.apartment_outlined,
                            color: const Color(0xFF0B3A70),
                            soft: true,
                          ),
                          SharedAdminMetaChip(
                            label: selectedScope.slug,
                            icon: Icons.tag,
                          ),
                          SharedAdminMetaChip(
                            label:
                                widget.mode == ScopedFooterLinksMode.quickLinks
                                ? 'روابط سريعة'
                                : 'خدمات سريعة',
                            icon:
                                widget.mode == ScopedFooterLinksMode.quickLinks
                                ? Icons.link
                                : Icons.miscellaneous_services,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton.icon(
                            onPressed: _saving ? null : () => _save(settings),
                            icon: _saving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save),
                            label: const Text('حفظ'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => setState(
                              () => _links.add(const _EditableFooterLink()),
                            ),
                            icon: const Icon(Icons.add_link),
                            label: const Text('إضافة رابط'),
                          ),
                          OutlinedButton.icon(
                            onPressed: filteredLinks.isEmpty
                                ? null
                                : () => setState(() {
                                    for (var i = 0; i < _links.length; i++) {
                                      final row = _links[i];
                                      final shouldEnable = _filteredLinks()
                                          .contains(row);
                                      if (shouldEnable)
                                        _links[i] = row.copyWith(enabled: true);
                                    }
                                  }),
                            icon: const Icon(Icons.task_alt_outlined),
                            label: const Text('تفعيل النتائج الحالية'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_links.isNotEmpty)
                  SharedAdminSurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'معاينة سريعة',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final item in _links.take(6))
                              SharedAdminMetaChip(
                                label: item.label.trim().isEmpty
                                    ? 'رابط بدون عنوان'
                                    : item.label.trim(),
                                icon: item.route.trim().startsWith('http')
                                    ? Icons.open_in_new_outlined
                                    : Icons.route_outlined,
                                color: item.enabled
                                    ? const Color(0xFF0B3A70)
                                    : const Color(0xFF6B7280),
                                soft: item.enabled,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Expanded(
                  child: filteredLinks.isEmpty
                      ? const SharedAdminEmptyState(
                          title: 'لا توجد روابط مطابقة',
                          message:
                              'جرّب تغيير كلمات البحث أو التبديل بين المفعّل والمعطّل أو إضافة رابط جديد.',
                          icon: Icons.link_off_outlined,
                        )
                      : ListView.separated(
                          itemCount: filteredLinks.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, filteredIndex) {
                            final row = filteredLinks[filteredIndex];
                            final index = _links.indexOf(row);
                            final isExternal = row.route.trim().startsWith(
                              'http',
                            );
                            return SharedAdminSurfaceCard(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      SharedAdminMetaChip(
                                        label: row.enabled ? 'مفعّل' : 'معطّل',
                                        icon: row.enabled
                                            ? Icons.check_circle_outline
                                            : Icons.pause_circle_outline,
                                        color: row.enabled
                                            ? const Color(0xFF1D7A46)
                                            : const Color(0xFF6B7280),
                                        soft: row.enabled,
                                      ),
                                      SharedAdminMetaChip(
                                        label: isExternal
                                            ? 'رابط خارجي'
                                            : 'مسار داخلي',
                                        icon: isExternal
                                            ? Icons.open_in_new_outlined
                                            : Icons.route_outlined,
                                        color: isExternal
                                            ? const Color(0xFFB22222)
                                            : const Color(0xFF946200),
                                        soft: true,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      SizedBox(
                                        width: 280,
                                        child: TextFormField(
                                          initialValue: row.label,
                                          decoration: const InputDecoration(
                                            labelText: 'العنوان',
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (v) => _links[index] = row
                                              .copyWith(label: v),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 500,
                                        child: TextFormField(
                                          initialValue: row.route,
                                          decoration: const InputDecoration(
                                            labelText: 'المسار أو الرابط',
                                            border: OutlineInputBorder(),
                                          ),
                                          onChanged: (v) => _links[index] = row
                                              .copyWith(route: v),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      FilterChip(
                                        label: const Text('مفعّل'),
                                        selected: row.enabled,
                                        onSelected: (v) => setState(
                                          () => _links[index] = row.copyWith(
                                            enabled: v,
                                          ),
                                        ),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: index > 0
                                            ? () => setState(() {
                                                final current = _links.removeAt(
                                                  index,
                                                );
                                                _links.insert(
                                                  index - 1,
                                                  current,
                                                );
                                              })
                                            : null,
                                        icon: const Icon(Icons.arrow_upward),
                                        label: const Text('أعلى'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: index < _links.length - 1
                                            ? () => setState(() {
                                                final current = _links.removeAt(
                                                  index,
                                                );
                                                _links.insert(
                                                  index + 1,
                                                  current,
                                                );
                                              })
                                            : null,
                                        icon: const Icon(Icons.arrow_downward),
                                        label: const Text('أسفل'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () => _duplicateLink(index),
                                        icon: const Icon(Icons.copy_outlined),
                                        label: const Text('نسخ'),
                                      ),
                                      TextButton.icon(
                                        onPressed: _links.length > 1
                                            ? () => setState(
                                                () => _links.removeAt(index),
                                              )
                                            : null,
                                        icon: const Icon(Icons.delete_outline),
                                        label: const Text('حذف'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ScopeOption {
  const _ScopeOption({required this.slug, required this.label});
  final String slug;
  final String label;
}

class _EditableFooterLink {
  const _EditableFooterLink({
    this.label = '',
    this.route = '',
    this.enabled = true,
  });

  final String label;
  final String route;
  final bool enabled;

  _EditableFooterLink copyWith({String? label, String? route, bool? enabled}) {
    return _EditableFooterLink(
      label: label ?? this.label,
      route: route ?? this.route,
      enabled: enabled ?? this.enabled,
    );
  }
}
