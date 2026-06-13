// lib/presentation/screens/admin/web_admin_dashboard.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/core/access/access_profile.dart';
import 'package:waqf/core/access/access_provider.dart';
import 'package:waqf/core/access/admin_route_access_contract.dart';
import 'package:waqf/core/access/user_dashboard_contract.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/core/enums/enums.dart';
import 'package:waqf/presentation/providers/auth_provider.dart';
import 'package:waqf/presentation/providers/user_dashboard_provider.dart';
import 'package:waqf/presentation/widgets/admin/user_access_overview_section.dart';
import 'package:waqf/features/platform/dynamic_systems/data/models/pwf_dynamic_system_models.dart';
import 'package:waqf/features/platform/dynamic_systems/presentation/providers/pwf_dynamic_system_registry_providers.dart';

class WebAdminDashboard extends ConsumerStatefulWidget {
  const WebAdminDashboard({super.key});

  @override
  ConsumerState<WebAdminDashboard> createState() => _WebAdminDashboardState();
}

class _WebAdminDashboardState extends ConsumerState<WebAdminDashboard> {
  String _selectedDashboard = 'main';
  bool _autoRefresh = false;
  int _refreshInterval = 30;
  bool _showAdvancedMetrics = false;
  String _selectedTimeRange = '7d';
  String _viewMode = 'charts';
  Timer? _refreshTimer;

