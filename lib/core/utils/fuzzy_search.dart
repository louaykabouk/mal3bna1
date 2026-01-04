/// Fuzzy search utility for Arabic text with typo tolerance.
/// 
/// Features:
/// - Arabic text normalization (removes diacritics, unifies characters)
/// - Typo-tolerant matching using edit distance
/// - Scoring system for ranking results
library fuzzy_search;

/// Normalizes Arabic text for fuzzy matching.
/// 
/// Performs:
/// - Removes diacritics (tashkeel)
/// - Unifies hamza forms
/// - Normalizes yaa/alif maqsoora
/// - Converts taa marbuta to haa
/// - Removes extra spaces
/// - Converts to lowercase
String normalizeArabicText(String text) {
  if (text.isEmpty) return text;
  
  String normalized = text;
  
  // Remove diacritics (tashkeel)
  normalized = normalized.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
  
  // Unify hamza forms (أ, إ, آ, ؤ, ئ) -> أ
  normalized = normalized.replaceAll('إ', 'أ');
  normalized = normalized.replaceAll('آ', 'أ');
  normalized = normalized.replaceAll('ؤ', 'أ');
  normalized = normalized.replaceAll('ئ', 'أ');
  
  // Normalize yaa/alif maqsoora (ى -> ي)
  normalized = normalized.replaceAll('ى', 'ي');
  
  // Convert taa marbuta to haa (ة -> ه)
  normalized = normalized.replaceAll('ة', 'ه');
  
  // Remove extra spaces and trim
  normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
  
  // Convert to lowercase (for consistency, though Arabic doesn't have case)
  normalized = normalized.toLowerCase();
  
  return normalized;
}

/// Normalizes Arabic text for space-ignoring fuzzy matching.
/// 
/// Same as normalizeArabicText but ALSO:
/// - Removes ALL spaces and punctuation
/// - Removes Tatweel (ـ)
/// So "ملعب 1" becomes "ملعب1"
String normalizeArabicIgnoreSpaces(String text) {
  if (text.isEmpty) return text;
  
  String normalized = text;
  
  // Remove diacritics (tashkeel)
  normalized = normalized.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
  
  // Unify hamza forms (أ, إ, آ, ؤ, ئ) -> ا (unify to ا not أ for consistency)
  normalized = normalized.replaceAll('أ', 'ا');
  normalized = normalized.replaceAll('إ', 'ا');
  normalized = normalized.replaceAll('آ', 'ا');
  normalized = normalized.replaceAll('ؤ', 'ا');
  normalized = normalized.replaceAll('ئ', 'ا');
  
  // Normalize yaa/alif maqsoora (ى -> ي)
  normalized = normalized.replaceAll('ى', 'ي');
  
  // Convert taa marbuta to haa (ة -> ه)
  normalized = normalized.replaceAll('ة', 'ه');
  
  // Remove Tatweel (ـ)
  normalized = normalized.replaceAll('ـ', '');
  
  // Remove ALL spaces, punctuation, and special characters
  normalized = normalized.replaceAll(RegExp(r'[\s\p{P}\p{S}]', unicode: true), '');
  
  // Convert to lowercase
  normalized = normalized.toLowerCase();
  
  return normalized;
}

/// Fuzzy match that ignores spaces and punctuation.
/// 
/// Returns true if query matches target after normalization.
/// Examples:
/// - "ملعب1" matches "ملعب 1"
/// - "ملعب  1" matches "ملعب1"
bool fuzzyMatchIgnoreSpaces(String query, String target) {
  if (query.trim().isEmpty) return true;
  
  final qNorm = normalizeArabicIgnoreSpaces(query);
  final tNorm = normalizeArabicIgnoreSpaces(target);
  
  // Direct contains match
  if (tNorm.contains(qNorm)) {
    return true;
  }
  
  // Reverse match (query contains target)
  if (qNorm.contains(tNorm) && tNorm.length >= 2) {
    return true;
  }
  
  return false;
}

/// Calculates Levenshtein distance between two strings.
/// 
/// Returns the minimum number of single-character edits (insertions,
/// deletions, or substitutions) required to change one string into another.
int levenshteinDistance(String a, String b) {
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  
  final matrix = List.generate(
    a.length + 1,
    (i) => List<int>.filled(b.length + 1, 0),
  );
  
  for (int i = 0; i <= a.length; i++) {
    matrix[i][0] = i;
  }
  for (int j = 0; j <= b.length; j++) {
    matrix[0][j] = j;
  }
  
  for (int i = 1; i <= a.length; i++) {
    for (int j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      matrix[i][j] = [
        matrix[i - 1][j] + 1,      // deletion
        matrix[i][j - 1] + 1,      // insertion
        matrix[i - 1][j - 1] + cost, // substitution
      ].reduce((a, b) => a < b ? a : b);
    }
  }
  
  return matrix[a.length][b.length];
}

/// Fast contains check with normalization (fallback for performance)
bool fastNormalizedContains(String query, String target) {
  final normalizedQuery = normalizeArabicText(query);
  final normalizedTarget = normalizeArabicText(target);
  return normalizedTarget.contains(normalizedQuery) || 
         normalizedQuery.contains(normalizedTarget);
}

