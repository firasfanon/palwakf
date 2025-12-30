// lib/presentation/screens/admin/hero_slider_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/data/repositories/homepage_repository.dart';
import 'package:waqf/presentation/widgets/web/web_container.dart';
import 'package:waqf/presentation/widgets/web/web_sidebar.dart';


// =====================================================
// PROVIDERS
// =====================================================
final heroSliderRepositoryProvider = Provider<HomepageRepository>((ref) {
  return HomepageRepository(Supabase.instance.client);
});

// Hero Slides Notifier - Better control over state
class HeroSlidesNotifier extends AsyncNotifier<List<HeroSlide>> {
  @override
  Future<List<HeroSlide>> build() async {
    final repository = ref.watch(heroSliderRepositoryProvider);
    return repository.fetchAllHeroSlides();
  }

  // Method to manually refresh
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(heroSliderRepositoryProvider);
      return repository.fetchAllHeroSlides();
    });
  }

// Method to add slide
  Future<void> addSlide(HeroSlide slide) async {
    final repository = ref.read(heroSliderRepositoryProvider);

    // Step 1: If the slide is active, shift existing active slides with same or higher order
    if (slide.isActive) {
      await repository.shiftDisplayOrders(slide.displayOrder);
    }

    // Step 2: Create the new slide
    await repository.createHeroSlide(slide);

    // Step 3: Auto refresh after adding
    await refresh();
  }

  // Method to update slide
  Future<void> updateSlide(HeroSlide slide) async {
    final repository = ref.read(heroSliderRepositoryProvider);
    await repository.updateHeroSlide(slide);
    await refresh(); // Auto refresh after updating
  }

  // Method to delete slide
  Future<void> deleteSlide(String id) async {
    final repository = ref.read(heroSliderRepositoryProvider);
    await repository.deleteHeroSlide(id);
    await refresh(); // Auto refresh after deleting
  }

  // Method to delete multiple slides
  Future<void> deleteSlides(List<String> ids) async {
    final repository = ref.read(heroSliderRepositoryProvider);
    for (final id in ids) {
      await repository.deleteHeroSlide(id);
    }
    await refresh(); // Auto refresh after bulk delete
  }
}

final heroSlidesProvider = AsyncNotifierProvider<HeroSlidesNotifier, List<HeroSlide>>(() {
  return HeroSlidesNotifier();
});

// =====================================================
// HERO SLIDER MANAGEMENT SCREEN
// =====================================================
class HeroSliderManagementScreen extends ConsumerStatefulWidget {
  const HeroSliderManagementScreen({super.key});

  @override
  ConsumerState<HeroSliderManagementScreen> createState() =>
      _HeroSliderManagementScreenState();
}

