import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/widgets.dart';
import '../../stores/live_match_store.dart';

class LiveMatchDetailsScreen extends StatelessWidget {
  final String activityId;

  const LiveMatchDetailsScreen({
    super.key,
    required this.activityId,
  });

  @override
  Widget build(BuildContext context) {
    final cairoFont = GoogleFonts.cairo();
    final store = LiveMatchStore();
    final match = store.getLiveMatchById(activityId);

    if (match == null) {
      return Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('تفاصيل المباراة'),
          ),
          body: const Center(
            child: Text('المباراة غير موجودة'),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'تفاصيل المباراة المباشرة',
            style: AppTextStyles.h1.copyWith(
              color: const Color(0xFF4BCB78),
              fontFamily: cairoFont.fontFamily,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Field name
              _buildDetailRow(
                icon: Icons.location_on,
                label: 'الملعب',
                value: match.fieldName,
                cairoFont: cairoFont,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Date
              _buildDetailRow(
                icon: Icons.calendar_today,
                label: 'التاريخ',
                value: '${match.date.day}/${match.date.month}/${match.date.year}',
                cairoFont: cairoFont,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Time
              _buildDetailRow(
                icon: Icons.access_time,
                label: 'الوقت',
                value: '${match.time.hour.toString().padLeft(2, '0')}:${match.time.minute.toString().padLeft(2, '0')}',
                cairoFont: cairoFont,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Price
              _buildDetailRow(
                icon: Icons.attach_money,
                label: 'سعر للشخص',
                value: '${match.pricePerPerson.toInt()} ل.س',
                cairoFont: cairoFont,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Capacity
              _buildDetailRow(
                icon: Icons.people,
                label: 'عدد الأشخاص',
                value: '${match.capacity}',
                cairoFont: cairoFont,
              ),
              if (match.conditions != null && match.conditions!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'الشروط',
                  style: AppTextStyles.h3.copyWith(
                    fontFamily: cairoFont.fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    match.conditions!,
                    style: AppTextStyles.body.copyWith(
                      fontFamily: cairoFont.fontFamily,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required TextStyle cairoFont,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF4BCB78),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$label: ',
          style: AppTextStyles.body.copyWith(
            fontFamily: cairoFont.fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontFamily: cairoFont.fontFamily,
            ),
          ),
        ),
      ],
    );
  }
}

