import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/activity_item.dart';
import '../widgets/widgets.dart';

class ActivityCard extends StatelessWidget {
  final ActivityItem activity;
  final TextStyle cairoFont;
  final VoidCallback onTap;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.cairoFont,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Background: gradient container with icon
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF4BCB78).withValues(alpha: 0.15),
                      const Color(0xFF4BCB78).withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Center(
                  child: activity.type == ActivityType.event
                      ? SvgPicture.asset(
                          'assets/icons/trophy-solid-full.svg',
                          width: 60,
                          height: 60,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF4BCB78),
                            BlendMode.srcIn,
                          ),
                        )
                      : Icon(
                          Icons.sports_soccer,
                          size: 60,
                          color: const Color(0xFF4BCB78),
                        ),
                ),
              ),
              // Gradient overlay for text readability
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
              // Top badges
              if (activity.type == ActivityType.event) ...[
                // Top-right: Teams count
                if (activity.teamsCount != null)
                  PositionedDirectional(
                    top: 12,
                    end: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4BCB78),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${activity.teamsCount} فريق',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontFamily: cairoFont.fontFamily,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                // Top-left: Stage
                if (activity.stage != null)
                  PositionedDirectional(
                    top: 12,
                    start: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4BCB78),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        activity.stage!,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontFamily: cairoFont.fontFamily,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
              ] else ...[
                // Top-right: Field name
                if (activity.fieldName != null)
                  PositionedDirectional(
                    top: 12,
                    end: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4BCB78),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        activity.fieldName!,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontFamily: cairoFont.fontFamily,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                // Top-left: People count
                if (activity.peopleCount != null)
                  PositionedDirectional(
                    top: 12,
                    start: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4BCB78),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${activity.peopleCount} شخص',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontFamily: cairoFont.fontFamily,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
              ],
              // Bottom section: Title, date, and price
              PositionedDirectional(
                bottom: 0,
                start: 0,
                end: 0,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        activity.title,
                        style: AppTextStyles.h3.copyWith(
                          fontFamily: cairoFont.fontFamily,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // Date and price chips
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        textDirection: TextDirection.rtl,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              _formatDate(activity.dateTime),
                              style: AppTextStyles.bodySmall.copyWith(
                                fontFamily: cairoFont.fontFamily,
                                color: const Color(0xFF4BCB78),
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${activity.pricePerPerson} ل.س',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontFamily: cairoFont.fontFamily,
                                color: const Color(0xFF4BCB78),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}

