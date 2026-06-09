// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_constants.dart';
import 'core/services/storage_service.dart';
import 'app/routing/router_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'core/brand/brand_registry.dart';
import 'core/brand/brand_theme.dart';
import 'core/visual_identity/visual_identity_publish_repository.dart';
import 'core/visual_identity/visual_identity_registry.dart';
import 'core/layout/pwf_global_layout_contract.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Temporary stabilization for Web: the current project still uses
  // GoogleFonts.cairo / scheherazadeNew in many widgets. Until all of them are
  // migrated to local bundled fonts, runtime fetching must remain enabled.
  GoogleFonts.config.allowRuntimeFetching = true;

  await _initializeServices();
  _configureSystemUI();

  runApp(
    const ProviderScope(
      child: PalestinianMinistryApp(),
    ),
  );
}

Future<void> _initializeServices() async {
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('✅ Environment variables loaded successfully');
    debugPrint('🔍 Environment: ${AppConstants.environment}');
  } catch (e) {
    debugPrint('⚠️  .env file not found, using default values');
    debugPrint('   This is expected for web platform on first run');
    debugPrint('   Make sure to run: cp .env.example .env');
  }

  try {
    await StorageService.instance.init();
    debugPrint('✅ Storage service initialized');
  } catch (e) {
    debugPrint('❌ Storage service initialization failed: $e');
  }

  try {
    final supabaseUrl = AppConstants.baseUrl;
    final supabaseKey = AppConstants.apiKey;

    if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
      throw Exception(
          'Supabase URL or API key is missing. Please configure .env file.');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
      debug: false,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        detectSessionInUri: false,
      ),
    );

    debugPrint('✅ Supabase initialized successfully');
    debugPrint('   URL: $supabaseUrl');

    await _initializePublishedVisualIdentity();
  } catch (e, stackTrace) {
    debugPrint('❌ Supabase initialization failed: $e');
    debugPrint('   Stack trace: $stackTrace');
    debugPrint('   Please check your .env file configuration');
  }
}

Future<void> _initializePublishedVisualIdentity() async {
  try {
    final repo = PwfVisualIdentityPublishRepository(Supabase.instance.client);
    final state = await repo.fetchState();
    PwfVisualIdentityRegistry.applyPublishedMappings(state.publishedByContext);
    if (state.publishedByContext.isEmpty) {
      debugPrint(
          '🎨 Visual identity bootstrap: no published overrides found, using defaults');
    } else {
      debugPrint(
          '🎨 Visual identity bootstrap: loaded ${state.publishedByContext.length} published override(s)');
    }
  } catch (e, stackTrace) {
    debugPrint('⚠️ Visual identity bootstrap failed: $e');
    debugPrint('   Stack trace: $stackTrace');
  }
}

void _configureSystemUI() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}

class PalestinianMinistryApp extends ConsumerStatefulWidget {
  const PalestinianMinistryApp({super.key});

  @override
  ConsumerState<PalestinianMinistryApp> createState() =>
      _PalestinianMinistryAppState();
}

class _PalestinianMinistryAppState
    extends ConsumerState<PalestinianMinistryApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authStateProvider.notifier).initialize());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: ref.watch(goRouterProvider),
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
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
      theme: BrandTheme.buildTheme(BrandRegistry.platform),
      builder: (context, child) {
        return PwfGlobalAppBoundary(
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
