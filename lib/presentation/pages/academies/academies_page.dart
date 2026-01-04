import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AcademiesPage extends StatelessWidget {
  const AcademiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Text(
          'الأكاديميات',
          style: GoogleFonts.cairo(
            fontSize: 24,
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.grey.shade800,
          ),
        ),
      ),
    );
  }
}

