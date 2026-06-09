import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../app/routing/app_routes.dart';
import '../../../../../../app/rbac/system_key.dart';
import '../../../../../../features/platform/home/presentation/widgets/sections/pwf_home_sections_renderer.dart';
import 'pwf_dynamic_page_governance_registry.dart';
import 'pwf_home_management_sections.dart';
import 'pwf_homepage_sections_manager.dart';
import 'widgets/admin_surface_management_layout.dart';
import 'package:waqf/core/admin_governance/page_manager_governance_contract.dart';

/// Admin → Home Management
///
/// Reorganized to restore the old panel logic in a cleaner form:
/// - Main tabs for related categories
/// - Section ordering workspace
/// - Quick launch cards for connected admin modules
/// - Live preview kept on the same page
typedef WebHomepageManagementScreen = WebHomePageManagementScreen;

Widget pwfBuildMiniChip({required String label, required Color color}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: color.withValues(alpha: 0.20)),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _HomeManagementTarget {
  final String slug;
  final String label;
  final bool isActive;
  final bool isSystem;

  const _HomeManagementTarget({
    required this.slug,
    required this.label,
    required this.isActive,
    required this.isSystem,
  });
}

class _HomeManagementTargetsBundle {
  final List<_HomeManagementTarget> units;
  final List<_HomeManagementTarget> systems;

  const _HomeManagementTargetsBundle({
    required this.units,
    required this.systems,
  });
}

final _homeManagementTargetsProvider =
    FutureProvider<_HomeManagementTargetsBundle>((ref) async {
      final repo = ref.read(orgUnitsRepositoryProvider);
      final rows = await repo.fetchUnitsWithProfiles(onlyActive: false);
      final systemSlugs = SystemKey.values
          .where((e) => e != SystemKey.site && e != SystemKey.platformAdmin)
          .map((e) => e.slug)
          .toSet();

      final units = <_HomeManagementTarget>[];
      final systemMap = <String, _HomeManagementTarget>{
        for (final key in SystemKey.values.where(
          (e) => e != SystemKey.site && e != SystemKey.platformAdmin,
        ))
          key.slug: _HomeManagementTarget(
            slug: key.slug,
            label: key.nameAr,
            isActive: true,
            isSystem: true,
          ),
      };

      for (final row in rows) {
        final slug = (row['slug'] ?? '').toString().trim().toLowerCase();
        if (slug.isEmpty || slug == 'home') continue;
        final isActive = (row['is_active'] ?? true) == true;
        final unitType = (row['unit_type'] ?? '')
            .toString()
            .trim()
            .toLowerCase();
        final label = (row['name_ar'] ?? row['name_en'] ?? slug).toString();
        final target = _HomeManagementTarget(
          slug: slug,
          label: label,
          isActive: isActive,
          isSystem: unitType == 'system' || systemSlugs.contains(slug),
        );
        if (target.isSystem) {
          systemMap[slug] = target;
        } else {
          units.add(target);
        }
      }

      units.sort((a, b) {
        if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
        return a.label.compareTo(b.label);
      });
      final systems = systemMap.values.toList()
        ..sort((a, b) => a.label.compareTo(b.label));

      return _HomeManagementTargetsBundle(units: units, systems: systems);
    });

class WebHomePageManagementScreen extends ConsumerStatefulWidget {
  const WebHomePageManagementScreen({super.key, this.initialSurface = 'home'});

  final String initialSurface;

  @override
  ConsumerState<WebHomePageManagementScreen> createState() =>
      _WebHomepageManagementScreenState();
}

