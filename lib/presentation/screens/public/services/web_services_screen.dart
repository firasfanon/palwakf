// lib/presentation/screens/public/services/web_services_screen.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../widgets/web/web_app_bar.dart';
import '../../../widgets/web/web_footer.dart';
import '../../../widgets/web/web_container.dart';
import '../../../widgets/common/app_filter_chip.dart';

class WebServicesScreen extends StatefulWidget {
  const WebServicesScreen({super.key});

  @override
  State<WebServicesScreen> createState() => _WebServicesScreenState();
}

class _WebServicesScreenState extends State<WebServicesScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  final List<String> _categories = [
    'جميع الخدمات',
    'خدمات المساجد',
    'الأوقاف الإسلامية',
    'الشؤون الدينية',
    'التعليم الديني',
    'الحج والعمرة',
    'الفتاوى والإرشاد',
    'خدمات إدارية',
  ];

  final List<Map<String, dynamic>> _services = [
    {
      'id': 1,
      'title': 'ترخيص الخطابة',
      'description': 'الحصول على ترخيص رسمي لممارسة الخطابة في المساجد',
      'category': 'خدمات المساجد',
      'icon': Icons.mic,
      'status': 'متاح',
      'color': AppColors.islamicGreen,
      'requirements': ['نسخة من الهوية', 'شهادة دراسية', 'حسن سيرة وسلوك'],
      'duration': '٧-١٠ أيام عمل',
    },
    {
      'id': 2,
      'title': 'تسجيل مسجد جديد',
      'description': 'تسجيل مسجد جديد في سجلات الوزارة',
      'category': 'خدمات المساجد',
      'icon': Icons.mosque,
      'status': 'متاح',
      'color': AppColors.success,
      'requirements': ['مخططات البناء', 'رخصة البناء', 'موقع المسجد'],
      'duration': '١٥-٢٠ يوم عمل',
    },
    {
      'id': 3,
      'title': 'طلب دعم مالي',
      'description': 'تقديم طلب للحصول على دعم مالي للمساجد أو المشاريع الوقفية',
      'category': 'الأوقاف الإسلامية',
      'icon': Icons.attach_money,
      'status': 'متاح',
      'color': AppColors.goldenYellow,
      'requirements': ['طلب رسمي', 'دراسة جدوى', 'موافقات مبدئية'],
      'duration': '٣٠-٤٥ يوم عمل',
    },
    {
      'id': 4,
      'title': 'شهادة حسن سيرة وسلوك',
      'description': 'الحصول على شهادة رسمية من الوزارة',
      'category': 'خدمات إدارية',
      'icon': Icons.verified_user,
      'status': 'متاح',
      'color': AppColors.info,
      'requirements': ['نسخة من الهوية', 'صورة شخصية'],
      'duration': '٣-٥ أيام عمل',
    },
    {
      'id': 5,
      'title': 'التسجيل في دورات تدريبية',
      'description': 'التسجيل في الدورات التعليمية والتدريبية المختلفة',
      'category': 'التعليم الديني',
      'icon': Icons.school,
      'status': 'متاح',
      'color': AppColors.sageGreen,
      'requirements': ['استمارة تسجيل', 'نسخة من الهوية'],
      'duration': 'فوري',
    },
    {
      'id': 6,
      'title': 'حجز موعد مع الوزير',
      'description': 'حجز موعد لمقابلة معالي الوزير',
      'category': 'خدمات إدارية',
      'icon': Icons.calendar_today,
      'status': 'متاح',
      'color': AppColors.islamicGreen,
      'requirements': ['طلب رسمي', 'موضوع الاجتماع'],
      'duration': '٥-٧ أيام عمل',
    },
    {
      'id': 7,
      'title': 'تصاريح الحج والعمرة',
      'description': 'الحصول على التصاريح اللازمة لأداء فريضة الحج والعمرة',
      'category': 'الحج والعمرة',
      'icon': Icons.flight_takeoff,
      'status': 'قريباً',
      'color': AppColors.warning,
      'requirements': ['جواز سفر ساري', 'شهادة صحية', 'رسوم التصريح'],
      'duration': '١٠-١٥ يوم عمل',
    },
    {
      'id': 8,
      'title': 'استشارات دينية',
      'description': 'الحصول على استشارات وفتاوى دينية من علماء مختصين',
      'category': 'الفتاوى والإرشاد',
      'icon': Icons.question_answer,
      'status': 'متاح',
      'color': AppColors.info,
      'requirements': ['لا يوجد متطلبات'],
      'duration': 'فوري',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WebAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            _buildStatsSection(),
            _buildMainContent(),
            const WebFooter(),
          ],
        ),
      ),
    );
  }

  // ==================== HERO SECTION ====================
  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.islamicGreen, Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: WebContainer(
        child: Column(
          children: [
            // Title
            Text(
              'خدمات الوزارة الإلكترونية',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  const Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 4,
                    color: Colors.black26,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Subtitle
            Text(
              'نقدم لكم مجموعة متكاملة من الخدمات الإلكترونية السريعة والموثوقة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white.withValues(alpha:0.9),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Search Bar
            Container(
              constraints: const BoxConstraints(maxWidth: 600),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                textDirection: TextDirection.rtl,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'ابحث عن خدمة...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 20, right: 20),
                    child: Icon(Icons.search, color: AppColors.islamicGreen, size: 28),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _searchQuery = ''),
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Category Filter Tabs
            _buildCategoryTabs(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: _categories.map((category) {
        final isSelected = _selectedCategory == category ||
            (category == 'جميع الخدمات' && _selectedCategory == null);

        return AppFilterChip(
          label: category,
          isSelected: isSelected,
          onSelected: () => setState(() {
            _selectedCategory = category == 'جميع الخدمات' ? null : category;
          }),
          onDarkBackground: true,
        );
      }).toList(),
    );
  }

  // ==================== STATS SECTION ====================
  Widget _buildStatsSection() {
    final filteredServices = _getFilteredServices();
    final availableCount = filteredServices.where((s) => s['status'] == 'متاح').length;
    final categoriesCount = filteredServices.map((s) => s['category']).toSet().length;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: WebContainer(
        child: Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.miscellaneous_services,
                count: filteredServices.length.toString(),
                label: 'إجمالي الخدمات',
                color: AppColors.islamicGreen,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildStatCard(
                icon: Icons.check_circle,
                count: availableCount.toString(),
                label: 'خدمة متاحة',
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildStatCard(
                icon: Icons.category,
                count: categoriesCount.toString(),
                label: 'تصنيف',
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildStatCard(
                icon: Icons.access_time,
                count: '٢٤/٧',
                label: 'متاح دائماً',
                color: AppColors.goldenYellow,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: color.withValues(alpha:0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha:0.7)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha:0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            count,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ==================== MAIN CONTENT ====================
  Widget _buildMainContent() {
    final filteredServices = _getFilteredServices();

    return Container(
      color: AppColors.surfaceVariant,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: WebContainer(
        child: Column(
          children: [
            // Results Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الخدمات المتاحة (${filteredServices.length})',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.success.withValues(alpha:0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: AppColors.success),
                      const SizedBox(width: 8),
                      Text(
                        'جميع الخدمات متاحة إلكترونياً',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Services Grid
            filteredServices.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 0.9,
              ),
              itemCount: filteredServices.length,
              itemBuilder: (context, index) => _buildServiceCard(filteredServices[index]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final isAvailable = service['status'] == 'متاح';

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showServiceDetails(service),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (service['color'] as Color).withValues(alpha:0.1),
                      (service['color'] as Color).withValues(alpha:0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppConstants.radiusL),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            service['color'] as Color,
                            (service['color'] as Color).withValues(alpha:0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (service['color'] as Color).withValues(alpha:0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        service['icon'] as IconData,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? AppColors.success.withValues(alpha:0.2)
                            : AppColors.warning.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        service['status'] as String,
                        style: TextStyle(
                          color: isAvailable ? AppColors.success : AppColors.warning,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['title'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: Text(
                          service['description'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Duration
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              service['duration'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Action Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppConstants.radiusL),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isAvailable ? () => _showServiceDetails(service) : null,
                    icon: Icon(
                      isAvailable ? Icons.arrow_forward : Icons.lock,
                      size: 18,
                    ),
                    label: Text(isAvailable ? 'ابدأ الخدمة' : 'قريباً'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isAvailable
                          ? service['color'] as Color
                          : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== SERVICE DETAILS DIALOG ====================
  void _showServiceDetails(Map<String, dynamic> service) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      service['color'] as Color,
                      (service['color'] as Color).withValues(alpha:0.8),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppConstants.radiusXL),
                    topRight: Radius.circular(AppConstants.radiusXL),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        service['icon'] as IconData,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service['title'] as String,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha:0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              service['category'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      Text(
                        'وصف الخدمة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: service['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        service['description'] as String,
                        style: const TextStyle(fontSize: 16, height: 1.6),
                      ),

                      const SizedBox(height: 24),

                      // Requirements
                      Text(
                        'المتطلبات',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: service['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...(service['requirements'] as List<String>).map((req) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 20,
                              color: service['color'] as Color,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                req,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      )),

                      const SizedBox(height: 24),

                      // Duration
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (service['color'] as Color).withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: service['color'] as Color,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'مدة الإنجاز',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  service['duration'] as String,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action Buttons
                      if (service['status'] == 'متاح')
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // TODO: Navigate to service form
                                },
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('ابدأ الخدمة'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: service['color'] as Color,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                // TODO: Download form
                              },
                              icon: const Icon(Icons.download),
                              label: const Text('تحميل النموذج'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: service['color'] as Color,
                                side: BorderSide(color: service['color'] as Color),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== EMPTY STATE ====================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: AppColors.islamicGreen.withValues(alpha:0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.miscellaneous_services,
                size: 80,
                color: AppColors.islamicGreen.withValues(alpha:0.5),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'لا توجد خدمات',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'لم يتم العثور على خدمات تطابق معايير البحث',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() {
                _searchQuery = '';
                _selectedCategory = null;
              }),
              icon: const Icon(Icons.refresh),
              label: const Text('عرض جميع الخدمات'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.islamicGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPER METHODS ====================
  List<Map<String, dynamic>> _getFilteredServices() {
    return _services.where((service) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          (service['title'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (service['description'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());

      // Category filter
      final matchesCategory = _selectedCategory == null ||
          service['category'] == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }
}