import 'package:flutter/foundation.dart';
import '../models/activity_item.dart';

class ActivitiesStore extends ChangeNotifier {
  static final ActivitiesStore _instance = ActivitiesStore._internal();
  factory ActivitiesStore() => _instance;
  ActivitiesStore._internal();

  final List<ActivityItem> _items = [];

  List<ActivityItem> get items => List.unmodifiable(_items);

  List<ActivityItem> get sortedItems {
    final sorted = [..._items];
    sorted.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return sorted;
  }

  void addEvent(ActivityItem item) {
    if (item.type != ActivityType.event) {
      throw ArgumentError('Item must be of type event');
    }
    _items.add(item);
    notifyListeners();
  }

  void addLiveMatch(ActivityItem item) {
    if (item.type != ActivityType.liveMatch) {
      throw ArgumentError('Item must be of type liveMatch');
    }
    _items.add(item);
    notifyListeners();
  }

  void removeActivity(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  ActivityItem? getActivityById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }
}

