import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the selected bottom navigation tab index
/// Default is 2 (الرئيسية / Home tab)
final selectedTabIndexProvider = StateProvider<int>((ref) => 2);

