// lib/presentation/screens/public/mosques/web_mosques_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/mosque.dart';
import '../../../providers/mosque_providers.dart';
import '../../../widgets/web/web_app_bar.dart';
import '../../../widgets/web/web_footer.dart';
import '../../../widgets/web/web_container.dart';

class WebMosquesScreen extends ConsumerStatefulWidget {
  const WebMosquesScreen({super.key});

  @override
  ConsumerState<WebMosquesScreen> createState() => _WebMosquesScreenState();
}

class _WebMosquesScreenState extends ConsumerState<WebMosquesScreen> {
  String _searchQuery = '';
  String? _selectedGovernorate;
  MosqueType? _selectedType;
  final Set<String> _selectedFeatures = {};
  int _minCapacity = 0;
  int _maxCapacity = 2000;

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
              'دليل المساجد الفلسطينية',
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
              'استكشف المساجد في جميع أنحاء فلسطين',
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
                  hintText: 'ابحث عن مسجد بالاسم أو الموقع...',
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

            // Quick Filter Tabs
            _buildQuickFilters(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _buildQuickFilterChip(
          label: 'الكل',
          isSelected: _selectedType == null,
          onTap: () => setState(() => _selectedType = null),
          icon: Icons.apps,
        ),
        _buildQuickFilterChip(
          label: 'المساجد الجامعة',
          isSelected: _selectedType == MosqueType.jamia,
          onTap: () => setState(() => _selectedType = MosqueType.jamia),
          icon: Icons.mosque,
        ),
        _buildQuickFilterChip(
          label: 'مساجد الحي',
          isSelected: _selectedType == MosqueType.masjid,
          onTap: () => setState(() => _selectedType = MosqueType.masjid),
          icon: Icons.location_city,
        ),
        _buildQuickFilterChip(
          label: 'المصليات',
          isSelected: _selectedType == MosqueType.musalla,
          onTap: () => setState(() => _selectedType = MosqueType.musalla),
          icon: Icons.place,
        ),
        _buildQuickFilterChip(
          label: 'المساجد التاريخية',
          isSelected: _selectedType == MosqueType.historical,
          onTap: () => setState(() => _selectedType = MosqueType.historical),
          icon: Icons.history_edu,
        ),
      ],
    );
  }

  Widget _buildQuickFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha:0.3),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.islamicGreen : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.islamicGreen : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== STATS SECTION ====================
  Widget _buildStatsSection() {
    final mosquesAsync = ref.watch(allMosquesProvider);

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: WebContainer(
        child: mosquesAsync.when(
          data: (mosques) {
            final filteredMosques = _getFilteredMosques(mosques);
            final jamiaCount = filteredMosques.where((m) => m.type == MosqueType.jamia).length;
            final masjidCount = filteredMosques.where((m) => m.type == MosqueType.masjid).length;
            final musallaCount = filteredMosques.where((m) => m.type == MosqueType.musalla).length;

            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.mosque,
                    count: filteredMosques.length.toString(),
                    label: 'إجمالي المساجد',
                    color: AppColors.islamicGreen,
                    onTap: () => setState(() => _selectedType = null),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.location_city,
                    count: jamiaCount.toString(),
                    label: 'مسجد جامع',
                    color: AppColors.goldenYellow,
                    onTap: () => setState(() => _selectedType = MosqueType.jamia),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.place,
                    count: masjidCount.toString(),
                    label: 'مسجد حي',
                    color: AppColors.info,
                    onTap: () => setState(() => _selectedType = MosqueType.masjid),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.place_outlined,
                    count: musallaCount.toString(),
                    label: 'مصلى',
                    color: AppColors.success,
                    onTap: () => setState(() => _selectedType = MosqueType.musalla),
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox(height: 100),
          error: (_, __) => const SizedBox(height: 100),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
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
        ),
      ),
    );
  }

  // ==================== MAIN CONTENT ====================
  Widget _buildMainContent() {
    final mosquesAsync = ref.watch(allMosquesProvider);

    return Container(
      color: AppColors.surfaceVariant,
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: WebContainer(
        child: mosquesAsync.when(
          data: (mosques) {
            final filteredMosques = _getFilteredMosques(mosques);

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sidebar Filters
                SizedBox(
                  width: 280,
                  child: _buildFiltersSidebar(mosques),
                ),

                const SizedBox(width: 40),

                // Mosque Cards Grid
                Expanded(
                  child: filteredMosques.isEmpty
                      ? _buildEmptyState()
                      : _buildMosquesGrid(filteredMosques),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(60),
              child: CircularProgressIndicator(color: AppColors.islamicGreen),
            ),
          ),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(60),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('حدث خطأ في تحميل البيانات'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== FILTERS SIDEBAR ====================
  Widget _buildFiltersSidebar(List<Mosque> mosques) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.islamicGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.filter_list, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'تصفية النتائج',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // Governorate Filter
          _buildFilterSection(
            title: 'المحافظة',
            child: DropdownButtonFormField<String>(
              initialValue: _selectedGovernorate,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: const Text('جميع المحافظات'),
              items: AppConstants.governorates.map((gov) {
                return DropdownMenuItem(value: gov, child: Text(gov));
              }).toList(),
              onChanged: (value) => setState(() => _selectedGovernorate = value),
            ),
          ),

          const SizedBox(height: 24),

          // Features Filter
          _buildFilterSection(
            title: 'المميزات',
            child: Column(
              children: [
                _buildFeatureCheckbox('مناسب لذوي الإعاقة', 'wheelchair'),
                _buildFeatureCheckbox('مكيف', 'ac'),
                _buildFeatureCheckbox('قسم نساء', 'female'),
                _buildFeatureCheckbox('مواقف سيارات', 'parking'),
                _buildFeatureCheckbox('مكتبة', 'library'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Reset Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة تعيين الفلاتر'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Map View Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Show map view
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('عرض الخريطة - قريباً')),
                );
              },
              icon: const Icon(Icons.map),
              label: const Text('عرض على الخريطة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.islamicGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildFeatureCheckbox(String label, String feature) {
    final isSelected = _selectedFeatures.contains(feature);

    return CheckboxListTile(
      value: isSelected,
      onChanged: (value) {
        setState(() {
          if (value == true) {
            _selectedFeatures.add(feature);
          } else {
            _selectedFeatures.remove(feature);
          }
        });
      },
      title: Text(
        label,
        style: const TextStyle(fontSize: 14),
      ),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: AppColors.islamicGreen,
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedGovernorate = null;
      _selectedType = null;
      _selectedFeatures.clear();
      _searchQuery = '';
      _minCapacity = 0;
      _maxCapacity = 2000;
    });
  }

  // ==================== MOSQUES GRID ====================
  Widget _buildMosquesGrid(List<Mosque> mosques) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Results Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'النتائج (${mosques.length})',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            DropdownButton<String>(
              value: 'recent',
              items: const [
                DropdownMenuItem(value: 'recent', child: Text('الأحدث')),
                DropdownMenuItem(value: 'name', child: Text('الاسم')),
                DropdownMenuItem(value: 'capacity', child: Text('السعة')),
              ],
              onChanged: (value) {
                // TODO: Implement sorting
              },
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.1,
          ),
          itemCount: mosques.length,
          itemBuilder: (context, index) => _buildMosqueCard(mosques[index]),
        ),
      ],
    );
  }

  Widget _buildMosqueCard(Mosque mosque) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showMosqueDetails(mosque),
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
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getTypeColor(mosque.type).withValues(alpha:0.1),
                      _getTypeColor(mosque.type).withValues(alpha:0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppConstants.radiusL),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getTypeColor(mosque.type),
                            _getTypeColor(mosque.type).withValues(alpha:0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _getTypeColor(mosque.type).withValues(alpha:0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.mosque, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mosque.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getTypeColor(mosque.type).withValues(alpha:0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              mosque.type.displayName,
                              style: TextStyle(
                                color: _getTypeColor(mosque.type),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(mosque.status).withValues(alpha:0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.circle,
                        size: 12,
                        color: _getStatusColor(mosque.status),
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
                      _buildInfoRow(
                        icon: Icons.person,
                        label: 'الإمام',
                        value: mosque.imam,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        icon: Icons.location_on,
                        label: 'الموقع',
                        value: mosque.location.address,
                      ),
                      if (mosque.capacity > 0) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          icon: Icons.group,
                          label: 'السعة',
                          value: '${mosque.capacity} مصلي',
                        ),
                      ],
                      const Spacer(),
                      if (mosque.hasWheelchairAccess ||
                          mosque.hasAirConditioning ||
                          mosque.hasFemaleSection) ...[
                        const Divider(height: 24),
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
                      ],
                    ],
                  ),
                ),
              ),

              // Footer Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppConstants.radiusL),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showMosqueDetails(mosque),
                        icon: const Icon(Icons.info_outline, size: 18),
                        label: const Text('التفاصيل'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.islamicGreen,
                          side: const BorderSide(color: AppColors.islamicGreen),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Open map
                        },
                        icon: const Icon(Icons.directions, size: 18),
                        label: const Text('الاتجاهات'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.islamicGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.islamicGreen.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: AppColors.islamicGreen),
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
                  fontSize: 14,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha:0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
                Icons.mosque,
                size: 80,
                color: AppColors.islamicGreen.withValues(alpha:0.5),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'لا توجد مساجد',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'لم يتم العثور على مساجد تطابق معايير البحث',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _resetFilters,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة تعيين الفلاتر'),
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

  // ==================== MOSQUE DETAILS DIALOG ====================
  void _showMosqueDetails(Mosque mosque) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: AppColors.islamicGradient,
                  borderRadius: BorderRadius.only(
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
                              mosque.type.displayName,
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
                                  style: TextStyle(
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

                      // Basic Details
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

                      // Features
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
                                  _buildFeatureCard(Icons.ac_unit, 'مكيف'),
                                if (mosque.hasFemaleSection)
                                  _buildFeatureCard(Icons.female, 'قسم نساء'),
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
                                // TODO: Open maps
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
                                // TODO: Make phone call
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
                            // TODO: Share mosque
                          },
                        ),
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
              style: const TextStyle(
                fontSize: 18,
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
          child: Column(children: children),
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
            style: const TextStyle(
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
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

  // ==================== HELPER METHODS ====================
  List<Mosque> _getFilteredMosques(List<Mosque> mosques) {
    return mosques.where((mosque) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty ||
          mosque.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          mosque.location.address
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          mosque.imam.toLowerCase().contains(_searchQuery.toLowerCase());

      // Governorate filter
      final matchesGovernorate = _selectedGovernorate == null ||
          mosque.governorate == _selectedGovernorate;

      // Type filter
      final matchesType = _selectedType == null || mosque.type == _selectedType;

      // Features filter
      bool matchesFeatures = true;
      if (_selectedFeatures.contains('wheelchair') &&
          !mosque.hasWheelchairAccess) {
        matchesFeatures = false;
      }
      if (_selectedFeatures.contains('ac') && !mosque.hasAirConditioning) {
        matchesFeatures = false;
      }
      if (_selectedFeatures.contains('female') && !mosque.hasFemaleSection) {
        matchesFeatures = false;
      }
      if (_selectedFeatures.contains('parking') && !mosque.hasParkingSpace) {
        matchesFeatures = false;
      }
      if (_selectedFeatures.contains('library') && !mosque.hasLibrary) {
        matchesFeatures = false;
      }

      // Capacity filter
      final matchesCapacity =
          mosque.capacity >= _minCapacity && mosque.capacity <= _maxCapacity;

      return matchesSearch &&
          matchesGovernorate &&
          matchesType &&
          matchesFeatures &&
          matchesCapacity;
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