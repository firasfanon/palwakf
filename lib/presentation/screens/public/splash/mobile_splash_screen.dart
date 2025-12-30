import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../app/routing/app_routes.dart';
import '../../../widgets/common/loading_widget.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/homepage_settings_provider.dart';
import '../../../widgets/home/hero_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MobileSplashScreen extends ConsumerStatefulWidget { // ← CHANGE TO ConsumerStatefulWidget
  const MobileSplashScreen({super.key});

  @override
  ConsumerState<MobileSplashScreen> createState() => _SplashScreenState(); // ← CHANGE HERE
}

class _SplashScreenState extends ConsumerState<MobileSplashScreen> // ← ADD ConsumerState
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Text animation controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Logo scale animation
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    // Text fade animation
    _textAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    // Text slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutBack,
    ));
  }

  // ✨ THIS IS THE KEY METHOD - UPDATED WITH AUTH CHECK AND PRELOADING
  void _startSplashSequence() async {
    // Set status bar style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Start logo animation
    await _logoController.forward();

    // Start text animation
    await _textController.forward();

    // Wait for animations to complete
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Fire-and-forget preloading so splash never blocks navigation
    unawaited(_preloadInBackground());

    if (!mounted) return;

    // Check authentication
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    final target = isAuthenticated ? AppRoutes.adminDashboard : AppRoutes.home;

    // Navigate after the current frame to avoid navigation timing issues
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.go(target);
    });
  }

  Future<void> _preloadInBackground() async {
    try {
      final slides = await ref
          .read(heroSlidesProvider.future)
          .timeout(const Duration(seconds: 4));
      if (!mounted) return;
      if (slides.isNotEmpty) {
        await Future.wait(
          slides.map(
            (s) => precacheImage(CachedNetworkImageProvider(s.imageUrl), context),
          ),
        );
      }
    } catch (_) {
      // Ignore
    }

    try {
      await ref
          .read(activeBreakingNewsProvider.future)
          .timeout(const Duration(seconds: 4));
      await ref
          .read(breakingNewsSectionNotifierProvider.notifier)
          .loadSettings()
          .timeout(const Duration(seconds: 4));
    } catch (_) {
      // Ignore
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.islamicGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo section
                AnimatedBuilder(
                  animation: _logoAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha:0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.mosque,
                          size: 60,
                          color: AppColors.islamicGreen,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // App name and ministry info
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textAnimation.value,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            Text(
                              'وزارة الأوقاف والشؤون الدينية',
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  const Shadow(
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                    color: Colors.black26,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'دولة فلسطين',
                              style: AppTextStyles.titleLarge.copyWith(
                                color: Colors.white.withValues(alpha:0.9),
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Palestinian Ministry of Endowments',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: Colors.white.withValues(alpha:0.8),
                                fontFamily: AppTextStyles.englishFont,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),

                // Loading indicator
                const LoadingWidget(
                  message: 'جاري التحميل...',
                  color: Colors.white,
                  size: 40,
                ),

                const SizedBox(height: 40),

                // Version info
                AnimatedBuilder(
                  animation: _textAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textAnimation.value * 0.7,
                      child: Text(
                        'الإصدار ${AppConstants.appVersion}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha:0.7),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

