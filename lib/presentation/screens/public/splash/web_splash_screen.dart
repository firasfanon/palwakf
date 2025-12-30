import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../app/routing/app_routes.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/homepage_settings_provider.dart';
import '../../../widgets/home/hero_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Web-optimized Splash Screen matching web theme
class WebSplashScreen extends ConsumerStatefulWidget {
  const WebSplashScreen({super.key});

  @override
  ConsumerState<WebSplashScreen> createState() => _WebSplashScreenState();
}

class _WebSplashScreenState extends ConsumerState<WebSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitializationSequence();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  void _startInitializationSequence() async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    // Fire-and-forget preloading so splash never blocks navigation
    unawaited(_preloadInBackground());

    // Keep branding visible briefly
    await Future.delayed(const Duration(milliseconds: 900));

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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo container matching web app bar style
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.islamicGreen.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.mosque,
                  size: 50,
                  color: AppColors.islamicGreen,
                ),
              ),

              const SizedBox(height: 32),

              // Ministry name in Arabic
              Text(
                'وزارة الأوقاف والشؤون الدينية',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.islamicGreen,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // English name
              Text(
                'Palestinian Ministry of Endowments',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontFamily: AppTextStyles.englishFont,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60),

              // Loading indicator - matching app theme
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.islamicGreen,
                  ),
                  strokeWidth: 3,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'جاري التحميل...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
