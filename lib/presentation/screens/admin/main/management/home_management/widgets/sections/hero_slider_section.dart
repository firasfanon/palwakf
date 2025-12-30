import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/data/models/homepage_section.dart';
import 'package:waqf/presentation/screens/admin/main/management/hero_slider_management/hero_slider_management_screen.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/common/section_header.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/forms/slide_form_dialog.dart';


class HeroSliderSection extends ConsumerStatefulWidget {
  const HeroSliderSection({super.key});

  @override
  ConsumerState<HeroSliderSection> createState() =>
      _HeroSliderSectionState();
}

class _HeroSliderSectionState extends ConsumerState<HeroSliderSection> {
  String _viewMode = 'grid'; // 'grid' or 'list'

  @override
  Widget build(BuildContext context) {
    final slidesAsync = ref.watch(heroSlidesProvider);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha:0.05),
            Colors.purple.withValues(alpha:0.02)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          slidesAsync.when(
            data: (slides) => _buildContent(slides),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(48.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
              ),
            ),
            error: (error, stack) => _buildError(error),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SectionHeader(
      icon: Icons.slideshow,
      title: 'إدارة الشرائح الرئيسية',
      color: Colors.purple,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          ElevatedButton.icon(
            onPressed: _handleAddSlide,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('إضافة شريحة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
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
          color: isActive ? Colors.purple : Colors.transparent,
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

  Widget _buildContent(List<HeroSlide> slides) {
    if (slides.isEmpty) {
      return _buildEmpty();
    }

    final sortedSlides = List<HeroSlide>.from(slides)
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return _viewMode == 'grid'
        ? _buildGrid(sortedSlides)
        : _buildList(sortedSlides);
  }

  Widget _buildGrid(List<HeroSlide> slides) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.8,
      ),
      itemCount: slides.length,
      itemBuilder: (context, index) => _buildSlideCard(slides[index]),
    );
  }

  Widget _buildSlideCard(HeroSlide slide) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        onTap: () => _handleEditSlide(slide),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                    child: CachedNetworkImage(
                      imageUrl: slide.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 40),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha:0.6),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Text(
                      slide.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: slide.isActive
                            ? AppConstants.success
                            : Colors.grey,
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
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.purple,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${slide.displayOrder}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () => _handleEditSlide(slide),
                    tooltip: 'تعديل',
                    color: Colors.purple,
                  ),
                  IconButton(
                    icon: Icon(
                      slide.isActive ? Icons.visibility_off : Icons.visibility,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<HeroSlide> slides) {
    return Column(
      children: slides.map((slide) => _buildListItem(slide)).toList(),
    );
  }

  Widget _buildListItem(HeroSlide slide) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () => _handleEditSlide(slide),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${slide.displayOrder}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: slide.imageUrl,
                  width: 100,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 100,
                    height: 60,
                    color: Colors.grey[300],
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 100,
                    height: 60,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slide.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      slide.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
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
              const SizedBox(width: 16),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => _handleEditSlide(slide),
                    tooltip: 'تعديل',
                    color: Colors.purple,
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

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            Icon(
              Icons.slideshow,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد شرائح بعد',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بإضافة شريحة جديدة',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _handleAddSlide,
              icon: const Icon(Icons.add),
              label: const Text('إضافة شريحة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'حدث خطأ في تحميل الشرائح',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(heroSlidesProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddSlide() {
    final parentContext = context;
    final messenger = ScaffoldMessenger.of(parentContext);

    showDialog(
      context: context,
      builder: (context) => SlideFormDialog(
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
      builder: (context) => SlideFormDialog(
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
}