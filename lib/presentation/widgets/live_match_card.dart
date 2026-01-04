import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/live_match_model.dart';
import '../widgets/widgets.dart';

class LiveMatchCard extends StatelessWidget {
  final LiveMatch match;

  const LiveMatchCard({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    final cairoFont = GoogleFonts.cairo();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Field name and price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  match.fieldName,
                  style: AppTextStyles.h3.copyWith(
                    fontFamily: cairoFont.fontFamily,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4BCB78),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${match.pricePerPerson.toInt()} ل.س',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontFamily: cairoFont.fontFamily,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Date and time
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${match.date.day}/${match.date.month}/${match.date.year}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontFamily: cairoFont.fontFamily,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Icon(
                Icons.access_time,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${match.time.hour.toString().padLeft(2, '0')}:${match.time.minute.toString().padLeft(2, '0')}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontFamily: cairoFont.fontFamily,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Capacity
          Row(
            children: [
              Icon(
                Icons.people,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'عدد الأشخاص: ${match.capacity}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontFamily: cairoFont.fontFamily,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          // Conditions (if exists)
          if (match.conditions != null && match.conditions!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                match.conditions!,
                style: AppTextStyles.bodySmall.copyWith(
                  fontFamily: cairoFont.fontFamily,
                  color: Colors.grey.shade700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

