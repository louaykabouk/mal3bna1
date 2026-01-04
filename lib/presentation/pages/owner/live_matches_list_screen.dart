import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/widgets.dart';
import '../../stores/live_match_store.dart';
import '../../widgets/live_match_card.dart';
import 'add_live_match_screen.dart';

class LiveMatchesListScreen extends StatefulWidget {
  const LiveMatchesListScreen({super.key});

  @override
  State<LiveMatchesListScreen> createState() => _LiveMatchesListScreenState();
}

class _LiveMatchesListScreenState extends State<LiveMatchesListScreen> {
  late final TextStyle _cairoFont = GoogleFonts.cairo();
  final LiveMatchStore _store = LiveMatchStore();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when returning to this page
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final matches = _store.liveMatches;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'المباريات المباشرة',
            style: AppTextStyles.h1.copyWith(
              color: const Color(0xFF4BCB78),
              fontFamily: _cairoFont.fontFamily,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.add,
                color: Color(0xFF4BCB78),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddLiveMatchScreen(),
                  ),
                ).then((_) {
                  // Refresh when returning
                  if (mounted) {
                    setState(() {});
                  }
                });
              },
            ),
          ],
        ),
        body: matches.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      size: 80,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'لا توجد مباريات مباشرة بعد',
                      style: AppTextStyles.h3.copyWith(
                        fontFamily: _cairoFont.fontFamily,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppPrimaryButton(
                      label: 'إضافة مباراة مباشرة',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AddLiveMatchScreen(),
                          ),
                        ).then((_) {
                          // Refresh when returning
                          if (mounted) {
                            setState(() {});
                          }
                        });
                      },
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final match = matches[index];
                  return LiveMatchCard(match: match);
                },
              ),
      ),
    );
  }
}

