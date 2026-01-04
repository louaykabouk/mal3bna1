import '../models/event_model.dart';

// Simple in-memory event store
class EventStore {
  static final EventStore _instance = EventStore._internal();
  factory EventStore() => _instance;
  EventStore._internal();

  final List<Event> _events = [];

  List<Event> get events => List.unmodifiable(_events);

  void addEvent(Event event) {
    _events.add(event);
  }

  void removeEvent(String eventId) {
    _events.removeWhere((e) => e.id == eventId);
  }

  Event? getEventById(String eventId) {
    try {
      return _events.firstWhere((e) => e.id == eventId);
    } catch (e) {
      return null;
    }
  }

  void clear() {
    _events.clear();
  }
}