class _HeroSliderManagementScreenState
    extends ConsumerState<HeroSliderManagementScreen> {
  // View mode
  String _viewMode = 'grid'; // 'grid' or 'list'
  bool _showInactiveSlides = true;
  String _sortBy = 'order'; // 'order', 'created', 'updated'

  // Selection
  final Set<String> _selectedSlides = {};
  bool _isMultiSelectMode = false;

  @override
  void dispose() {
    _selectedSlides.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final slidesAsync = ref.watch(heroSlidesProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      body: Row(
        children: [
          const WebSidebar(currentRoute: '/admin/hero-slider'),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: slidesAsync.when(
                    data: (slides) => _buildContent(slides),
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => _buildError(error),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // TOP BAR
  // =====================================================
  Widget _buildTopBar() {
    return Container(
      height: 70,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            const Icon(Icons.slideshow,
                color: AppConstants.islamicGreen, size: 28),
            const SizedBox(width: 12),
            const Text(
              'إدارة الشرائح الرئيسية',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.islamicGreen,
              ),
            ),
            const Spacer(),

            // View Mode Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildViewModeButton(Icons.grid_view, 'grid'),
                  const SizedBox(width: 4),
                  _buildViewModeButton(Icons.view_list, 'list'),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Show Inactive Toggle
            Row(
              children: [
                Checkbox(
                  value: _showInactiveSlides,
                  onChanged: (v) =>
                      setState(() => _showInactiveSlides = v ?? true),
                  activeColor: AppConstants.islamicGreen,
                ),
                const Text('عرض المخفية'),
              ],
            ),
            const SizedBox(width: 16),

            // Sort Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'order', child: Text('الترتيب')),
                    DropdownMenuItem(value: 'created', child: Text('الأحدث')),
                    DropdownMenuItem(value: 'updated', child: Text('آخر تحديث')),
                  ],
                  onChanged: (v) => setState(() => _sortBy = v!),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Multi-select Mode
            if (_isMultiSelectMode) ...[
              OutlinedButton.icon(
                onPressed: _handleBulkDelete,
                icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                label: Text('حذف (${_selectedSlides.length})'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isMultiSelectMode = false;
                    _selectedSlides.clear();
                  });
                },
                child: const Text('إلغاء'),
              ),
              const SizedBox(width: 16),
            ],

            // Add New Slide Button
            ElevatedButton.icon(
              onPressed: _handleAddSlide,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('إضافة شريحة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.islamicGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewModeButton(IconData icon, String mode) {
    final isActive = _viewMode == mode;
    return InkWell(
      onTap: () => setState(() => _viewMode = mode),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? AppConstants.islamicGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey[600],
          size: 20,
        ),
      ),
    );
  }

  // =====================================================
  // CONTENT
  // =====================================================
  Widget _buildContent(List<HeroSlide> allSlides) {
    // Filter slides
    var slides = allSlides;
    if (!_showInactiveSlides) {
      slides = slides.where((s) => s.isActive).toList();
    }

    // Sort slides
    switch (_sortBy) {
      case 'created':
        slides.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'updated':
        slides.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
      case 'order':
      default:
        slides.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    }

    if (slides.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: WebContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsBar(allSlides),
            const SizedBox(height: 24),
            _viewMode == 'grid'
                ? _buildGridView(slides)
                : _buildListView(slides),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBar(List<HeroSlide> allSlides) {
    final activeCount = allSlides.where((s) => s.isActive).length;
    final inactiveCount = allSlides.length - activeCount;

    return Row(
      children: [
        _buildStatChip(
          icon: Icons.slideshow,
          label: 'إجمالي الشرائح',
          value: allSlides.length.toString(),
          color: AppConstants.islamicGreen,
        ),
        const SizedBox(width: 16),
        _buildStatChip(
          icon: Icons.check_circle,
          label: 'نشطة',
          value: activeCount.toString(),
          color: AppConstants.success,
        ),
        const SizedBox(width: 16),
        _buildStatChip(
          icon: Icons.visibility_off,
          label: 'مخفية',
          value: inactiveCount.toString(),
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // GRID VIEW
  // =====================================================
  Widget _buildGridView(List<HeroSlide> slides) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.5,
      ),
      itemCount: slides.length,
      itemBuilder: (context, index) => _buildSlideCard(slides[index], index),
    );
  }

  Widget _buildSlideCard(HeroSlide slide, int index) {
    final isSelected = _selectedSlides.contains(slide.id);

    return Card(
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? AppConstants.islamicGreen : Colors.grey[200]!,
          width: isSelected ? 3 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _handleSlideClick(slide),
        onLongPress: () => _handleLongPress(slide),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  // Background Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: slide.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 50),
                      ),
                    ),
                  ),

                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha:0.7),
                        ],
                      ),
                    ),
                  ),

                  // Title Overlay
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Text(
                      slide.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Status Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: slide.isActive ? AppConstants.success : Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        slide.isActive ? 'نشطة' : 'مخفية',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Order Badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppConstants.islamicGreen,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${slide.displayOrder}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Selection Checkbox
                  if (_isMultiSelectMode)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (v) => _toggleSelection(slide.id),
                        activeColor: AppConstants.islamicGreen,
                      ),
                    ),
                ],
              ),
            ),

            // Info Section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slide.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Action Buttons
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () => _handleEditSlide(slide),
                            tooltip: 'تعديل',
                            color: AppConstants.islamicGreen,
                          ),
                          IconButton(
                            icon: Icon(
                              slide.isActive
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              size: 18,
                            ),
                            onPressed: () => _handleToggleActive(slide),
                            tooltip: slide.isActive ? 'إخفاء' : 'إظهار',
                            color: Colors.orange,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18),
                            onPressed: () => _handleDeleteSlide(slide),
                            tooltip: 'حذف',
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // LIST VIEW
  // =====================================================
  Widget _buildListView(List<HeroSlide> slides) {
    return Column(
      children: slides.asMap().entries.map((entry) {
        final index = entry.key;
        final slide = entry.value;
        return _buildSlideListItem(slide, index);
      }).toList(),
    );
  }

  Widget _buildSlideListItem(HeroSlide slide, int index) {
    final isSelected = _selectedSlides.contains(slide.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppConstants.islamicGreen : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _handleSlideClick(slide),
        onLongPress: () => _handleLongPress(slide),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Selection Checkbox
              if (_isMultiSelectMode)
                Checkbox(
                  value: isSelected,
                  onChanged: (v) => _toggleSelection(slide.id),
                  activeColor: AppConstants.islamicGreen,
                ),

              // Order
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppConstants.islamicGreen.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${slide.displayOrder}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.islamicGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: slide.imageUrl,
                  width: 120,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 120,
                    height: 80,
                    color: Colors.grey[300],
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 120,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slide.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      slide.subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      slide.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Status & CTA
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: slide.isActive
                          ? AppConstants.success.withValues(alpha:0.1)
                          : Colors.grey.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      slide.isActive ? 'نشطة' : 'مخفية',
                      style: TextStyle(
                        color: slide.isActive ? AppConstants.success : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    slide.ctaText ?? 'اقرأ المزيد',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppConstants.islamicGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),

              // Actions
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _handleEditSlide(slide),
                    tooltip: 'تعديل',
                    color: AppConstants.islamicGreen,
                  ),
                  IconButton(
                    icon: Icon(
                      slide.isActive ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () => _handleToggleActive(slide),
                    tooltip: slide.isActive ? 'إخفاء' : 'إظهار',
                    color: Colors.orange,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () => _handleDeleteSlide(slide),
                    tooltip: 'حذف',
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =====================================================
  // EMPTY STATE
  // =====================================================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.slideshow,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد شرائح بعد',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ابدأ بإضافة شريحة جديدة',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _handleAddSlide,
            icon: const Icon(Icons.add),
            label: const Text('إضافة شريحة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.islamicGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ERROR STATE
  // =====================================================
  Widget _buildError(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 100,
            color: Colors.red,
          ),
          const SizedBox(height: 24),
          const Text(
            'حدث خطأ في تحميل الشرائح',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => ref.read(heroSlidesProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.islamicGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // ACTIONS
  // =====================================================
  void _handleSlideClick(HeroSlide slide) {
    if (_isMultiSelectMode) {
      _toggleSelection(slide.id);
    } else {
      _handleEditSlide(slide);
    }
  }

  void _handleLongPress(HeroSlide slide) {
    setState(() {
      _isMultiSelectMode = true;
      _selectedSlides.add(slide.id);
    });
  }

  void _toggleSelection(String slideId) {
    setState(() {
      if (_selectedSlides.contains(slideId)) {
        _selectedSlides.remove(slideId);
        if (_selectedSlides.isEmpty) {
          _isMultiSelectMode = false;
        }
      } else {
        _selectedSlides.add(slideId);
      }
    });
  }

  void _handleAddSlide() {
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (context) => _SlideFormDialog(
        onSave: (slide) async {
          await ref.read(heroSlidesProvider.notifier).addSlide(slide);

          if (mounted) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('تم إضافة الشريحة بنجاح'),
                backgroundColor: AppConstants.success,
              ),
            );
          }
        },
      ),
    );
  }

  void _handleEditSlide(HeroSlide slide) {
    final parentContext = context;
    final messenger = ScaffoldMessenger.of(parentContext);

    showDialog(
      context: context,
      builder: (context) => _SlideFormDialog(
        slide: slide,
        onSave: (updatedSlide) async {
          await ref.read(heroSlidesProvider.notifier).updateSlide(updatedSlide);

          if (mounted) {
            messenger.showSnackBar(
              const SnackBar(
                content: Text('تم تحديث الشريحة بنجاح'),
                backgroundColor: AppConstants.success,
              ),
            );
          }
        },
      ),
    );
  }

  void _handleToggleActive(HeroSlide slide) async {
    final messenger = ScaffoldMessenger.of(context);

    await ref.read(heroSlidesProvider.notifier).updateSlide(
      slide.copyWith(isActive: !slide.isActive),
    );

    if (mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            slide.isActive ? 'تم إخفاء الشريحة' : 'تم إظهار الشريحة',
          ),
          backgroundColor: AppConstants.info,
        ),
      );
    }
  }

  void _handleDeleteSlide(HeroSlide slide) {
    final parentContext = context;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الشريحة "${slide.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final messenger = ScaffoldMessenger.of(parentContext);

              await ref.read(heroSlidesProvider.notifier).deleteSlide(slide.id);

              if (mounted) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف الشريحة بنجاح'),
                    backgroundColor: AppConstants.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _handleBulkDelete() {
    if (_selectedSlides.isEmpty) return;

    final parentContext = context;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
          'هل أنت متأكد من حذف ${_selectedSlides.length} شريحة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final messenger = ScaffoldMessenger.of(parentContext);

              await ref.read(heroSlidesProvider.notifier).deleteSlides(
                _selectedSlides.toList(),
              );

              if (mounted) {
                setState(() {
                  _selectedSlides.clear();
                  _isMultiSelectMode = false;
                });

                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف الشرائح بنجاح'),
                    backgroundColor: AppConstants.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// SLIDE FORM DIALOG
// =====================================================
class _SlideFormDialog extends StatefulWidget {
  final HeroSlide? slide;
  final Function(HeroSlide) onSave;

  const _SlideFormDialog({
    this.slide,
    required this.onSave,
  });

  @override
  State<_SlideFormDialog> createState() => _SlideFormDialogState();
}

class _SlideFormDialogState extends State<_SlideFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _descriptionController;
  late TextEditingController _imageUrlController;
  late TextEditingController _ctaTextController;
  late TextEditingController _ctaLinkController;
  late int _displayOrder;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final slide = widget.slide;
    _titleController = TextEditingController(text: slide?.title ?? '');
    _subtitleController = TextEditingController(text: slide?.subtitle ?? '');
    _descriptionController =
        TextEditingController(text: slide?.description ?? '');
    _imageUrlController = TextEditingController(text: slide?.imageUrl ?? '');
    _ctaTextController =
        TextEditingController(text: slide?.ctaText ?? 'اقرأ المزيد');
    _ctaLinkController = TextEditingController(text: slide?.ctaLink ?? '/news');
    _displayOrder = slide?.displayOrder ?? 1;
    _isActive = slide?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _ctaTextController.dispose();
    _ctaLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.slide != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 800,
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEditing ? 'تعديل الشريحة' : 'إضافة شريحة جديدة',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.islamicGreen,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'العنوان',
                    hintText: 'عنوان الشريحة',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'الحقل مطلوب' : null,
                ),
                const SizedBox(height: 16),

                // Subtitle
                TextFormField(
                  controller: _subtitleController,
                  decoration: const InputDecoration(
                    labelText: 'العنوان الفرعي',
                    hintText: 'عنوان فرعي',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'الحقل مطلوب' : null,
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'الوصف',
                    hintText: 'وصف الشريحة',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'الحقل مطلوب' : null,
                ),
                const SizedBox(height: 16),

                // Image URL
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'رابط الصورة',
                    hintText: 'https://example.com/image.jpg',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'الحقل مطلوب' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ctaTextController,
                        decoration: const InputDecoration(
                          labelText: 'نص الزر',
                          hintText: 'اقرأ المزيد',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                        v?.isEmpty ?? true
                            ? 'الحقل مطلوب'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _ctaLinkController,
                        decoration: const InputDecoration(
                          labelText: 'رابط الزر',
                          hintText: '/news',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                        v?.isEmpty ?? true
                            ? 'الحقل مطلوب'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        initialValue: _displayOrder,
                        decoration: const InputDecoration(
                          labelText: 'الترتيب',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(
                          10,
                              (i) =>
                              DropdownMenuItem(
                                value: i + 1,
                                child: Text('${i + 1}'),
                              ),
                        ),
                        onChanged: (v) => setState(() => _displayOrder = v!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text('نشطة'),
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v ?? true),
                        activeColor: AppConstants.islamicGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.islamicGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: Text(isEditing ? 'تحديث' : 'إضافة'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

    final slide = HeroSlide(
      id: widget.slide?.id ?? '',
      title: _titleController.text,
      subtitle: _subtitleController.text,
      description: _descriptionController.text,
      imageUrl: _imageUrlController.text,
      ctaText: _ctaTextController.text.isEmpty
          ? null // ← Pass null if empty
          : _ctaTextController.text,
      ctaLink: _ctaLinkController.text.isEmpty
          ? null // ← Pass null if empty
          : _ctaLinkController.text,
      displayOrder: _displayOrder,
      isActive: _isActive,
      createdAt: widget.slide?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(slide);
    Navigator.pop(context);
  }

}