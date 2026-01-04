import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/models/field_service.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../widgets/service_toggle_item.dart';

class AddFieldServicesSelector extends StatelessWidget {
  final Set<FieldService> selectedServices;
  final ValueChanged<FieldService> onServiceToggled;

  static const List<FieldService> availableServices = [
    FieldService.water,
    FieldService.ball,
    FieldService.seating,
    FieldService.parking,
    FieldService.lockerRoom,
  ];

  const AddFieldServicesSelector({
    super.key,
    required this.selectedServices,
    required this.onServiceToggled,
  });

  @override
  Widget build(BuildContext context) {
    final cairoFont = GoogleFonts.cairo();
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final itemWidth = 70.0;
        final totalWidth = itemWidth * availableServices.length;
        final useScroll = totalWidth > screenWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'الخدمات',
              style: AppTextStyles.h3.copyWith(
                fontFamily: cairoFont.fontFamily,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (useScroll)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: availableServices.asMap().entries.map((entry) {
                    final index = entry.key;
                    final service = entry.value;
                    final isSelected = selectedServices.contains(service);
                    return Padding(
                      padding: EdgeInsets.only(
                        right: index == 0 ? 0 : AppSpacing.md,
                      ),
                      child: ServiceToggleItem(
                        service: service,
                        isSelected: isSelected,
                        onTap: () => onServiceToggled(service),
                      ),
                    );
                  }).toList(),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: availableServices.map((service) {
                  final isSelected = selectedServices.contains(service);
                  return ServiceToggleItem(
                    service: service,
                    isSelected: isSelected,
                    onTap: () => onServiceToggled(service),
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }
}

