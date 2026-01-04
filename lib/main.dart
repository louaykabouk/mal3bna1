import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_gate.dart';
import 'presentation/pages/pages.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/theme/app_text_styles.dart';

void main() {
  debugPrint('[main] Starting app...');
  
  // Set up global error handlers (these work outside zones)
  _setupErrorHandlers();
  
  // ALL Flutter initialization must happen in the SAME zone as runApp()
  // This prevents "Zone mismatch" errors
  runZonedGuarded(() {
    // Ensure Flutter binding is initialized (required before any Flutter APIs)
    // MUST be inside the same zone as runApp()
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('[main] WidgetsFlutterBinding.ensureInitialized() completed');
    
    // Create theme controller (but don't await init - let bootstrap page handle it)
    debugPrint('[main] Creating theme controller...');
    final themeController = ThemeController();
    debugPrint('[main] Theme controller created');
    
    // Run app - no blocking awaits
    // The bootstrap page will handle async initialization
    debugPrint('[main] Calling runApp()...');
    runApp(
      ProviderScope(
        overrides: [
          themeControllerProvider.overrideWith((ref) => themeController),
        ],
        child: const AppBootstrapPage(),
      ),
    );
    debugPrint('[main] runApp() called - first frame should render now');
  }, (error, stack) {
    debugPrint('[ZoneError] Unhandled error: $error');
    debugPrint('[ZoneError] Stack: $stack');
  });
}

void _setupErrorHandlers() {
  debugPrint('[main] Setting up error handlers...');
  
  // Flutter framework errors
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('[FlutterError] ${details.exception}');
    debugPrint('[FlutterError] Stack: ${details.stack}');
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  };
  
  // Platform/async errors
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[PlatformError] $error');
    debugPrint('[PlatformError] Stack: $stack');
    return true; // Handled
  };
  
  debugPrint('[main] Error handlers set up');
}

class SportLifeApp extends ConsumerWidget {
  const SportLifeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('[SportLifeApp] build() called');
    final themeController = ref.watch(themeControllerProvider);
    
    debugPrint('[SportLifeApp] themeController.initialized: ${themeController.initialized}');
    
    debugPrint('[SportLifeApp] Building main MaterialApp with AuthGate');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SportLife',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4BCB78),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4BCB78),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeController.mode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      locale: const Locale('ar'),
      // Register routes for navigation within auth flows
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(
              builder: (context) => const LoginPage(),
              settings: settings,
            );
          case '/register':
            return MaterialPageRoute(
              builder: (context) => const RegisterPage(),
              settings: settings,
            );
          case '/verify':
            return MaterialPageRoute(
              builder: (context) => const VerifyOtpPage(),
              settings: settings,
            );
          case '/verify_email':
            return MaterialPageRoute(
              builder: (context) => const VerifyEmailPage(),
              settings: settings,
            );
          default:
            return null; // Let AuthGate handle routing
        }
      },
      onUnknownRoute: (settings) {
        // Safety fallback for unknown routes
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('خطأ'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'الصفحة غير موجودة: ${settings.name}',
                    style: AppTextStyles.h2,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          settings: settings,
        );
      },
      // AuthGate handles all routing decisions based on auth state and Firestore role
      home: const AuthGate(),
    );
  }
}
