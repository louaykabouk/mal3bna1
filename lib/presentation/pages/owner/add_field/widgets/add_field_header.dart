import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../theme/app_text_styles.dart';

class AddFieldHeader extends StatelessWidget implements PreferredSizeWidget {
  final bool isEditMode;

  const AddFieldHeader({
    super.key,
    required this.isEditMode,
  });

  @override
  Widget build(BuildContext context) {
    final cairoFont = GoogleFonts.cairo();
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        isEditMode ? 'تعديل الملعب' : 'إضافة ملعب',
        style: AppTextStyles.h1.copyWith(
          color: const Color(0xFF4BCB78),
          fontFamily: cairoFont.fontFamily,
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

