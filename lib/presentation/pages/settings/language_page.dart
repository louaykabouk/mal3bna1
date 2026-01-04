import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.grey.shade800,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'اللغة',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Text(
            'صفحة اللغة',
            style: GoogleFonts.cairo(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }
}

