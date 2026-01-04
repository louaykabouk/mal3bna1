import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/widgets.dart';
import '../../models/event_model.dart';
import 'event_settings_sheet.dart';

// Models
class Team {
  final String id;
  final String name;
  final bool isBye;

  Team({
    required this.id,
    required this.name,
    this.isBye = false,
  });

  Team copyWith({String? id, String? name, bool? isBye}) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      isBye: isBye ?? this.isBye,
    );
  }
}

class Match {
  final int roundIndex;
  final int matchIndex;
  final Team? teamA;
  final Team? teamB;
  final Team? winner;

  Match({
    required this.roundIndex,
    required this.matchIndex,
    this.teamA,
    this.teamB,
    this.winner,
  });

  Match copyWith({
    int? roundIndex,
    int? matchIndex,
    Team? teamA,
    Team? teamB,
    Team? winner,
  }) {
    return Match(
      roundIndex: roundIndex ?? this.roundIndex,
      matchIndex: matchIndex ?? this.matchIndex,
      teamA: teamA ?? this.teamA,
      teamB: teamB ?? this.teamB,
      winner: winner ?? this.winner,
    );
  }
}

class TournamentRound {
  final String name;
  final List<Match> matches;

  TournamentRound({
    required this.name,
    required this.matches,
  });
}

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

enum RoundTab { roundOf16, quarterFinal, semiFinal, finalRound }

class _AddEventScreenState extends State<AddEventScreen> {
  final TextEditingController _teamNameController = TextEditingController();
  final List<Team> _teams = [];
  List<TournamentRound> _rounds = [];
  bool _bracketGenerated = false;
  final ScrollController _bracketScrollController = ScrollController();
  RoundTab _selectedRoundTab = RoundTab.roundOf16;

  @override
  void dispose() {
    _teamNameController.dispose();
    _bracketScrollController.dispose();
    super.dispose();
  }

  // Build 16-slot seeding array from teams list
  List<Team?> _buildSeedingSlots() {
    final slots = List<Team?>.filled(16, null);
    for (int i = 0; i < _teams.length && i < 16; i++) {
      slots[i] = _teams[i];
    }
    return slots;
  }

