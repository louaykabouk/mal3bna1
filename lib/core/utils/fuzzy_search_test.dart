/// Simple test/debug utility for fuzzy search functionality.
/// 
/// This file contains test cases to validate fuzzy search behavior
/// with Arabic text. Run these tests to ensure fuzzy matching works correctly.
/// 
/// Usage:
/// ```dart
/// void main() {
///   testFuzzySearch();
/// }
/// ```

import 'fuzzy_search.dart';

/// Test function to validate fuzzy search behavior
void testFuzzySearch() {
  print('=== Fuzzy Search Test ===\n');
  
  // Test 1: Normalization
  print('Test 1: Text Normalization');
  final testCases = [
    ('ملعب الأحلام', 'ملعب الاحلام'),
    ('ملعب الاحلاام', 'ملعب الاحلام'),
    ('ملعب الأحلاام', 'ملعب الاحلام'),
    ('ملعب  الاحلام', 'ملعب الاحلام'), // Extra spaces
  ];
  
  for (final (input, expected) in testCases) {
    final normalized = normalizeArabicText(input);
    final expectedNormalized = normalizeArabicText(expected);
    final match = normalized == expectedNormalized;
    print('  "$input" -> "$normalized" ${match ? "✓" : "✗"}');
    if (!match) {
      print('    Expected: "$expectedNormalized"');
    }
  }
  
  // Test 2: Fuzzy matching scores
  print('\nTest 2: Fuzzy Matching Scores');
  final searchQuery = 'ملعب الاحلام';
  final targets = [
    'ملعب الأحلام',      // Should match (high score)
    'ملعب الاحلاام',     // Should match (typo)
    'ملعب الاحلام الكبير', // Should match (contains)
    'ملعب آخر',          // Should not match (low score)
    'ملعب',              // Partial match
  ];
  
  for (final target in targets) {
    final score = calculateFuzzyScore(searchQuery, target);
    print('  Query: "$searchQuery" vs Target: "$target"');
    print('    Score: ${score.toStringAsFixed(3)} ${score >= 0.3 ? "✓" : "✗"}');
  }
  
  // Test 3: Multi-field search
  print('\nTest 3: Multi-Field Search');
  final playgrounds = [
    {'title': 'ملعب الأحلام', 'location': 'دمشق، سوريا'},
    {'title': 'ملعب الاحلاام', 'location': 'حلب، سوريا'},
    {'title': 'ملعب آخر', 'location': 'دمشق، سوريا'},
    {'title': 'ملعب جديد', 'location': 'اللاذقية، سوريا'},
  ];
  
  final results = fuzzySearchMultiField<Map<String, String>>(
    query: 'ملعب الاحلام',
    items: playgrounds,
    getSearchableFields: (item) => [item['title']!, item['location']!],
    minScore: 0.3,
  );
  
  print('  Query: "ملعب الاحلام"');
  print('  Results: ${results.length}');
  for (final result in results) {
    print('    - ${result.item['title']} (${result.score.toStringAsFixed(3)})');
  }
  
  // Test 4: Empty query
  print('\nTest 4: Empty Query');
  final emptyResults = fuzzySearchMultiField<Map<String, String>>(
    query: '',
    items: playgrounds,
    getSearchableFields: (item) => [item['title']!, item['location']!],
  );
  print('  Empty query returns all items: ${emptyResults.length == playgrounds.length ? "✓" : "✗"}');
  
  print('\n=== Test Complete ===');
}

/// Debug helper to test specific queries
void debugFuzzySearch(String query, List<String> targets) {
  print('Debug Fuzzy Search: "$query"');
  for (final target in targets) {
    final score = calculateFuzzyScore(query, target);
    final normalizedQuery = normalizeArabicText(query);
    final normalizedTarget = normalizeArabicText(target);
    print('  "$target" -> Score: ${score.toStringAsFixed(3)}');
    print('    Normalized: "$normalizedQuery" vs "$normalizedTarget"');
  }
}

