import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/review_model.dart';
import '../stores/reviews_store.dart';
import '../widgets/widgets.dart';

class StadiumReviewsSection extends StatefulWidget {
  final String? stadiumId;

  const StadiumReviewsSection({
    super.key,
    this.stadiumId,
  });

  @override
  State<StadiumReviewsSection> createState() => _StadiumReviewsSectionState();
}

class _StadiumReviewsSectionState extends State<StadiumReviewsSection> {
  late final TextStyle _cairoFont = GoogleFonts.cairo();
  late final TextEditingController _reviewController;
  int _selectedRating = 0;
  final ReviewsStore _reviewsStore = ReviewsStore();

  @override
  void initState() {
    super.initState();
    _reviewController = TextEditingController();
    _reviewsStore.addListener(_onReviewsChanged);
  }

  @override
  void dispose() {
    _reviewsStore.removeListener(_onReviewsChanged);
    _reviewController.dispose();
    super.dispose();
  }

  void _onReviewsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _submitReview() {
    if (_selectedRating < 1 || _reviewController.text.trim().isEmpty) {
      return;
    }

    if (!mounted || widget.stadiumId == null) return;

    final review = Review(
      fieldId: widget.stadiumId!,
      stars: _selectedRating,
      text: _reviewController.text.trim(),
      createdAt: DateTime.now(),
    );

    _reviewsStore.addReview(review);

    setState(() {
      _selectedRating = 0;
      _reviewController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إرسال التقييم',
          style: _cairoFont,
        ),
        backgroundColor: const Color(0xFF4BCB78),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'التقييمات',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Rating input section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Star rating
                Text(
                  'قيم الملعب',
                  style: _cairoFont.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedRating = starIndex;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          starIndex <= _selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: starIndex <= _selectedRating
                              ? const Color(0xFF4BCB78)
                              : Colors.grey.shade400,
                          size: 32,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: AppSpacing.md),
                // Review text field
                TextFormField(
                  controller: _reviewController,
                  decoration: InputDecoration(
                    hintText: 'اكتب تقييمك هنا...',
                    hintStyle: _cairoFont.copyWith(
                      color: Colors.grey.shade500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF4BCB78),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: _cairoFont,
                  maxLines: null,
                  minLines: 3,
                  textDirection: ui.TextDirection.rtl,
                  onChanged: (value) {
                    setState(() {}); // Update button state
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_selectedRating >= 1 &&
                            _reviewController.text.trim().isNotEmpty)
                        ? _submitReview
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4BCB78),
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'إرسال التقييم',
                      style: _cairoFont.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Reviews list
        Builder(
          builder: (context) {
            final fieldReviews = widget.stadiumId != null
                ? _reviewsStore.getReviewsByFieldId(widget.stadiumId!)
                : <Review>[];
            
            if (fieldReviews.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Center(
                  child: Text(
                    'لا توجد تقييمات بعد',
                    style: _cairoFont.copyWith(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: fieldReviews.map((review) {
                  return _ReviewItem(
                    review: review,
                    cairoFont: _cairoFont,
                    formatDate: _formatDate,
                  );
                }).toList(),
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final Review review;
  final TextStyle cairoFont;
  final String Function(DateTime) formatDate;

  const _ReviewItem({
    required this.review,
    required this.cairoFont,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stars and date row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Stars
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.stars ? Icons.star : Icons.star_border,
                    color: index < review.stars
                        ? const Color(0xFF4BCB78)
                        : Colors.grey.shade300,
                    size: 18,
                  );
                }),
              ),
              // Date
              Text(
                formatDate(review.createdAt),
                style: cairoFont.copyWith(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Review text
          Text(
            review.text,
            style: cairoFont.copyWith(
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
            textDirection: ui.TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

