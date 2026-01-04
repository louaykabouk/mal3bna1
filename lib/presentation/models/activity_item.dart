enum ActivityType {
  event,
  liveMatch,
}

class ActivityItem {
  final String id;
  final ActivityType type;
  final String title;
  final DateTime dateTime;
  final String? fieldName; // only for liveMatch
  final int? peopleCount; // only for liveMatch
  final int pricePerPerson;
  final String? rules; // optional
  final int? teamsCount; // only for event
  final String? stage; // only for event ("دور الـ16", "ربع النهائي"...)
  
  // For event: reference to original Event object
  final String? eventId;
  // For liveMatch: reference to original LiveMatch object
  final String? liveMatchId;

  ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.dateTime,
    this.fieldName,
    this.peopleCount,
    required this.pricePerPerson,
    this.rules,
    this.teamsCount,
    this.stage,
    this.eventId,
    this.liveMatchId,
  });
}

