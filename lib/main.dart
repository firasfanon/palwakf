// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/constants/app_constants.dart';
import 'core/services/storage_service.dart';
import 'app/routing/router_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'core/brand/brand_registry.dart';
import 'core/brand/brand_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await _initializeServices();

  // Configure system UI
  _configureSystemUI();

  // Run app
  runApp(
    const ProviderScope(
      child: PalestinianMinistryApp(),
    ),
  );
}

Future<void> _initializeServices() async {
  // 1. Load environment variables (Must be first!)
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('✅ Environment variables loaded successfully');
    debugPrint('🔍 Environment: ${AppConstants.environment}');
  } catch (e) {
    debugPrint('⚠️  .env file not found, using default values');
    debugPrint('   This is expected for web platform on first run');
    debugPrint('   Make sure to run: cp .env.example .env');
  }

  // 2. Initialize Storage Service
  try {
    await StorageService.instance.init();
    debugPrint('✅ Storage service initialized');
  } catch (e) {
    debugPrint('❌ Storage service initialization failed: $e');
  }

  // 3. Initialize Supabase (with validation)
  try {
    final supabaseUrl = AppConstants.baseUrl;
    final supabaseKey = AppConstants.apiKey;

    // Validate that we have proper credentials
    if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      throw Exception('Supabase URL or API key is missing. Please configure .env file.');
    }

    // FIXED: Removed the problematic pre-check that tried to access Supabase.instance before initialization
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
      debug: false, // Set to true for debugging
    );

    debugPrint('✅ Supabase initialized successfully');
    debugPrint('   URL: $supabaseUrl');
  } catch (e, stackTrace) {
    debugPrint('❌ Supabase initialization failed: $e');
    debugPrint('   Stack trace: $stackTrace');
    debugPrint('   Please check your .env file configuration');
    // Don't rethrow - let the app continue with limited functionality
  }

  // TODO: Add other services when needed (notifications, etc.)
}

void _configureSystemUI() {
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configure system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}

class PalestinianMinistryApp extends ConsumerWidget {
  const PalestinianMinistryApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Ensure auth state is initialized once (restores session + loads admin_users profile).
    ref.read(authStateProvider.notifier).initialize();

    return MaterialApp.router(
      routerConfig: ref.watch(goRouterProvider),
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Localization
      locale: const Locale('ar', 'PS'),
      supportedLocales: const [
        Locale('ar', 'PS'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Theme configuration
      theme: BrandTheme.buildTheme(BrandRegistry.platform),

      // Routing

      // Builder for RTL support
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.0),
            ),
            child: child ?? const SizedBox(),
          ),
        );
      },
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.islamicGreen,
        brightness: Brightness.light,
      ),
      primaryColor: AppColors.islamicGreen,
      scaffoldBackgroundColor: AppColors.background,
      useMaterial3: true,
    );
  }
}