/// Calculates a fuzzy match score between query and target text.
/// 
/// Returns a score from 0.0 (no match) to 1.0 (perfect match).
/// Higher scores indicate better matches.
/// 
/// Scoring factors:
/// - Exact match: 1.0
/// - Substring contains: 0.8 - 0.9
/// - Token overlap: 0.5 - 0.7
/// - Edit distance: 0.0 - 0.5 (based on similarity ratio)
double calculateFuzzyScore(String query, String target) {
  final normalizedQuery = normalizeArabicText(query);
  final normalizedTarget = normalizeArabicText(target);
  
  if (normalizedQuery.isEmpty) return 1.0;
  if (normalizedTarget.isEmpty) return 0.0;
  
  // Exact match
  if (normalizedQuery == normalizedTarget) {
    return 1.0;
  }
  
  // Fast path: normalized contains (high score)
  if (normalizedTarget.contains(normalizedQuery)) {
    // Score based on position: earlier matches are better
    final position = normalizedTarget.indexOf(normalizedQuery);
    final lengthRatio = normalizedQuery.length / normalizedTarget.length;
    final positionRatio = 1.0 - (position / normalizedTarget.length) * 0.1;
    // Higher score for longer matches and earlier positions
    return 0.7 + (lengthRatio * 0.2) + (positionRatio * 0.1);
  }
  
  // Reverse substring (query contains target substring)
  if (normalizedQuery.contains(normalizedTarget)) {
    return 0.75;
  }
  
  // Token overlap (split by spaces) - fast path
  final queryTokens = normalizedQuery.split(' ').where((t) => t.isNotEmpty).toList();
  final targetTokens = normalizedTarget.split(' ').where((t) => t.isNotEmpty).toList();
  
  if (queryTokens.isNotEmpty && targetTokens.isNotEmpty) {
    int matches = 0;
    for (final queryToken in queryTokens) {
      for (final targetToken in targetTokens) {
        if (targetToken.contains(queryToken) || queryToken.contains(targetToken)) {
          matches++;
          break;
        }
      }
    }
    final tokenScore = matches / queryTokens.length;
    if (tokenScore >= 0.3) { // Lower threshold for token matching
      return 0.4 + (tokenScore * 0.3); // 0.4 - 0.7 range
    }
  }
  
  // Edit distance based score (only for short queries to avoid performance issues)
  if (normalizedQuery.length <= 20 && normalizedTarget.length <= 50) {
    final maxLength = normalizedQuery.length > normalizedTarget.length
        ? normalizedQuery.length
        : normalizedTarget.length;
    
    if (maxLength > 0) {
      final distance = levenshteinDistance(normalizedQuery, normalizedTarget);
      final similarity = 1.0 - (distance / maxLength);
      
      // More lenient threshold for edit distance
      if (similarity > 0.4) {
        return similarity * 0.4; // Scale to 0.0 - 0.4 range
      }
    }
  }
  
  return 0.0;
}

/// Represents a search result with its score.
class FuzzySearchResult<T> {
  final T item;
  final double score;
  
  const FuzzySearchResult({
    required this.item,
    required this.score,
  });
}

/// Performs fuzzy search on a list of items.
/// 
/// [query] - The search query string
/// [items] - List of items to search through
/// [getSearchableText] - Function to extract searchable text from each item
/// [minScore] - Minimum score threshold (default: 0.3)
/// 
/// Returns a sorted list of results (highest score first).
List<FuzzySearchResult<T>> fuzzySearch<T>({
  required String query,
  required List<T> items,
  required String Function(T) getSearchableText,
  double minScore = 0.3,
}) {
  if (query.trim().isEmpty) {
    // Return all items with score 1.0 when query is empty
    return items.map((item) => FuzzySearchResult<T>(
      item: item,
      score: 1.0,
    )).toList();
  }
  
  final results = <FuzzySearchResult<T>>[];
  
  for (final item in items) {
    final searchableText = getSearchableText(item);
    final score = calculateFuzzyScore(query, searchableText);
    
    if (score >= minScore) {
      results.add(FuzzySearchResult<T>(
        item: item,
        score: score,
      ));
    }
  }
  
  // Sort by score (descending)
  results.sort((a, b) => b.score.compareTo(a.score));
  
  return results;
}

/// Performs fuzzy search on items with multiple searchable fields.
/// 
/// [query] - The search query string
/// [items] - List of items to search through
/// [getSearchableFields] - Function to extract multiple searchable text fields
/// [minScore] - Minimum score threshold (default: 0.3)
/// 
/// Returns a sorted list of results (highest score first).
/// The score is the maximum score across all searchable fields.
List<FuzzySearchResult<T>> fuzzySearchMultiField<T>({
  required String query,
  required List<T> items,
  required List<String> Function(T) getSearchableFields,
  double minScore = 0.3,
}) {
  if (query.trim().isEmpty) {
    return items.map((item) => FuzzySearchResult<T>(
      item: item,
      score: 1.0,
    )).toList();
  }
  
  final results = <FuzzySearchResult<T>>[];
  
  for (final item in items) {
    final searchableFields = getSearchableFields(item);
    double maxScore = 0.0;
    
    for (final field in searchableFields) {
      final score = calculateFuzzyScore(query, field);
      if (score > maxScore) {
        maxScore = score;
      }
    }
    
    if (maxScore >= minScore) {
      results.add(FuzzySearchResult<T>(
        item: item,
        score: maxScore,
      ));
    }
  }
  
  // Sort by score (descending)
  results.sort((a, b) => b.score.compareTo(a.score));
  
  return results;
}

