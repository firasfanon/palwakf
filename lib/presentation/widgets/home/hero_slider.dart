// lib/presentation/widgets/home/hero_slider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../app/routing/app_routes.dart';
import '../../../data/models/homepage_section.dart';
import '../../../data/repositories/homepage_repository.dart';

// Provider for hero slides from database
final heroSlidesProvider = FutureProvider<List<HeroSlide>>((ref) async {
  final repository = HomepageRepository(Supabase.instance.client);
  return repository.fetchActiveHeroSlides();
});

class HeroSlider extends ConsumerStatefulWidget {
  const HeroSlider({super.key});

  @override
  ConsumerState<HeroSlider> createState() => _HeroSliderState();
}

class _HeroSliderState extends ConsumerState<HeroSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoPlayTimer;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || _isHovering) {
        return;
      }

      final slidesAsync = ref.read(heroSlidesProvider);
      slidesAsync.whenData((slides) {
        if (slides.isEmpty) return;

        if (_currentPage < slides.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        if (mounted && _pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  void _pauseAutoPlay() {
    setState(() {
      _isHovering = true;
    });
  }

  void _resumeAutoPlay() {
    setState(() {
      _isHovering = false;
    });
  }

  void _goToSlide(int index) {
    if (!mounted || !_pageController.hasClients) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _previousSlide(int totalSlides) {
    if (_currentPage > 0) {
      _goToSlide(_currentPage - 1);
    } else {
      _goToSlide(totalSlides - 1);
    }
  }

  void _nextSlide(int totalSlides) {
    if (_currentPage < totalSlides - 1) {
      _goToSlide(_currentPage + 1);
    } else {
      _goToSlide(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final slidesAsync = ref.watch(heroSlidesProvider);

    return slidesAsync.when(
      data: (slides) {
        if (slides.isEmpty) {
          return _buildEmptyState();
        }
        return _buildSlider(slides);
      },
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildSlider(List<HeroSlide> slides) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.5,
      child: MouseRegion(
        onEnter: (_) => _pauseAutoPlay(),
        onExit: (_) => _resumeAutoPlay(),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                if (mounted) {
                  setState(() {
                    _currentPage = index;
                  });
                }
              },
              itemCount: slides.length,
              itemBuilder: (context, index) {
                return _buildSlide(slides[index], index);
              },
            ),

          // Slider Indicators
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  slides.length,
                      (index) => GestureDetector(
                    onTap: () => _goToSlide(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 40 : 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppConstants.goldenYellow
                            : Colors.white.withValues(alpha:0.5),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: _currentPage == index
                            ? [
                          BoxShadow(
                            color: AppConstants.goldenYellow.withValues(alpha:0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Left Arrow (RTL - goes to next)
          Positioned(
            left: 32,
            top: 0,
            bottom: 0,
            child: Center(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _nextSlide(slides.length),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right,
                        color: Colors.white, size: 32),
                  ),
                ),
              ),
            ),
          ),

          // Right Arrow (RTL - goes to previous)
          Positioned(
            right: 32,
            top: 0,
            bottom: 0,
            child: Center(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => _previousSlide(slides.length),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_left,
                        color: Colors.white, size: 32),
                  ),
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildSlide(HeroSlide slide, int index) {
    final isActive = _currentPage == index;

    return Stack(
      children: [
        // Background Image
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: slide.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              decoration: const BoxDecoration(gradient: AppConstants.islamicGradient),
            ),
            errorWidget: (context, url, error) => Container(
              decoration: const BoxDecoration(gradient: AppConstants.islamicGradient),
              child: const Center(
                  child: Icon(Icons.image, size: 80, color: Colors.white54)),
            ),
          ),
        ),

        // Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppConstants.sageGreen.withValues(alpha:0.8),
                  AppConstants.islamicGreen.withValues(alpha:0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Content
        Positioned.fill(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                AnimatedOpacity(
                  opacity: isActive ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    slide.title,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                      shadows: [
                        Shadow(
                            offset: Offset(2, 2),
                            blurRadius: 4,
                            color: Colors.black45)
                      ],
                    ),
                  ),
                ),
              //  const SizedBox(height: 20),

                // Content Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Text Section
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AnimatedOpacity(
                            opacity: isActive ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 1000),
                            child: Text(
                              slide.subtitle,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 24,
                                color: AppConstants.goldenYellow,
                                fontWeight: FontWeight.w600,
                                shadows: const [
                                  Shadow(
                                      offset: Offset(1, 1),
                                      blurRadius: 3,
                                      color: Colors.black45)
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          AnimatedOpacity(
                            opacity: isActive ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 1200),
                            child: Text(
                              slide.description,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withValues(alpha:0.9),
                                height: 1.6,
                                shadows: const [
                                  Shadow(
                                      offset: Offset(1, 1),
                                      blurRadius: 3,
                                      color: Colors.black45)
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 40),

                    // Buttons Section
                    Expanded(
                      flex: 4,
                      child: AnimatedOpacity(
                        opacity: isActive ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 1400),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Primary CTA (from database)

                            //                          ✅✅✅   DEFAULT VALUES     ✅✅✅
                            ElevatedButton.icon(
                              onPressed: () =>
                                  context.go(slide.ctaLink ?? '/'),  // ← Default route
                              icon: const Icon(Icons.article),
                              label: Text(slide.ctaText ?? 'اقرأ المزيد'),            // ← Default text
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppConstants.islamicGreen,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 20),
                                textStyle: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 5,
                              ),
                            ),

                            /*


                            // ✅✅✅ Only show button if both ctaText and ctaLink exist ✅✅✅
                            if (slide.ctaText != null && slide.ctaLink != null)
                              ElevatedButton.icon(
                                onPressed: () =>
                                    context.go(slide.ctaLink!),  // ← Add !
                                icon: const Icon(Icons.article),
                                label: Text(slide.ctaText!),                        // ← Add !
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppConstants.islamicGreen,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 20),
                                  textStyle: const TextStyle(
                                      fontSize: 18, fontWeight: FontWeight.bold),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  elevation: 5,
                                ),
                              ),

                            */
                            const SizedBox(height: 20),
                            // Secondary CTA
                            OutlinedButton.icon(
                              onPressed: () => context.go(AppRoutes.about),
                              icon: Icon(Icons.info_outline),  // ✅ Remove const
                              label: Text('تعرف علينا'),  // ✅ Remove const
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white, width: 2),  // ✅ Remove const
                                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),  // ✅ Remove const
                                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),  // ✅ Remove const
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        ),
      ],
    );
  }

  // Loading State
  Widget _buildLoadingState() {
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenHeight * 0.6,
      child: Container(
        decoration: const BoxDecoration(gradient: AppConstants.islamicGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppConstants.goldenYellow,
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                'جاري التحميل...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState() {
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenHeight * 0.6,
      child: Container(
        decoration: const BoxDecoration(gradient: AppConstants.islamicGradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.image_not_supported,
                  size: 80,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'لا توجد شرائح متاحة حالياً',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'يرجى إضافة شرائح من لوحة التحكم',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Error State
  Widget _buildErrorState(Object error) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: screenHeight * 0.6,
      child: Container(
        color: Colors.grey[900],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              const Text(
                'حدث خطأ في تحميل الشرائح',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  ref.refresh(heroSlidesProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.islamicGreen,
                  foregroundColor: Colors.white,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}