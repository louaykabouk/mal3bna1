import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/widgets.dart';
import '../../models/event_model.dart';
import '../../models/activity_item.dart';
import '../../stores/event_store.dart';
import '../../stores/activities_store.dart';
import 'activities_list_screen.dart';

class EventSettingsSheet extends StatefulWidget {
  final List<String> teams;
  final BracketState Function() convertBracket;

  const EventSettingsSheet({
    super.key,
    required this.teams,
    required this.convertBracket,
  });

  @override
  State<EventSettingsSheet> createState() => _EventSettingsSheetState();
}

class _EventSettingsSheetState extends State<EventSettingsSheet> {
  late final TextEditingController _termsController;
  late final TextEditingController _priceController;
  late final GlobalKey<FormState> _formKey;
  late final TextStyle _cairoFont;

  @override
  void initState() {
    super.initState();
    _termsController = TextEditingController();
    _priceController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    _cairoFont = GoogleFonts.cairo();
  }

  @override
  void dispose() {
    _termsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    // Read values BEFORE any navigation or disposal
    final terms = _termsController.text.trim();
    final priceText = _priceController.text.trim();
    final price = double.parse(priceText);

    // Convert bracket to Event format
    final bracket = widget.convertBracket();
    final teamNames = widget.teams;

    // Create event (NO image field)
    final event = Event(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'فعالية جديدة',
      createdAt: DateTime.now(),
      teams: teamNames,
      bracket: bracket,
      terms: terms,
      pricePerPerson: price,
      coverImagePath: null,
    );

    // Save to store
    EventStore().addEvent(event);

    // Create ActivityItem for unified list
    final activityItem = ActivityItem(
      id: event.id,
      type: ActivityType.event,
      title: 'فعالية: ${event.title}',
      dateTime: event.createdAt,
      pricePerPerson: event.pricePerPerson.toInt(),
      rules: terms,
      teamsCount: teamNames.length,
      stage: 'دور الـ16',
      eventId: event.id,
    );

    // Add to activities store
    ActivitiesStore().addEvent(activityItem);

    // Capture root navigator BEFORE closing bottom sheet
    final rootNavigator = Navigator.of(context, rootNavigator: true);

    // Close bottom sheet FIRST
    Navigator.of(context).pop();

    // Navigate to Activities list page after frame (safe navigation)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Navigate to Activities list page using captured navigator
      rootNavigator.pushReplacement(
        MaterialPageRoute(
          builder: (newContext) {
            // Show success message after navigation completes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final scaffoldMessenger = ScaffoldMessenger.maybeOf(newContext);
              if (scaffoldMessenger != null) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم حفظ الفعالية',
                      style: _cairoFont,
                    ),
                    backgroundColor: const Color(0xFF4BCB78),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            });
            return const ActivitiesListScreen();
          },
        ),
      );
    });
  }

  void _handleCancel() {
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      'إعدادات الفعالية',
                      style: AppTextStyles.h2.copyWith(
                        fontFamily: _cairoFont.fontFamily,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Terms field
                    TextFormField(
                      controller: _termsController,
                      decoration: InputDecoration(
                        labelText: 'شروط الفعالية',
                        hintText: 'أدخل شروط الفعالية...',
                        hintStyle: _cairoFont,
                        labelStyle: _cairoFont,
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
                      ),
                      style: _cairoFont,
                      maxLines: 4,
                      minLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال شروط الفعالية';
                        }
                        if (value.trim().length < 5) {
                          return 'يجب أن تكون الشروط على الأقل 5 أحرف';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Price field
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'سعر للشخص',
                        hintText: '0',
                        hintStyle: _cairoFont,
                        labelStyle: _cairoFont,
                        suffixText: 'ل.س',
                        suffixStyle: _cairoFont.copyWith(
                          color: Colors.grey.shade600,
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
                      ),
                      style: _cairoFont,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال السعر';
                        }
                        final price = double.tryParse(value.trim());
                        if (price == null || price <= 0) {
                          return 'يجب أن يكون السعر أكبر من صفر';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _handleCancel,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'إلغاء',
                              style: _cairoFont.copyWith(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppPrimaryButton(
                            label: 'حفظ',
                            onPressed: _handleSave,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

