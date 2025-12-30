// lib/presentation/screens/admin/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/presentation/providers/auth_provider.dart';
import 'package:waqf/presentation/widgets/common/admin_app_bar.dart';


class MobileAdminDashboard extends ConsumerStatefulWidget {
  const MobileAdminDashboard({super.key});

  @override
  ConsumerState<MobileAdminDashboard> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<MobileAdminDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Check authentication on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  void _checkAuth() {
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      AppRoutes.pushAndClearStack(context, AppRoutes.adminLogin);
    }
  }

  final List<DashboardModule> _modules = [
    const DashboardModule(
      title: 'إدارة القضايا',
      icon: Icons.gavel,
      route: AppRoutes.adminCases,
      color: AppColors.islamicGreen,
      count: 45,
      description: 'القضايا المفتوحة',
    ),
    const DashboardModule(
      title: 'الأراضي الوقفية',
      icon: Icons.landscape,
      route: AppRoutes.adminWaqfLands,
      color: AppColors.goldenYellow,
      count: 128,
      description: 'عقار وقفي',
    ),
    const DashboardModule(
      title: 'إدارة الوثائق',
      icon: Icons.folder,
      route: AppRoutes.adminDocuments,
      color: AppColors.info,
      count: 1520,
      description: 'وثيقة',
    ),
    const DashboardModule(
      title: 'المساجد',
      icon: Icons.mosque,
      route: '/admin/mosques',
      color: AppColors.success,
      count: 89,
      description: 'مسجد مسجل',
    ),
    const DashboardModule(
      title: 'الأنشطة',
      icon: Icons.event,
      route: '/admin/activities',
      color: Colors.purple,
      count: 23,
      description: 'نشاط فعال',
    ),
    const DashboardModule(
      title: 'المستخدمين',
      icon: Icons.people,
      route: '/admin/users',
      color: AppColors.sageGreen,
      count: 67,
      description: 'مستخدم نشط',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    // Listen for auth changes
    ref.listen(isAuthenticatedProvider, (previous, next) {
      if (!next) {
        AppRoutes.pushAndClearStack(context, AppRoutes.adminLogin);
      }
    });

    return Scaffold(
      appBar: AdminAppBar(
        title: 'لوحة التحكم الإدارية',
        showBackButton: false,
        actions: [
          // User profile button
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: AppColors.goldenYellow,
              child: Text(
                currentUser?.name.substring(0, 1) ?? 'A',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            offset: const Offset(0, 50),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentUser?.name ?? 'مستخدم',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentUser?.email ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.islamicGreen.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        currentUser?.role ?? '',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.islamicGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 12),
                    Text('الملف الشخصي'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 12),
                    Text('الإعدادات'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: AppColors.error),
                    SizedBox(width: 12),
                    Text('تسجيل الخروج', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
            onSelected: _handleMenuAction,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section with user info
            _buildWelcomeSection(currentUser),

            const SizedBox(height: 24),

            // Statistics Cards
            _buildStatisticsCards(),

            const SizedBox(height: 24),

            // Charts Section
            _buildChartsSection(),

            const SizedBox(height: 24),

            // Quick Actions
            _buildQuickActions(),

            const SizedBox(height: 24),

            // Recent Activity
            _buildRecentActivity(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildWelcomeSection(currentUser) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        gradient: AppColors.islamicGradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً ${currentUser?.name ?? 'مستخدم'}',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentUser?.department ?? 'نظام إدارة وزارة الأوقاف والشؤون الدينية',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withValues(alpha:0.9),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'آخر تحديث: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha:0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.dashboard,
              size: 30,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات سريعة',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: _modules.length,
          itemBuilder: (context, index) {
            final module = _modules[index];
            return _buildStatCard(module);
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(DashboardModule module) {
    return Card(
      child: InkWell(
        onTap: () => context.go(module.route),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: module.color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  module.icon,
                  color: module.color,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${module.count}',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: module.color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                module.description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                module.title,
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التقارير والإحصائيات',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildCasesChart()),
            const SizedBox(width: 12),
            Expanded(child: _buildWaqfChart()),
          ],
        ),
      ],
    );
  }

  Widget _buildCasesChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'حالة القضايا',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: AppColors.success,
                      value: 35,
                      title: 'مُحلّة\n35',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: AppColors.warning,
                      value: 25,
                      title: 'قيد المراجعة\n25',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: AppColors.info,
                      value: 15,
                      title: 'جديدة\n15',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaqfChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الأراضي الوقفية حسب المحافظة',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 50,
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(toY: 45, color: AppColors.islamicGreen, width: 16)
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(toY: 32, color: AppColors.goldenYellow, width: 16)
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(toY: 28, color: AppColors.info, width: 16)
                    ]),
                    BarChartGroupData(x: 3, barRods: [
                      BarChartRodData(toY: 23, color: AppColors.success, width: 16)
                    ]),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const titles = ['القدس', 'رام الله', 'نابلس', 'الخليل'];
                          if (value.toInt() < titles.length) {
                            return Text(
                              titles[value.toInt()],
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final quickActions = [
      QuickAction(
        title: 'إضافة قضية جديدة',
        icon: Icons.add_circle,
        color: AppColors.islamicGreen,
        onTap: () {},
      ),
      QuickAction(
        title: 'تسجيل وثيقة',
        icon: Icons.upload_file,
        color: AppColors.info,
        onTap: () {},
      ),
      QuickAction(
        title: 'إنشاء تقرير',
        icon: Icons.assessment,
        color: AppColors.warning,
        onTap: () {},
      ),
      QuickAction(
        title: 'إدارة المستخدمين',
        icon: Icons.people_alt,
        color: AppColors.sageGreen,
        onTap: () {},
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إجراءات سريعة',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: quickActions.length,
          itemBuilder: (context, index) {
            final action = quickActions[index];
            return Card(
              child: InkWell(
                onTap: action.onTap,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingM),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: action.color.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          action.icon,
                          color: action.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          action.title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'النشاطات الأخيرة',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.islamicGreen.withValues(alpha:0.1),
                  child: const Icon(
                    Icons.notifications,
                    color: AppColors.islamicGreen,
                    size: 20,
                  ),
                ),
                title: Text(
                  'تم إنشاء قضية جديدة #${1000 + index}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'منذ ${index + 1} ساعة',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.sageGreen,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'الرئيسية',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.gavel),
          label: 'القضايا',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.landscape),
          label: 'الأوقاف',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder),
          label: 'الوثائق',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'الإعدادات',
        ),
      ],
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'profile':
        _showProfileDialog();
        break;
      case 'settings':
      // Navigate to settings
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الإعدادات')),
        );
        break;
      case 'logout':
        _showLogoutDialog();
        break;
    }
  }

  void _showProfileDialog() {
    final user = ref.read(currentUserProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الملف الشخصي'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileRow('الاسم', user?.name ?? ''),
            _buildProfileRow('البريد الإلكتروني', user?.email ?? ''),
            _buildProfileRow('الدور', user?.role ?? ''),
            if (user?.department != null)
              _buildProfileRow('القسم', user!.department!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to edit profile
            },
            child: const Text('تعديل'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // Logout
              await ref.read(authStateProvider.notifier).logout();

              // Navigation handled by listener
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}

class DashboardModule {
  final String title;
  final IconData icon;
  final String route;
  final Color color;
  final int count;
  final String description;

  const DashboardModule({
    required this.title,
    required this.icon,
    required this.route,
    required this.color,
    required this.count,
    required this.description,
  });
}

class QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}