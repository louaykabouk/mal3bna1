import 'package:flutter/foundation.dart';
import '../models/review_model.dart';

class ReviewsStore extends ChangeNotifier {
  static final ReviewsStore _instance = ReviewsStore._internal();
  factory ReviewsStore() => _instance;
  ReviewsStore._internal();

  final List<Review> _reviews = [];

  List<Review> get reviews => List.unmodifiable(_reviews);

  void addReview(Review review) {
    _reviews.add(review);
    notifyListeners();
  }

  List<Review> getReviewsByFieldId(String fieldId) {
    return _reviews.where((review) => review.fieldId == fieldId).toList();
  }

  double getAverageRatingForField(String fieldId) {
    final fieldReviews = getReviewsByFieldId(fieldId);
    if (fieldReviews.isEmpty) return 0.0;
    final sum = fieldReviews.fold<int>(0, (sum, review) => sum + review.stars);
    return sum / fieldReviews.length;
  }

  void clear() {
    _reviews.clear();
    notifyListeners();
  }
}

final reviewsStore = ReviewsStore();

