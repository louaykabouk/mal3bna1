import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../providers/theme_provider.dart';
import '../../../main.dart' show SportLifeApp;

/// Bootstrap page that initializes app state asynchronously
/// and renders the first frame immediately.
class AppBootstrapPage extends ConsumerStatefulWidget {
  const AppBootstrapPage({super.key});

  @override
  ConsumerState<AppBootstrapPage> createState() => _AppBootstrapPageState();
}

class _AppBootstrapPageState extends ConsumerState<AppBootstrapPage> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    debugPrint('[AppBootstrap] Starting app initialization...');
    
    try {
      // Initialize Firebase first
      debugPrint('[AppBootstrap] Initializing Firebase...');
      await Firebase.initializeApp();
      debugPrint('[AppBootstrap] Firebase initialized');
      
      // Initialize theme controller asynchronously with timeout
      debugPrint('[AppBootstrap] Reading theme controller...');
      final themeController = ref.read(themeControllerProvider);
      debugPrint('[AppBootstrap] Theme controller read, initialized: ${themeController.initialized}');
      
      if (!themeController.initialized) {
        debugPrint('[AppBootstrap] Initializing theme controller...');
        await themeController.init().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            debugPrint('[AppBootstrap] Theme init timed out, using default');
          },
        );
        debugPrint('[AppBootstrap] Theme controller initialized: ${themeController.initialized}');
      }
      
      // AuthGate in SportLifeApp will handle role fetching and routing
      // No need to initialize role provider here
      
      // Mark bootstrap as complete so we can render the app
      debugPrint('[AppBootstrap] Marking bootstrap as complete...');
      if (mounted) {
        setState(() {
          _initialized = true;
        });
        debugPrint('[AppBootstrap] Initialization complete, _initialized = true');
      }
    } catch (e, stackTrace) {
      debugPrint('[AppBootstrap] Error during initialization: $e');
      debugPrint('[AppBootstrap] Stack trace: $stackTrace');
      // Still proceed to app even on error - let SportLifeApp handle it
      if (mounted) {
        setState(() {
          _initialized = true;
        });
        debugPrint('[AppBootstrap] Marked as initialized despite error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('[AppBootstrap] build() called, _initialized: $_initialized');
    
    // Show loading screen while initializing bootstrap
    if (!_initialized) {
      debugPrint('[AppBootstrap] Showing loading screen...');
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SportLife',
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(
              color: const Color(0xFF4BCB78),
            ),
          ),
        ),
      );
    }
    
    // Once initialized, build the actual app
    debugPrint('[AppBootstrap] Building SportLifeApp...');
    return const SportLifeApp();
  }
}

