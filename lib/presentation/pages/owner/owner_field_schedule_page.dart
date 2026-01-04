import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class OwnerFieldSchedulePage extends StatefulWidget {
  final String fieldName;
  final String? fieldId;

  const OwnerFieldSchedulePage({
    super.key,
    required this.fieldName,
    this.fieldId,
  });

  @override
  State<OwnerFieldSchedulePage> createState() => _OwnerFieldSchedulePageState();
}

class _OwnerFieldSchedulePageState extends State<OwnerFieldSchedulePage> {
  late final TextStyle _cairoFont = GoogleFonts.cairo();
  DateTime _selectedDate = DateTime.now();
  
  // Local booked slots data (key: date string, value: list of booked time slots)
  final Map<String, List<String>> _bookedSlots = {
    // Example: Today has some booked slots
    _dateKey(DateTime.now()): ['10:00', '12:00', '18:00'],
    // Tomorrow has different booked slots
    _dateKey(DateTime.now().add(const Duration(days: 1))): ['14:00', '16:00'],
  };

  static String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  // Generate list of dates (today + next 13 days = 14 days total)
  List<DateTime> _generateDates() {
    final dates = <DateTime>[];
    final today = DateTime.now();
    for (int i = 0; i < 14; i++) {
      dates.add(today.add(Duration(days: i)));
    }
    return dates;
  }

  // Generate time slots from startHour to endHour with stepMinutes interval
  List<String> generateTimeSlots(int startHour, int endHour, int stepMinutes) {
    final slots = <String>[];
    int currentHour = startHour;
    int currentMinute = 0;

    while (currentHour < endHour || (currentHour == endHour && currentMinute == 0)) {
      final startTime = '${currentHour.toString().padLeft(2, '0')}:${currentMinute.toString().padLeft(2, '0')}';
      
      // Calculate end time
      int endHourCalc = currentHour;
      int endMinuteCalc = currentMinute + stepMinutes;
      if (endMinuteCalc >= 60) {
        endHourCalc++;
        endMinuteCalc -= 60;
      }
      
      final endTime = '${endHourCalc.toString().padLeft(2, '0')}:${endMinuteCalc.toString().padLeft(2, '0')}';
      slots.add('$startTime - $endTime');
      
      // Move to next slot
      currentMinute += stepMinutes;
      if (currentMinute >= 60) {
        currentHour++;
        currentMinute -= 60;
      }
    }
    
    return slots;
  }

  String _formatDate(DateTime date) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    
    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'اليوم';
    } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'غداً';
    } else {
      final weekdays = ['', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
      final weekday = weekdays[date.weekday];
      return '$weekday ${date.day}/${date.month}';
    }
  }

  bool _isSlotBooked(String slotTime) {
    final dateKey = _dateKey(_selectedDate);
    final bookedSlots = _bookedSlots[dateKey] ?? [];
    // Extract start time from slot (e.g., "10:00 - 11:00" -> "10:00")
    final startTime = slotTime.split(' - ')[0];
    return bookedSlots.contains(startTime);
  }

  @override
  Widget build(BuildContext context) {
    final dates = _generateDates();
    final timeSlots = generateTimeSlots(8, 23, 60); // 08:00 to 23:00, 60 min intervals

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.fieldName,
            style: AppTextStyles.h1.copyWith(
              color: const Color(0xFF4BCB78),
              fontFamily: _cairoFont.fontFamily,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Date selector
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  final date = dates[index];
                  final isSelected = date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF4BCB78)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF4BCB78)
                              : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _formatDate(date),
                            style: _cairoFont.copyWith(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}/${date.month}',
                            style: _cairoFont.copyWith(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            // Time slots list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: timeSlots.length,
                itemBuilder: (context, index) {
                  final slot = timeSlots[index];
                  final isBooked = _isSlotBooked(slot);

                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: isBooked
                          ? Colors.grey.shade200
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isBooked
                            ? Colors.grey.shade300
                            : const Color(0xFF4BCB78).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      enabled: !isBooked,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      title: Text(
                        slot,
                        style: _cairoFont.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isBooked ? Colors.grey.shade600 : Colors.black87,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: isBooked
                              ? Colors.red.shade100
                              : const Color(0xFF4BCB78).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isBooked ? 'محجوز' : 'متاح',
                          style: _cairoFont.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isBooked
                                ? Colors.red.shade700
                                : const Color(0xFF4BCB78),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

