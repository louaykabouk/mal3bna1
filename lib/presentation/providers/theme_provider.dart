import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static const String _themeKey = 'dark_mode';
  static const Duration _initTimeout = Duration(seconds: 2);
  
  bool _isDark = false;
  bool _initialized = false;

  bool get isDark => _isDark;
  ThemeMode get mode => _isDark ? ThemeMode.dark : ThemeMode.light;
  bool get initialized => _initialized;

  /// Initialize theme with timeout and error handling.
  /// Never blocks - always completes within timeout or uses fallback.
  Future<void> init() async {
    if (_initialized) {
      debugPrint('[ThemeController] Already initialized, skipping');
      return;
    }
    
    debugPrint('[ThemeController] Starting initialization...');
    
    try {
      // Use timeout to prevent hanging
      final prefs = await SharedPreferences.getInstance()
          .timeout(_initTimeout, onTimeout: () {
        debugPrint('[ThemeController] SharedPreferences.getInstance() timed out after ${_initTimeout.inSeconds}s');
        throw TimeoutException('SharedPreferences initialization timeout', _initTimeout);
      });
      
      // Get theme preference
      // getBool() returns bool? (nullable), so we use ?? to provide a safe default
      // This ensures _isDark is always assigned a non-null bool value
      final themeValue = prefs.getBool(_themeKey);
      _isDark = themeValue ?? false;
      _initialized = true;
      debugPrint('[ThemeController] Initialized successfully: ${_isDark ? "dark" : "light"} mode');
      notifyListeners();
    } on TimeoutException catch (e) {
      debugPrint('[ThemeController] Timeout during init: $e');
      // Use safe fallback - light mode
      _isDark = false;
      _initialized = true;
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('[ThemeController] Error during init: $e');
      debugPrint('[ThemeController] Stack trace: $stackTrace');
      // Use safe fallback - light mode
      _isDark = false;
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> setDark(bool value) async {
    _isDark = value;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, value);
      notifyListeners();
    } catch (e) {
      debugPrint('[ThemeController] Error setting dark mode: $e');
      // Still update local state even if persistence fails
      notifyListeners();
    }
  }
}

final themeControllerProvider = ChangeNotifierProvider<ThemeController>((ref) {
  final controller = ThemeController();
  controller.init();
  return controller;
});

// Legacy provider for backward compatibility
final themeProvider = Provider<ThemeMode>((ref) {
  final controller = ref.watch(themeControllerProvider);
  return controller.mode;
});

