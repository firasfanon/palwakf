// lib/presentation/screens/public/mosques/mobile_mosques_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/mosque.dart';
import '../../../providers/mosque_providers.dart';

class MobileMosquesScreen extends ConsumerStatefulWidget {
  const MobileMosquesScreen({super.key});

  @override
  ConsumerState<MobileMosquesScreen> createState() => _MosquesScreenState();
}

class _MosquesScreenState extends ConsumerState<MobileMosquesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String? _selectedGovernorate;
  MosqueType? _selectedType;
  bool _isMapView = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Modern Sliver App Bar with Gradient
          _buildSliverAppBar(),

          // Search and Filters
          SliverToBoxAdapter(
            child: _buildSearchAndFilters(),
          ),

          // Stats Section
          SliverToBoxAdapter(
            child: _buildStatsSection(),
          ),

          // Mosques List
          _buildMosquesList(),
        ],
      ),

      // Floating Action Buttons
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Map Toggle FAB
          FloatingActionButton(
            heroTag: 'map',
            onPressed: () => setState(() => _isMapView = !_isMapView),
            backgroundColor: Colors.white,
            child: Icon(
              _isMapView ? Icons.list : Icons.map,
              color: AppColors.islamicGreen,
            ),
          ),
          const SizedBox(height: 12),

          // Filter FAB
          FloatingActionButton(
            heroTag: 'filter',
            onPressed: _showFilterBottomSheet,
            backgroundColor: AppColors.islamicGreen,
            child: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.islamicGreen,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'دليل المساجد',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.islamicGreen,
                Color(0xFF16A34A),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Decorative Pattern
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: Image.asset(
                    'assets/images/pattern.png', // Add Islamic pattern
                    repeat: ImageRepeat.repeat,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox();
                    },
                  ),
                ),
              ),

              // Mosque Icon
              Positioned(
                right: 20,
                bottom: 20,
                child: Icon(
                  Icons.mosque,
                  size: 120,
                  color: Colors.white.withValues(alpha:0.1),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            // Implement search
          },
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Modern Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              textDirection: TextDirection.rtl,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'ابحث عن مسجد...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: AppColors.islamicGreen),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'الكل',
                  isSelected: _selectedGovernorate == null && _selectedType == null,
                  onTap: () => setState(() {
                    _selectedGovernorate = null;
                    _selectedType = null;
                  }),
                  icon: Icons.apps,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'المساجد الجامعة',
                  isSelected: _selectedType == MosqueType.jamia,
                  onTap: () => setState(() => _selectedType = MosqueType.jamia),
                  icon: Icons.mosque,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'مساجد الحي',
                  isSelected: _selectedType == MosqueType.masjid,
                  onTap: () => setState(() => _selectedType = MosqueType.masjid),
                  icon: Icons.location_city,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  label: 'المصليات',
                  isSelected: _selectedType == MosqueType.musalla,
                  onTap: () => setState(() => _selectedType = MosqueType.musalla),
                  icon: Icons.place,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.islamicGradient : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColors.islamicGreen.withValues(alpha:0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    final mosquesAsync = ref.watch(allMosquesProvider);

    return mosquesAsync.when(
      data: (mosques) {
        final filteredMosques = _getFilteredMosques(mosques);
        final jamiaCount = filteredMosques.where((m) => m.type == MosqueType.jamia).length;
        final masjidCount = filteredMosques.where((m) => m.type == MosqueType.masjid).length;

        return Container(
          margin: const EdgeInsets.all(AppConstants.paddingM),
          padding: const EdgeInsets.all(AppConstants.paddingL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.islamicGreen.withValues(alpha:0.1),
                AppColors.goldenYellow.withValues(alpha:0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            border: Border.all(
              color: AppColors.islamicGreen.withValues(alpha:0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.mosque,
                count: filteredMosques.length.toString(),
                label: 'مسجد',
                color: AppColors.islamicGreen,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[300],
              ),
              _buildStatItem(
                icon: Icons.location_city,
                count: jamiaCount.toString(),
                label: 'جامع',
                color: AppColors.goldenYellow,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[300],
              ),
              _buildStatItem(
                icon: Icons.place,
                count: masjidCount.toString(),
                label: 'مصلى',
                color: AppColors.info,
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 100),
      error: (_, __) => const SizedBox(height: 100),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMosquesList() {
    final mosquesAsync = ref.watch(allMosquesProvider);

    return mosquesAsync.when(
      data: (mosques) {
        final filteredMosques = _getFilteredMosques(mosques);

        if (filteredMosques.isEmpty) {
          return SliverFillRemaining(
            child: _buildEmptyState(),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildModernMosqueCard(filteredMosques[index]),
              childCount: filteredMosques.length,
            ),
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('حدث خطأ: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernMosqueCard(Mosque mosque) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMosqueDetails(mosque),
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Mosque Icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppColors.islamicGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.islamicGreen.withValues(alpha:0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mosque,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Title and Type
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mosque.name,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getTypeColor(mosque.type).withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              mosque.type.displayName,
                              style: TextStyle(
                                color: _getTypeColor(mosque.type),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(mosque.status).withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getStatusColor(mosque.status).withValues(alpha:0.3),
                        ),
                      ),
                      child: Icon(
                        Icons.circle,
                        size: 8,
                        color: _getStatusColor(mosque.status),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Divider
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.grey[300]!,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Info Rows
                _buildInfoRow(
                  icon: Icons.person,
                  label: 'الإمام',
                  value: mosque.imam,
                  color: AppColors.islamicGreen,
                ),
                const SizedBox(height: 10),
                _buildInfoRow(
                  icon: Icons.location_on,
                  label: 'الموقع',
                  value: mosque.location.address,
                  color: AppColors.goldenYellow,
                ),
                if (mosque.capacity > 0) ...[
                  const SizedBox(height: 10),
                  _buildInfoRow(
                    icon: Icons.group,
                    label: 'السعة',
                    value: '${mosque.capacity} مصلي',
                    color: AppColors.info,
                  ),
                ],

                const SizedBox(height: 16),

                // Features Row
                if (mosque.hasWheelchairAccess ||
                    mosque.hasAirConditioning ||
                    mosque.hasFemaleSection) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (mosque.hasWheelchairAccess)
                        _buildFeatureBadge(Icons.accessible, 'ذوي الإعاقة'),
                      if (mosque.hasAirConditioning)
                        _buildFeatureBadge(Icons.ac_unit, 'مكيف'),
                      if (mosque.hasFemaleSection)
                        _buildFeatureBadge(Icons.female, 'قسم نساء'),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Action Button
                Container(
                  width: double.infinity,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.islamicGreen.withValues(alpha:0.1),
                        AppColors.goldenYellow.withValues(alpha:0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showMosqueDetails(mosque),
                      borderRadius: BorderRadius.circular(10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: AppColors.islamicGreen,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'عرض التفاصيل',
                            style: TextStyle(
                              color: AppColors.islamicGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.success.withValues(alpha:0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.islamicGreen.withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.mosque,
              size: 64,
              color: AppColors.islamicGreen.withValues(alpha:0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد مساجد',
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم العثور على مساجد تطابق البحث',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showMosqueDetails(Mosque mosque) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MosqueDetailsBottomSheet(mosque: mosque),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXL),
          ),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppColors.islamicGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.filter_list,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'خيارات التصفية',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Filter Options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Governorate Filter
                  Text(
                    'المحافظة',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Add governorate chips here

                  const SizedBox(height: 24),

                  // Type Filter
                  Text(
                    'نوع المسجد',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Add type chips here
                ],
              ),
            ),

            // Apply Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.islamicGreen,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'تطبيق الفلتر',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Mosque> _getFilteredMosques(List<Mosque> mosques) {
    return mosques.where((mosque) {
      final matchesSearch = _searchQuery.isEmpty ||
          mosque.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          mosque.location.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          mosque.imam.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesGovernorate = _selectedGovernorate == null ||
          mosque.governorate == _selectedGovernorate;

      final matchesType = _selectedType == null ||
          mosque.type == _selectedType;

      return matchesSearch && matchesGovernorate && matchesType;
    }).toList();
  }

  Color _getTypeColor(MosqueType type) {
    switch (type) {
      case MosqueType.jamia:
        return AppColors.islamicGreen;
      case MosqueType.masjid:
        return AppColors.goldenYellow;
      case MosqueType.musalla:
        return AppColors.info;
      case MosqueType.historical:
        return AppColors.sageGreen;
    }
  }

  Color _getStatusColor(MosqueStatus status) {
    switch (status) {
      case MosqueStatus.active:
        return AppColors.success;
      case MosqueStatus.underConstruction:
        return AppColors.warning;
      case MosqueStatus.underRenovation:
        return AppColors.info;
      case MosqueStatus.inactive:
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }
}

// Enhanced Bottom Sheet for Mosque Details
class MosqueDetailsBottomSheet extends StatelessWidget {
  final Mosque mosque;

  const MosqueDetailsBottomSheet({super.key, required this.mosque});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusXL),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppConstants.paddingL),
                  children: [
                    // Header with Icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppColors.islamicGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.islamicGreen.withValues(alpha:0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.mosque,
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
                                mosque.name,
                                style: AppTextStyles.headlineSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.islamicGreen.withValues(alpha:0.2),
                                      AppColors.goldenYellow.withValues(alpha:0.2),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  mosque.type.displayName,
                                  style: TextStyle(
                                    color: AppColors.islamicGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Description if available
                    if (mosque.description.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha:0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withValues(alpha:0.1),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue[700],
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                mosque.description,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.grey[700],
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Details Section
                    _buildDetailSection(
                      title: 'التفاصيل الأساسية',
                      icon: Icons.info,
                      color: AppColors.islamicGreen,
                      children: [
                        _buildDetailItem(
                          icon: Icons.person,
                          label: 'الإمام',
                          value: mosque.imam,
                        ),
                        _buildDetailItem(
                          icon: Icons.location_on,
                          label: 'العنوان',
                          value: mosque.location.address,
                        ),
                        _buildDetailItem(
                          icon: Icons.location_city,
                          label: 'المحافظة',
                          value: mosque.governorate,
                        ),
                        if (mosque.capacity > 0)
                          _buildDetailItem(
                            icon: Icons.group,
                            label: 'السعة',
                            value: '${mosque.capacity} مصلي',
                          ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Features Section
                    if (mosque.hasWheelchairAccess ||
                        mosque.hasAirConditioning ||
                        mosque.hasFemaleSection ||
                        mosque.hasParkingSpace) ...[
                      _buildDetailSection(
                        title: 'المميزات والخدمات',
                        icon: Icons.verified,
                        color: AppColors.success,
                        children: [
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              if (mosque.hasWheelchairAccess)
                                _buildFeatureCard(
                                  Icons.accessible,
                                  'مناسب لذوي الإعاقة',
                                ),
                              if (mosque.hasAirConditioning)
                                _buildFeatureCard(
                                  Icons.ac_unit,
                                  'مكيف',
                                ),
                              if (mosque.hasFemaleSection)
                                _buildFeatureCard(
                                  Icons.female,
                                  'قسم نساء',
                                ),
                              if (mosque.hasParkingSpace)
                                _buildFeatureCard(
                                  Icons.local_parking,
                                  'مواقف سيارات',
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.directions,
                            label: 'الاتجاهات',
                            color: AppColors.islamicGreen,
                            onTap: () {
                              // Open maps
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.phone,
                            label: 'اتصال',
                            color: AppColors.goldenYellow,
                            onTap: () {
                              // Make phone call
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: _buildActionButton(
                        icon: Icons.share,
                        label: 'مشاركة',
                        color: AppColors.info,
                        onTap: () {
                          // Share mosque
                        },
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.islamicGreen.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.islamicGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.success.withValues(alpha:0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha:0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.success),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha:0.1),
                color.withValues(alpha:0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha:0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}