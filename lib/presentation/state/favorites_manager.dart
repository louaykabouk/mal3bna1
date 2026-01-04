import 'package:flutter/foundation.dart';
import '../pages/field_details/field_details_page.dart';

class FavoritesManager extends ChangeNotifier {
  static final FavoritesManager _instance = FavoritesManager._internal();
  factory FavoritesManager() => _instance;
  FavoritesManager._internal();

  final Map<String, FieldItem> _favorites = {};

  Map<String, FieldItem> get favorites => Map.unmodifiable(_favorites);
  List<FieldItem> get favoritesList => _favorites.values.toList();
  bool isFavorite(String fieldId) => _favorites.containsKey(fieldId);

  void addFavorite(FieldItem field) {
    if (!_favorites.containsKey(field.id)) {
      _favorites[field.id] = field;
      notifyListeners();
    }
  }

  void removeFavorite(String fieldId) {
    if (_favorites.containsKey(fieldId)) {
      _favorites.remove(fieldId);
      notifyListeners();
    }
  }

  void toggleFavorite(FieldItem field) {
    if (_favorites.containsKey(field.id)) {
      removeFavorite(field.id);
    } else {
      addFavorite(field);
    }
  }
}