class _WebHomepageManagementScreenState
    extends ConsumerState<WebHomePageManagementScreen> {
  String _activeTab = 'layout';
  late String _surfaceScope;
  String _selectedSystemSlug = SystemKey.mustakshif.slug;
  String? _selectedUnitSlug;
  String? _lastScopedSyncSlug;

  @override
  void initState() {
    super.initState();
    _surfaceScope = widget.initialSurface;
  }

  String _effectiveSurface(BuildContext context) {
    final requestedSurface = GoRouterState.of(
      context,
    ).uri.queryParameters['surface'];
    const supported = <String>{'home', 'unit', 'system'};
    if (_surfaceScope == 'home' &&
        requestedSurface != null &&
        supported.contains(requestedSurface)) {
      return requestedSurface;
    }
    return _surfaceScope;
  }

  String _effectiveTab(BuildContext context) {
    final requestedTab = GoRouterState.of(context).uri.queryParameters['tab'];
    const supported = <String>{
      'layout',
      'identity',
      'content',
      'navigation',
      'governance',
    };
    if (_activeTab == 'layout' &&
        requestedTab != null &&
        supported.contains(requestedTab)) {
      return requestedTab;
    }
    return _activeTab;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pwfHomepageSectionsManagerProvider);
    final manager = ref.read(pwfHomepageSectionsManagerProvider.notifier);
    final currentSurface = _effectiveSurface(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_appBarTitleForSurface(currentSurface)),
          actions: [
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            IconButton(
              tooltip: 'تحديث',
              onPressed: state.isLoading ? null : manager.load,
              icon: const Icon(Icons.refresh),
            ),
            IconButton(
              tooltip: 'تراجع عن التعديلات',
              onPressed: (!state.isLoading && state.isDirty)
                  ? manager.resetDraft
                  : null,
              icon: const Icon(Icons.undo),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: (!state.isLoading && state.isDirty && !state.isSaving)
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
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSurfaceTabs(currentSurface, manager),
              const SizedBox(height: 12),
              if (currentSurface == 'home') ...[
                _buildMainTabs(),
                const SizedBox(height: 12),
                Expanded(child: _buildTabBody(context, state, manager)),
              ] else if (currentSurface == 'unit') ...[
                Expanded(
                  child: _buildScopedSurfacesWorkspace(
                    context,
                    state,
                    manager,
                    isSystem: false,
                  ),
                ),
              ] else ...[
                Expanded(
                  child: _buildScopedSurfacesWorkspace(
                    context,
                    state,
                    manager,
                    isSystem: true,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _appBarTitleForSurface(String surface) {
    switch (surface) {
      case 'unit':
        return 'إدارة واجهات الوحدات';
      case 'system':
        return 'إدارة واجهات الأنظمة';
      case 'home':
      default:
        return 'إدارة الصفحة الرئيسية';
    }
  }

  String _routeForSurface(String surface) {
    switch (surface) {
      case 'unit':
        return AppRoutes.adminUnitSurfacesManagement;
      case 'system':
        return AppRoutes.adminSystemSurfacesManagement;
      case 'home':
      default:
        return AppRoutes.adminHomeManagement;
    }
  }

  void _selectSurface(
    BuildContext context,
    String surface,
    PwfHomepageSectionsManager manager,
  ) {
    setState(() => _surfaceScope = surface);
    if (surface == 'home') {
      manager.setUnitSlug('home');
    } else if (surface == 'system') {
      manager.setUnitSlug(_selectedSystemSlug);
    }
    final targetRoute = _routeForSurface(surface);
    final currentUri = GoRouterState.of(context).uri;
    if (currentUri.path != targetRoute) {
      context.go(targetRoute);
    }
  }

  void _scheduleScopedSync(String slug, PwfHomepageSectionsManager manager) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final current = ref.read(pwfHomepageSectionsManagerProvider).unitSlug;
      if (current != slug) {
        manager.setUnitSlug(slug);
      }
      _lastScopedSyncSlug = slug;
    });
  }

  Widget _buildSurfaceTabs(
    String currentSurface,
    PwfHomepageSectionsManager manager,
  ) {
    final tabs = const [
      _ManagementTab('home', 'الرئيسية', Icons.home_filled),
      _ManagementTab('unit', 'الوحدات', Icons.account_tree_rounded),
      _ManagementTab('system', 'الأنظمة', Icons.widgets_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isActive = currentSurface == tab.id;
          return Expanded(
            child: InkWell(
              onTap: () => _selectSurface(context, tab.id, manager),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF0B3A70)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab.icon,
                      size: 18,
                      color: isActive ? Colors.white : Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        tab.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScopedSurfacesWorkspace(
    BuildContext context,
    PwfHomepageSectionsState state,
    PwfHomepageSectionsManager manager, {
    required bool isSystem,
  }) {
    final targetsAsync = ref.watch(_homeManagementTargetsProvider);
    return targetsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (bundle) {
        final targets = isSystem ? bundle.systems : bundle.units;
        if (targets.isEmpty) {
          return Center(
            child: Text(
              isSystem
                  ? 'لا توجد أنظمة متاحة للمعاينة بعد.'
                  : 'لا توجد وحدات متاحة للمعاينة بعد.',
            ),
          );
        }
        final selectedSlug = isSystem
            ? (targets.any((e) => e.slug == _selectedSystemSlug)
                  ? _selectedSystemSlug
                  : targets.first.slug)
            : (targets.any((e) => e.slug == _selectedUnitSlug)
                  ? _selectedUnitSlug!
                  : targets.first.slug);

        if (!isSystem && _selectedUnitSlug == null) {
          _selectedUnitSlug = selectedSlug;
        }
        if (isSystem && _selectedSystemSlug != selectedSlug) {
          _selectedSystemSlug = selectedSlug;
        }
        if (selectedSlug != state.unitSlug &&
            _lastScopedSyncSlug != selectedSlug) {
          _scheduleScopedSync(selectedSlug, manager);
          return const Center(child: CircularProgressIndicator());
        }

        final selectedTarget = targets.firstWhere(
          (e) => e.slug == selectedSlug,
          orElse: () => targets.first,
        );
        final leftPanel = _buildScopedLeftPanel(
          context,
          isSystem: isSystem,
          targets: targets,
          selectedSlug: selectedSlug,
          onChanged: (value) {
            if (isSystem) {
              setState(() => _selectedSystemSlug = value);
            } else {
              setState(() => _selectedUnitSlug = value);
            }
            _scheduleScopedSync(value, manager);
          },
        );
        final preview = _buildScopedPreview(
          context,
          state,
          selectedTarget: selectedTarget,
          isSystem: isSystem,
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 1280) {
              return ListView(
                children: [
                  SizedBox(height: 760, child: leftPanel),
                  const SizedBox(height: 12),
                  SizedBox(height: 900, child: preview),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(width: 420, child: leftPanel),
                const VerticalDivider(width: 1),
                Expanded(child: preview),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildScopedLeftPanel(
    BuildContext context, {
    required bool isSystem,
    required List<_HomeManagementTarget> targets,
    required String selectedSlug,
    required ValueChanged<String> onChanged,
  }) {
    final heading = isSystem ? 'إدارة واجهات الأنظمة' : 'إدارة واجهات الوحدات';
    final subtitle = isSystem
        ? 'هذه المساحة تدير Body الأنظمة تحت العقد الحاكم للمنصة، مع إبقاء الـ Chrome عامًا ومركزيًا. التعديلات تُعاين فورًا قبل الحفظ.'
        : 'هذه المساحة تدير Body صفحات الوحدات مباشرة من مصدر الوحدات الحقيقي، مع معاينة حيّة للتعديلات قبل الحفظ.';
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
            heading,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(height: 1.55, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedSlug,
            decoration: InputDecoration(
              labelText: isSystem ? 'النظام الهدف' : 'الوحدة الهدف',
              border: const OutlineInputBorder(),
            ),
            items: targets
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
            onChanged: (value) {
              if (value == null) return;
              onChanged(value);
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildLeftPanel(
              context,
              title: 'الأقسام (سحب/إفلات)',
              scopeSlug: selectedSlug,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopedPreview(
    BuildContext context,
    PwfHomepageSectionsState state, {
    required _HomeManagementTarget selectedTarget,
    required bool isSystem,
  }) {
    final title = isSystem ? 'معاينة واجهة النظام' : 'معاينة واجهة الوحدة';
    return _buildPreview(
      context,
      state,
      title: title,
      previewSlug: selectedTarget.slug,
      badgeLabel: selectedTarget.label,
    );
  }

  Widget _buildMainTabs() {
    final currentTab = _effectiveTab(context);
    final tabs = const [
      _ManagementTab('layout', 'ترتيب الصفحة', Icons.view_quilt_rounded),
      _ManagementTab('identity', 'الهوية والبنية', Icons.style_rounded),
      _ManagementTab('content', 'المحتوى العام', Icons.article_rounded),
      _ManagementTab('navigation', 'التنقل والربط', Icons.route_rounded),
      _ManagementTab('governance', 'الحوكمة', Icons.rule_folder_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isActive = currentTab == tab.id;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _activeTab = tab.id),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF0B3A70)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab.icon,
                      size: 18,
                      color: isActive ? Colors.white : Colors.black54,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        tab.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabBody(
    BuildContext context,
    PwfHomepageSectionsState state,
    PwfHomepageSectionsManager manager,
  ) {
    switch (_effectiveTab(context)) {
      case 'identity':
        return _buildQuickLaunchWorkspace(
          context: context,
          state: state,
          manager: manager,
          title: 'الهوية والبنية العامة',
          subtitle:
              'تجميع العناصر السيادية المرتبطة بالهيدر والهيكل العام والشرائح والإطار البصري للواجهة العامة.',
          cards: const [
            _QuickLaunchCardData(
              'إدارة الصفحة الرئيسية',
              'التحكم بترتيب أقسام الصفحة الرئيسية العامة ومعاينتها ضمن عقد المنصة.',
              AppRoutes.adminHomeManagement,
              Icons.home_filled,
            ),
            _QuickLaunchCardData(
              'إدارة واجهات الوحدات',
              'إدارة الصفحة العامة لكل وحدة ومحتواها وترتيب أقسامها، منفصلة تمامًا عن شاشة Unit Pages التشغيلية القديمة.',
              AppRoutes.adminUnitSurfacesManagement,
              Icons.account_tree_rounded,
            ),
            _QuickLaunchCardData(
              'إدارة واجهات الأنظمة',
              'إدارة Hero وMain Navigation وBody صفحات الأنظمة داخل عقد المنصة الحاكم، دون خلطها مع وحدات المنصة.',
              AppRoutes.adminSystemSurfacesManagement,
              Icons.widgets_rounded,
            ),
            _QuickLaunchCardData(
              'إدارة الأجزاء الفرعية للوحدات',
              'استعادة شاشة Unit Pages التشغيلية القديمة كمسار مستقل، بعيدًا عن واجهات الوحدات العامة.',
              AppRoutes.adminUnitPagesExecution,
              Icons.view_list_rounded,
            ),
            _QuickLaunchCardData(
              'السلايدر / الهيرو',
              'إدارة الشرائح الرئيسية والرسائل البصرية الأولى في الواجهة العامة.',
              AppRoutes.adminHeroSlider,
              Icons.slideshow_rounded,
            ),
          ],
        );
      case 'content':
        return _buildQuickLaunchWorkspace(
          context: context,
          state: state,
          manager: manager,
          title: 'المحتوى العام',
          subtitle:
              'الوصول السريع إلى العناصر التحريرية التي تغذي الصفحة الرئيسية أو ترتبط بها مباشرة.',
          cards: const [
            _QuickLaunchCardData(
              'الأنشطة والفعاليات',
              'متابعة أنشطة الوزارة ومديرياتها كما تظهر في الواجهة العامة.',
              AppRoutes.adminActivitiesManagement,
              Icons.event_note_rounded,
            ),
            _QuickLaunchCardData(
              'الأخبار العاجلة',
              'إدارة الرسائل اللحظية والتنبيهات الأعلى تأثيرًا في الصفحة.',
              AppRoutes.adminBreakingNews,
              Icons.new_releases_rounded,
            ),
            _QuickLaunchCardData(
              'خطب الجمعة',
              'المنشورات والمواد الدينية العامة المرتبطة بخطب الجمعة.',
              AppRoutes.adminFridaySermons,
              Icons.record_voice_over_rounded,
            ),
            _QuickLaunchCardData(
              'معرض الوسائط',
              'ضبط المعرض الإعلامي والصور/الفيديوهات التي تغذي الصفحة العامة.',
              AppRoutes.adminSharedContent,
              Icons.perm_media_rounded,
            ),
          ],
        );
      case 'navigation':
        return _buildQuickLaunchWorkspace(
          context: context,
          state: state,
          manager: manager,
          title: 'التنقل والربط',
          subtitle:
              'الربط بين إدارة الصفحة الرئيسية وباقي وحدات المنصة التي تؤثر على التنقل والمداخل العامة.',
          cards: const [
            _QuickLaunchCardData(
              'إدارة واجهات الوحدات',
              'الانتقال إلى Workspace واجهات الوحدات وربطها بالـ slugs والوحدات الحقيقية من org_units.',
              AppRoutes.adminUnitSurfacesManagement,
              Icons.account_tree_rounded,
            ),
            _QuickLaunchCardData(
              'إدارة واجهات الأنظمة',
              'الانتقال إلى Workspace واجهات الأنظمة تحت نفس الـ shell العام للمنصة.',
              AppRoutes.adminSystemSurfacesManagement,
              Icons.widgets_rounded,
            ),
            _QuickLaunchCardData(
              'المؤسسات والوحدات',
              'التأكد من slugs والوحدات والأنظمة الممثلة داخل org_units قبل ربط الصفحات بها.',
              AppRoutes.adminOrgUnits,
              Icons.business_rounded,
            ),
            _QuickLaunchCardData(
              'المستخدمون',
              'متابعة صلاحيات ومستخدمي الإدارة المرتبطين بتحرير الواجهات العامة.',
              AppRoutes.adminUsers,
              Icons.people_alt_rounded,
            ),
          ],
        );
      case 'governance':
        return _buildGovernanceWorkspace(context);
      case 'layout':
      default:
        return _buildLayoutWorkspace(context, state, manager);
    }
  }

  Widget _buildLayoutWorkspace(
    BuildContext context,
    PwfHomepageSectionsState state,
    PwfHomepageSectionsManager manager,
  ) {
    return _buildResponsiveSplit(
      left: _buildLeftPanel(
        context,
        title: 'الأقسام (سحب/إفلات)',
        scopeSlug: 'home',
      ),
      right: _buildPreview(
        context,
        state,
        title: 'معاينة الصفحة الرئيسية',
        previewSlug: 'home',
        badgeLabel: 'home',
      ),
      leftHeight: 760,
      rightHeight: 1060,
    );
  }

  Widget _buildGovernanceWorkspace(BuildContext context) {
    final counts = {
      for (final scope in PwfDynamicComponentScope.values)
        scope: pwfDynamicComponentsByScope(scope).length,
    };

    final left = Container(
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
            'حوكمة الصفحة الديناميكية',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'هذا الجدول يثبت ما هو سيادي مركزي، وما هو مشترك مع الوحدات عبر slug، وما هو خدمة مركزية محقونة، مع الحفاظ على التطوير فوق الصفحة الحالية لا من الصفر.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(height: 1.5, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PwfDynamicComponentScope.values.map((scope) {
              final color = scope.color;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withValues(alpha: 0.22)),
                ),
                child: Text(
                  '${scope.labelAr}: ${counts[scope] ?? 0}',
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const _UnitPagesExecutionOverviewCard(),
          const SizedBox(height: 14),
          Expanded(
            child: ListView(
              children: [
                _buildGovernanceLegendCard(
                  context,
                  title: 'سيادي مركزي',
                  color: PwfDynamicComponentScope.sovereign.color,
                  description:
                      'مثل كلمة الوزير والرسالة والرؤيا والـ Hero؛ تُدار مركزيًا حتى عند ظهورها داخل الصفحة الديناميكية.',
                ),
                const SizedBox(height: 10),
                _buildGovernanceLegendCard(
                  context,
                  title: 'مشترك مع الوحدات',
                  color: PwfDynamicComponentScope.shared.color,
                  description:
                      'مثل الأخبار والأنشطة والتواصل والروابط؛ نوعها واحد لكن نطاقها يختلف بين home والـ slug.',
                ),
                const SizedBox(height: 10),
                _buildGovernanceLegendCard(
                  context,
                  title: 'خدمة مركزية محقونة',
                  color: PwfDynamicComponentScope.injected.color,
                  description:
                      'مثل مواقيت الصلاة وخطب الجمعة والقرآن والزكاة والشكاوى؛ تدار مركزيًا ثم تُحقن داخل الصفحة.',
                ),
                const SizedBox(height: 10),
                _buildGovernanceLegendCard(
                  context,
                  title: 'قالب / Shell',
                  color: PwfDynamicComponentScope.shell.color,
                  description:
                      'مثل Top Bar والهيدر العام؛ الشكل موحد لكن بعض البيانات داخله قد تصبح سياقية حسب slug.',
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Text(
                    'مهم: وجود Route إداري لا يعني اكتمال CRUD. هذا الجدول يثبت الحوكمة أولًا، ثم تُغلق الشاشات الناقصة تدريجيًا فوق الموجود.',
                    style: TextStyle(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final right = Container(
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
            'جدول المكونات الفعلي',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'مرجع تشغيلي يحدد لكل مكوّن: نطاقه، موضع ظهوره، وهل هو section حاليًا، وأين يُدار داخل لوحة التحكم.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(height: 1.5, color: Colors.black54),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.separated(
              itemCount: kPwfDynamicPageComponents.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = kPwfDynamicPageComponents[index];
                return _buildGovernanceRow(context, item);
              },
            ),
          ),
        ],
      ),
    );

    return _buildResponsiveSplit(
      left: left,
      right: right,
      leftHeight: 760,
      rightHeight: 1100,
    );
  }

  Widget _buildGovernanceLegendCard(
    BuildContext context, {
    required String title,
    required Color color,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLaunchWorkspace({
    required BuildContext context,
    required PwfHomepageSectionsState state,
    required PwfHomepageSectionsManager manager,
    required String title,
    required String subtitle,
    required List<_QuickLaunchCardData> cards,
  }) {
    final left = Container(
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
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(height: 1.5, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: cards.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final card = cards[index];
                return InkWell(
                  onTap: () => context.go(card.route),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0B3A70,
                            ).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            card.icon,
                            color: const Color(0xFF0B3A70),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                card.description,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      height: 1.4,
                                      color: Colors.black54,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.black45,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
    final right = _buildPreview(
      context,
      state,
      title: 'معاينة الصفحة الرئيسية',
      previewSlug: 'home',
      badgeLabel: 'home',
    );
    return _buildResponsiveSplit(left: left, right: right);
  }

  Widget _buildLeftPanel(
    BuildContext context, {
    String title = 'الأقسام (سحب/إفلات)',
    String? scopeSlug,
  }) {
    final state = ref.watch(pwfHomepageSectionsManagerProvider);
    final manager = ref.read(pwfHomepageSectionsManagerProvider.notifier);
    if (state.error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'حدث خطأ أثناء تحميل الأقسام',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(state.error!),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: manager.load,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final availableToAdd = kPwfHomeSections
        .where((d) => !state.draft.any((s) => s.sectionName == d.key))
        .toList();

    final grouped = _groupedSections(state.draft);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: availableToAdd.isEmpty
                      ? null
                      : () => _showAddSectionDialog(
                          context,
                          manager,
                          availableToAdd,
                        ),
                  icon: const Icon(Icons.add),
                  label: const Text('قسم جديد'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              scopeSlug == null || scopeSlug == 'home'
                  ? 'إعادة تنظيم الصفحة حسب الفئات المرجعية: بنية عامة، محتوى، وسائط وخدمات. يمكنك إعادة ترتيب العناصر القابلة للسحب فقط.'
                  : 'يمكنك إعادة ترتيب أقسام السطح المحدد ومعاينة النتيجة فورًا قبل الحفظ. العناصر المثبتة تبقى في مواضعها السيادية.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: grouped.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text('${entry.key}: ${entry.value.length}'),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            ReorderableListView.builder(
              shrinkWrap: true,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: state.draft.length,
              onReorder: (oldIndex, newIndex) =>
                  manager.reorder(oldIndex, newIndex),
              itemBuilder: (context, index) {
                final s = state.draft[index];
                final def = findPwfHomeSection(s.sectionName);
                final pinned = def?.isPinned ?? false;
                final family = _sectionFamilyLabel(s.sectionName);

                return Card(
                  key: ValueKey(s.sectionName),
                  child: ListTile(
                    title: Text(def?.titleAr ?? s.sectionName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${def?.titleEn ?? ''} • $family'),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _sectionVisibilityChips(s),
                        ),
                      ],
                    ),
                    leading: Switch(
                      value: s.isActive,
                      onChanged: (v) => manager.toggleActive(s.sectionName, v),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (pinned)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.push_pin, size: 18),
                          ),
                        ReorderableDragStartListener(
                          enabled: !pinned,
                          index: index,
                          child: Icon(
                            Icons.drag_handle,
                            color: pinned ? Colors.black26 : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              'ملاحظة: TopBar و MainNav مثبتان بالأعلى (غير قابلين للسحب)، و Footer مثبت دائمًا كآخر عنصر (غير قابل للسحب).',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(
    BuildContext context,
    PwfHomepageSectionsState state, {
    String title = 'معاينة الصفحة الرئيسية',
    String previewSlug = 'home',
    String? badgeLabel,
  }) {
    return PwfAdminSurfacePreviewFrame(
      title: title,
      subtitle: 'المسار: ${badgeLabel ?? previewSlug}',
      badge: badgeLabel ?? previewSlug,
      dirty: state.isDirty,
      child: PwfHomeSectionsRenderer(
        unitSlug: previewSlug,
        sections: state.draft,
      ),
    );
  }

  Future<void> _showAddSectionDialog(
    BuildContext context,
    PwfHomepageSectionsManager manager,
    List<PwfHomeSectionDef> available,
  ) async {
    String? selectedKey = available.first.key;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('إضافة قسم جديد'),
          content: DropdownButton<String>(
            value: selectedKey,
            items: available
                .map(
                  (d) => DropdownMenuItem(
                    value: d.key,
                    child: Text('${d.titleAr} — ${d.titleEn}'),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              selectedKey = v;
              (ctx as Element).markNeedsBuild();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () {
                if (selectedKey != null) manager.addSection(selectedKey!);
                Navigator.of(ctx).pop();
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResponsiveSplit({
    required Widget left,
    required Widget right,
    double? leftHeight,
    double? rightHeight,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportHeight =
            constraints.hasBoundedHeight &&
                constraints.maxHeight.isFinite &&
                constraints.maxHeight > 0
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;
        final viewportWidth =
            constraints.hasBoundedWidth &&
                constraints.maxWidth.isFinite &&
                constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final fallbackPanelHeight = viewportHeight < 560
            ? 560.0
            : viewportHeight;
        final leftPanelHeight = (leftHeight ?? fallbackPanelHeight)
            .clamp(560.0, 1400.0)
            .toDouble();
        final rightPanelHeight = (rightHeight ?? fallbackPanelHeight)
            .clamp(560.0, 1600.0)
            .toDouble();
        final maxPanelHeight = leftPanelHeight > rightPanelHeight
            ? leftPanelHeight
            : rightPanelHeight;
        final isWide = viewportWidth >= 1200;

        if (isWide) {
          const gap = 20.0;
          final safeWidth = viewportWidth.isFinite && viewportWidth > gap
              ? viewportWidth
              : 1200.0;
          final leftWidth = ((safeWidth - gap) * 5 / 12)
              .clamp(360.0, 620.0)
              .toDouble();
          final rightWidth = (safeWidth - gap - leftWidth)
              .clamp(520.0, 1100.0)
              .toDouble();

          return SingleChildScrollView(
            child: SizedBox(
              width: leftWidth + gap + rightWidth,
              height: maxPanelHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: leftWidth,
                    height: leftPanelHeight,
                    child: ClipRect(child: left),
                  ),
                  const SizedBox(width: gap),
                  SizedBox(
                    width: rightWidth,
                    height: rightPanelHeight,
                    child: ClipRect(child: right),
                  ),
                ],
              ),
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: SizedBox(
                width: viewportWidth,
                height: leftPanelHeight,
                child: ClipRect(child: left),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: SizedBox(
                width: viewportWidth,
                height: rightPanelHeight,
                child: ClipRect(child: right),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGovernanceRow(
    BuildContext context,
    PwfDynamicPageComponentDef item,
  ) {
    final scopeColor = item.scope.color;
    final chips = <Widget>[
      pwfBuildMiniChip(label: item.scope.labelAr, color: scopeColor),
      pwfBuildMiniChip(
        label: item.appearsOnHome ? 'يظهر في home' : 'ليس لـ home',
        color: item.appearsOnHome ? const Color(0xFF1565C0) : Colors.grey,
      ),
      pwfBuildMiniChip(
        label: item.appearsOnUnitSlug ? 'يظهر مع slug' : 'ليس للوحدات',
        color: item.appearsOnUnitSlug ? const Color(0xFF2E7D32) : Colors.grey,
      ),
      pwfBuildMiniChip(
        label: item.isSectionCatalogItem
            ? 'ضمن sections catalog'
            : 'خارج sections catalog',
        color: item.isSectionCatalogItem
            ? const Color(0xFF6A1B9A)
            : const Color(0xFF757575),
      ),
      if (item.usesInternalPublicContract)
        pwfBuildMiniChip(
          label: item.internalContractLabelAr,
          color: const Color(0xFF8D6E63),
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
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
                  color: scopeColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: scopeColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.titleAr,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.categoryAr,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              if (item.hasAdminRoute)
                OutlinedButton.icon(
                  onPressed: () => context.go(item.adminRoute!),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('إدارة'),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
          const SizedBox(height: 10),
          Text(
            'الجهة المديرة: ${item.managedByAr}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            item.notesAr,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              height: 1.55,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<String>> _groupedSections(List<dynamic> sections) {
    final map = <String, List<String>>{};
    for (final s in sections) {
      final family = _sectionFamilyLabel(s.sectionName);
      map.putIfAbsent(family, () => <String>[]).add(s.sectionName);
    }
    return map;
  }

  List<Widget> _sectionVisibilityChips(dynamic section) {
    final key = section.sectionName.toString();
    final isActive = section.isActive == true;
    final displayOrder = section.displayOrder;
    final chips = <Widget>[
      pwfBuildMiniChip(
        label: isActive ? 'ظاهر من DB' : 'مخفي من DB',
        color: isActive ? const Color(0xFF2E7D32) : const Color(0xFF9E9E9E),
      ),
      pwfBuildMiniChip(
        label: 'ترتيب $displayOrder',
        color: const Color(0xFF1565C0),
      ),
    ];

    if (key == 'pwf_public_services_catalog') {
      chips.addAll([
        pwfBuildMiniChip(
          label: 'مصدر البيانات public.services',
          color: const Color(0xFF8F1D1D),
        ),
        pwfBuildMiniChip(
          label: 'النطاق من homepage_sections',
          color: const Color(0xFF6A1B9A),
        ),
        pwfBuildMiniChip(
          label: 'العقارات الوقفية مؤجلة',
          color: const Color(0xFF795548),
        ),
      ]);
    }

    return chips;
  }

  String _sectionFamilyLabel(String key) {
    if (key == 'pwf_top_bar' || key == 'pwf_main_nav' || key == 'pwf_footer') {
      return 'البنية / القالب العام';
    }
    if (key.contains('hero') ||
        key.contains('breaking') ||
        key.contains('minister')) {
      return 'الهوية والسيادة';
    }
    if (key.contains('news') ||
        key.contains('announcements') ||
        key.contains('activities') ||
        key.contains('sermons')) {
      return 'المحتوى العام';
    }
    if (key.contains('media')) {
      return 'الوسائط';
    }
    if (key.contains('links') ||
        key.contains('services') ||
        key.contains('prayer') ||
        key.contains('map')) {
      return 'الخدمات والربط';
    }
    return 'أقسام أخرى';
  }

  Widget pwfBuildMiniChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ManagementTab {
  final String id;
  final String label;
  final IconData icon;
  const _ManagementTab(this.id, this.label, this.icon);
}

class _QuickLaunchCardData {
  final String title;
  final String description;
  final String route;
  final IconData icon;
  const _QuickLaunchCardData(
    this.title,
    this.description,
    this.route,
    this.icon,
  );
}

class _UnitPagesExecutionOverviewCard extends StatelessWidget {
  const _UnitPagesExecutionOverviewCard();

  @override
  Widget build(BuildContext context) {
    final closure = PwfAdminGovernanceContract.unitPagesClosureChecklist;
    final roles = PwfAdminGovernanceContract.pageManagerProfiles;
    final audits = PwfAdminGovernanceContract.auditVerificationItems;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F4C81).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF0F4C81).withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'إغلاق Unit Pages + مدراء الصفحات + Audit',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'هذه البطاقة تحوّل المرجع المدمج إلى حالة تنفيذية حيّة داخل إدارة الصفحة الرئيسية، حتى لا يبقى ملف Unit Pages أو صلاحيات مدراء الصفحات أو التحقق من الأوديت معرفةً منفصلة عن الشاشة نفسها.',
            style: TextStyle(color: Color(0xFF374151), height: 1.55),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _statusBadge(
                'بنود الإغلاق',
                '${closure.length}',
                const Color(0xFF0F4C81),
              ),
              _statusBadge(
                'مستويات الصلاحية',
                '${roles.length}',
                const Color(0xFF7A1F2B),
              ),
              _statusBadge(
                'محاور الأوديت',
                '${audits.length}',
                const Color(0xFF1F6B45),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...closure
              .take(3)
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: item.status.color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.description,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF4B5563),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: item.status.color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: item.status.color.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Text(
                          item.status.labelAr,
                          style: TextStyle(
                            color: item.status.color,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 6),
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

  Widget pwfBuildMiniChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _statusBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
}
