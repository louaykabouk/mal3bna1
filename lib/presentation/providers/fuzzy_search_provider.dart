import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/fuzzy_search.dart' show fuzzyMatchIgnoreSpaces;

/// Provider for search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider that holds the source list of all playgrounds
/// This should be set from the Home page
final allPlaygroundsProvider = StateProvider<List<Map<String, String>>>((ref) => []);

/// Provider for filtered playgrounds based on search query
/// This watches both the source list and the search query
final filteredPlaygroundsProvider = Provider<List<Map<String, String>>>((ref) {
  final allPlaygrounds = ref.watch(allPlaygroundsProvider);
  final query = ref.watch(searchQueryProvider);
  
  final qRaw = query.trim();
  
  // Debug: Log query and item count
  print('[SEARCH] q="$qRaw" full=${allPlaygrounds.length}');
  
  // If query is empty, return all items
  if (qRaw.isEmpty) {
    print('[SEARCH] Empty query, returning all ${allPlaygrounds.length} items');
    return allPlaygrounds;
  }
  
  // Filter using space-ignoring fuzzy match
  final filtered = allPlaygrounds.where((playground) {
    final title = playground['title'] ?? '';
    final location = playground['location'] ?? '';
    
    // Match against title or location
    return fuzzyMatchIgnoreSpaces(qRaw, title) || 
           fuzzyMatchIgnoreSpaces(qRaw, location);
  }).toList();
  
  // Debug: Log filtered results
  final qNorm = qRaw.replaceAll(RegExp(r'\s+'), '');
  print('[SEARCH] qNorm="$qNorm" filtered=${filtered.length}');
  if (filtered.isNotEmpty) {
    print('[SEARCH] First 3: ${filtered.take(3).map((e) => e['title']).toList()}');
  } else {
    print('[SEARCH] No matches found');
  }
  
  // IMPORTANT: Return filtered list (even if empty), NOT all items
  return filtered;
});