  final List<DashboardType> _dashboardTypes = [
    DashboardType(
      id: 'main',
      name: 'الرئيسية',
      icon: Icons.home,
      description: 'نظرة عامة شاملة',
    ),
    DashboardType(
      id: 'financial',
      name: 'المالية',
      icon: Icons.attach_money,
      description: 'التقارير المالية',
    ),
    DashboardType(
      id: 'operations',
      name: 'العمليات',
      icon: Icons.settings,
      description: 'إدارة العمليات',
    ),
    DashboardType(
      id: 'analytics',
      name: 'التحليلات',
      icon: Icons.analytics,
      description: 'تحليلات متقدمة',
    ),
    DashboardType(
      id: 'security',
      name: 'الأمان',
      icon: Icons.security,
      description: 'مراقبة الأمان',
    ),
    DashboardType(
      id: 'performance',
      name: 'الأداء',
      icon: Icons.trending_up,
      description: 'مؤشرات الأداء',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _checkAuth() {
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      AppRoutes.pushAndClearStack(context, AppRoutes.adminLogin);
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    if (_autoRefresh) {
      _refreshTimer = Timer.periodic(
        Duration(seconds: _refreshInterval),
        (_) => setState(() {}),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(isAuthenticatedProvider, (previous, next) {
      if (!next) AppRoutes.pushAndClearStack(context, AppRoutes.adminLogin);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // REUSABLE SIDEBAR - Following DRY principle
          // MAIN CONTENT AREA
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildMainContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    final currentUser = ref.watch(currentUserProvider);
    final contract = ref
        .watch(currentUserDashboardContractProvider)
        .valueOrNull;
    final accessProfile = ref.watch(accessProfileProvider).valueOrNull;
    final hasOperationalAccess = _hasOperationalDashboardAccess(
      contract,
      accessProfile,
    );
    final isCentral = currentUser?.isCentral ?? false;
    final title = isCentral ? 'لوحة التحكم المركزية' : 'لوحة عملي';
    final subtitle = isCentral
        ? 'نظرة عامة موحدة على الأنظمة والسياسات والمحتوى'
        : 'الأنظمة والأدوات المتاحة لك بحسب دورك وصلاحياتك الحالية.';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F4C81),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF6B7280), height: 1.4),
              ),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (hasOperationalAccess) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'تحديث تلقائي',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F4C81),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: _autoRefresh,
                        onChanged: (value) => setState(() {
                          _autoRefresh = value;
                          _startAutoRefresh();
                        }),
                        activeThumbColor: const Color(0xFF0F4C81),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTimeRange,
                      items: const [
                        DropdownMenuItem(value: '24h', child: Text('24 ساعة')),
                        DropdownMenuItem(value: '7d', child: Text('7 أيام')),
                        DropdownMenuItem(value: '30d', child: Text('30 يوم')),
                        DropdownMenuItem(value: '1y', child: Text('سنة')),
                      ],
                      onChanged: (value) =>
                          setState(() => _selectedTimeRange = value!),
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('تحديث'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C81),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('تصدير'),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Badge(
                    label: const Text('5'),
                    child: const Icon(Icons.notifications_outlined),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Badge(
                    label: const Text('3'),
                    child: const Icon(Icons.mail_outline),
                  ),
                ),
              ] else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 18,
                        color: Color(0xFF92400E),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'وصول مقيد حسب الصلاحيات',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    final contractAsync = ref.watch(currentUserDashboardContractProvider);
    final accessProfile = ref.watch(accessProfileProvider).valueOrNull;

    return contractAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
        child: Text('تعذر تحميل عقد لوحة التحكم للمستخدم الحالي.'),
      ),
      data: (contract) {
        final hasOperationalAccess = _hasOperationalDashboardAccess(
          contract,
          accessProfile,
        );
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDashboardHero(),
              const SizedBox(height: 20),
              _buildCurrentUserAccessSection(),
              const SizedBox(height: 20),
              _buildAdminOrganizerHub(accessProfile),
              const SizedBox(height: 20),
              if (hasOperationalAccess) ...[
                _buildDashboardTypeSelector(),
                const SizedBox(height: 24),
                if (_showAdvancedMetrics) ...[
                  _buildAdvancedSettings(),
                  const SizedBox(height: 24),
                ],
                _buildDashboardContent(),
              ] else
                _buildRestrictedDashboardWorkspace(contract),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardHero() {
    final currentUser = ref.watch(currentUserProvider);
    final isCentral = currentUser?.isCentral ?? false;
    final scopeLabel = currentUser?.scopeLabel ?? 'مركزي';
    final username = (currentUser?.username ?? '').toString().trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCentral ? 'اللوحة المركزية للمنصة' : 'مساحة العمل الشخصية',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F4C81),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isCentral
                    ? 'واجهة موحدة لإدارة المنصة والأنظمة والمحتوى والمستخدمين ضمن نفس السجل المركزي.'
                    : 'لوحة ديناميكية تتغير تلقائيًا بحسب الأنظمة المسموحة لك ونطاقك الحالي داخل PalWakf.',
                style: const TextStyle(color: Color(0xFF6B7280), height: 1.6),
              ),
              if (currentUser != null) ...[
                const SizedBox(height: 10),
                Text(
                  '${currentUser.displayName}${username.isNotEmpty ? ' • @$username' : ''} • $scopeLabel',
                  style: const TextStyle(
                    color: Color(0xFF0F4C81),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroBadge(
                label: isCentral ? 'مركزي' : 'شخصي',
                icon: isCentral ? Icons.hub_outlined : Icons.person_outline,
              ),
              _HeroBadge(label: scopeLabel, icon: Icons.apartment_outlined),
              _HeroBadge(label: 'أنظمة متصلة', icon: Icons.widgets_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminOrganizerHub(AccessProfile? profile) {
    final dynamicSystems =
        ref.watch(visibleDynamicAdminSystemsProvider).valueOrNull ??
        const <PwfDynamicSystemModule>[];
    final rawGroups = <_AdminHubGroup>[
      _AdminHubGroup(
        id: 'general',
        title: 'الرئيسية',
        subtitle: 'مداخل سريعة إلى اللوحة والمساعد وإدارة المستخدمين والوحدات.',
        items: const [
          _AdminHubItem(
            'لوحة التحكم',
            AppRoutes.adminDashboard,
            Icons.dashboard_rounded,
          ),
          _AdminHubItem(
            'المساعد الداخلي',
            AppRoutes.adminAssistant,
            Icons.assistant_rounded,
          ),
          _AdminHubItem(
            'معاينة شات الجمهور',
            AppRoutes.adminChatbot,
            Icons.smart_toy_rounded,
          ),
          _AdminHubItem(
            'المستخدمون',
            AppRoutes.adminUsers,
            Icons.people_alt_rounded,
          ),
          _AdminHubItem(
            'المؤسسات والوحدات',
            AppRoutes.adminOrgUnits,
            Icons.account_tree_rounded,
          ),
        ],
      ),
      _AdminHubGroup(
        id: 'public',
        title: 'الواجهة العامة',
        subtitle:
            'إدارة الصفحة الرئيسية والهوية العامة والمحتوى التشغيلي العام.',
        items: const [
          _AdminHubItem(
            'إدارة الصفحة الرئيسية',
            AppRoutes.adminHomeManagement,
            Icons.home_filled,
          ),
          _AdminHubItem(
            'السلايدر / الهيرو',
            AppRoutes.adminHeroSlider,
            Icons.slideshow_rounded,
          ),
          _AdminHubItem(
            'الأخبار العاجلة',
            AppRoutes.adminBreakingNews,
            Icons.campaign_rounded,
          ),
          _AdminHubItem(
            'إدارة المحتوى المشترك',
            AppRoutes.adminSharedContent,
            Icons.dynamic_feed_rounded,
          ),
          _AdminHubItem(
            'الأنشطة والفعاليات',
            AppRoutes.adminActivitiesManagement,
            Icons.event_note_rounded,
          ),
          _AdminHubItem(
            'خطب الجمعة',
            AppRoutes.adminFridaySermons,
            Icons.mic_rounded,
          ),
        ],
      ),
      _AdminHubGroup(
        id: 'public_pages',
        title: 'الصفحات العامة',
        subtitle:
            'بوابة إدارية موحدة للصفحات العامة المكتملة وربطها بمصادرها الفعلية داخل المنصة.',
        items: const [
          _AdminHubItem(
            'بوابة الصفحات العامة',
            AppRoutes.adminPublicPagesHub,
            Icons.web_asset_rounded,
          ),
          _AdminHubItem(
            'عن الوزارة',
            AppRoutes.adminAboutPage,
            Icons.info_outline_rounded,
          ),
          _AdminHubItem(
            'كلمة الوزير',
            AppRoutes.adminMinisterPage,
            Icons.record_voice_over_outlined,
          ),
          _AdminHubItem(
            'الرؤية والرسالة',
            AppRoutes.adminVisionMissionPage,
            Icons.track_changes_outlined,
          ),
          _AdminHubItem(
            'الهيكل التنظيمي',
            AppRoutes.adminStructurePage,
            Icons.account_tree_outlined,
          ),
          _AdminHubItem(
            'الوزراء السابقون',
            AppRoutes.adminFormerMinistersPage,
            Icons.history_edu_outlined,
          ),
          _AdminHubItem(
            'الخدمات',
            AppRoutes.adminServicesPage,
            Icons.design_services_outlined,
          ),
          _AdminHubItem(
            'الخدمات الإلكترونية',
            AppRoutes.adminEServicesPage,
            Icons.computer_outlined,
          ),
          _AdminHubItem(
            'الاجتماعيات',
            AppRoutes.adminSocialServicesPage,
            Icons.people_outline_rounded,
          ),
          _AdminHubItem(
            'المشاريع',
            AppRoutes.adminProjectsPage,
            Icons.work_outline_rounded,
          ),
          _AdminHubItem(
            'اتصل بنا',
            AppRoutes.adminContactPage,
            Icons.contact_phone_outlined,
          ),
          _AdminHubItem(
            'سياسة الخصوصية',
            AppRoutes.adminPrivacyPage,
            Icons.privacy_tip_outlined,
          ),
          _AdminHubItem(
            'شروط الاستخدام',
            AppRoutes.adminTermsPage,
            Icons.rule_folder_outlined,
          ),
          _AdminHubItem(
            'خريطة الموقع',
            AppRoutes.adminSitemapPage,
            Icons.map_outlined,
          ),
        ],
      ),
      _AdminHubGroup(
        id: 'platform_services',
        title: 'خدمات المنصة',
        subtitle:
            'صفحات إدارية فعلية لخدمات المنصة العامة، منفصلة عن إدارة الصفحة الرئيسية نفسها.',
        items: const [
          _AdminHubItem(
            'خدمة الزكاة',
            AppRoutes.adminZakat,
            Icons.volunteer_activism_rounded,
          ),
          _AdminHubItem(
            'مواقيت الصلاة',
            AppRoutes.adminPrayerTimes,
            Icons.access_time_filled_rounded,
          ),
          _AdminHubItem(
            'القرآن الكريم',
            AppRoutes.adminQuran,
            Icons.menu_book_rounded,
          ),
        ],
      ),
      _AdminHubGroup(
        id: 'technical_services',
        title: 'الخدمات التقنية',
        subtitle:
            'مركز النسخ الاحتياطي والصيانة وصحة النظام والنشر والسجلات ضمن بوابات آمنة لا تنفذ إجراءات مؤثرة من Flutter.',
        items: const [
          _AdminHubItem(
            'الخدمات التقنية',
            AppRoutes.adminTechnicalServices,
            Icons.admin_panel_settings_rounded,
          ),
          _AdminHubItem(
            'النسخ الاحتياطي',
            AppRoutes.adminTechnicalServicesBackup,
            Icons.backup_rounded,
          ),
          _AdminHubItem(
            'وضع الصيانة',
            AppRoutes.adminTechnicalServicesMaintenance,
            Icons.construction_rounded,
          ),
          _AdminHubItem(
            'صحة النظام',
            AppRoutes.adminTechnicalServicesHealth,
            Icons.monitor_heart_rounded,
          ),
          _AdminHubItem(
            'النشر والإصدارات',
            AppRoutes.adminTechnicalServicesDeployment,
            Icons.rocket_launch_rounded,
          ),
          _AdminHubItem(
            'السجلات والتدقيق',
            AppRoutes.adminTechnicalServicesAudit,
            Icons.manage_search_rounded,
          ),
        ],
      ),
      _AdminHubGroup(
        id: 'systems',
        title: 'الأنظمة',
        subtitle:
            'الوصول المباشر إلى الأنظمة السيادية والتشغيلية من نفس البوابة.',
        items: const [
          _AdminHubItem(
            'نظام الأراضي الوقفية',
            AppRoutes.adminWaqfLands,
            Icons.landscape_rounded,
          ),
          _AdminHubItem(
            'نظام القضايا',
            AppRoutes.adminCases,
            Icons.gavel_rounded,
          ),
          _AdminHubItem(
            'نظام المهام',
            AppRoutes.adminTasks,
            Icons.task_alt_rounded,
          ),
          _AdminHubItem(
            'نظام الوثائق',
            AppRoutes.adminDocuments,
            Icons.folder_rounded,
          ),
          _AdminHubItem(
            'نظام المساجد',
            AppRoutes.adminMosques,
            Icons.mosque_rounded,
          ),
        ],
      ),
    ];

    final dynamicItems = _dynamicDashboardItems(dynamicSystems, profile);
    if (dynamicItems.isNotEmpty) {
      rawGroups.add(
        _AdminHubGroup(
          id: 'dynamic_systems',
          title: 'الأنظمة والأقسام الديناميكية',
          subtitle:
              'تظهر من platform.system_registry وplatform.system_sections حسب صلاحيات المستخدم.',
          items: dynamicItems,
        ),
      );
    }

    final groups = rawGroups
        .map((group) => _filterDashboardGroupForAccess(group, profile))
        .where((group) => group.items.isNotEmpty)
        .toList(growable: false);

    if (groups.isEmpty) {
      return _buildRestrictedDashboardWorkspace(
        ref.watch(currentUserDashboardContractProvider).valueOrNull,
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تنظيم لوحة التحكم',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'إعادة تجميع الوصول الإداري وفق الفئات المرجعية للوحة القديمة ولكن بصيغة أحدث وأكثر وضوحًا.',
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isTight = constraints.maxWidth < 1120;
                return Column(
                  children: groups.map((group) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppConstants.islamicGreen.withValues(
                                      alpha: 0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.grid_view_rounded,
                                    color: AppConstants.islamicGreen,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        group.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        group.subtitle,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: Colors.grey[700],
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: group.items.map((item) {
                                final width = isTight
                                    ? (constraints.maxWidth - 64)
                                    : 220.0;
                                return InkWell(
                                  onTap: () => AppRoutes.pushReplacement(
                                    context,
                                    item.route,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: width.clamp(180.0, 240.0),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: AppConstants.islamicGreen
                                                .withValues(alpha: 0.10),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            item.icon,
                                            color: AppConstants.islamicGreen,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            item.label,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<_AdminHubItem> _dynamicDashboardItems(
    List<PwfDynamicSystemModule> systems,
    AccessProfile? profile,
  ) {
    final items = <_AdminHubItem>[];
    for (final system in systems) {
      if (!system.isActive || !system.showInDashboard) continue;
      if (profile != null &&
          !profile.isSuperuser &&
          !profile.canAccessDynamicSystem(system.systemKey))
        continue;
      items.add(
        _AdminHubItem(system.nameAr, system.routeForShell(), system.icon),
      );
      for (final section in system.sections) {
        if (!section.isActive || !section.showInDashboard) continue;
        if (profile != null &&
            !profile.isSuperuser &&
            !profile.canAccessDynamicSection(
              system.systemKey,
              requiredPermissionKey: section.requiredPermissionKey,
            )) {
          continue;
        }
        items.add(
          _AdminHubItem(section.titleAr, section.routePath, section.icon),
        );
      }
    }
    return items;
  }

  String? _dynamicSystemKeyFromRoute(String route) {
    final segments = Uri.parse(route).pathSegments;
    if (segments.length >= 3 &&
        segments[0] == 'admin' &&
        segments[1] == 'systems') {
      return Uri.decodeComponent(segments[2]);
    }
    return null;
  }

  _AdminHubGroup _filterDashboardGroupForAccess(
    _AdminHubGroup group,
    AccessProfile? profile,
  ) {
    final items = group.items
        .where((item) => _canShowDashboardHubItem(item, profile))
        .toList(growable: false);
    return _AdminHubGroup(
      id: group.id,
      title: group.title,
      subtitle: group.subtitle,
      items: items,
    );
  }

  bool _canShowDashboardHubItem(_AdminHubItem item, AccessProfile? profile) {
    final route = _normalizeRoute(item.route);
    if (_dashboardCommonRoutes.contains(route)) return true;
    if (profile == null || !profile.isActive) return false;
    if (profile.isSuperuser) return true;
    final dynamicSystemKey = _dynamicSystemKeyFromRoute(route);
    if (dynamicSystemKey != null)
      return profile.canAccessDynamicSystem(dynamicSystemKey);
    final contract = AdminRouteAccessContracts.contractFor(route);
    if (contract != null) return contract.allows(profile);
    return _allowsKnownUncontractedDashboardRoute(route, profile);
  }

  bool _allowsKnownUncontractedDashboardRoute(
    String route,
    AccessProfile profile,
  ) {
    if (profile.canManagePlatformAdmin()) return true;
    if (route.startsWith('/admin/public-pages')) {
      return profile.hasRoleAtLeast(SystemKey.site, UserRole.user) ||
          profile.can(SystemKey.site, Permission.read) ||
          profile.can(SystemKey.site, Permission.manageSite);
    }
    return false;
  }

  bool _hasOperationalDashboardAccess(
    UserDashboardContract? contract,
    AccessProfile? profile,
  ) {
    if (profile?.isSuperuser == true) return true;
    if (profile == null || !profile.isActive) return false;
    if (contract?.visibleSystemsCount != null &&
        contract!.visibleSystemsCount > 0)
      return true;
    if (contract?.adminTools.isNotEmpty == true) return true;
    if (profile.roles.isNotEmpty || profile.dynamicRoles.isNotEmpty)
      return true;
    if (profile.dynamicPermissions.values.any(
      (permissions) => permissions.isNotEmpty,
    ))
      return true;
    return profile.permissions.values.any(
      (permissions) => permissions.isNotEmpty,
    );
  }

  String _normalizeRoute(String? route) {
    final value = (route ?? '').trim();
    if (value.isEmpty) return '';
    final noQuery = value.split('?').first;
    if (noQuery.length > 1 && noQuery.endsWith('/'))
      return noQuery.substring(0, noQuery.length - 1);
    return noQuery;
  }

  static const _dashboardCommonRoutes = <String>{
    AppRoutes.adminDashboard,
    AppRoutes.adminMyActivity,
    AppRoutes.adminProfile,
    AppRoutes.adminUsageGuide,
    AppRoutes.adminAssistant,
  };

  Widget _buildRestrictedDashboardWorkspace(UserDashboardContract? contract) {
    final quickItems = <_AdminHubItem>[
      const _AdminHubItem(
        'نشاطي',
        AppRoutes.adminMyActivity,
        Icons.history_rounded,
      ),
      const _AdminHubItem(
        'المساعد الداخلي',
        AppRoutes.adminAssistant,
        Icons.assistant_rounded,
      ),
      const _AdminHubItem(
        'دليل الاستخدام',
        AppRoutes.adminUsageGuide,
        Icons.menu_book_rounded,
      ),
      const _AdminHubItem(
        'الملف الشخصي',
        AppRoutes.adminProfile,
        Icons.person_outline_rounded,
      ),
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFF92400E),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'لوحة محدودة حسب الصلاحيات',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contract == null
                            ? 'لم يتم تحميل عقد الوصول بعد. لا يتم عرض كروت تشغيلية حتى يثبت النظام صلاحيات المستخدم.'
                            : 'لا توجد أنظمة أو صلاحيات تشغيلية مرتبطة بحسابك الحالي. يمكنك استخدام الأدوات الشخصية والمساعد الداخلي ضمن نطاق إرشادي مقيّد فقط.',
                        style: TextStyle(color: Colors.grey[700], height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final item in quickItems)
                  InkWell(
                    onTap: () => AppRoutes.pushReplacement(context, item.route),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 230,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppConstants.islamicGreen.withValues(
                                alpha: 0.10,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              item.icon,
                              color: AppConstants.islamicGreen,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
    );
  }

  Widget _buildCurrentUserAccessSection() {
    final contractAsync = ref.watch(currentUserDashboardContractProvider);

    return contractAsync.when(
      data: (contract) {
        if (contract == null) {
          return const SizedBox.shrink();
        }
        return UserAccessOverviewSection(contract: contract);
      },
      loading: () => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildDashboardTypeSelector() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'نوع لوحة التحكم',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(
                        () => _showAdvancedMetrics = !_showAdvancedMetrics,
                      ),
                      icon: const Icon(Icons.settings, size: 18),
                      label: const Text('إعدادات متقدمة'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => setState(() {
                        _selectedDashboard = 'main';
                        _autoRefresh = false;
                        _showAdvancedMetrics = false;
                      }),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('إعادة تعيين'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _dashboardTypes.map((dashboard) {
                final isActive = _selectedDashboard == dashboard.id;
                return InkWell(
                  onTap: () =>
                      setState(() => _selectedDashboard = dashboard.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 180,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppConstants.islamicGreen
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive
                            ? AppConstants.islamicGreen
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppConstants.islamicGreen.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          dashboard.icon,
                          size: 32,
                          color: isActive
                              ? Colors.white
                              : AppConstants.islamicGreen,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          dashboard.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dashboard.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive
                                ? Colors.white.withValues(alpha: 0.9)
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الإعدادات المتقدمة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'فترة التحديث (ثانية)',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        initialValue: _refreshInterval,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 10, child: Text('10 ثوانٍ')),
                          DropdownMenuItem(value: 30, child: Text('30 ثانية')),
                          DropdownMenuItem(
                            value: 60,
                            child: Text('دقيقة واحدة'),
                          ),
                          DropdownMenuItem(value: 300, child: Text('5 دقائق')),
                        ],
                        onChanged: (value) => setState(() {
                          _refreshInterval = value!;
                          _startAutoRefresh();
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'عرض البيانات',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  setState(() => _viewMode = 'charts'),
                              icon: const Icon(Icons.bar_chart, size: 18),
                              label: const Text('رسوم'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _viewMode == 'charts'
                                    ? AppConstants.islamicGreen
                                    : Colors.grey[300],
                                foregroundColor: _viewMode == 'charts'
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  setState(() => _viewMode = 'tables'),
                              icon: const Icon(Icons.table_chart, size: 18),
                              label: const Text('جداول'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _viewMode == 'tables'
                                    ? AppConstants.islamicGreen
                                    : Colors.grey[300],
                                foregroundColor: _viewMode == 'tables'
                                    ? Colors.white
                                    : Colors.black87,
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
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent() {
    switch (_selectedDashboard) {
      case 'financial':
        return _buildFinancialDashboard();
      case 'security':
        return _buildSecurityDashboard();
      case 'analytics':
        return _buildAnalyticsDashboard();
      case 'performance':
        return _buildPerformanceDashboard();
      default:
        return _buildMainDashboard();
    }
  }

  Widget _buildMainDashboard() {
    return Column(
      children: [
        _buildStatisticsRow(),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildMonthlyChart()),
            const SizedBox(width: 24),
            Expanded(flex: 1, child: _buildPieChart()),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildRecentActivity()),
            const SizedBox(width: 24),
            Expanded(flex: 1, child: _buildSystemStatus()),
          ],
        ),
      ],
    );
  }

  // FIX FOR OVERFLOW - Replace _buildStatisticsRow method

  Widget _buildStatisticsRow() {
    final stats = [
      {
        'title': 'القضايا المفتوحة',
        'value': '45',
        'icon': Icons.gavel,
        'color': AppColors.islamicGreen,
        'trend': '+12%',
      },
      {
        'title': 'الأراضي الوقفية',
        'value': '1,247',
        'icon': Icons.landscape,
        'color': AppColors.goldenYellow,
        'trend': '+5%',
      },
      {
        'title': 'الوثائق',
        'value': '15,432',
        'icon': Icons.folder,
        'color': AppColors.info,
        'trend': '+8%',
      },
      {
        'title': 'المستخدمون',
        'value': '156',
        'icon': Icons.people,
        'color': AppColors.success,
        'trend': '+3',
      },
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        const spacing = 16.0;
        final crossAxisCount = availableWidth < 560
            ? 1
            : availableWidth < 900
            ? 2
            : 4;
        final itemWidth =
            ((availableWidth - (spacing * (crossAxisCount - 1))) /
                    crossAxisCount)
                .clamp(0.0, availableWidth)
                .toDouble();

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final stat in stats)
              SizedBox(
                width: itemWidth,
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (stat['color'] as Color).withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                stat['icon'] as IconData,
                                color: stat['color'] as Color,
                                size: 20,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                stat['trend'] as String,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            stat['value'] as String,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          stat['title'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMonthlyChart() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'النشاط الشهري',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 400,
                  barGroups: List.generate(
                    6,
                    (i) => BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: (i + 1) * 50.0,
                          color: AppConstants.islamicGreen,
                          width: 40,
                        ),
                      ],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text(
                          ['ينا', 'فبر', 'مار', 'أبر', 'ماي', 'يون'][value
                              .toInt()],
                        ),
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'توزيع القضايا',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: AppColors.success,
                      value: 35,
                      title: '٣٥',
                      radius: 60,
                    ),
                    PieChartSectionData(
                      color: AppColors.warning,
                      value: 25,
                      title: '٢٥',
                      radius: 60,
                    ),
                    PieChartSectionData(
                      color: AppColors.info,
                      value: 15,
                      title: '١٥',
                      radius: 60,
                    ),
                  ],
                  sectionsSpace: 3,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'النشاط الأخير',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppConstants.islamicGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.notifications,
                        color: AppConstants.islamicGreen,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'نشاط رقم ${i + 1}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'منذ ${i + 1} ساعة',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'حالة النظام',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              4,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(['المعالج', 'الذاكرة', 'التخزين', 'الشبكة'][i]),
                        Text(
                          '${(i + 1) * 20}%',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (i + 1) * 0.2,
                      backgroundColor: Colors.grey[200],
                      color: AppConstants.islamicGreen,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialDashboard() => const Center(
    child: Text(
      'لوحة المالية',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
  );
  Widget _buildSecurityDashboard() => const Center(
    child: Text(
      'لوحة الأمان',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
  );
  Widget _buildAnalyticsDashboard() => const Center(
    child: Text(
      'لوحة التحليلات',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
  );
  Widget _buildPerformanceDashboard() => const Center(
    child: Text(
      'لوحة الأداء',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
  );
}

class _HeroBadge extends StatelessWidget {
  final String label;
  final IconData icon;

  const _HeroBadge({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF0F4C81)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0F4C81),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminHubGroup {
  final String id;
  final String title;
  final String subtitle;
  final List<_AdminHubItem> items;
  const _AdminHubGroup({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.items,
  });
}

class _AdminHubItem {
  final String label;
  final String route;
  final IconData icon;
  const _AdminHubItem(this.label, this.route, this.icon);
}

class DashboardType {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  DashboardType({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });
}
