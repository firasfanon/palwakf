// lib/presentation/screens/admin/web_admin_dashboard.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/presentation/providers/auth_provider.dart';
import 'package:waqf/presentation/widgets/web/web_sidebar.dart';


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
    DashboardType(id: 'main', name: 'الرئيسية', icon: Icons.home, description: 'نظرة عامة شاملة'),
    DashboardType(id: 'financial', name: 'المالية', icon: Icons.attach_money, description: 'التقارير المالية'),
    DashboardType(id: 'operations', name: 'العمليات', icon: Icons.settings, description: 'إدارة العمليات'),
    DashboardType(id: 'analytics', name: 'التحليلات', icon: Icons.analytics, description: 'تحليلات متقدمة'),
    DashboardType(id: 'security', name: 'الأمان', icon: Icons.security, description: 'مراقبة الأمان'),
    DashboardType(id: 'performance', name: 'الأداء', icon: Icons.trending_up, description: 'مؤشرات الأداء'),
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
      _refreshTimer = Timer.periodic(Duration(seconds: _refreshInterval), (_) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(isAuthenticatedProvider, (previous, next) {
      if (!next) AppRoutes.pushAndClearStack(context, AppRoutes.adminLogin);
    });

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      body: Row(
        children: [
          // REUSABLE SIDEBAR - Following DRY principle
          WebSidebar(currentRoute: AppRoutes.adminDashboard),
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
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            const Text('لوحة التحكم المتقدمة', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppConstants.islamicGreen)),
            const Spacer(),
            Row(
              children: [
                Text('تحديث تلقائي:', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                const SizedBox(width: 8),
                Switch(
                  value: _autoRefresh,
                  onChanged: (value) => setState(() {
                    _autoRefresh = value;
                    _startAutoRefresh();
                  }),
                  activeThumbColor: AppConstants.islamicGreen,
                ),
              ],
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTimeRange,
                  items: const [
                    DropdownMenuItem(value: '24h', child: Text('24 ساعة')),
                    DropdownMenuItem(value: '7d', child: Text('7 أيام')),
                    DropdownMenuItem(value: '30d', child: Text('30 يوم')),
                    DropdownMenuItem(value: '1y', child: Text('سنة')),
                  ],
                  onChanged: (value) => setState(() => _selectedTimeRange = value!),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, size: 18),
              label: const Text('تصدير'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.sageGreen),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('تحديث'),
              style: ElevatedButton.styleFrom(backgroundColor: AppConstants.islamicGreen),
            ),
            const SizedBox(width: 16),
            IconButton(onPressed: () {}, icon: Badge(label: const Text('5'), child: const Icon(Icons.notifications_outlined))),
            const SizedBox(width: 8),
            IconButton(onPressed: () {}, icon: Badge(label: const Text('3'), child: const Icon(Icons.mail_outline))),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDashboardTypeSelector(),
          const SizedBox(height: 24),
          if (_showAdvancedMetrics) ...[_buildAdvancedSettings(), const SizedBox(height: 24)],
          _buildDashboardContent(),
        ],
      ),
    );
  }

  Widget _buildDashboardTypeSelector() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('نوع لوحة التحكم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(() => _showAdvancedMetrics = !_showAdvancedMetrics),
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
                  onTap: () => setState(() => _selectedDashboard = dashboard.id),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 180,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isActive ? AppConstants.islamicGreen : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isActive ? AppConstants.islamicGreen : Colors.grey[300]!, width: 2),
                      boxShadow: isActive ? [BoxShadow(color: AppConstants.islamicGreen.withValues(alpha:0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
                    ),
                    child: Column(
                      children: [
                        Icon(dashboard.icon, size: 32, color: isActive ? Colors.white : AppConstants.islamicGreen),
                        const SizedBox(height: 12),
                        Text(dashboard.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isActive ? Colors.white : Colors.black87)),
                        const SizedBox(height: 4),
                        Text(dashboard.description, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: isActive ? Colors.white.withValues(alpha:0.9) : Colors.grey[600])),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('الإعدادات المتقدمة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('فترة التحديث (ثانية)', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        initialValue: _refreshInterval,
                        decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        items: const [
                          DropdownMenuItem(value: 10, child: Text('10 ثوانٍ')),
                          DropdownMenuItem(value: 30, child: Text('30 ثانية')),
                          DropdownMenuItem(value: 60, child: Text('دقيقة واحدة')),
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
                      const Text('عرض البيانات', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => setState(() => _viewMode = 'charts'),
                              icon: const Icon(Icons.bar_chart, size: 18),
                              label: const Text('رسوم'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _viewMode == 'charts' ? AppConstants.islamicGreen : Colors.grey[300],
                                foregroundColor: _viewMode == 'charts' ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => setState(() => _viewMode = 'tables'),
                              icon: const Icon(Icons.table_chart, size: 18),
                              label: const Text('جداول'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _viewMode == 'tables' ? AppConstants.islamicGreen : Colors.grey[300],
                                foregroundColor: _viewMode == 'tables' ? Colors.white : Colors.black87,
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
      {'title': 'القضايا المفتوحة', 'value': '45', 'icon': Icons.gavel, 'color': AppColors.islamicGreen, 'trend': '+12%'},
      {'title': 'الأراضي الوقفية', 'value': '1,247', 'icon': Icons.landscape, 'color': AppColors.goldenYellow, 'trend': '+5%'},
      {'title': 'الوثائق', 'value': '15,432', 'icon': Icons.folder, 'color': AppColors.info, 'trend': '+8%'},
      {'title': 'المستخدمون', 'value': '156', 'icon': Icons.people, 'color': AppColors.success, 'trend': '+3'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2, // ← INCREASE THIS
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14), // ← REDUCE
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8), // ← REDUCE
                      decoration: BoxDecoration(
                        color: (stat['color'] as Color).withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(stat['icon'] as IconData, color: stat['color'] as Color, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(stat['trend'] as String, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success)),
                    ),
                  ],
                ),
                const Spacer(),
                Text(stat['value'] as String, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(stat['title'] as String, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildMonthlyChart() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('النشاط الشهري', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 400,
                  barGroups: List.generate(6, (i) => BarChartGroupData(x: i, barRods: [BarChartRodData(toY: (i + 1) * 50.0, color: AppConstants.islamicGreen, width: 40)])),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Text(['ينا', 'فبر', 'مار', 'أبر', 'ماي', 'يون'][value.toInt()]))),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('توزيع القضايا', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(color: AppColors.success, value: 35, title: '٣٥', radius: 60),
                    PieChartSectionData(color: AppColors.warning, value: 25, title: '٢٥', radius: 60),
                    PieChartSectionData(color: AppColors.info, value: 15, title: '١٥', radius: 60),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('النشاط الأخير', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        decoration: BoxDecoration(color: AppConstants.islamicGreen.withValues(alpha:0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.notifications, color: AppConstants.islamicGreen, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('نشاط رقم ${i + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text('منذ ${i + 1} ساعة', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('حالة النظام', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                          Text('${(i + 1) * 20}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: (i + 1) * 0.2, backgroundColor: Colors.grey[200], color: AppConstants.islamicGreen),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialDashboard() => const Center(child: Text('لوحة المالية', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
  Widget _buildSecurityDashboard() => const Center(child: Text('لوحة الأمان', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
  Widget _buildAnalyticsDashboard() => const Center(child: Text('لوحة التحليلات', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
  Widget _buildPerformanceDashboard() => const Center(child: Text('لوحة الأداء', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)));
}

class DashboardType {
  final String id;
  final String name;
  final IconData icon;
  final String description;
  DashboardType({required this.id, required this.name, required this.icon, required this.description});
}