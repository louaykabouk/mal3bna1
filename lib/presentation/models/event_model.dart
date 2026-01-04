// Event and Bracket Models
class EventMatch {
  final String? teamA;
  final String? teamB;
  final String? winner;

  EventMatch({
    this.teamA,
    this.teamB,
    this.winner,
  });

  EventMatch copyWith({
    String? teamA,
    String? teamB,
    String? winner,
  }) {
    return EventMatch(
      teamA: teamA ?? this.teamA,
      teamB: teamB ?? this.teamB,
      winner: winner ?? this.winner,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teamA': teamA,
      'teamB': teamB,
      'winner': winner,
    };
  }

  factory EventMatch.fromJson(Map<String, dynamic> json) {
    return EventMatch(
      teamA: json['teamA'] as String?,
      teamB: json['teamB'] as String?,
      winner: json['winner'] as String?,
    );
  }
}

class BracketState {
  final List<EventMatch> roundOf16; // 8 matches
  final List<EventMatch> quarterFinal; // 4 matches
  final List<EventMatch> semiFinal; // 2 matches
  final EventMatch finalMatch; // 1 match

  BracketState({
    required this.roundOf16,
    required this.quarterFinal,
    required this.semiFinal,
    required this.finalMatch,
  });

  BracketState copyWith({
    List<EventMatch>? roundOf16,
    List<EventMatch>? quarterFinal,
    List<EventMatch>? semiFinal,
    EventMatch? finalMatch,
  }) {
    return BracketState(
      roundOf16: roundOf16 ?? this.roundOf16,
      quarterFinal: quarterFinal ?? this.quarterFinal,
      semiFinal: semiFinal ?? this.semiFinal,
      finalMatch: finalMatch ?? this.finalMatch,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roundOf16': roundOf16.map((m) => m.toJson()).toList(),
      'quarterFinal': quarterFinal.map((m) => m.toJson()).toList(),
      'semiFinal': semiFinal.map((m) => m.toJson()).toList(),
      'finalMatch': finalMatch.toJson(),
    };
  }

  factory BracketState.fromJson(Map<String, dynamic> json) {
    return BracketState(
      roundOf16: (json['roundOf16'] as List)
          .map((m) => EventMatch.fromJson(m as Map<String, dynamic>))
          .toList(),
      quarterFinal: (json['quarterFinal'] as List)
          .map((m) => EventMatch.fromJson(m as Map<String, dynamic>))
          .toList(),
      semiFinal: (json['semiFinal'] as List)
          .map((m) => EventMatch.fromJson(m as Map<String, dynamic>))
          .toList(),
      finalMatch: EventMatch.fromJson(json['finalMatch'] as Map<String, dynamic>),
    );
  }
}

class Event {
  final String id;
  final String title;
  final DateTime createdAt;
  final List<String> teams;
  final BracketState bracket;
  final String terms;
  final double pricePerPerson;
  final String? coverImagePath;

  Event({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.teams,
    required this.bracket,
    required this.terms,
    required this.pricePerPerson,
    this.coverImagePath,
  });

  Event copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    List<String>? teams,
    BracketState? bracket,
    String? terms,
    double? pricePerPerson,
    String? coverImagePath,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      teams: teams ?? this.teams,
      bracket: bracket ?? this.bracket,
      terms: terms ?? this.terms,
      pricePerPerson: pricePerPerson ?? this.pricePerPerson,
      coverImagePath: coverImagePath ?? this.coverImagePath,
    );
  }
}

