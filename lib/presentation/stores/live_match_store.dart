import '../models/live_match_model.dart';

class LiveMatchStore {
  static final LiveMatchStore _instance = LiveMatchStore._internal();
  factory LiveMatchStore() => _instance;
  LiveMatchStore._internal();

  final List<LiveMatch> _liveMatches = [];

  List<LiveMatch> get liveMatches => List.unmodifiable(_liveMatches);

  void addLiveMatch(LiveMatch match) {
    _liveMatches.add(match);
  }

  void removeLiveMatch(String matchId) {
    _liveMatches.removeWhere((match) => match.id == matchId);
  }

  void updateLiveMatch(LiveMatch updatedMatch) {
    final index = _liveMatches.indexWhere((match) => match.id == updatedMatch.id);
    if (index != -1) {
      _liveMatches[index] = updatedMatch;
    }
  }

  LiveMatch? getLiveMatchById(String matchId) {
    try {
      return _liveMatches.firstWhere((match) => match.id == matchId);
    } catch (e) {
      return null;
    }
  }
}

