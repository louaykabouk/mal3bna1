import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/owner_fields_provider.dart';
import '../../stores/reviews_store.dart';
import '../../models/field_model.dart';
import '../../models/review_model.dart';
import '../../widgets/widgets.dart';

class OwnerFieldReviewsScreen extends ConsumerStatefulWidget {
  const OwnerFieldReviewsScreen({super.key});

  @override
  ConsumerState<OwnerFieldReviewsScreen> createState() => _OwnerFieldReviewsScreenState();
}

class _OwnerFieldReviewsScreenState extends ConsumerState<OwnerFieldReviewsScreen> {
  late final TextStyle _cairoFont = GoogleFonts.cairo();
  final ReviewsStore _reviewsStore = ReviewsStore();
  final Map<String, bool> _expandedFields = {};

  @override
  void initState() {
    super.initState();
    _reviewsStore.addListener(_onReviewsChanged);
  }

  @override
  void dispose() {
    _reviewsStore.removeListener(_onReviewsChanged);
    super.dispose();
  }

  void _onReviewsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  String _getFieldDisplayName(FieldModel field) {
    if (field.name.trim().isNotEmpty) {
      return field.name;
    }
    return 'ملعب بدون اسم';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  double _getAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0.0;
    final sum = reviews.fold<int>(0, (sum, review) => sum + review.stars);
    return sum / reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    final fields = ref.watch(ownerFieldsProvider);
    final allReviews = _reviewsStore.reviews;

    // Filter reviews for owner's fields only
    final ownerFieldIds = fields.map((f) => f.id).toSet();
    final ownerReviews = allReviews.where((r) => ownerFieldIds.contains(r.fieldId)).toList();

    // Group reviews by field
    final Map<String, List<Review>> reviewsByField = {};
    for (final review in ownerReviews) {
      reviewsByField.putIfAbsent(review.fieldId, () => []).add(review);
    }

    // Sort reviews within each field (newest first)
    for (final fieldId in reviewsByField.keys) {
      reviewsByField[fieldId]!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.grey.shade800,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'تقييمات ملاعبي',
            style: AppTextStyles.h1.copyWith(
              color: const Color(0xFF4BCB78),
              fontFamily: _cairoFont.fontFamily,
            ),
          ),
          centerTitle: true,
        ),
        body: fields.isEmpty
            ? Center(
                child: Text(
                  'لا يوجد ملاعب بعد',
                  style: _cairoFont.copyWith(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: fields.map((field) {
                    final fieldReviews = reviewsByField[field.id] ?? [];
                    final isExpanded = _expandedFields[field.id] ?? false;
                    final avgRating = _getAverageRating(fieldReviews);

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Field header (always visible)
                          InkWell(
                            onTap: () {
                              setState(() {
                                _expandedFields[field.id] = !isExpanded;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getFieldDisplayName(field),
                                          style: _cairoFont.copyWith(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Row(
                                          children: [
                                            // Average rating stars
                                            ...List.generate(5, (index) {
                                              final starValue = index + 1;
                                              return Icon(
                                                starValue <= avgRating.round()
                                                    ? Icons.star
                                                    : Icons.star_border,
                                                color: const Color(0xFF4BCB78),
                                                size: 16,
                                              );
                                            }),
                                            const SizedBox(width: AppSpacing.xs),
                                            Text(
                                              avgRating > 0
                                                  ? avgRating.toStringAsFixed(1)
                                                  : '0.0',
                                              style: _cairoFont.copyWith(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                            const SizedBox(width: AppSpacing.sm),
                                            Text(
                                              '(${fieldReviews.length} ${fieldReviews.length == 1 ? 'تقييم' : 'تقييمات'})',
                                              style: _cairoFont.copyWith(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Reviews list (expandable)
                          if (isExpanded)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(12),
                                ),
                              ),
                              child: fieldReviews.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(AppSpacing.lg),
                                      child: Center(
                                        child: Text(
                                          'لا توجد تقييمات لهذا الملعب',
                                          style: _cairoFont.copyWith(
                                            fontSize: 14,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: fieldReviews.map((review) {
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: AppSpacing.sm,
                                            left: AppSpacing.md,
                                            right: AppSpacing.md,
                                            top: AppSpacing.sm,
                                          ),
                                          padding: const EdgeInsets.all(AppSpacing.md),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.grey.shade200,
                                              width: 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  // Stars
                                                  Row(
                                                    children: List.generate(5, (index) {
                                                      return Icon(
                                                        index < review.stars
                                                            ? Icons.star
                                                            : Icons.star_border,
                                                        color: index < review.stars
                                                            ? const Color(0xFF4BCB78)
                                                            : Colors.grey.shade300,
                                                        size: 16,
                                                      );
                                                    }),
                                                  ),
                                                  // Date
                                                  Text(
                                                    _formatDate(review.createdAt),
                                                    style: _cairoFont.copyWith(
                                                      fontSize: 12,
                                                      color: Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: AppSpacing.xs),
                                              // Reviewer name (optional)
                                              if (review.reviewerName != null)
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                                                  child: Text(
                                                    review.reviewerName!,
                                                    style: _cairoFont.copyWith(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ),
                                              // Review text
                                              Text(
                                                review.text,
                                                style: _cairoFont.copyWith(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade800,
                                                ),
                                                textDirection: ui.TextDirection.rtl,
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
      ),
    );
  }
}