  void _addTeam() {
    final name = _teamNameController.text.trim();
    if (name.isEmpty) return;
    if (_teams.length >= 16) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا يمكن إضافة أكثر من 16 فريق',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _teams.add(Team(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
      ));
      _teamNameController.clear();
      
      // If bracket is already generated, reseed while preserving winners
      if (_bracketGenerated) {
        _reseedBracketPreservingWinners();
      }
    });
  }

  void _removeTeam(String teamId) {
    setState(() {
      _teams.removeWhere((team) => team.id == teamId);
      
      // If bracket is already generated, reseed while preserving winners
      if (_bracketGenerated) {
        _reseedBracketPreservingWinners();
      }
    });
  }

  int _nextPowerOfTwo(int n) {
    if (n <= 1) return 2;
    int power = 2;
    while (power < n) {
      power *= 2;
    }
    return power;
  }

  void _reseedBracketPreservingWinners() {
    if (_teams.length < 2) {
      setState(() {
        _rounds.clear();
        _bracketGenerated = false;
      });
      return;
    }

    // Build 16-slot seeding array
    final slotTeams = _buildSeedingSlots();
    final targetSize = _nextPowerOfTwo(_teams.length);
    
    // Preserve existing winners by round and match index
    final Map<String, Team?> preservedWinners = {};
    for (var round in _rounds) {
      for (var match in round.matches) {
        final key = '${match.roundIndex}_${match.matchIndex}';
        if (match.winner != null && !match.winner!.isBye) {
          // Check if winner still exists in teams
          final winnerExists = _teams.any((t) => t.id == match.winner!.id);
          if (winnerExists) {
            preservedWinners[key] = match.winner;
          }
        }
      }
    }

    // Generate rounds
    final rounds = <TournamentRound>[];
    int roundNumber = 0;

    // Round of 16 (8 matches) - always generate if targetSize >= 16
    if (targetSize >= 16) {
      final r16Matches = <Match>[];
      for (int i = 0; i < 8; i++) {
        final slotA = slotTeams[i * 2];
        final slotB = slotTeams[i * 2 + 1];
        
        // Check if we can preserve winner from existing bracket
        final key = '${roundNumber}_$i';
        Team? preservedWinner;
        if (preservedWinners.containsKey(key)) {
          final oldWinner = preservedWinners[key]!;
          // Only preserve if the winner is still in one of the slots
          if ((slotA != null && slotA.id == oldWinner.id) ||
              (slotB != null && slotB.id == oldWinner.id)) {
            preservedWinner = oldWinner;
          }
        }

        r16Matches.add(Match(
          roundIndex: roundNumber,
          matchIndex: i,
          teamA: slotA,
          teamB: slotB,
          winner: preservedWinner,
        ));
      }
      rounds.add(TournamentRound(
        name: 'دور الـ16',
        matches: r16Matches,
      ));
      roundNumber++;
    }

    // Quarterfinal (4 matches)
    if (targetSize >= 8) {
      final qfMatches = <Match>[];
      for (int i = 0; i < 4; i++) {
        final key = '${roundNumber}_$i';
        Team? preservedTeamA;
        Team? preservedTeamB;
        Team? preservedWinner;

        // Try to preserve from existing bracket
        if (preservedWinners.containsKey(key)) {
          preservedWinner = preservedWinners[key];
        }

        // Propagate winners from previous round if available
        if (roundNumber > 0 && rounds.isNotEmpty) {
          final prevRound = rounds[roundNumber - 1];
          final matchAIndex = i * 2;
          final matchBIndex = i * 2 + 1;
          
          if (matchAIndex < prevRound.matches.length) {
            preservedTeamA = prevRound.matches[matchAIndex].winner;
          }
          if (matchBIndex < prevRound.matches.length) {
            preservedTeamB = prevRound.matches[matchBIndex].winner;
          }
        }

        qfMatches.add(Match(
          roundIndex: roundNumber,
          matchIndex: i,
          teamA: preservedTeamA,
          teamB: preservedTeamB,
          winner: preservedWinner,
        ));
      }
      rounds.add(TournamentRound(
        name: 'ربع النهائي',
        matches: qfMatches,
      ));
      roundNumber++;
    }

    // Semifinal (2 matches)
    if (targetSize >= 4) {
      final sfMatches = <Match>[];
      for (int i = 0; i < 2; i++) {
        final key = '${roundNumber}_$i';
        Team? preservedTeamA;
        Team? preservedTeamB;
        Team? preservedWinner;

        if (preservedWinners.containsKey(key)) {
          preservedWinner = preservedWinners[key];
        }

        // Propagate from previous round
        if (roundNumber > 0 && rounds.isNotEmpty) {
          final prevRound = rounds[roundNumber - 1];
          final matchAIndex = i * 2;
          final matchBIndex = i * 2 + 1;
          
          if (matchAIndex < prevRound.matches.length) {
            preservedTeamA = prevRound.matches[matchAIndex].winner;
          }
          if (matchBIndex < prevRound.matches.length) {
            preservedTeamB = prevRound.matches[matchBIndex].winner;
          }
        }

        sfMatches.add(Match(
          roundIndex: roundNumber,
          matchIndex: i,
          teamA: preservedTeamA,
          teamB: preservedTeamB,
          winner: preservedWinner,
        ));
      }
      rounds.add(TournamentRound(
        name: 'نصف النهائي',
        matches: sfMatches,
      ));
      roundNumber++;
    }

    // Final (1 match)
    final finalMatches = <Match>[];
    final key = '${roundNumber}_0';
    Team? preservedTeamA;
    Team? preservedTeamB;
    Team? preservedWinner;

    if (preservedWinners.containsKey(key)) {
      preservedWinner = preservedWinners[key];
    }

    // Propagate from previous round
    if (roundNumber > 0 && rounds.isNotEmpty) {
      final prevRound = rounds[roundNumber - 1];
      if (prevRound.matches.length >= 2) {
        preservedTeamA = prevRound.matches[0].winner;
        preservedTeamB = prevRound.matches[1].winner;
      }
    }

    finalMatches.add(Match(
      roundIndex: roundNumber,
      matchIndex: 0,
      teamA: preservedTeamA,
      teamB: preservedTeamB,
      winner: preservedWinner,
    ));
    rounds.add(TournamentRound(
      name: 'النهائي',
      matches: finalMatches,
    ));

    setState(() {
      _rounds = rounds;
    });
  }

  void _generateBracket() {
    if (_teams.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يجب إضافة فريقين على الأقل',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _reseedBracketPreservingWinners();
    setState(() {
      _bracketGenerated = true;
    });

    // Scroll to bracket after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_bracketScrollController.hasClients) {
        _bracketScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _selectWinner(Match match, Team? selectedTeam) {
    if (selectedTeam == null || selectedTeam == match.winner) return;

    setState(() {
      // Update current match
      final roundIndex = match.roundIndex;
      final matchIndex = match.matchIndex;
      final updatedMatch = match.copyWith(winner: selectedTeam);
      _rounds[roundIndex].matches[matchIndex] = updatedMatch;

      // Propagate to next round
      if (roundIndex < _rounds.length - 1) {
        final nextRound = _rounds[roundIndex + 1];
        final nextMatchIndex = matchIndex ~/ 2;
        if (nextMatchIndex < nextRound.matches.length) {
          final nextMatch = nextRound.matches[nextMatchIndex];
          
          // Determine which position (A or B) in next match
          final isPositionA = matchIndex % 2 == 0;
          final updatedNextMatch = isPositionA
              ? nextMatch.copyWith(teamA: selectedTeam)
              : nextMatch.copyWith(teamB: selectedTeam);
          
          nextRound.matches[nextMatchIndex] = updatedNextMatch;

          // If both teams are set in next match, check if we need to clear old winner
          if (updatedNextMatch.teamA != null && updatedNextMatch.teamB != null) {
            // Clear winner if teams changed
            if (updatedNextMatch.winner != null &&
                updatedNextMatch.winner != updatedNextMatch.teamA &&
                updatedNextMatch.winner != updatedNextMatch.teamB) {
              nextRound.matches[nextMatchIndex] = updatedNextMatch.copyWith(winner: null);
            }
          }
        }
      }
    });
  }

  void _resetBracket() {
    setState(() {
      _rounds.clear();
      _bracketGenerated = false;
      _selectedRoundTab = RoundTab.roundOf16;
    });
  }

  BracketState _convertToBracketState() {
    // Find rounds by name or match count
    TournamentRound? r16Round;
    TournamentRound? qfRound;
    TournamentRound? sfRound;
    TournamentRound? finalRound;

    for (var round in _rounds) {
      if (round.name == 'دور الـ16' || round.name.contains('دور الـ16') || round.matches.length == 8) {
        r16Round = round;
      } else if (round.name == 'ربع النهائي' || round.name.contains('ربع') || round.matches.length == 4) {
        qfRound = round;
      } else if (round.name == 'نصف النهائي' || round.name.contains('نصف') || round.matches.length == 2) {
        sfRound = round;
      } else if (round.name == 'النهائي' || round.name.contains('النهائي') || round.matches.length == 1) {
        finalRound = round;
      }
    }

    // Convert to EventMatch format - ensure we always have 8 matches for roundOf16
    final r16Matches = <EventMatch>[];
    if (r16Round != null) {
      r16Matches.addAll(r16Round.matches.map((m) {
        return EventMatch(
          teamA: m.teamA?.name,
          teamB: m.teamB?.name,
          winner: m.winner?.name,
        );
      }));
    }
    // Fill to 8 matches if needed
    while (r16Matches.length < 8) {
      r16Matches.add(EventMatch());
    }

    // Quarterfinal - ensure 4 matches
    final qfMatches = <EventMatch>[];
    if (qfRound != null) {
      qfMatches.addAll(qfRound.matches.map((m) {
        return EventMatch(
          teamA: m.teamA?.name,
          teamB: m.teamB?.name,
          winner: m.winner?.name,
        );
      }));
    }
    while (qfMatches.length < 4) {
      qfMatches.add(EventMatch());
    }

    // Semifinal - ensure 2 matches
    final sfMatches = <EventMatch>[];
    if (sfRound != null) {
      sfMatches.addAll(sfRound.matches.map((m) {
        return EventMatch(
          teamA: m.teamA?.name,
          teamB: m.teamB?.name,
          winner: m.winner?.name,
        );
      }));
    }
    while (sfMatches.length < 2) {
      sfMatches.add(EventMatch());
    }

    // Final - always 1 match
    final finalMatch = finalRound?.matches.isNotEmpty == true
        ? EventMatch(
            teamA: finalRound!.matches[0].teamA?.name,
            teamB: finalRound.matches[0].teamB?.name,
            winner: finalRound.matches[0].winner?.name,
          )
        : EventMatch();

    return BracketState(
      roundOf16: r16Matches,
      quarterFinal: qfMatches,
      semiFinal: sfMatches,
      finalMatch: finalMatch,
    );
  }

  void _saveEvent() {
    if (!_bracketGenerated || _rounds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يجب إنشاء المخطط أولاً',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show bottom sheet for terms and price
    _showEventSettingsSheet();
  }

  void _showEventSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventSettingsSheet(
        teams: _teams.map((t) => t.name).toList(),
        convertBracket: () => _convertToBracketState(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cairoFont = GoogleFonts.cairo();

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            'إضافة فعالية',
            style: AppTextStyles.h1.copyWith(
              color: const Color(0xFF4BCB78),
              fontFamily: cairoFont.fontFamily,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: _bracketGenerated
              ? Column(
                  children: [
                    // Bracket Display Section
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton.icon(
                                onPressed: _resetBracket,
                                icon: const Icon(Icons.refresh, size: 20),
                                label: Text(
                                  'إعادة ضبط',
                                  style: GoogleFonts.cairo(),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                              Text(
                                'مخطط التصفيات',
                                style: AppTextStyles.h2.copyWith(
                                  fontFamily: cairoFont.fontFamily,
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
                                  cairoFont: cairoFont,
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
                                  cairoFont: cairoFont,
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
                                  cairoFont: cairoFont,
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
                                  cairoFont: cairoFont,
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
                        child: _buildRoundMatchesList(context, cairoFont),
                      ),
                    ),
                    // Save Button
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: AppPrimaryButton(
                        label: 'حفظ الفعالية',
                        onPressed: _saveEvent,
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  controller: _bracketScrollController,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Team Entry Section
                      _buildTeamEntrySection(context, cairoFont),
                      const SizedBox(height: AppSpacing.xl),
                      // Generate Bracket Button
                      AppPrimaryButton(
                        label: 'إنشاء مخطط التصفيات',
                        onPressed: _teams.length >= 2 ? _generateBracket : null,
                      ),
                      if (_teams.length < 2)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.sm),
                          child: Text(
                            'يجب إضافة فريقين على الأقل',
                            style: AppTextStyles.body.copyWith(
                              fontFamily: cairoFont.fontFamily,
                              color: Colors.red,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTeamEntrySection(BuildContext context, TextStyle cairoFont) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'إضافة الفرق',
          style: AppTextStyles.h2.copyWith(
            fontFamily: cairoFont.fontFamily,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _teamNameController,
                decoration: InputDecoration(
                  hintText: 'اسم الفريق',
                  hintStyle: GoogleFonts.cairo(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF4BCB78),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                ),
                style: GoogleFonts.cairo(),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addTeam(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            ElevatedButton.icon(
              onPressed: _addTeam,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'إضافة فريق',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4BCB78),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${_teams.length}/16',
          style: AppTextStyles.body.copyWith(
            fontFamily: cairoFont.fontFamily,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: AppSpacing.md),
        if (_teams.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _teams.map((team) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          team.name,
                          style: AppTextStyles.body.copyWith(
                            fontFamily: cairoFont.fontFamily,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _removeTeam(team.id),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  TournamentRound? _getSelectedRound() {
    if (_rounds.isEmpty) return null;
    
    TournamentRound? roundOf16Round;
    TournamentRound? quarterFinalRound;
    TournamentRound? semiFinalRound;
    TournamentRound? finalRound;
    
    for (var round in _rounds) {
      if (round.name == 'دور الـ16' || round.name.contains('دور الـ16')) {
        roundOf16Round = round;
      } else if (round.name == 'ربع النهائي' || round.name.contains('ربع')) {
        quarterFinalRound = round;
      } else if (round.name == 'نصف النهائي' || round.name.contains('نصف')) {
        semiFinalRound = round;
      } else if (round.name == 'النهائي' || round.name.contains('النهائي')) {
        finalRound = round;
      }
    }
    
    // Fallback by match count
    if (roundOf16Round == null || quarterFinalRound == null || 
        semiFinalRound == null || finalRound == null) {
      for (var round in _rounds) {
        if (round.matches.length == 8 && roundOf16Round == null) {
          roundOf16Round = round;
        } else if (round.matches.length == 4 && quarterFinalRound == null) {
          quarterFinalRound = round;
        } else if (round.matches.length == 2 && semiFinalRound == null) {
          semiFinalRound = round;
        } else if (round.matches.length == 1 && finalRound == null) {
          finalRound = round;
        }
      }
    }
    
    switch (_selectedRoundTab) {
      case RoundTab.roundOf16:
        return roundOf16Round;
      case RoundTab.quarterFinal:
        return quarterFinalRound;
      case RoundTab.semiFinal:
        return semiFinalRound;
      case RoundTab.finalRound:
        return finalRound;
    }
  }

  int? _getSelectedRoundIndex() {
    final selectedRound = _getSelectedRound();
    if (selectedRound == null) return null;
    
    for (int i = 0; i < _rounds.length; i++) {
      if (_rounds[i] == selectedRound) {
        return i;
      }
    }
    return null;
  }

  String _getMatchKey(int roundIndex, int matchIndex) {
    if (roundIndex == 0) return 'r16_m$matchIndex';
    if (roundIndex == 1) return 'qf_m$matchIndex';
    if (roundIndex == 2) return 'sf_m$matchIndex';
    if (roundIndex == 3) return 'f_m0';
    return 'r$roundIndex-m$matchIndex';
  }

  Widget _buildRoundMatchesList(BuildContext context, TextStyle cairoFont) {
    final selectedRound = _getSelectedRound();
    final roundIndex = _getSelectedRoundIndex();
    
    if (selectedRound == null || roundIndex == null) {
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
      itemCount: selectedRound.matches.length,
      itemBuilder: (context, matchIndex) {
        final match = selectedRound.matches[matchIndex];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: MatchCard(
            key: ValueKey(_getMatchKey(roundIndex, matchIndex)),
            match: match,
            roundIndex: roundIndex,
            matchIndex: matchIndex,
            onSelectTeamA: () {
              if (match.teamA != null && !match.teamA!.isBye) {
                _selectWinner(match, match.teamA);
              }
            },
            onSelectTeamB: () {
              if (match.teamB != null && !match.teamB!.isBye) {
                _selectWinner(match, match.teamB);
              }
            },
            cairoFont: cairoFont,
          ),
        );
      },
    );
  }
}

// Round Tab Button Widget
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

// Match Card Widget
class MatchCard extends StatelessWidget {
  final Match match;
  final int roundIndex;
  final int matchIndex;
  final VoidCallback onSelectTeamA;
  final VoidCallback onSelectTeamB;
  final TextStyle cairoFont;

  const MatchCard({
    super.key,
    required this.match,
    required this.roundIndex,
    required this.matchIndex,
    required this.onSelectTeamA,
    required this.onSelectTeamB,
    required this.cairoFont,
  });

  @override
  Widget build(BuildContext context) {
    final isTeamASelected = match.winner == match.teamA;
    final isTeamBSelected = match.winner == match.teamB;
    final canSelectA = match.teamA != null && !match.teamA!.isBye;
    final canSelectB = match.teamB != null && !match.teamB!.isBye;

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
          // Team A Slot
          GestureDetector(
            onTap: canSelectA ? onSelectTeamA : null,
            child: Container(
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
                match.teamA?.name ?? '---',
                style: AppTextStyles.body.copyWith(
                  fontFamily: cairoFont.fontFamily,
                  color: match.teamA == null
                      ? Colors.grey.shade500
                      : match.teamA!.isBye
                          ? Colors.grey.shade500
                          : Colors.black87,
                  fontWeight: isTeamASelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
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
          // Team B Slot
          GestureDetector(
            onTap: canSelectB ? onSelectTeamB : null,
            child: Container(
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
                match.teamB?.name ?? '---',
                style: AppTextStyles.body.copyWith(
                  fontFamily: cairoFont.fontFamily,
                  color: match.teamB == null
                      ? Colors.grey.shade500
                      : match.teamB!.isBye
                          ? Colors.grey.shade500
                          : Colors.black87,
                  fontWeight: isTeamBSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
