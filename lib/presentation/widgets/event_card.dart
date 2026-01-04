import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/widgets.dart';
import '../models/event_model.dart';
import '../pages/owner/event_details_page.dart';

class EventCard extends StatelessWidget {
  final Event event;

  const EventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final cairoFont = GoogleFonts.cairo();

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => EventDetailsPage(event: event),
          ),
        );
      },
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
                  // Academy/Trophy icon
                  child: SvgPicture.asset(
                    'assets/icons/trophy-solid-full.svg',
                    width: 60,
                    height: 60,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF4BCB78),
                      BlendMode.srcIn,
                    ),
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
              // Top-right: Price badge
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
                    'سعر للشخص: ${event.pricePerPerson.toInt()} ل.س',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontFamily: cairoFont.fontFamily,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              // Top-left: Teams count badge
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
                    'عدد الفرق: ${event.teams.length}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontFamily: cairoFont.fontFamily,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
              // Bottom section: Title and chips
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
                        event.title,
                        style: AppTextStyles.h3.copyWith(
                          fontFamily: cairoFont.fontFamily,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      // Chips row
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
                              'دور الـ16',
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
                              _formatDate(event.createdAt),
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
    // Format: "DD/MM/YYYY"
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}
