import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';
import 'package:waqf/presentation/providers/org_units_provider.dart';
import 'package:waqf/presentation/providers/unit_context_provider.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/shared/shared_content_admin_ui.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/shared/shared_content_scope.dart';

class ScopedMiniMapTeaserManagementSection extends ConsumerStatefulWidget {
  const ScopedMiniMapTeaserManagementSection({super.key});

  @override
  ConsumerState<ScopedMiniMapTeaserManagementSection> createState() =>
      _ScopedMiniMapTeaserManagementSectionState();
}

class _ScopedMiniMapTeaserManagementSectionState
    extends ConsumerState<ScopedMiniMapTeaserManagementSection> {
  String _unitSlug = 'home';
  String _loadedKey = '';
  bool _enabled = true;
  bool _saving = false;
  late final TextEditingController _titleController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _visualTitleController;
  late final TextEditingController _visualSubtitleController;
  late final TextEditingController _headlineController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _openLabelController;
  late final TextEditingController _openRouteController;
  late final TextEditingController _layersLabelController;
  late final TextEditingController _layersRouteController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _subtitleController = TextEditingController();
    _visualTitleController = TextEditingController();
    _visualSubtitleController = TextEditingController();
    _headlineController = TextEditingController();
    _descriptionController = TextEditingController();
    _openLabelController = TextEditingController();
    _openRouteController = TextEditingController();
    _layersLabelController = TextEditingController();
    _layersRouteController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _visualTitleController.dispose();
    _visualSubtitleController.dispose();
    _headlineController.dispose();
    _descriptionController.dispose();
    _openLabelController.dispose();
    _openRouteController.dispose();
    _layersLabelController.dispose();
    _layersRouteController.dispose();
    super.dispose();
  }

  void _hydrateIfNeeded(List<HomepageSection> sections) {
    HomepageSection? section;
    for (final row in sections) {
      if (row.sectionName.trim().toLowerCase() == 'pwf_mini_map_teaser') {
        section = row;
        break;
      }
    }
    final settings = section == null
        ? <String, dynamic>{}
        : Map<String, dynamic>.from(section.settings);
    final key = '$_unitSlug|${section?.id ?? 'none'}';
    if (_loadedKey == key) return;

    _enabled = settings['enabled'] is bool ? settings['enabled'] as bool : true;
    _titleController.text = (settings['title'] ?? 'الخريطة التفاعلية للأوقاف')
        .toString();
    _subtitleController.text =
        (settings['subtitle'] ?? 'استكشاف المواقع والطبقات الجغرافية ذات الصلة')
            .toString();
    _visualTitleController.text = (settings['visual_title'] ?? 'معاينة الخريطة')
        .toString();
    _visualSubtitleController.text =
        (settings['visual_subtitle'] ?? 'سيتم ربطها بـ Mustakshif / GIS لاحقًا')
            .toString();
    _headlineController.text = (settings['headline'] ?? 'استكشف على الخريطة')
        .toString();
    _descriptionController.text =
        (settings['description'] ??
                'اعرض طبقات إدارية وتاريخية، وارتباطات مكانية للمحتوى والخدمات.')
            .toString();
    _openLabelController.text = (settings['open_map_label'] ?? 'فتح الخريطة')
        .toString();
    _openRouteController.text = (settings['open_map_route'] ?? '#').toString();
    _layersLabelController.text =
        (settings['layers_label'] ?? 'استعراض الطبقات').toString();
    _layersRouteController.text = (settings['layers_route'] ?? '#').toString();
    _loadedKey = key;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      String? unitId;
      try {
        unitId = await ref.read(unitIdBySlugProvider(_unitSlug).future);
      } catch (_) {
        unitId = null;
      }
      final repository = ref.read(homepageRepositoryProvider);
      final nowIso = DateTime.now().toUtc().toIso8601String();
      await repository.saveSectionsMeta([
        HomepageSection(
          id: '',
          sectionName: 'pwf_mini_map_teaser',
          settings: {
            'enabled': _enabled,
            'title': _titleController.text.trim(),
            'subtitle': _subtitleController.text.trim(),
            'visual_title': _visualTitleController.text.trim(),
            'visual_subtitle': _visualSubtitleController.text.trim(),
            'headline': _headlineController.text.trim(),
            'description': _descriptionController.text.trim(),
            'open_map_label': _openLabelController.text.trim(),
            'open_map_route': _openRouteController.text.trim(),
            'layers_label': _layersLabelController.text.trim(),
            'layers_route': _layersRouteController.text.trim(),
          },
          isActive: _enabled,
          displayOrder: 0,
          createdAt: nowIso,
          updatedAt: nowIso,
          updatedBy: null,
          unitId: unitId,
        ),
      ], unitId: unitId);
      ref.invalidate(homepageSectionsForUnitProvider(_unitSlug));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ إعدادات Mini Map Teaser')),
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

  @override
  Widget build(BuildContext context) {
    final unitsAsync = ref.watch(orgUnitsListProvider);
    final sectionsAsync = ref.watch(homepageSectionsForUnitProvider(_unitSlug));

    return unitsAsync.when(
      loading: () =>
          const SharedAdminLoadingState(message: 'جاري تحميل الوحدات...'),
      error: (e, _) => SharedAdminErrorState(message: 'تعذر تحميل الوحدات: $e'),
      data: (units) {
        final options = buildSharedContentScopeOptions(units);
        final selectedScope = options.any((e) => e.slug == _unitSlug)
            ? options.firstWhere((e) => e.slug == _unitSlug)
            : (options.isNotEmpty
                  ? options.first
                  : const SharedContentScopeOption(
                      slug: 'home',
                      label: 'الوزارة / الصفحة الرئيسية',
                      isHome: true,
                    ));
        return sectionsAsync.when(
          loading: () => const SharedAdminLoadingState(
            message: 'جاري تحميل إعدادات الخريطة التمهيدية...',
          ),
          error: (e, _) =>
              SharedAdminErrorState(message: 'تعذر تحميل الإعدادات: $e'),
          data: (sections) {
            _hydrateIfNeeded(sections);
            return LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth.isFinite
                    ? constraints.maxWidth
                    : MediaQuery.of(context).size.width;
                final controlColumns = maxWidth >= 1200
                    ? 3
                    : maxWidth >= 760
                    ? 2
                    : 1;
                const spacing = 12.0;
                final controlWidth = controlColumns == 1
                    ? maxWidth
                    : (maxWidth - ((controlColumns - 1) * spacing)) /
                          controlColumns;
                final pairColumns = maxWidth >= 760 ? 2 : 1;
                final pairWidth = pairColumns == 1
                    ? maxWidth
                    : (maxWidth - 12) / 2;

                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    SharedAdminSurfaceCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              SharedContentScopeBadge(slug: _unitSlug),
                              SharedAdminMetaChip(
                                label: selectedScope.label,
                                icon: selectedScope.isHome
                                    ? Icons.public
                                    : Icons.account_tree_outlined,
                                soft: true,
                              ),
                              const SharedAdminMetaChip(
                                label: 'pwf_mini_map_teaser',
                                icon: Icons.map_outlined,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Mini Map Teaser',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'إدارة قسم الخريطة التمهيدية داخل الصفحة العامة بنفس منطق home/slug، مع إبقاء الربط النهائي مع Mustakshif وطبقات GIS داخل المرحلة اللاحقة.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: const Color(0xFF4B5563),
                                  height: 1.6,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: pairWidth,
                          child: SharedAdminStatCard(
                            label: 'الحالة',
                            value: _enabled ? 'مفعّل' : 'معطّل',
                            icon: _enabled
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: _enabled
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFFB22222),
                            helper: 'حالة عرض القسم داخل الصفحة العامة',
                          ),
                        ),
                        SizedBox(
                          width: pairWidth,
                          child: SharedAdminStatCard(
                            label: 'فتح الخريطة',
                            value:
                                _openRouteController.text.trim().startsWith('/')
                                ? 'جاهز'
                                : 'مؤجل',
                            icon:
                                _openRouteController.text.trim().startsWith('/')
                                ? Icons.check_circle_outline
                                : Icons.schedule_outlined,
                            color:
                                _openRouteController.text.trim().startsWith('/')
                                ? const Color(0xFF2E7D32)
                                : const Color(0xFF8A5A00),
                            helper: _openRouteController.text.trim().isEmpty
                                ? 'لا يوجد مسار بعد'
                                : _openRouteController.text.trim(),
                          ),
                        ),
                        SizedBox(
                          width: pairWidth,
                          child: SharedAdminStatCard(
                            label: 'الطبقات',
                            value:
                                _layersRouteController.text.trim().startsWith(
                                  '/',
                                )
                                ? 'جاهزة'
                                : 'مؤجلة',
                            icon:
                                _layersRouteController.text.trim().startsWith(
                                  '/',
                                )
                                ? Icons.layers_outlined
                                : Icons.pending_outlined,
                            color:
                                _layersRouteController.text.trim().startsWith(
                                  '/',
                                )
                                ? const Color(0xFF0B3A70)
                                : const Color(0xFF8A5A00),
                            helper: _layersRouteController.text.trim().isEmpty
                                ? 'لا يوجد مسار بعد'
                                : _layersRouteController.text.trim(),
                          ),
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
                                width: controlWidth,
                                child: DropdownButtonFormField<String>(
                                  value: _unitSlug,
                                  decoration: const InputDecoration(
                                    labelText: 'النطاق',
                                    border: OutlineInputBorder(),
                                  ),
                                  isExpanded: true,
                                  items: options
                                      .map(
                                        (o) => DropdownMenuItem(
                                          value: o.slug,
                                          child: Text(
                                            '${o.label} — ${o.slug}',
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(growable: false),
                                  onChanged: (v) => setState(() {
                                    _unitSlug = v ?? _unitSlug;
                                    _loadedKey = '';
                                  }),
                                ),
                              ),
                              SizedBox(
                                width: controlWidth,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: FilterChip(
                                    label: const Text('القسم مفعّل'),
                                    selected: _enabled,
                                    onSelected: (v) =>
                                        setState(() => _enabled = v),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: controlWidth,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    final route = _openRouteController.text
                                        .trim();
                                    if (route.startsWith('/')) {
                                      context.go(route);
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'لا يوجد مسار داخلي جاهز لفتح الخريطة بعد.',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('اختبار فتح الخريطة'),
                                ),
                              ),
                              SizedBox(
                                width: controlWidth,
                                child: FilledButton.icon(
                                  onPressed: _saving ? null : _save,
                                  icon: _saving
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.save_outlined),
                                  label: const Text('حفظ الإعدادات'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SharedAdminSectionNotice(
                            message:
                                '${sharedContentScopeHint(_unitSlug)}\nهذه الصفحة تضبط النصوص والأزرار والمعاينة الظاهرة في قسم الخريطة التمهيدية دون التوسع حاليًا إلى تعديل طبقات GIS نفسها.',
                            icon: Icons.explore_outlined,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, c) {
                        final isNarrow = c.maxWidth < 1000;
                        final preview = _PreviewCard(
                          title: _titleController.text.trim().isEmpty
                              ? 'الخريطة التفاعلية للأوقاف'
                              : _titleController.text.trim(),
                          subtitle: _subtitleController.text.trim().isEmpty
                              ? 'استكشاف المواقع والطبقات الجغرافية ذات الصلة'
                              : _subtitleController.text.trim(),
                          visualTitle:
                              _visualTitleController.text.trim().isEmpty
                              ? 'معاينة الخريطة'
                              : _visualTitleController.text.trim(),
                          visualSubtitle:
                              _visualSubtitleController.text.trim().isEmpty
                              ? 'سيتم ربطها بـ Mustakshif / GIS لاحقًا'
                              : _visualSubtitleController.text.trim(),
                          headline: _headlineController.text.trim().isEmpty
                              ? 'استكشف على الخريطة'
                              : _headlineController.text.trim(),
                          description:
                              _descriptionController.text.trim().isEmpty
                              ? 'اعرض طبقات إدارية وتاريخية، وارتباطات مكانية للمحتوى والخدمات.'
                              : _descriptionController.text.trim(),
                          openLabel: _openLabelController.text.trim().isEmpty
                              ? 'فتح الخريطة'
                              : _openLabelController.text.trim(),
                          layersLabel:
                              _layersLabelController.text.trim().isEmpty
                              ? 'استعراض الطبقات'
                              : _layersLabelController.text.trim(),
                          mapReady: _openRouteController.text.trim().startsWith(
                            '/',
                          ),
                          layersReady: _layersRouteController.text
                              .trim()
                              .startsWith('/'),
                        );
                        final editor = SharedAdminSurfaceCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تحرير محتوى القسم',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 12),
                              _field(_titleController, 'عنوان القسم'),
                              const SizedBox(height: 12),
                              _field(
                                _subtitleController,
                                'الوصف المختصر',
                                minLines: 2,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 12),
                              _field(
                                _visualTitleController,
                                'عنوان المعاينة البصرية',
                              ),
                              const SizedBox(height: 12),
                              _field(
                                _visualSubtitleController,
                                'الوصف البصري القصير',
                              ),
                              const SizedBox(height: 12),
                              _field(_headlineController, 'العنوان الداخلي'),
                              const SizedBox(height: 12),
                              _field(
                                _descriptionController,
                                'الوصف',
                                minLines: 2,
                                maxLines: 4,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  SizedBox(
                                    width: pairWidth,
                                    child: _field(
                                      _openLabelController,
                                      'زر فتح الخريطة',
                                    ),
                                  ),
                                  SizedBox(
                                    width: pairWidth,
                                    child: _field(
                                      _openRouteController,
                                      'مسار فتح الخريطة',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  SizedBox(
                                    width: pairWidth,
                                    child: _field(
                                      _layersLabelController,
                                      'زر استعراض الطبقات',
                                    ),
                                  ),
                                  SizedBox(
                                    width: pairWidth,
                                    child: _field(
                                      _layersRouteController,
                                      'مسار استعراض الطبقات',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );

                        return isNarrow
                            ? Column(
                                children: [
                                  preview,
                                  const SizedBox(height: 16),
                                  editor,
                                ],
                              )
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: preview),
                                  const SizedBox(width: 16),
                                  Expanded(child: editor),
                                ],
                              );
                      },
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    int minLines = 1,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) => setState(() {}),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.title,
    required this.subtitle,
    required this.visualTitle,
    required this.visualSubtitle,
    required this.headline,
    required this.description,
    required this.openLabel,
    required this.layersLabel,
    this.mapReady = false,
    this.layersReady = false,
  });

  final String title;
  final String subtitle;
  final String visualTitle;
  final String visualSubtitle;
  final String headline;
  final String description;
  final String openLabel;
  final String layersLabel;
  final bool mapReady;
  final bool layersReady;

  @override
  Widget build(BuildContext context) {
    return SharedAdminSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معاينة مباشرة',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  const Color(0xFF0B3A70).withValues(alpha: 0.96),
                  const Color(0xFF8A5A00).withValues(alpha: 0.92),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        color: Colors.white,
                        size: 42,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        visualTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        visualSubtitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.86),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  headline,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: mapReady ? () {} : null,
                      icon: const Icon(Icons.open_in_new),
                      label: Text(openLabel),
                    ),
                    OutlinedButton.icon(
                      onPressed: layersReady ? () {} : null,
                      icon: const Icon(Icons.layers_outlined),
                      label: Text(layersLabel),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
