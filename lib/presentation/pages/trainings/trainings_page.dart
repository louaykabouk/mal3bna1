import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrainingsPage extends StatelessWidget {
  const TrainingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Text(
          'التمارين',
          style: GoogleFonts.cairo(
            fontSize: 24,
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.grey.shade800,
          ),
        ),
      ),
    );
  }
}

