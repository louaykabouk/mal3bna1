class Review {
  final String fieldId;
  final int stars;
  final String text;
  final DateTime createdAt;
  final String? reviewerName;

  Review({
    required this.fieldId,
    required this.stars,
    required this.text,
    required this.createdAt,
    this.reviewerName,
  });
}

