import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/widgets.dart';
import '../../models/event_model.dart';

class EventDetailsPage extends StatefulWidget {
  final Event event;

  const EventDetailsPage({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

enum RoundTab { roundOf16, quarterFinal, semiFinal, finalRound }

class _EventDetailsPageState extends State<EventDetailsPage> {
  late final TextStyle _cairoFont = GoogleFonts.cairo();
  RoundTab _selectedRoundTab = RoundTab.roundOf16;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.event.title,
            style: AppTextStyles.h1.copyWith(
              color: const Color(0xFF4BCB78),
              fontFamily: _cairoFont.fontFamily,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Tab buttons
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'مخطط التصفيات',
                        style: AppTextStyles.h2.copyWith(
                          fontFamily: _cairoFont.fontFamily,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  // Round Tab Buttons (4 tabs)
                  Row(
                    children: [
                      Expanded(
                        child: RoundTabButton(
                          label: 'النهائي',
                          isActive: _selectedRoundTab == RoundTab.finalRound,
                          onTap: () {
                            setState(() {
                              _selectedRoundTab = RoundTab.finalRound;
                            });
                          },
                          cairoFont: _cairoFont,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: RoundTabButton(
                          label: 'نصف النهائي',
                          isActive: _selectedRoundTab == RoundTab.semiFinal,
                          onTap: () {
                            setState(() {
                              _selectedRoundTab = RoundTab.semiFinal;
                            });
                          },
                          cairoFont: _cairoFont,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: RoundTabButton(
                          label: 'ربع النهائي',
                          isActive: _selectedRoundTab == RoundTab.quarterFinal,
                          onTap: () {
                            setState(() {
                              _selectedRoundTab = RoundTab.quarterFinal;
                            });
                          },
                          cairoFont: _cairoFont,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: RoundTabButton(
                          label: 'دور الـ16',
                          isActive: _selectedRoundTab == RoundTab.roundOf16,
                          onTap: () {
                            setState(() {
                              _selectedRoundTab = RoundTab.roundOf16;
                            });
                          },
                          cairoFont: _cairoFont,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Match Cards List (Scrollable)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _buildRoundMatchesList(context, _cairoFont),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<EventMatch> _getSelectedRoundMatches() {
    switch (_selectedRoundTab) {
      case RoundTab.roundOf16:
        return widget.event.bracket.roundOf16;
      case RoundTab.quarterFinal:
        return widget.event.bracket.quarterFinal;
      case RoundTab.semiFinal:
        return widget.event.bracket.semiFinal;
      case RoundTab.finalRound:
        return [widget.event.bracket.finalMatch];
    }
  }

  Widget _buildRoundMatchesList(BuildContext context, TextStyle cairoFont) {
    final matches = _getSelectedRoundMatches();

    if (matches.isEmpty) {
      return Center(
        child: Text(
          'لا توجد مباريات',
          style: AppTextStyles.body.copyWith(
            fontFamily: cairoFont.fontFamily,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: matches.length,
      itemBuilder: (context, matchIndex) {
        final match = matches[matchIndex];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: ReadOnlyMatchCard(
            match: match,
            matchIndex: matchIndex,
            cairoFont: cairoFont,
          ),
        );
      },
    );
  }
}

// Round Tab Button Widget (reused from AddEventScreen)
class RoundTabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final TextStyle cairoFont;

  const RoundTabButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.cairoFont,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF4BCB78)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? const Color(0xFF4BCB78)
                : const Color(0xFF4BCB78).withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: AppTextStyles.h3.copyWith(
              fontFamily: cairoFont.fontFamily,
              color: isActive
                  ? Colors.white
                  : const Color(0xFF4BCB78),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

// Read-only Match Card Widget
class ReadOnlyMatchCard extends StatelessWidget {
  final EventMatch match;
  final int matchIndex;
  final TextStyle cairoFont;

  const ReadOnlyMatchCard({
    super.key,
    required this.match,
    required this.matchIndex,
    required this.cairoFont,
  });

  @override
  Widget build(BuildContext context) {
    final isTeamASelected = match.winner == match.teamA;
    final isTeamBSelected = match.winner == match.teamB;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Team A Slot (read-only)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isTeamASelected
                  ? const Color(0xFF4BCB78).withValues(alpha: 0.15)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isTeamASelected
                    ? const Color(0xFF4BCB78)
                    : Colors.grey.shade300,
                width: isTeamASelected ? 2 : 1,
              ),
            ),
            child: Text(
              match.teamA ?? '---',
              style: AppTextStyles.body.copyWith(
                fontFamily: cairoFont.fontFamily,
                color: match.teamA == null
                    ? Colors.grey.shade500
                    : Colors.black87,
                fontWeight: isTeamASelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // VS Label
          Text(
            'VS',
            style: AppTextStyles.body.copyWith(
              fontFamily: cairoFont.fontFamily,
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Team B Slot (read-only)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isTeamBSelected
                  ? const Color(0xFF4BCB78).withValues(alpha: 0.15)
                  : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isTeamBSelected
                    ? const Color(0xFF4BCB78)
                    : Colors.grey.shade300,
                width: isTeamBSelected ? 2 : 1,
              ),
            ),
            child: Text(
              match.teamB ?? '---',
              style: AppTextStyles.body.copyWith(
                fontFamily: cairoFont.fontFamily,
                color: match.teamB == null
                    ? Colors.grey.shade500
                    : Colors.black87,
                fontWeight: isTeamBSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

